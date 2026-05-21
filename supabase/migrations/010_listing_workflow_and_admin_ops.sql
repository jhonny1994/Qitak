alter table public.listings
  add column if not exists status text,
  add column if not exists submitted_at timestamptz,
  add column if not exists moderated_by uuid references public.profiles(id) on delete set null,
  add column if not exists moderated_at timestamptz,
  add column if not exists rejection_reason text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'listings_status_check'
  ) then
    alter table public.listings
      add constraint listings_status_check
      check (status in ('draft', 'pending_review', 'active', 'paused', 'rejected', 'closed'));
  end if;
end $$;

update public.listings
set status = 'active'
where status is null or status = 'draft';

alter table public.listings
  alter column status set default 'draft';

drop policy if exists "listings_seller_insert" on public.listings;
drop policy if exists "listings_owner_update" on public.listings;
drop policy if exists "listing_fitments_owner_write" on public.listing_fitments;
drop policy if exists "listing_fitments_owner_update" on public.listing_fitments;
drop policy if exists "listing_media_owner_insert" on public.listing_media;
drop policy if exists "listing_media_owner_delete" on public.listing_media;

drop policy if exists "listings_public_read" on public.listings;
create policy "Anyone can read active listings"
on public.listings for select
to anon, authenticated
using (status = 'active');

drop policy if exists "Sellers can read own listings (any status)" on public.listings;
create policy "Sellers can read own listings (any status)"
on public.listings for select
to authenticated
using (seller_user_id = auth.uid());

drop policy if exists "Admins can read all listings" on public.listings;
create policy "Admins can read all listings"
on public.listings for select
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

drop policy if exists "listing_media_public_read" on public.listing_media;
create policy "Anyone can read media for active listings"
on public.listing_media for select
to anon, authenticated
using (
  exists (
    select 1
    from public.listings l
    where l.id = listing_id
      and l.status = 'active'
  )
);

drop policy if exists "Sellers can read own listing media" on public.listing_media;
create policy "Sellers can read own listing media"
on public.listing_media for select
to authenticated
using (
  exists (
    select 1
    from public.listings l
    where l.id = listing_id
      and l.seller_user_id = auth.uid()
  )
);

drop policy if exists "Admins can read all listing media" on public.listing_media;
create policy "Admins can read all listing media"
on public.listing_media for select
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

create table if not exists public.admin_conversation_access_logs (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.conversation_threads(id) on delete cascade,
  admin_user_id uuid not null references public.profiles(id) on delete cascade,
  purpose text not null check (purpose in ('dispute_review', 'abuse_review', 'support_intervention')),
  note text,
  created_at timestamptz not null default now()
);

alter table public.admin_conversation_access_logs enable row level security;

drop policy if exists "Admins can read access logs" on public.admin_conversation_access_logs;
create policy "Admins can read access logs"
on public.admin_conversation_access_logs for select
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

create or replace function public._assert_admin_user()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  if not exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  ) then
    raise exception 'admin privileges required';
  end if;
end;
$$;

create or replace function public._assert_approved_seller()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  if not exists (
    select 1
    from public.profiles p
    join public.sellers s on s.user_id = p.id
    where p.id = auth.uid()
      and p.role = 'seller'
      and p.is_active = true
      and s.verification_status = 'approved'
  ) then
    raise exception 'seller approval required';
  end if;
end;
$$;

