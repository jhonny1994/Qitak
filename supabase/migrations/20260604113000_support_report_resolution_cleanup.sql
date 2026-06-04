insert into public.app_policy_options (policy_type, code, label_key, sort_order)
values
  (
    'support_report_resolution_decision',
    'resolve',
    'adminSupportDecisionResolve',
    10
  ),
  (
    'support_report_resolution_decision',
    'close',
    'adminSupportDecisionClose',
    20
  ),
  (
    'support_report_resolution_reason_code',
    'verified_and_resolved',
    'adminSupportReasonVerifiedAndResolved',
    10
  ),
  (
    'support_report_resolution_reason_code',
    'user_guided',
    'adminSupportReasonUserGuided',
    20
  ),
  (
    'support_report_resolution_reason_code',
    'duplicate_ticket',
    'adminSupportReasonDuplicateTicket',
    30
  ),
  (
    'support_report_resolution_reason_code',
    'out_of_scope',
    'adminSupportReasonOutOfScope',
    40
  )
on conflict (policy_type, code) do update
set label_key = excluded.label_key,
    sort_order = excluded.sort_order,
    is_active = true,
    updated_at = now();

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
declare
  v_entity_type text;
  v_next_status text;
begin
  perform public._assert_admin_user();

  if nullif(trim(coalesce(p_reason_code, '')), '') is null then
    raise exception 'reason code required';
  end if;

  select reported_entity_type
  into v_entity_type
  from public.reports
  where id = p_report_id;

  if v_entity_type is null then
    raise exception 'report not found';
  end if;

  if v_entity_type = 'support' then
    if p_decision not in ('resolve', 'close') then
      raise exception 'invalid support report decision';
    end if;

    if p_reason_code not in (
      'verified_and_resolved',
      'user_guided',
      'duplicate_ticket',
      'out_of_scope'
    ) then
      raise exception 'invalid support report reason code';
    end if;

    v_next_status := case
      when p_decision = 'close' then 'dismissed'
      else 'actioned'
    end;
  else
    if p_decision not in (
      'dismiss',
      'warn_seller',
      'remove_listing',
      'suspend_seller'
    ) then
      raise exception 'invalid report decision';
    end if;

    if p_reason_code not in (
      'spam',
      'policy_violation',
      'insufficient_evidence'
    ) then
      raise exception 'invalid report reason code';
    end if;

    v_next_status := case
      when p_decision = 'dismiss' then 'dismissed'
      else 'actioned'
    end;
  end if;

  update public.reports
  set status = v_next_status,
      resolution_action = p_decision,
      resolution_reason_code = p_reason_code,
      resolution_note = nullif(trim(coalesce(p_note, '')), ''),
      resolved_by = auth.uid(),
      resolved_at = now()
  where id = p_report_id;

  return jsonb_build_object(
    'report_id', p_report_id,
    'decision', p_decision,
    'status', v_next_status
  );
end;
$$;
