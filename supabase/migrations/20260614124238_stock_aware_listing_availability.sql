-- Replace boolean-only marketplace availability with stock-aware runtime checks.

create or replace function public.listing_reserved_units(p_listing_id uuid)
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select count(*)::integer
  from public.deals d
  where d.listing_id = p_listing_id
    and d.status in (
      'pending_seller_response',
      'seller_confirmed',
      'payment_proof_submitted',
      'payment_confirmed',
      'dispute_opened'
    );
$$;

revoke all on function public.listing_reserved_units(uuid) from public, anon;
grant execute on function public.listing_reserved_units(uuid) to authenticated;
grant execute on function public.listing_reserved_units(uuid) to anon;

create or replace function public.listing_committed_units(p_listing_id uuid)
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select count(*)::integer
  from public.deals d
  where d.listing_id = p_listing_id
    and d.status in (
      'pending_seller_response',
      'seller_confirmed',
      'payment_proof_submitted',
      'payment_confirmed',
      'completed',
      'dispute_opened'
    );
$$;

revoke all on function public.listing_committed_units(uuid) from public, anon;
grant execute on function public.listing_committed_units(uuid) to authenticated;
grant execute on function public.listing_committed_units(uuid) to anon;

create or replace function public.listing_has_remaining_stock(
  p_listing_id uuid,
  p_quantity integer
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select greatest(
    coalesce(p_quantity, 0) - public.listing_committed_units(p_listing_id),
    0
  ) > 0;
$$;

revoke all on function public.listing_has_remaining_stock(uuid, integer) from public, anon;
grant execute on function public.listing_has_remaining_stock(uuid, integer) to authenticated;
grant execute on function public.listing_has_remaining_stock(uuid, integer) to anon;

create or replace function public.sync_listing_availability(p_listing_id uuid)
returns void
language sql
volatile
set search_path = public
as $$
  update public.listings l
  set is_available = (
        l.status = 'active'
        and public.listing_has_remaining_stock(l.id, l.quantity)
      ),
      updated_at = now()
  where l.id = p_listing_id;
$$;

drop index if exists idx_one_active_deal_per_listing;
create index if not exists idx_active_deals_by_listing
on public.deals (listing_id)
where status in (
  'pending_seller_response',
  'seller_confirmed',
  'payment_proof_submitted',
  'payment_confirmed',
  'dispute_opened'
);

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
  v_remaining_units integer;
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
  where id = p_listing_id
  for update;

  if not found then
    raise exception 'listing not found';
  end if;

  if v_listing.seller_user_id <> p_seller_id then
    raise exception 'seller mismatch';
  end if;

  if v_listing.status <> 'active' then
    raise exception 'listing unavailable';
  end if;

  if not public.listing_has_remaining_stock(p_listing_id, v_listing.quantity) then
    perform public.sync_listing_availability(p_listing_id);
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

  perform public.sync_listing_availability(p_listing_id);

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
revoke execute on function public.create_deal_request(uuid, uuid, uuid, text, text) from public, anon;

create or replace function public.transition_deal(
  p_deal_id uuid,
  p_next_status text,
  p_note text default null
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
  v_note text := nullif(trim(coalesce(p_note, '')), '');
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

  if p_next_status = 'cancelled'
     and v_deal.status = 'pending_seller_response'
     and v_is_seller
     and v_note is null then
    raise exception 'cancellation reason required';
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
      cancellation_reason = case
        when p_next_status = 'cancelled' then v_note
        else cancellation_reason
      end,
      payment_proof_rejection_reason = case
        when p_next_status in ('seller_confirmed', 'payment_confirmed', 'completed', 'cancelled')
          then null
        else payment_proof_rejection_reason
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
    jsonb_strip_nulls(
      jsonb_build_object(
        'from_status', v_previous_status,
        'note', v_note
      )
    ),
    v_now
  );

  if p_next_status in ('cancelled', 'expired', 'completed') then
    perform public.sync_listing_availability(v_deal.listing_id);
  end if;

  return v_deal;
end;
$$;

grant execute on function public.transition_deal(uuid, text, text) to authenticated;
revoke execute on function public.transition_deal(uuid, text, text) from public, anon;

drop function if exists public.transition_deal(uuid, text);

create or replace function public.reject_deal_payment_proof(
  p_deal_id uuid,
  p_reason text default null
)
returns public.deals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deal public.deals%rowtype;
  v_now timestamptz := now();
  v_reason text := nullif(trim(coalesce(p_reason, '')), '');
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  if v_reason is null then
    raise exception 'rejection reason required';
  end if;

  select *
  into v_deal
  from public.deals
  where id = p_deal_id;

  if not found then
    raise exception 'deal not found';
  end if;

  if v_deal.seller_id <> auth.uid()
     or v_deal.status <> 'payment_proof_submitted' then
    raise exception 'transition denied';
  end if;

  update public.deals
  set status = 'seller_confirmed',
      payment_proof_path = null,
      payment_proof_submitted_at = null,
      payment_confirmed_at = null,
      payment_proof_rejection_reason = v_reason,
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
    'payment_proof_rejected',
    auth.uid(),
    jsonb_build_object(
      'from_status', 'payment_proof_submitted',
      'reason', v_reason
    ),
    v_now
  );

  return v_deal;
