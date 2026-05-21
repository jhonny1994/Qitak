drop policy if exists "profiles_self_insert" on public.profiles;
create policy "profiles_self_insert"
on public.profiles
for insert
to authenticated
with check (
  auth.uid() = id
  and role in ('buyer', 'seller')
  and is_active = true
);
