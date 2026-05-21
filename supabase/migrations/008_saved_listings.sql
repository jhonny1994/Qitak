create table if not exists public.saved_listings (
  user_id uuid not null references public.profiles(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, listing_id)
);

alter table public.saved_listings enable row level security;

create policy "saved_listings_owner_read"
on public.saved_listings
for select
to authenticated
using (user_id = auth.uid());

create policy "saved_listings_owner_insert"
on public.saved_listings
for insert
to authenticated
with check (user_id = auth.uid());

create policy "saved_listings_owner_delete"
on public.saved_listings
for delete
to authenticated
using (user_id = auth.uid());