end;
$$;

grant execute on function public.reject_deal_payment_proof(uuid, text) to authenticated;
revoke execute on function public.reject_deal_payment_proof(uuid, text) from public, anon;

drop function if exists public.reject_deal_payment_proof(uuid);

drop policy if exists listings_select_public_active on public.listings;
create policy listings_select_public_active
on public.listings
as permissive
for select
to anon, authenticated
using (
  status = 'active'
  and public.listing_has_remaining_stock(id, quantity)
);

drop policy if exists listing_media_select_public_active on public.listing_media;
create policy listing_media_select_public_active
on public.listing_media
as permissive
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.listings l
    where l.id = listing_media.listing_id
      and l.status = 'active'
      and public.listing_has_remaining_stock(l.id, l.quantity)
  )
);

update public.listings l
set is_available = (
      l.status = 'active'
      and public.listing_has_remaining_stock(l.id, l.quantity)
    ),
    updated_at = now()
where l.status in ('active', 'closed', 'draft', 'under_review', 'rejected');

create or replace function public.seller_upsert_listing_draft(payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_listing_id uuid;
  v_existing_owner uuid;
  v_seller_id uuid;
  v_media_count integer;
  v_media_item jsonb;
  v_requested_quantity integer;
  v_committed_units integer := 0;
begin
  perform public._assert_approved_seller();

  select s.id
  into v_seller_id
  from public.sellers s
  where s.user_id = auth.uid()
    and s.verification_status = 'approved'::public.seller_verification_status;

  if v_seller_id is null then
    raise exception 'seller approval required';
  end if;

  v_listing_id := nullif(payload ->> 'listing_id', '')::uuid;
  v_media_count := coalesce(jsonb_array_length(coalesce(payload -> 'media', '[]'::jsonb)), 0);
  v_requested_quantity := coalesce((payload ->> 'quantity')::integer, 1);

  if v_media_count < 1 then
    raise exception 'at least one photo is required for draft saves';
  end if;

  if v_listing_id is not null then
    select seller_user_id into v_existing_owner
    from public.listings
    where id = v_listing_id;

    if v_existing_owner is distinct from auth.uid() then
      raise exception 'listing ownership mismatch';
    end if;

    v_committed_units := public.listing_committed_units(v_listing_id);
    if v_requested_quantity < v_committed_units then
      raise exception 'quantity below committed stock';
    end if;

    update public.listings
    set title = coalesce(payload ->> 'title', title),
        description = coalesce(payload ->> 'description', description),
        price = coalesce((payload ->> 'price')::numeric, price),
        wilaya_code = payload ->> 'wilaya_code',
        commune_code = payload ->> 'commune_code',
        wilaya_id = coalesce((payload ->> 'wilaya_id')::integer, wilaya_id),
        commune_id = coalesce(payload ->> 'commune_id', commune_id),
        category_id = payload ->> 'category_id',
        condition = coalesce(payload ->> 'condition', condition),
        quantity = coalesce((payload ->> 'quantity')::integer, quantity),
        exchange_enabled = coalesce((payload ->> 'exchange_enabled')::boolean, exchange_enabled),
        exchange_description = nullif(trim(coalesce(payload ->> 'exchange_description', '')), ''),
        brand = coalesce(payload ->> 'brand', brand),
        vehicle_fitment = coalesce(payload -> 'vehicle_fitment', vehicle_fitment),
        fulfillment_mode = coalesce(payload ->> 'fulfillment_mode', fulfillment_mode),
        seller_display_name = coalesce(
          (select full_name from public.profiles where id = auth.uid()),
          seller_display_name
        ),
        status = 'draft',
        submitted_at = null,
        moderated_at = null,
        moderated_by = null,
        rejection_reason = null,
        updated_at = now()
    where id = v_listing_id;
  else
    insert into public.listings (
      seller_user_id,
      seller_id,
      title,
      description,
      price,
      wilaya_code,
      commune_code,
      wilaya_id,
      commune_id,
      category_id,
      condition,
      quantity,
      exchange_enabled,
      exchange_description,
      brand,
      vehicle_fitment,
      fulfillment_mode,
      seller_display_name,
      status,
      submitted_at
    )
    values (
      auth.uid(),
      v_seller_id,
      coalesce(payload ->> 'title', ''),
      coalesce(payload ->> 'description', ''),
      coalesce((payload ->> 'price')::numeric, 0),
      payload ->> 'wilaya_code',
      payload ->> 'commune_code',
      coalesce((payload ->> 'wilaya_id')::integer, nullif(payload ->> 'wilaya_code', '')::integer),
      coalesce(payload ->> 'commune_id', payload ->> 'commune_code'),
      payload ->> 'category_id',
      coalesce(payload ->> 'condition', 'used'),
      v_requested_quantity,
      coalesce((payload ->> 'exchange_enabled')::boolean, false),
      nullif(trim(coalesce(payload ->> 'exchange_description', '')), ''),
      coalesce(payload ->> 'brand', ''),
      coalesce(payload -> 'vehicle_fitment', '[]'::jsonb),
      coalesce(payload ->> 'fulfillment_mode', 'pickup'),
      coalesce((select full_name from public.profiles where id = auth.uid()), ''),
      'draft',
      null
    )
    returning id into v_listing_id;
  end if;

  delete from public.listing_fitments where listing_id = v_listing_id;
  delete from public.listing_media where listing_id = v_listing_id;

  insert into public.listing_fitments (
    listing_id,
    brand_code,
    model_code,
    model_year
  )
  values (
    v_listing_id,
    coalesce(payload ->> 'brand_code', ''),
    coalesce(payload ->> 'model_code', ''),
    coalesce((payload ->> 'model_year')::integer, 1950)
  );

  for v_media_item in
    select value
    from jsonb_array_elements(coalesce(payload -> 'media', '[]'::jsonb))
  loop
    insert into public.listing_media (
      listing_id,
      storage_path,
      public_url,
      mime_type,
      sort_order
    )
    values (
      v_listing_id,
      v_media_item ->> 'storage_path',
      v_media_item ->> 'public_url',
      coalesce(v_media_item ->> 'mime_type', 'image/jpeg'),
      coalesce((v_media_item ->> 'sort_order')::integer, 0)
    );
  end loop;

  perform public.sync_listing_availability(v_listing_id);

  return jsonb_build_object(
    'listing_id', v_listing_id,
    'status', 'draft'
  );
end;
$$;

create or replace function public.seller_submit_listing(payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_result jsonb;
  v_listing_id uuid;
  v_status text;
  v_min_photos integer := 1;
  v_media_count integer;
  v_category_id uuid;
  v_requires_review boolean := false;
begin
  perform public._assert_approved_seller();

  v_media_count := coalesce(jsonb_array_length(coalesce(payload -> 'media', '[]'::jsonb)), 0);
  v_category_id := nullif(payload ->> 'category_id', '')::uuid;

  if v_category_id is not null then
    select coalesce((metadata ->> 'min_photos')::integer, 1),
           coalesce((metadata ->> 'requires_review')::boolean, false)
    into v_min_photos, v_requires_review
    from public.part_categories
    where id = v_category_id;
  end if;

  if v_media_count < v_min_photos then
    raise exception 'at least % photos are required for submission', v_min_photos;
  end if;

  v_result := public.seller_upsert_listing_draft(payload);
  v_listing_id := (v_result ->> 'listing_id')::uuid;
  v_status := case when v_requires_review then 'pending_review' else 'active' end;

  update public.listings
  set status = v_status,
      submitted_at = case when v_requires_review then now() else null end,
      updated_at = now(),
      rejection_reason = null,
      moderated_at = null,
      moderated_by = null
  where id = v_listing_id
    and seller_user_id = auth.uid();

  perform public.sync_listing_availability(v_listing_id);

  return jsonb_build_object(
    'listing_id', v_listing_id,
    'status', v_status
  );
end;
$$;

create or replace function public.seller_submit_listing_for_review(payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  return public.seller_submit_listing(payload);
end;
$$;

create or replace function public.admin_review_listing(
  p_listing_id uuid,
  p_decision text,
  p_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_status text;
begin
  perform public._assert_admin_user();

  if p_decision not in ('approve', 'reject') then
    raise exception 'invalid moderation decision';
  end if;

  v_status := case when p_decision = 'approve' then 'active' else 'rejected' end;

  update public.listings
  set status = v_status,
      moderated_by = auth.uid(),
      moderated_at = now(),
      rejection_reason = case when p_decision = 'reject' then nullif(trim(coalesce(p_note, '')), '') else null end,
      updated_at = now()
  where id = p_listing_id;

  perform public.sync_listing_availability(p_listing_id);

  return jsonb_build_object(
    'listing_id', p_listing_id,
    'status', v_status
  );
end;
$$;
