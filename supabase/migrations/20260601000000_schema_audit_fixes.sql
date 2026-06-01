-- =============================================================================
-- MIGRATION: Schema audit fixes
-- Date: 2026-06-01
-- Issues fixed:
--   1. pg_all_foreign_keys and tap_funky pgTAP views exposed to anon/authenticated
--      via PostgREST — discloses full schema structure including auth.* internals.
--   2. reports table has no duplicate constraint — allows spam-reporting a listing.
--   3. 11 INSERT/UPDATE policies targeted {public} instead of {authenticated} —
--      semantically incorrect, violates least privilege (low actual risk but clean-up).
-- =============================================================================

-- ---------------------------------------------------------------------------
-- FIX 1: Revoke schema-exposing pgTAP views from API roles
-- These views are part of the pgTAP test framework and should only be
-- accessible internally (service_role / postgres), never via the REST API.
-- ---------------------------------------------------------------------------
revoke select on public.pg_all_foreign_keys from anon, authenticated;
revoke select on public.tap_funky            from anon, authenticated;


-- ---------------------------------------------------------------------------
-- FIX 2: Prevent duplicate reports on the same entity by the same reporter
-- A buyer could otherwise flood the admin queue with identical reports.
-- ---------------------------------------------------------------------------
alter table public.reports
  add constraint reports_reporter_entity_unique
  unique (reporter_id, reported_entity_id);


-- ---------------------------------------------------------------------------
-- FIX 3: Tighten write policies from {public} to {authenticated}
-- Recreate each policy explicitly targeting `authenticated` so that:
--   a) anon users get a clean "permission denied" instead of an RLS violation
--   b) intent is unambiguous in the schema
-- ---------------------------------------------------------------------------

-- conversations: INSERT
drop policy "Buyer can create listing-anchored conversation" on public.conversations;
create policy "Buyer can create listing-anchored conversation"
  on public.conversations
  for insert
  to authenticated
  with check (buyer_id = (select auth.uid()));

-- deals: INSERT
drop policy "Buyer can create deal intent" on public.deals;
create policy "Buyer can create deal intent"
  on public.deals
  for insert
  to authenticated
  with check (buyer_id = (select auth.uid()));

-- dispute_evidence: INSERT
drop policy "Dispute filer can upload evidence" on public.dispute_evidence;
create policy "Dispute filer can upload evidence"
  on public.dispute_evidence
  for insert
  to authenticated
  with check (
    uploaded_by = (select auth.uid())
    and exists (
      select 1 from disputes d
      where d.id = dispute_evidence.dispute_id
        and d.filed_by = (select auth.uid())
    )
  );

-- disputes: INSERT
drop policy "Buyer can create dispute for own deal" on public.disputes;
create policy "Buyer can create dispute for own deal"
  on public.disputes
  for insert
  to authenticated
  with check (
    filed_by = (select auth.uid())
    and deal_id in (
      select id from deals
      where buyer_id = (select auth.uid())
        and status = any(array['seller_confirmed','completed','dispute_opened'])
    )
  );

-- messages: INSERT
drop policy "Conversation participants can send messages" on public.messages;
create policy "Conversation participants can send messages"
  on public.messages
  for insert
  to authenticated
  with check (
    sender_id = (select auth.uid())
    and conversation_id in (
      select id from conversations
      where buyer_id  = (select auth.uid())
         or seller_id = (select auth.uid())
    )
  );

-- notification_preferences: INSERT
drop policy "Users can insert own notification preferences" on public.notification_preferences;
create policy "Users can insert own notification preferences"
  on public.notification_preferences
  for insert
  to authenticated
  with check (user_id = (select auth.uid()));

-- notification_preferences: UPDATE
drop policy "Users can update own notification preferences" on public.notification_preferences;
create policy "Users can update own notification preferences"
  on public.notification_preferences
  for update
  to authenticated
  using  (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- profiles: INSERT
drop policy "profiles_self_insert" on public.profiles;
create policy "profiles_self_insert"
  on public.profiles
  for insert
  to authenticated
  with check (
    (select auth.uid()) = id
    and role = any(array['buyer'::user_role, 'seller'::user_role])
    and is_active = true
  );

-- profiles: UPDATE
drop policy "profiles_update_consolidated" on public.profiles;
create policy "profiles_update_consolidated"
  on public.profiles
  for update
  to authenticated
  using  (
    (select auth.uid()) = id
    or is_admin_actor((select auth.uid()))
  )
  with check (
    (
      (select auth.uid()) = id
      and private.profile_immutable_fields_match(
        (select auth.uid()), role, email, is_active
      )
    )
    or is_admin_actor((select auth.uid()))
  );

-- reports: INSERT
drop policy "Buyer can create own listing reports" on public.reports;
create policy "Buyer can create own listing reports"
  on public.reports
  for insert
  to authenticated
  with check (
    reporter_id = (select auth.uid())
    and reported_entity_type = 'listing'
    and exists (
      select 1 from profiles p
      where p.id     = (select auth.uid())
        and p.role   = 'buyer'::user_role
        and p.is_active = true
    )
    and exists (
      select 1 from listings l
      where l.id = reports.reported_entity_id
        and l.seller_user_id <> (select auth.uid())
    )
  );

-- seller_reviews: INSERT
drop policy "Buyer can insert review for own completed deal" on public.seller_reviews;
create policy "Buyer can insert review for own completed deal"
  on public.seller_reviews
  for insert
  to authenticated
  with check (
    buyer_id = (select auth.uid())
    and deal_id in (
      select id from deals
      where buyer_id = (select auth.uid())
        and status   = 'completed'
    )
  );
