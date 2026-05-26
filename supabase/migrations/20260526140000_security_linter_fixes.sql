-- Fix 1: SECURITY DEFINER views (ERROR level)
-- Both views were flagged as SECURITY DEFINER, which bypasses RLS on the
-- underlying tables and runs queries as the view owner (postgres) rather
-- than the calling user. Set security_invoker = true so the querying
-- user's grants and RLS policies are enforced as expected.

alter view public.app_domain_contracts set (security_invoker = true);
alter view public.app_policy_contracts set (security_invoker = true);

-- Fix 2: is_admin_actor accessible to authenticated via RPC (WARN level)
-- is_admin_actor is an internal helper used exclusively inside RLS policy
-- expressions. Revoking EXECUTE from the authenticated role prevents it
-- from being called directly via /rest/v1/rpc/is_admin_actor while still
-- allowing Postgres to invoke it during RLS policy evaluation (which runs
-- under the table owner / security-definer context, not the client role).

revoke execute on function public.is_admin_actor(uuid) from authenticated;