create or replace function public.seller_upsert_listing_draft(payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_listing_id uuid;
  v_existing_owner uuid;
  v_seller_id uuid;
  v_media_count integer;
  v_media_item jsonb;
begin
  perform public._assert_approved_seller();

  select s.id
  into v_seller_id
  from public.sellers s
  where s.user_id = auth.uid()
    and s.verification_status = 'approved';

  if v_seller_id is null then
    raise exception 'seller approval required';
  end if;

  v_listing_id := nullif(payload ->> 'listing_id', '')::uuid;
  v_media_count := coalesce(jsonb_array_length(coalesce(payload -> 'media', '[]'::jsonb)), 0);

  if v_media_count < 1 then
    raise exception 'at least one photo is required for draft saves';
  end if;

  if v_listing_id is not null then
    select seller_user_id into v_existing_owner
    from public.listings
    where id = v_listing_id;

    if v_existing_owner is distinct from auth.uid() then
      raise exception 'listing ownership mismatch';
    end if;

    update public.listings
    set title = coalesce(payload ->> 'title', title),
        description = coalesce(payload ->> 'description', description),
        price = coalesce((payload ->> 'price')::numeric, price),
        wilaya_code = payload ->> 'wilaya_code',
        commune_code = payload ->> 'commune_code',
        wilaya_id = coalesce((payload ->> 'wilaya_id')::integer, wilaya_id),
        commune_id = coalesce(payload ->> 'commune_id', commune_id),
        category_id = payload ->> 'category_id',
        condition = coalesce(payload ->> 'condition', condition),
        quantity = coalesce((payload ->> 'quantity')::integer, quantity),
        exchange_enabled = coalesce((payload ->> 'exchange_enabled')::boolean, exchange_enabled),
        exchange_description = nullif(trim(coalesce(payload ->> 'exchange_description', '')), ''),
        brand = coalesce(payload ->> 'brand', brand),
        vehicle_fitment = coalesce(payload -> 'vehicle_fitment', vehicle_fitment),
        fulfillment_mode = coalesce(payload ->> 'fulfillment_mode', fulfillment_mode),
        seller_display_name = coalesce(
          (select full_name from public.profiles where id = auth.uid()),
          seller_display_name
        ),
        status = 'draft',
        submitted_at = null,
        moderated_at = null,
        moderated_by = null,
        rejection_reason = null,
        updated_at = now()
    where id = v_listing_id;
  else
    insert into public.listings (
      seller_user_id,
      seller_id,
      title,
      description,
      price,
      wilaya_code,
      commune_code,
      wilaya_id,
      commune_id,
      category_id,
      condition,
      quantity,
      exchange_enabled,
      exchange_description,
      brand,
      vehicle_fitment,
      fulfillment_mode,
      seller_display_name,
      status,
      submitted_at
    )
    values (
      auth.uid(),
      v_seller_id,
      coalesce(payload ->> 'title', ''),
      coalesce(payload ->> 'description', ''),
      coalesce((payload ->> 'price')::numeric, 0),
      payload ->> 'wilaya_code',
      payload ->> 'commune_code',
      coalesce((payload ->> 'wilaya_id')::integer, nullif(payload ->> 'wilaya_code', '')::integer),
      coalesce(payload ->> 'commune_id', payload ->> 'commune_code'),
      payload ->> 'category_id',
      coalesce(payload ->> 'condition', 'used'),
      coalesce((payload ->> 'quantity')::integer, 1),
      coalesce((payload ->> 'exchange_enabled')::boolean, false),
      nullif(trim(coalesce(payload ->> 'exchange_description', '')), ''),
      coalesce(payload ->> 'brand', ''),
      coalesce(payload -> 'vehicle_fitment', '[]'::jsonb),
      coalesce(payload ->> 'fulfillment_mode', 'pickup'),
      coalesce((select full_name from public.profiles where id = auth.uid()), ''),
      'draft',
      null
    )
    returning id into v_listing_id;
  end if;

  delete from public.listing_fitments where listing_id = v_listing_id;
  delete from public.listing_media where listing_id = v_listing_id;

  insert into public.listing_fitments (
    listing_id,
    brand_code,
    model_code,
    model_year
  )
  values (
    v_listing_id,
    coalesce(payload ->> 'brand_code', ''),
    coalesce(payload ->> 'model_code', ''),
    coalesce((payload ->> 'model_year')::integer, 1950)
  );

  for v_media_item in
    select value
    from jsonb_array_elements(coalesce(payload -> 'media', '[]'::jsonb))
  loop
    insert into public.listing_media (
      listing_id,
      storage_path,
      public_url,
      mime_type,
      sort_order
    )
    values (
      v_listing_id,
      v_media_item ->> 'storage_path',
      v_media_item ->> 'public_url',
      coalesce(v_media_item ->> 'mime_type', 'image/jpeg'),
      coalesce((v_media_item ->> 'sort_order')::integer, 0)
    );
  end loop;

  return jsonb_build_object(
    'listing_id', v_listing_id,
    'status', 'draft'
  );
end;
$$;

create or replace function public.seller_submit_listing(payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_result jsonb;
  v_listing_id uuid;
  v_media_count integer;
  v_requires_review boolean := true;
  v_min_photos integer := 2;
  v_status text := 'pending_review';
begin
  select
    coalesce((policy ->> 'requires_review')::boolean, risk_level <> 'green'),
    greatest(coalesce((policy ->> 'min_photos')::integer, 2), 2)
  into v_requires_review, v_min_photos
  from public.part_categories
  where id = (payload ->> 'category_id')::uuid
    and is_active = true
    and risk_level in ('green', 'yellow');

  if not found then
    raise exception 'listing category is not allowed for submission';
  end if;

  v_media_count := coalesce(jsonb_array_length(coalesce(payload -> 'media', '[]'::jsonb)), 0);
  if v_media_count < v_min_photos then
    raise exception 'at least % photos are required for submission', v_min_photos;
  end if;

  v_result := public.seller_upsert_listing_draft(payload);
  v_listing_id := (v_result ->> 'listing_id')::uuid;
  v_status := case when v_requires_review then 'pending_review' else 'active' end;

  update public.listings
  set status = v_status,
      submitted_at = case when v_requires_review then now() else null end,
      updated_at = now(),
      rejection_reason = null,
      moderated_at = null,
      moderated_by = null
  where id = v_listing_id
    and seller_user_id = auth.uid();

  return jsonb_build_object(
    'listing_id', v_listing_id,
    'status', v_status
  );
end;
$$;

create or replace function public.seller_submit_listing_for_review(payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  return public.seller_submit_listing(payload);
end;
$$;

create or replace function public.admin_review_listing(
  p_listing_id uuid,
  p_decision text,
  p_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_status text;
begin
  perform public._assert_admin_user();

  if p_decision not in ('approve', 'reject') then
    raise exception 'invalid moderation decision';
  end if;

  v_status := case when p_decision = 'approve' then 'active' else 'rejected' end;

  update public.listings
  set status = v_status,
      moderated_by = auth.uid(),
      moderated_at = now(),
      rejection_reason = case when p_decision = 'reject' then nullif(trim(coalesce(p_note, '')), '') else null end,
      updated_at = now()
  where id = p_listing_id;

  return jsonb_build_object(
    'listing_id', p_listing_id,
    'status', v_status
  );
end;
$$;

create or replace function public.admin_log_conversation_access(
  p_thread_id uuid,
  p_purpose text,
  p_note text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  perform public._assert_admin_user();

  insert into public.admin_conversation_access_logs (
    thread_id,
    admin_user_id,
    purpose,
    note
  )
  values (
    p_thread_id,
    auth.uid(),
    p_purpose,
    nullif(trim(coalesce(p_note, '')), '')
  )
  returning id into v_id;

  return v_id;
end;
$$;

grant execute on function public.seller_upsert_listing_draft(jsonb) to authenticated;
grant execute on function public.seller_submit_listing(jsonb) to authenticated;
grant execute on function public.seller_submit_listing_for_review(jsonb) to authenticated;
grant execute on function public.admin_review_listing(uuid, text, text) to authenticated;
grant execute on function public.admin_log_conversation_access(uuid, text, text) to authenticated;
