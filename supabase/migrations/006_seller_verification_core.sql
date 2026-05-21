create table if not exists public.sellers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  seller_type text not null check (seller_type in ('individual', 'business')),
  business_name text,
  bio text not null default '',
  wilaya_id integer not null,
  commune_id text not null,
  rating_average numeric(3,2) not null default 0,
  rating_count integer not null default 0,
  verification_status text not null default 'not_started'
    check (verification_status in ('not_started', 'draft', 'submitted', 'needs_more_info', 'approved', 'rejected', 'suspended')),
  verified_at timestamptz,
  policy_accepted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.seller_documents (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.sellers(id) on delete cascade,
  document_type text not null,
  storage_path text not null,
  uploaded_at timestamptz not null default now()
);

alter table public.sellers enable row level security;
alter table public.seller_documents enable row level security;

drop policy if exists "sellers_self_read" on public.sellers;
create policy "sellers_self_read"
on public.sellers
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "sellers_admin_read" on public.sellers;
create policy "sellers_admin_read"
on public.sellers
for select
to authenticated
using (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
);

drop policy if exists "sellers_self_upsert" on public.sellers;
create policy "sellers_self_upsert"
on public.sellers
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "sellers_self_update_before_approval" on public.sellers;
create policy "sellers_self_update_before_approval"
on public.sellers
for update
to authenticated
using (user_id = auth.uid())
with check (
  user_id = auth.uid()
  and verification_status in ('draft', 'submitted', 'needs_more_info', 'rejected')
);

drop policy if exists "sellers_admin_update" on public.sellers;
create policy "sellers_admin_update"
on public.sellers
for update
to authenticated
using (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
)
with check (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
);

drop policy if exists "profiles_admin_update" on public.profiles;
create policy "profiles_admin_update"
on public.profiles
for update
to authenticated
using (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
)
with check (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
);
