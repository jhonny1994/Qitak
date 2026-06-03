alter table public.reports
  drop constraint if exists reports_reported_entity_type_check;

alter table public.reports
  add constraint reports_reported_entity_type_check
  check (reported_entity_type in ('listing', 'seller', 'message', 'support'));

alter table public.reports
  drop constraint if exists reports_reporter_entity_unique;

drop index if exists public.reports_reporter_entity_unique_non_support_idx;

create unique index reports_reporter_entity_unique_non_support_idx
  on public.reports(reporter_id, reported_entity_type, reported_entity_id)
  where reported_entity_type <> 'support';

drop policy if exists "Buyer can create own listing reports" on public.reports;
drop policy if exists "Authenticated users can create supported reports" on public.reports;

create policy "Authenticated users can create supported reports"
  on public.reports
  for insert
  to authenticated
  with check (
    reporter_id = (select auth.uid())
    and exists (
      select 1
      from public.profiles p
      where p.id = (select auth.uid())
        and p.is_active = true
        and (
          (
            reported_entity_type = 'listing'
            and p.role = 'buyer'::public.user_role
            and exists (
              select 1
              from public.listings l
              where l.id = reports.reported_entity_id
                and l.seller_user_id <> (select auth.uid())
            )
          )
          or (
            reported_entity_type = 'support'
            and reported_entity_id = (select auth.uid())
          )
        )
    )
  );

insert into public.app_domain_codes (domain_key, code, sort_order, metadata)
values (
  'reported_entity_type',
  'support',
  40,
  jsonb_build_object('label_key', 'supportTicketEntityType')
)
on conflict (domain_key, code) do update
set sort_order = excluded.sort_order,
    metadata = excluded.metadata,
    is_active = true,
    updated_at = now();

insert into public.app_policy_options (policy_type, code, label_key, sort_order)
values
  ('support_reason_code', 'account_access', 'supportReasonAccountAccess', 10),
  ('support_reason_code', 'payment_issue', 'supportReasonPaymentIssue', 20),
  ('support_reason_code', 'seller_issue', 'supportReasonSellerIssue', 30),
  ('support_reason_code', 'technical_issue', 'supportReasonTechnicalIssue', 40),
  ('support_reason_code', 'other', 'supportReasonOther', 50)
on conflict (policy_type, code) do update
set label_key = excluded.label_key,
    sort_order = excluded.sort_order,
    is_active = true,
    updated_at = now();
