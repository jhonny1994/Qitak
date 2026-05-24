-- Phase 3: Consolidate multiple permissive policies for performance

-- LISTINGS (SELECT for authenticated)
drop policy if exists "Anyone can read active listings" on public.listings;
drop policy if exists "Sellers can read own listings (any status)" on public.listings;
drop policy if exists "Admins can read all listings" on public.listings;
drop policy if exists "listings_select_authenticated_consolidated" on public.listings;
create policy "listings_select_authenticated_consolidated"
on public.listings
as permissive
for select
to authenticated
using (
  status = 'active'
  or seller_user_id = (select auth.uid())
  or public.is_admin_actor((select auth.uid()))
);

-- LISTING_MEDIA (SELECT for authenticated)
drop policy if exists "Anyone can read media for active listings" on public.listing_media;
drop policy if exists "Sellers can read own listing media" on public.listing_media;
drop policy if exists "Admins can read all listing media" on public.listing_media;
drop policy if exists "listing_media_select_authenticated_consolidated" on public.listing_media;
create policy "listing_media_select_authenticated_consolidated"
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
        l.status = 'active'
        or l.seller_user_id = (select auth.uid())
        or public.is_admin_actor((select auth.uid()))
      )
  )
);

-- PROFILES (SELECT for authenticated)
drop policy if exists "profiles_self_read" on public.profiles;
drop policy if exists "profiles_admin_read" on public.profiles;
drop policy if exists "profiles_select_authenticated_consolidated" on public.profiles;
create policy "profiles_select_authenticated_consolidated"
on public.profiles
as permissive
for select
to authenticated
using (
  id = (select auth.uid())
  or public.is_admin_actor((select auth.uid()))
);

-- PROFILES (UPDATE for authenticated)
-- Keep self mutable-fields guard in separate policy to avoid signature mismatch risk.
drop policy if exists "profiles_admin_update" on public.profiles;
drop policy if exists "profiles_update_admin_consolidated" on public.profiles;
create policy "profiles_update_admin_consolidated"
on public.profiles
as permissive
for update
to authenticated
using (public.is_admin_actor((select auth.uid())))
with check (public.is_admin_actor((select auth.uid())));

-- SELLER_DOCUMENTS (SELECT for authenticated)
drop policy if exists "seller_documents_owner_read" on public.seller_documents;
drop policy if exists "seller_documents_admin_read" on public.seller_documents;
drop policy if exists "seller_documents_select_authenticated_consolidated" on public.seller_documents;
create policy "seller_documents_select_authenticated_consolidated"
on public.seller_documents
as permissive
for select
to authenticated
using (
  exists (
    select 1
    from public.sellers s
    where s.id = seller_documents.seller_id
      and (
        s.user_id = (select auth.uid())
        or public.is_admin_actor((select auth.uid()))
      )
  )
);

-- SELLERS (SELECT for authenticated)
drop policy if exists "sellers_self_read" on public.sellers;
drop policy if exists "sellers_admin_read" on public.sellers;
drop policy if exists "sellers_select_authenticated_consolidated" on public.sellers;
create policy "sellers_select_authenticated_consolidated"
on public.sellers
as permissive
for select
to authenticated
using (
  user_id = (select auth.uid())
  or public.is_admin_actor((select auth.uid()))
);
