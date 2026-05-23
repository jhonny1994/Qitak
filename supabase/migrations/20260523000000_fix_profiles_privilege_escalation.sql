-- Drop the dangerous policy that allows any authenticated user to change their own role.
-- The WITH CHECK in "profiles_self_update_limited" only validates that the new role value is
-- one of the allowed enum values — it does NOT prevent a buyer from escalating to super_admin.
drop policy if exists "profiles_self_update_limited" on public.profiles;

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;
grant usage on schema private to service_role;

create or replace function private.profile_immutable_fields_match(
  target_user_id uuid,
  expected_role text,
  expected_email text,
  expected_is_active boolean
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = target_user_id
      and role = expected_role
      and email = expected_email
      and is_active = expected_is_active
  );
$$;

revoke all on function private.profile_immutable_fields_match(uuid, text, text, boolean) from public;
grant execute on function private.profile_immutable_fields_match(uuid, text, text, boolean) to authenticated;
grant execute on function private.profile_immutable_fields_match(uuid, text, text, boolean) to service_role;

-- Replace with a field-restricted self-update policy.
-- Users may only change full_name, phone, and language.
-- Immutable fields (role, email, is_active) must retain their pre-update values.
-- The private security-definer helper avoids recursive RLS checks on profiles.
-- Security-definer admin functions bypass RLS and can still modify these fields.
create policy "profiles_self_update_mutable_fields"
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (
  auth.uid() = id
  and private.profile_immutable_fields_match(
    auth.uid(),
    role,
    email,
    is_active
  )
);
