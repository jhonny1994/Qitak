create or replace function public.is_admin_actor(target_user_id uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = target_user_id
      and role in ('admin', 'super_admin')
      and is_active = true
  );
$$;

revoke all on function public.is_admin_actor(uuid) from public;
grant execute on function public.is_admin_actor(uuid) to authenticated;
grant execute on function public.is_admin_actor(uuid) to service_role;

drop policy if exists "profiles_admin_read" on public.profiles;
create policy "profiles_admin_read"
on public.profiles
for select
to authenticated
using (public.is_admin_actor(auth.uid()));

drop policy if exists "profiles_admin_update" on public.profiles;
create policy "profiles_admin_update"
on public.profiles
for update
to authenticated
using (public.is_admin_actor(auth.uid()))
with check (public.is_admin_actor(auth.uid()));
