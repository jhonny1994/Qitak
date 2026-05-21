do $$
begin
  insert into storage.buckets (id, name, public)
  values ('listing-media', 'listing-media', true)
  on conflict (id) do update
    set public = excluded.public;
exception
  when undefined_table then
    null;
end $$;

create table if not exists public.listing_media (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  storage_path text not null unique,
  public_url text not null,
  mime_type text not null default 'image/jpeg',
  sort_order integer not null default 0 check (sort_order >= 0),
  created_at timestamptz not null default now()
);

create index if not exists listing_media_listing_sort_idx
  on public.listing_media (listing_id, sort_order, created_at);

alter table public.listing_media enable row level security;

drop policy if exists "listing_media_public_read" on public.listing_media;
create policy "listing_media_public_read"
on public.listing_media
for select
to anon, authenticated
using (true);

drop policy if exists "listing_media_owner_insert" on public.listing_media;
create policy "listing_media_owner_insert"
on public.listing_media
for insert
to authenticated
with check (
  exists (
    select 1
    from public.listings l
    where l.id = listing_id
      and l.seller_user_id = auth.uid()
  )
);

drop policy if exists "listing_media_owner_delete" on public.listing_media;
create policy "listing_media_owner_delete"
on public.listing_media
for delete
to authenticated
using (
  exists (
    select 1
    from public.listings l
    where l.id = listing_id
      and l.seller_user_id = auth.uid()
  )
);

drop policy if exists "listing_media_public_read" on storage.objects;
create policy "listing_media_public_read"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'listing-media');

drop policy if exists "listing_media_owner_insert" on storage.objects;
create policy "listing_media_owner_insert"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'listing-media'
  and split_part(name, '/', 1) = auth.uid()::text
);

drop policy if exists "listing_media_owner_update" on storage.objects;
create policy "listing_media_owner_update"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'listing-media'
  and split_part(name, '/', 1) = auth.uid()::text
)
with check (
  bucket_id = 'listing-media'
  and split_part(name, '/', 1) = auth.uid()::text
);

drop policy if exists "listing_media_owner_delete" on storage.objects;
create policy "listing_media_owner_delete"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'listing-media'
  and split_part(name, '/', 1) = auth.uid()::text
);
