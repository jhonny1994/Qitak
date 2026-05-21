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
      and l.seller_id = p_seller_id
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

  if v_deal.status = 'intent_created' then
    if p_next_status <> 'pending_seller_response' or not v_is_buyer then
      raise exception 'transition denied';
    end if;
  elsif v_deal.status = 'pending_seller_response' then
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
    if p_next_status = 'completed' and (v_is_buyer or v_is_seller) then
      null;
    elsif p_next_status = 'cancelled' and (v_is_buyer or v_is_seller) then
      null;
    elsif p_next_status = 'dispute_opened' and v_is_buyer then
      null;
    else
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

create or replace function public.admin_resolve_dispute(
  p_dispute_id uuid,
  p_decision text,
  p_reason_code text,
  p_outcome_action text,
  p_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deal_id uuid;
  v_listing_id uuid;
  v_now timestamptz := now();
  v_status text;
begin
  perform public._assert_admin_user();

  if p_decision = 'buyer' then
    v_status := 'resolved_buyer';
  elsif p_decision = 'seller' then
    v_status := 'resolved_seller';
  elsif p_decision = 'dismiss' then
    v_status := 'dismissed';
  else
    raise exception 'invalid dispute decision';
  end if;

  update public.disputes
  set status = v_status,
      resolution_action = p_outcome_action,
      resolution_reason_code = p_reason_code,
      resolution_notes = nullif(trim(coalesce(p_note, '')), ''),
      resolution_note = nullif(trim(coalesce(p_note, '')), ''),
      resolved_by = auth.uid(),
      resolved_at = v_now,
      updated_at = v_now
  where id = p_dispute_id
  returning deal_id into v_deal_id;

  if v_deal_id is null then
    raise exception 'dispute not found';
  end if;

  update public.deals
  set status = 'dispute_resolved',
      updated_at = v_now
  where id = v_deal_id
  returning listing_id into v_listing_id;

  insert into public.deal_events (
    deal_id,
    event_type,
    actor_id,
    metadata,
    created_at
  )
  values (
    v_deal_id,
    'dispute_resolved',
    auth.uid(),
    jsonb_build_object(
      'decision', p_decision,
      'reason_code', p_reason_code,
      'outcome_action', p_outcome_action
    ),
    v_now
  );

  if p_decision in ('seller', 'dismiss') then
    update public.listings
    set is_available = true,
        updated_at = v_now
    where id = v_listing_id
      and status = 'active';
  end if;

  return jsonb_build_object(
    'dispute_id', p_dispute_id,
    'deal_id', v_deal_id,
    'decision', p_decision,
    'status', v_status
  );
end;
$$;

grant execute on function public.admin_resolve_dispute(uuid, text, text, text, text) to authenticated;

drop table if exists public.notification_reads cascade;
drop table if exists public.user_reports cascade;
drop table if exists public.transaction_disputes cascade;
drop table if exists public.transaction_ratings cascade;
drop table if exists public.conversation_messages cascade;
drop table if exists public.conversation_threads cascade;
drop table if exists public.transaction_records cascade;
