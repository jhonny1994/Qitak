drop policy if exists "sellers_admin_update" on public.sellers;

create or replace function public.admin_review_seller_application(
  p_application_id uuid,
  p_status text,
  p_reason_code text default null,
  p_note text default null
)
returns public.sellers
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.sellers%rowtype;
begin
  perform public._assert_admin_user();

  if p_status not in ('approved', 'needs_more_info', 'rejected') then
    raise exception 'invalid seller verification status';
  end if;

  if p_status in ('needs_more_info', 'rejected')
     and nullif(trim(coalesce(p_reason_code, '')), '') is null then
    raise exception 'reason code required';
  end if;

  update public.sellers
  set verification_status = p_status,
      review_reason_code = nullif(trim(coalesce(p_reason_code, '')), ''),
      review_note = nullif(trim(coalesce(p_note, '')), ''),
      verified_at = case when p_status = 'approved' then now() else null end,
      updated_at = now()
  where id = p_application_id
  returning * into v_row;

  if v_row.id is null then
    raise exception 'seller application not found';
  end if;

  return v_row;
end;
$$;

grant execute on function public.admin_review_seller_application(uuid, text, text, text) to authenticated;

create or replace function public.admin_resolve_report(
  p_report_id uuid,
  p_decision text,
  p_reason_code text,
  p_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public._assert_admin_user();

  if p_decision not in ('dismiss', 'warn_seller', 'remove_listing', 'suspend_seller') then
    raise exception 'invalid report decision';
  end if;

  if nullif(trim(coalesce(p_reason_code, '')), '') is null then
    raise exception 'reason code required';
  end if;

  if p_reason_code not in ('spam', 'policy_violation', 'insufficient_evidence') then
    raise exception 'invalid report reason code';
  end if;

  update public.reports
  set status = case when p_decision = 'dismiss' then 'closed' else 'actioned' end,
      resolution_action = p_decision,
      resolution_reason_code = p_reason_code,
      resolution_note = nullif(trim(coalesce(p_note, '')), ''),
      resolved_by = auth.uid(),
      resolved_at = now()
  where id = p_report_id;

  return jsonb_build_object('report_id', p_report_id, 'decision', p_decision);
end;
$$;

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

  if nullif(trim(coalesce(p_reason_code, '')), '') is null then
    raise exception 'reason code required';
  end if;

  if p_reason_code not in ('damaged_part', 'wrong_part', 'insufficient_evidence') then
    raise exception 'invalid dispute reason code';
  end if;

  if p_outcome_action not in ('no_action', 'warn', 'suspend', 'remove_listing') then
    raise exception 'invalid dispute outcome action';
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

grant execute on function public.admin_resolve_report(uuid, text, text, text) to authenticated;
grant execute on function public.admin_resolve_dispute(uuid, text, text, text, text) to authenticated;
