drop policy if exists listings_select_authenticated_consolidated on public.listings;
drop policy if exists listings_select_public_consolidated on public.listings;
drop policy if exists listings_select_public_active on public.listings;
drop policy if exists listings_select_authenticated_owner_admin on public.listings;

create policy listings_select_public_active
on public.listings
as permissive
for select
to anon, authenticated
using (
  status = 'active'
  and coalesce(is_available, true) = true
);

create policy listings_select_authenticated_owner_admin
on public.listings
as permissive
for select
to authenticated
using (
  seller_user_id = (select auth.uid())
  or public.is_admin_actor((select auth.uid()))
);

drop policy if exists listing_media_select_authenticated_consolidated on public.listing_media;
drop policy if exists listing_media_select_public_consolidated on public.listing_media;
drop policy if exists listing_media_select_public_active on public.listing_media;
drop policy if exists listing_media_select_authenticated_owner_admin on public.listing_media;

create policy listing_media_select_public_active
on public.listing_media
as permissive
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.listings l
    where l.id = listing_media.listing_id
      and l.status = 'active'
      and coalesce(l.is_available, true) = true
  )
);

create policy listing_media_select_authenticated_owner_admin
on public.listing_media
as permissive
for select
to authenticated
using (
  exists (
    select 1
    from public.listings l
    where l.id = listing_media.listing_id
      and (
        l.seller_user_id = (select auth.uid())
        or public.is_admin_actor((select auth.uid()))
      )
  )
);
