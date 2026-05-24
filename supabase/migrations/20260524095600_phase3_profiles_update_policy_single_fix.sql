begin;

-- Idempotent follow-up: ensure consolidated profiles UPDATE policy exists with desired logic.
-- Safe even if a prior migration already created it.

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
