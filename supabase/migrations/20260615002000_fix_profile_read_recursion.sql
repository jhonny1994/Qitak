create or replace function private.can_read_profile(target_profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, private
as $$
  select
    target_profile_id = auth.uid()
    or public.is_admin_actor(auth.uid())
    or exists (
      select 1
      from public.conversations c
      where (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
        and (c.buyer_id = target_profile_id or c.seller_id = target_profile_id)
    );
$$;

revoke all on function private.can_read_profile(uuid) from public;
grant execute on function private.can_read_profile(uuid) to authenticated;
grant execute on function private.can_read_profile(uuid) to service_role;

drop policy if exists "profiles_select_authenticated_consolidated" on public.profiles;
create policy "profiles_select_authenticated_consolidated"
on public.profiles
as permissive
for select
to authenticated
using (private.can_read_profile(id));
