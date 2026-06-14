alter table public.deals
  add column if not exists payment_proof_rejection_reason text,
  add column if not exists cancellation_reason text;

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
