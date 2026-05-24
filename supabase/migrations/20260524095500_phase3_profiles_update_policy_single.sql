begin;

-- Corrected: consolidate profiles UPDATE policies using live schema columns
-- and existing immutable-field helper signature.

drop policy if exists profiles_self_update_mutable_fields on public.profiles;
drop policy if exists profiles_update_admin_consolidated on public.profiles;
drop policy if exists profiles_admin_update on public.profiles;
drop policy if exists profiles_update_consolidated on public.profiles;

create policy profiles_update_consolidated
on public.profiles
as permissive
for update
to authenticated
using (
  ((select auth.uid()) = id)
  or public.is_admin_actor((select auth.uid()))
)
with check (
  (
    (select auth.uid()) = id
    and private.profile_immutable_fields_match(
      (select auth.uid()),
      role,
      email,
      is_active
    )
  )
  or public.is_admin_actor((select auth.uid()))
);

commit;
