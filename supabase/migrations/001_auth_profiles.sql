create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key,
  full_name text not null,
  email text not null unique,
  phone text not null,
  role text not null check (role in ('buyer', 'seller', 'admin', 'super_admin')),
  language text not null default 'ar' check (language in ('ar', 'en', 'fr')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles_self_read"
on public.profiles
for select
to authenticated
using (auth.uid() = id);

create policy "profiles_admin_read"
on public.profiles
for select
to authenticated
using (
  exists (
    select 1
    from public.profiles as admin_profile
    where admin_profile.id = auth.uid()
      and admin_profile.role in ('admin', 'super_admin')
      and admin_profile.is_active = true
  )
);

create policy "profiles_self_insert"
on public.profiles
for insert
to authenticated
with check (
  auth.uid() = id
  and role = 'buyer'
  and is_active = true
);

create policy "profiles_self_update_limited"
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (
  auth.uid() = id
  and role in ('buyer', 'seller', 'admin', 'super_admin')
);
