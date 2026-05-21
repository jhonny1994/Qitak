alter table public.listings
  add column if not exists category_id text,
  add column if not exists condition text not null default 'used'
    check (condition in ('new', 'like_new', 'used')),
  add column if not exists quantity integer not null default 1
    check (quantity > 0),
  add column if not exists exchange_enabled boolean not null default false,
  add column if not exists seller_display_name text not null default '';

update public.listings as l
set seller_display_name = coalesce(p.full_name, '')
from public.profiles as p
where p.id = l.seller_user_id
  and coalesce(l.seller_display_name, '') = '';

drop policy if exists "listings_public_read" on public.listings;
create policy "listings_public_read"
on public.listings
for select
to anon, authenticated
using (true);

drop policy if exists "listing_fitments_public_read" on public.listing_fitments;
create policy "listing_fitments_public_read"
on public.listing_fitments
for select
to anon, authenticated
using (true);
