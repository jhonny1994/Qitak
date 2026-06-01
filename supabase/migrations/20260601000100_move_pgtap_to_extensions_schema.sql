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

-- 2–3. Move pgTAP and grant access — only if pgtap is actually installed.
--      In CI (Supabase Docker) pgtap may not be present; skipping is safe
--      because there is nothing in public to expose via PostgREST there.
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pgtap') then
    -- Move all pgtap functions/types/operators out of public
    alter extension pgtap set schema extensions;

    -- Allow DB-level test sessions (anon/authenticated local-role switches)
    -- to resolve pgTAP symbols without exposing them via the REST API.
    grant usage on schema extensions to anon, authenticated;
    grant execute on all functions in schema extensions to anon, authenticated;
  end if;
end $$;
