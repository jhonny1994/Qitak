-- =============================================================================
-- MIGRATION: Move pgTAP extension out of the public schema
-- Date: 2026-06-01
-- Linter: extension_in_public (WARN) — pgtap installed in public schema
--
-- Problem: pgTAP is installed in `public`, which is exposed by PostgREST.
-- This makes ~300 test-framework functions (ok, is, plan, has_table, …)
-- callable by any authenticated user via /rest/v1/rpc/. They cannot read or
-- write application data, but they expose schema metadata unnecessarily.
--
-- Fix: Move pgTAP to a dedicated `extensions` schema that is NOT in
-- PostgREST's db_schema list. Grant USAGE + EXECUTE to anon/authenticated
-- so that pgTAP can still be called inside DB-level test transactions
-- (where `set local role anon` is used), but it is no longer reachable via
-- the REST API.
--
-- Test files that already had `set search_path = public, extensions;` will
-- work unchanged. The two that did not have been updated to match.
-- =============================================================================

-- 1. Create the extensions schema (idempotent)
create schema if not exists extensions;

-- 2. Move pgTAP — all its functions/types/operators move with it
alter extension pgtap set schema extensions;

-- 3. Allow DB-level test sessions (anon/authenticated local-role switches) to
--    resolve pgTAP symbols. PostgREST does NOT expose the extensions schema
--    so these grants do not create REST API surface.
grant usage on schema extensions to anon, authenticated;
grant execute on all functions in schema extensions to anon, authenticated;
