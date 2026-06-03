-- Finalize the purchase-request workflow by removing the deprecated
-- intent_created state and replacing the request-creation RPC.

update public.deals
set status = 'pending_seller_response',
    updated_at = now()
where status = 'intent_created';

update public.deal_events
set event_type = 'pending_seller_response'
where event_type = 'intent_created';

update public.deal_events
set metadata = jsonb_set(metadata, '{from_status}', '"pending_seller_response"', false)
where metadata ? 'from_status'
  and metadata ->> 'from_status' = 'intent_created';

delete from public.app_domain_codes
where domain_key = 'deal_status'
  and code = 'intent_created';

update public.app_domain_codes
set sort_order = case code
  when 'pending_seller_response' then 10
  when 'seller_confirmed' then 20
  when 'payment_proof_submitted' then 30
  when 'payment_confirmed' then 40
  when 'expired' then 50
  when 'cancelled' then 60
  when 'completed' then 70
  when 'dispute_opened' then 80
  when 'dispute_resolved' then 90
  else sort_order
end,
updated_at = now()
where domain_key = 'deal_status';

alter table public.deals
  alter column status set default 'pending_seller_response';

alter table public.deals
  drop constraint if exists deals_status_check;

alter table public.deals
  add constraint deals_status_check
  check (
    status in (
      'pending_seller_response',
      'seller_confirmed',
      'payment_proof_submitted',
      'payment_confirmed',
      'expired',
      'cancelled',
      'completed',
      'dispute_opened',
      'dispute_resolved'
    )
  );

drop index if exists idx_one_active_deal_per_listing;
create unique index if not exists idx_one_active_deal_per_listing
on public.deals (listing_id)
where status in (
  'pending_seller_response',
  'seller_confirmed',
  'payment_proof_submitted',
  'payment_confirmed'
);

drop policy if exists "Buyer can create deal intent" on public.deals;
drop policy if exists "Buyer can create deal request" on public.deals;
create policy "Buyer can create deal request"
  on public.deals
  for insert
  to authenticated
  with check (buyer_id = (select auth.uid()));

drop function if exists public.create_deal_intent(uuid, uuid, uuid, text, text);

create or replace function public.create_deal_request(
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
  v_listing public.listings%rowtype;
  v_deal public.deals%rowtype;
  v_now timestamptz := now();
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  if auth.uid() <> p_buyer_id then
    raise exception 'buyer mismatch';
  end if;

  select *
  into v_listing
  from public.listings
  where id = p_listing_id;

  if not found then
    raise exception 'listing not found';
  end if;

  if v_listing.seller_user_id <> p_seller_id then
    raise exception 'seller mismatch';
  end if;

  if v_listing.status <> 'active' or coalesce(v_listing.is_available, false) = false then
    raise exception 'listing unavailable';
  end if;

  insert into public.deals (
    listing_id,
    buyer_id,
    seller_id,
    status,
    deal_type,
    exchange_offer,
    expires_at,
    created_at,
    updated_at
  )
  values (
    p_listing_id,
    p_buyer_id,
    p_seller_id,
    'pending_seller_response',
    p_deal_type,
    nullif(trim(coalesce(p_exchange_offer, '')), ''),
    v_now + interval '24 hours',
    v_now,
    v_now
  )
  returning * into v_deal;

  update public.listings
  set is_available = false,
      updated_at = v_now
  where id = p_listing_id
    and status = 'active';

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
    jsonb_build_object('request_type', p_deal_type),
    v_now
  );

  return v_deal;
end;
$$;

grant execute on function public.create_deal_request(uuid, uuid, uuid, text, text) to authenticated;

create or replace function public.transition_deal(
  p_deal_id uuid,
  p_next_status text
)
returns public.deals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deal public.deals%rowtype;
  v_previous_status text;
  v_is_buyer boolean := false;
  v_is_seller boolean := false;
  v_now timestamptz := now();
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  select *
  into v_deal
  from public.deals
  where id = p_deal_id;

  if not found then
    raise exception 'deal not found';
  end if;

  v_is_buyer := v_deal.buyer_id = auth.uid();
  v_is_seller := v_deal.seller_id = auth.uid();
  v_previous_status := v_deal.status;

  if not v_is_buyer and not v_is_seller then
    raise exception 'transition denied';
  end if;

  if v_deal.status = 'pending_seller_response' then
    if p_next_status = 'seller_confirmed' and v_is_seller then
      null;
    elsif p_next_status = 'expired' and v_is_seller then
      null;
    elsif p_next_status = 'cancelled' and (v_is_buyer or v_is_seller) then
      null;
    else
      raise exception 'transition denied';
    end if;
  elsif v_deal.status = 'seller_confirmed' then
    if p_next_status = 'completed'
       and v_is_seller
       and v_deal.payment_method = 'cash' then
      null;
    elsif p_next_status = 'cancelled' and (v_is_buyer or v_is_seller) then
      null;
    else
      raise exception 'transition denied';
    end if;
  elsif v_deal.status = 'payment_proof_submitted' then
    if p_next_status = 'payment_confirmed' and v_is_seller then
      null;
    elsif p_next_status = 'cancelled' and (v_is_buyer or v_is_seller) then
      null;
    elsif p_next_status = 'dispute_opened' and (v_is_buyer or v_is_seller) then
      null;
    else
      raise exception 'transition denied';
    end if;
  elsif v_deal.status = 'payment_confirmed' then
    if p_next_status = 'completed' and v_is_buyer then
      null;
    elsif p_next_status = 'dispute_opened' and (v_is_buyer or v_is_seller) then
      null;
    else
      raise exception 'transition denied';
    end if;
  elsif v_deal.status = 'dispute_opened' then
    if p_next_status <> 'dispute_resolved' then
      raise exception 'transition denied';
    end if;
  else
    raise exception 'transition denied';
  end if;

  update public.deals
  set status = p_next_status,
      confirmed_at = case
        when p_next_status = 'seller_confirmed' then v_now
        else confirmed_at
      end,
      payment_confirmed_at = case
        when p_next_status = 'payment_confirmed' then v_now
        else payment_confirmed_at
      end,
      completed_at = case
        when p_next_status = 'completed' then v_now
        else completed_at
      end,
      cancelled_at = case
        when p_next_status = 'cancelled' then v_now
        else cancelled_at
      end,
      cancelled_by = case
        when p_next_status = 'cancelled' then auth.uid()
        else cancelled_by
      end,
      updated_at = v_now
  where id = p_deal_id
  returning * into v_deal;

  insert into public.deal_events (
    deal_id,
    event_type,
    actor_id,
    metadata,
    created_at
  )
  values (
    p_deal_id,
    p_next_status,
    auth.uid(),
    jsonb_build_object('from_status', v_previous_status),
    v_now
  );

  if p_next_status in ('cancelled', 'expired') then
    update public.listings
    set is_available = true,
        updated_at = v_now
    where id = v_deal.listing_id
      and status = 'active';
  end if;

  return v_deal;
end;
$$;

grant execute on function public.transition_deal(uuid, text) to authenticated;
