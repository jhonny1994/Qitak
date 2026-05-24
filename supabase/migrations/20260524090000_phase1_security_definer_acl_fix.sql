-- Phase 1: security-critical grant hardening for SECURITY DEFINER exposure
-- Generated from cloud drift finding: public.is_admin_actor executable by anon

begin;

-- Remove anonymous access explicitly (lint 0028)
revoke execute on function public.is_admin_actor(uuid) from anon;

-- Keep intended access explicit
grant execute on function public.is_admin_actor(uuid) to authenticated;
grant execute on function public.is_admin_actor(uuid) to service_role;

commit;
