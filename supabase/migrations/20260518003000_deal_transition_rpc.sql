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
    elsif p_next_status = 'cancelled' and (v_is_buyer or v_is_seller) then
      null;
    elsif p_next_status = 'expired' and v_is_seller then
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

  return v_deal;
end;
$$;

grant execute on function public.transition_deal(uuid, text) to authenticated;
