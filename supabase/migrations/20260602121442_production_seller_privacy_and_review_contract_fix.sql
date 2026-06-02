-- =============================================================================
-- MIGRATION: Restore seller-row privacy, fix deal seller-id contract mismatch,
--            and move seller reviews behind a server-side verified RPC.
-- Date: 2026-06-02
-- Reason: production hardening follow-up
--
-- Problem 1
--   20260602000000_sellers_public_for_active_listings.sql broadened SELECT on
--   public.sellers to any authenticated user when a seller had an active
--   listing. That exposes seller application rows directly, including review
--   metadata columns that are not part of the public marketplace surface.
--
-- Problem 2
--   The app passes seller profile ids into create_deal_intent. The RPC was
--   validating against listings.seller_id, which is the seller application row
--   UUID, not the seller profile UUID. This rejects otherwise valid runtime
--   deal creation requests as "listing unavailable".
--
-- Problem 3
--   Ratings currently depend on a client-side SELECT from public.sellers to
--   resolve seller_reviews.seller_id. That couples review writes to seller-row
--   visibility and keeps an unsafe direct INSERT path open on seller_reviews.
--
-- Fix
--   1. Restore the consolidated sellers SELECT policy to owner/admin only.
--   2. Re-align create_deal_intent to validate against listings.seller_user_id.
--   3. Replace direct seller_reviews inserts with a verified RPC that derives
--      the seller application row from the completed deal.
-- =============================================================================

-- ─── 1. Restore seller-row privacy ───────────────────────────────────────────

drop policy if exists sellers_select_authenticated_consolidated on public.sellers;
create policy sellers_select_authenticated_consolidated
on public.sellers
as permissive
for select
to authenticated
using (
  user_id = (select auth.uid())
  or public.is_admin_actor((select auth.uid()))
);


-- ─── 2. Fix create_deal_intent runtime contract ──────────────────────────────

create or replace function public.create_deal_intent(
  p_listing_id uuid,
  p_buyer_id uuid,
  p_seller_id uuid,
  p_deal_type text default 'buy',
  p_exchange_offer text default null
)
returns public.deals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deal public.deals%rowtype;
  v_now timestamptz := now();
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  if auth.uid() <> p_buyer_id then
    raise exception 'buyer mismatch';
  end if;

  if p_deal_type not in ('buy', 'exchange') then
    raise exception 'invalid deal type';
  end if;

  if not exists (
    select 1
    from public.listings l
    where l.id = p_listing_id
      and l.status = 'active'
      and l.seller_user_id = p_seller_id
      and l.is_available = true
  ) then
    raise exception 'listing unavailable';
  end if;

  insert into public.deals (
    listing_id,
    buyer_id,
    seller_id,
    deal_type,
    exchange_offer,
    status,
    expires_at,
    created_at,
    updated_at
  )
  values (
    p_listing_id,
    p_buyer_id,
    p_seller_id,
    p_deal_type,
    nullif(trim(coalesce(p_exchange_offer, '')), ''),
    'intent_created',
    v_now + interval '24 hours',
    v_now,
    v_now
  )
  returning * into v_deal;

  insert into public.deal_events (deal_id, event_type, actor_id, created_at)
  values (v_deal.id, 'intent_created', auth.uid(), v_now);

  update public.deals
  set status = 'pending_seller_response',
      updated_at = v_now
  where id = v_deal.id
  returning * into v_deal;

  insert into public.deal_events (
    deal_id,
    event_type,
    actor_id,
    metadata,
    created_at
  )
  values (
    v_deal.id,
    'pending_seller_response',
    auth.uid(),
    jsonb_build_object('from_status', 'intent_created'),
    v_now
  );

  update public.listings
  set is_available = false,
      updated_at = v_now
  where id = p_listing_id
    and status = 'active';

  return v_deal;
end;
$$;

grant execute on function public.create_deal_intent(uuid, uuid, uuid, text, text) to authenticated;


-- ─── 3. Harden seller review writes behind a verified RPC ───────────────────

drop policy if exists "Buyer can insert review for own completed deal" on public.seller_reviews;

create or replace function public.submit_seller_review(
  p_deal_id uuid,
  p_rating integer,
  p_comment text default null
)
returns public.seller_reviews
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deal public.deals%rowtype;
  v_seller_row public.sellers%rowtype;
  v_review public.seller_reviews%rowtype;
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  if p_rating < 1 or p_rating > 5 then
    raise exception 'invalid rating';
  end if;

  select *
  into v_deal
  from public.deals
  where id = p_deal_id
    and buyer_id = auth.uid()
    and status = 'completed';

  if v_deal.id is null then
    raise exception 'completed deal required';
  end if;

  select *
  into v_seller_row
  from public.sellers
  where user_id = v_deal.seller_id;

  if v_seller_row.id is null then
    raise exception 'seller record not found';
  end if;

  insert into public.seller_reviews (
    seller_id,
    deal_id,
    buyer_id,
    rating,
    comment
  )
  values (
    v_seller_row.id,
    v_deal.id,
    auth.uid(),
    p_rating,
    nullif(trim(coalesce(p_comment, '')), '')
  )
  returning * into v_review;

  return v_review;
exception
  when unique_violation then
    raise exception 'rating already submitted for this transaction.'
      using errcode = '23505';
end;
$$;

grant execute on function public.submit_seller_review(uuid, integer, text) to authenticated;
