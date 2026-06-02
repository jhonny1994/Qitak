-- =============================================================================
-- MIGRATION: Let buyers see the seller row of any active listing.
-- Date: 2026-06-02
-- Linter: real-user-repro (motivating gap from 005 follow-up)
--
-- Problem
--   Discovery and rating flows issue queries shaped like
--     listings?select=...,sellers!inner(user_id, business_name),...
--   The listings SELECT policy correctly lets authenticated users see
--   status='active' rows. But the sellers SELECT policy only allows
--   (user_id = auth.uid()) OR is_admin_actor(auth.uid()). A buyer is
--   neither, so the inner join filters out every listing — the home
--   screen and search both render as "no results" even when rows exist.
--
--   The rating flow has the same shape:
--     from('sellers').select('id').eq('user_id', toUserId).single()
--   — also blocked by the same policy.
--
-- Fix
--   Extend the existing consolidated sellers SELECT policy with one OR
--   clause: a seller row is visible to authenticated callers if the
--   seller has at least one listing with status='active'. This is the
--   idiomatic Supabase "sharing rows between users" pattern: the join
--   is row-level gated, and the app's column projection stays the
--   column-level boundary (consistent with the rest of the schema's
--   RLS model).
--
-- Performance
--   - (SELECT auth.uid()) wrapping for per-statement caching (per
--     supabase-postgres-best-practices/security-rls-performance).
--   - Partial index listings(seller_id) WHERE status='active' makes
--     the EXISTS subquery an Index Only Scan at production scale.
--
-- Pattern followed
--   supabase/migrations/20260523191240_security_advisor_hardening.sql
--   — same DROP+CREATE policy + header comment shape.
-- =============================================================================

create index if not exists listings_seller_id_active_idx
  on public.listings (seller_id)
  where status = 'active';

drop policy if exists sellers_select_authenticated_consolidated on public.sellers;
create policy sellers_select_authenticated_consolidated on public.sellers
  for select
  to authenticated
  using (
    (user_id = (select auth.uid()))
    or is_admin_actor((select auth.uid()))
    or exists (
      select 1
      from public.listings l
      where l.seller_id = sellers.id
        and l.status = 'active'
    )
  );
