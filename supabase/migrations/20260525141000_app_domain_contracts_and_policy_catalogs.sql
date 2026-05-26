create table if not exists public.app_domain_catalog (
  domain_key text primary key,
  domain_type text not null check (domain_type in ('invariant_state', 'policy_catalog')),
  description text not null default '',
  is_active boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists public.app_domain_codes (
  id uuid primary key default gen_random_uuid(),
  domain_key text not null references public.app_domain_catalog(domain_key) on delete cascade,
  code text not null,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(domain_key, code)
);

create table if not exists public.app_policy_options (
  id uuid primary key default gen_random_uuid(),
  policy_type text not null,
  code text not null,
  label_key text not null,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(policy_type, code)
);

create index if not exists idx_app_domain_codes_domain_sort
  on public.app_domain_codes(domain_key, sort_order, code);

create index if not exists idx_app_policy_options_type_sort
  on public.app_policy_options(policy_type, sort_order, code);

alter table public.app_domain_catalog enable row level security;
alter table public.app_domain_codes enable row level security;
alter table public.app_policy_options enable row level security;

drop policy if exists "app_domain_catalog_public_read" on public.app_domain_catalog;
create policy "app_domain_catalog_public_read"
on public.app_domain_catalog for select
to anon, authenticated
using (is_active = true);

drop policy if exists "app_domain_codes_public_read" on public.app_domain_codes;
create policy "app_domain_codes_public_read"
on public.app_domain_codes for select
to anon, authenticated
using (
  is_active = true
  and exists (
    select 1
    from public.app_domain_catalog c
    where c.domain_key = app_domain_codes.domain_key
      and c.is_active = true
  )
);

drop policy if exists "app_policy_options_public_read" on public.app_policy_options;
create policy "app_policy_options_public_read"
on public.app_policy_options for select
to anon, authenticated
using (is_active = true);

create or replace view public.app_domain_contracts as
select
  c.domain_key,
  c.domain_type,
  d.code,
  d.sort_order,
  d.metadata
from public.app_domain_catalog c
join public.app_domain_codes d
  on d.domain_key = c.domain_key
where c.is_active = true
  and d.is_active = true;

create or replace view public.app_policy_contracts as
select
  p.policy_type,
  p.code,
  p.label_key,
  p.sort_order,
  p.metadata
from public.app_policy_options p
where p.is_active = true;

grant usage on schema public to anon, authenticated;
grant select on public.app_domain_catalog to anon, authenticated;
grant select on public.app_domain_codes to anon, authenticated;
grant select on public.app_policy_options to anon, authenticated;
grant select on public.app_domain_contracts to anon, authenticated;
grant select on public.app_policy_contracts to anon, authenticated;

create or replace function public.get_app_domain_contracts(
  p_domain_key text default null
)
returns table (
  domain_key text,
  domain_type text,
  code text,
  sort_order integer,
  metadata jsonb
)
language sql
security invoker
set search_path = public
as $$
  select
    c.domain_key,
    c.domain_type,
    c.code,
    c.sort_order,
    c.metadata
  from public.app_domain_contracts c
  where p_domain_key is null or c.domain_key = p_domain_key
  order by c.domain_key, c.sort_order, c.code;
$$;

grant execute on function public.get_app_domain_contracts(text) to anon, authenticated;

create or replace function public.get_app_policy_contracts(
  p_policy_type text default null
)
returns table (
  policy_type text,
  code text,
  label_key text,
  sort_order integer,
  metadata jsonb
)
language sql
security invoker
set search_path = public
as $$
  select
    p.policy_type,
    p.code,
    p.label_key,
    p.sort_order,
    p.metadata
  from public.app_policy_contracts p
  where p_policy_type is null or p.policy_type = p_policy_type
  order by p.policy_type, p.sort_order, p.code;
$$;

grant execute on function public.get_app_policy_contracts(text) to anon, authenticated;

insert into public.app_domain_catalog (domain_key, domain_type, description)
values
  ('seller_verification_status', 'invariant_state', 'Seller application verification workflow states'),
  ('listing_status', 'invariant_state', 'Listing workflow moderation and publication states'),
  ('deal_status', 'invariant_state', 'Transaction/deal lifecycle states'),
  ('dispute_status', 'invariant_state', 'Dispute resolution lifecycle states'),
  ('report_status', 'invariant_state', 'Admin report lifecycle states'),
  ('reported_entity_type', 'invariant_state', 'Report target entity types')
on conflict (domain_key) do update
set domain_type = excluded.domain_type,
    description = excluded.description,
    is_active = true,
    updated_at = now();

insert into public.app_domain_codes (domain_key, code, sort_order)
values
  ('seller_verification_status', 'not_started', 10),
  ('seller_verification_status', 'draft', 20),
  ('seller_verification_status', 'submitted', 30),
  ('seller_verification_status', 'needs_more_info', 40),
  ('seller_verification_status', 'approved', 50),
  ('seller_verification_status', 'rejected', 60),
  ('seller_verification_status', 'suspended', 70),

  ('listing_status', 'draft', 10),
  ('listing_status', 'pending_review', 20),
  ('listing_status', 'active', 30),
  ('listing_status', 'paused', 40),
  ('listing_status', 'rejected', 50),
  ('listing_status', 'closed', 60),

  ('deal_status', 'intent_created', 10),
  ('deal_status', 'pending_seller_response', 20),
  ('deal_status', 'seller_confirmed', 30),
  ('deal_status', 'expired', 40),
  ('deal_status', 'cancelled', 50),
  ('deal_status', 'completed', 60),
  ('deal_status', 'dispute_opened', 70),
  ('deal_status', 'dispute_resolved', 80),

  ('dispute_status', 'open', 10),
  ('dispute_status', 'under_review', 20),
  ('dispute_status', 'resolved_buyer', 30),
  ('dispute_status', 'resolved_seller', 40),
  ('dispute_status', 'dismissed', 50),

  ('report_status', 'open', 10),
  ('report_status', 'under_review', 20),
  ('report_status', 'actioned', 30),
  ('report_status', 'dismissed', 40),

  ('reported_entity_type', 'listing', 10),
  ('reported_entity_type', 'seller', 20),
  ('reported_entity_type', 'message', 30)
on conflict (domain_key, code) do update
set sort_order = excluded.sort_order,
    is_active = true,
    updated_at = now();

insert into public.app_policy_options (policy_type, code, label_key, sort_order)
values
  ('seller_document_type', 'government_id_front', 'sellerDocumentIdFrontLabel', 10),
  ('seller_document_type', 'government_id_back', 'sellerDocumentIdBackLabel', 20),
  ('seller_document_type', 'business_registration', 'sellerDocumentBusinessRegistrationLabel', 30),

  ('seller_verification_reason_code', 'document_unreadable', 'adminVerificationReasonUnreadable', 10),
  ('seller_verification_reason_code', 'identity_mismatch', 'adminVerificationReasonIdentityMismatch', 20),
  ('seller_verification_reason_code', 'missing_business_registration', 'adminVerificationReasonMissingBusinessDocument', 30),

  ('report_resolution_reason_code', 'spam', 'adminReportReasonSpam', 10),
  ('report_resolution_reason_code', 'policy_violation', 'adminReportReasonPolicyViolation', 20),
  ('report_resolution_reason_code', 'insufficient_evidence', 'adminReportReasonInsufficientEvidence', 30),

  ('dispute_resolution_reason_code', 'damaged_part', 'adminDisputeReasonDamagedPart', 10),
  ('dispute_resolution_reason_code', 'wrong_part', 'adminDisputeReasonWrongPart', 20),
  ('dispute_resolution_reason_code', 'insufficient_evidence', 'adminDisputeReasonInsufficientEvidence', 30),

  ('report_resolution_decision', 'dismiss', 'adminReportDecisionDismiss', 10),
  ('report_resolution_decision', 'warn_seller', 'adminReportDecisionWarnSeller', 20),
  ('report_resolution_decision', 'remove_listing', 'adminReportDecisionRemoveListing', 30),
  ('report_resolution_decision', 'suspend_seller', 'adminReportDecisionSuspendSeller', 40),

  ('dispute_resolution_decision', 'buyer', 'adminDisputeDecisionBuyer', 10),
  ('dispute_resolution_decision', 'seller', 'adminDisputeDecisionSeller', 20),
  ('dispute_resolution_decision', 'dismiss', 'adminDisputeDecisionDismiss', 30),

  ('dispute_resolution_outcome_action', 'no_action', 'adminDisputeOutcomeNoAction', 10),
  ('dispute_resolution_outcome_action', 'warn', 'adminDisputeOutcomeWarn', 20),
  ('dispute_resolution_outcome_action', 'suspend', 'adminDisputeOutcomeSuspend', 30),
  ('dispute_resolution_outcome_action', 'remove_listing', 'adminDisputeOutcomeRemoveListing', 40),

  ('listing_report_reason_code', 'spam', 'reportListingReasonSpam', 10),
  ('listing_report_reason_code', 'misleading', 'reportListingReasonMisleading', 20),
  ('listing_report_reason_code', 'wrong_category', 'reportListingReasonWrongCategory', 30),
  ('listing_report_reason_code', 'other', 'reportListingReasonOther', 40),

  ('buyer_dispute_reason_code', 'wrong_part', 'disputeReasonWrongPart', 10),
  ('buyer_dispute_reason_code', 'condition_misrepresented', 'disputeReasonCondition', 20),
  ('buyer_dispute_reason_code', 'not_received', 'disputeReasonNotReceived', 30),
  ('buyer_dispute_reason_code', 'seller_unresponsive', 'disputeReasonUnresponsive', 40),
  ('buyer_dispute_reason_code', 'other', 'disputeReasonOther', 50)
on conflict (policy_type, code) do update
set label_key = excluded.label_key,
    sort_order = excluded.sort_order,
    is_active = true,
    updated_at = now();
