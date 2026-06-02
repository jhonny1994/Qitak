-- =============================================================================
-- MIGRATION: Convert sellers.verification_status from text+CHECK to a Postgres
--           ENUM type, and align dependent policies/RPCs/functions.
-- Date: 2026-06-01
-- Linter: domain-contracts-must-be-typed (motivating gap from 005)
--
-- Problem
--   sellers.verification_status is text with a CHECK constraint listing the
--   7 valid values. The same value set is replicated in
--   app_domain_codes under domain_key='seller_verification_status' as a soft
--   contract. A typo or an out-of-set value passes through the DB layer
--   silently until the application layer hits a missing contract row.
--
-- Fix
--   Promote the closed value set to a real Postgres ENUM so the DB itself
--   rejects any value that is not one of the 7. The app_domain_codes catalog
--   is retained as the display layer (label_key, sort_order, metadata) —
--   it is intentionally separate from the storage invariant.
--
-- Pattern followed
--   supabase/migrations/20260526130000_enum_type_conversion.sql — the prior
--   conversion of profiles.role / sellers.seller_type / device_tokens.platform
--   / admin_invites.role / app_domain_catalog.domain_type. Same shape:
--     1. Create the enum type.
--     2. Drop any RLS policy that compares the column against text literals.
--     3. Drop the inline CHECK (auto-dropped by ALTER TYPE, but explicit
--        drop keeps the migration idempotent on re-run).
--     4. ALTER COLUMN ... TYPE ... USING <col>::<enum_type>.
--     5. Re-set the DEFAULT with an explicit enum cast so the default is
--        enum-typed rather than a text literal glued onto an enum column.
--     6. Recreate the dropped RLS policies with explicit enum-array casts.
--     7. Update every PL/pgSQL function body that assigns to or compares
--        against the column with explicit enum casts, so PL/pgSQL variable
--        assignment + intent are both unambiguous.
--
-- Affected policies
--   public.sellers            : sellers_self_update_before_approval
--   public.seller_documents   : seller_documents_owner_insert
--   public.seller_documents   : seller_documents_owner_delete
--
-- Affected functions
--   public.admin_review_seller_application  : UPDATE assignment + guard array
--   public._assert_approved_seller          : SELECT comparison
--   public.seller_upsert_listing_draft      : SELECT comparison
--
-- Not affected
--   public.app_domain_contracts view and the 7 rows under
--   domain_key='seller_verification_status' — these are the display layer and
--   are intentionally retained alongside the enum.
-- =============================================================================


-- ─── 1. Create the enum type ──────────────────────────────────────────────────

create type public.seller_verification_status as enum (
  'not_started',
  'draft',
  'submitted',
  'needs_more_info',
  'approved',
  'rejected',
  'suspended'
);


-- ─── 2. Drop policies that reference the column ──────────────────────────────
-- ALTER COLUMN ... TYPE takes an ACCESS EXCLUSIVE lock and Postgres refuses
-- it while RLS policies reference the column. Drop these up front and
-- recreate at the end of the migration.

drop policy if exists "sellers_self_update_before_approval" on public.sellers;
drop policy if exists "seller_documents_owner_insert"        on public.seller_documents;
drop policy if exists "seller_documents_owner_delete"        on public.seller_documents;


-- ─── 3. Drop the inline CHECK constraint ──────────────────────────────────────
-- ALTER TYPE drops the auto-generated CHECK implicitly, but an explicit drop
-- keeps the migration safe to re-run and matches the pattern in
-- 20260526130000_enum_type_conversion.sql.

alter table public.sellers
  drop constraint if exists sellers_verification_status_check;


-- ─── 4. Convert the column to the enum type ──────────────────────────────────
-- All 7 existing text values map 1:1 to enum members — no data movement.
-- The USING clause is required because there is no implicit text→enum cast
-- in ALTER COLUMN context.
--
-- The column carries a DEFAULT 'not_started' (text) from
-- 006_seller_verification_core.sql:11-12. Postgres refuses to implicitly
-- coerce a text default while switching the column to an enum type, so we
-- drop the default first, perform the type change, and re-cast the default
-- in step 5.

alter table public.sellers
  alter column verification_status drop default;

alter table public.sellers
  alter column verification_status
    type public.seller_verification_status
    using verification_status::public.seller_verification_status;


-- ─── 5. Re-cast the column default with an explicit enum literal ─────────────
-- Without this, the default remains the bare text literal 'not_started' which
-- Postgres then implicitly coerces on every insert. Setting it as an enum
-- literal makes the type intent obvious in \d output and pg_dump.

alter table public.sellers
  alter column verification_status
    set default 'not_started'::public.seller_verification_status;


-- ─── 6. Recreate the 3 dropped RLS policies with explicit enum casts ─────────
-- 'value'::text → 'value'::public.seller_verification_status
-- ARRAY[...]    → ARRAY[...]::public.seller_verification_status[]
-- All other logic (subquery structure, is_active checks) is preserved verbatim
-- from the originals in 006_seller_verification_core.sql:59-68 and
-- 20260523191240_security_advisor_hardening.sql:36-76.

create policy "sellers_self_update_before_approval"
  on public.sellers for update
  to authenticated
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and verification_status = any (
      array['draft', 'submitted', 'needs_more_info', 'rejected']::public.seller_verification_status[]
    )
  );

create policy "seller_documents_owner_insert"
  on public.seller_documents for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.sellers s
      where s.id = seller_id
        and s.user_id = auth.uid()
        and s.verification_status = any (
          array['not_started', 'draft', 'submitted', 'needs_more_info', 'rejected']::public.seller_verification_status[]
        )
    )
  );

create policy "seller_documents_owner_delete"
  on public.seller_documents for delete
  to authenticated
  using (
    exists (
      select 1
      from public.sellers s
      where s.id = seller_id
        and s.user_id = auth.uid()
        and s.verification_status = any (
          array['not_started', 'draft', 'submitted', 'needs_more_info', 'rejected']::public.seller_verification_status[]
        )
    )
  );


-- ─── 7. Update admin_review_seller_application RPC ───────────────────────────
-- The p_status parameter is text (unchanged signature for backward
-- compatibility with existing callers). Internally we now:
--   (a) guard against invalid input with an explicit enum-array cast on the
--       RHS of the NOT IN check (clearer intent, matches the prior migration),
--   (b) cast the text variable to the enum when assigning to the column
--       (PL/pgSQL does NOT auto-coerce text→enum on UPDATE assignment).
-- The verified_at case-expression compares p_status (text) against a text
-- literal 'approved' — that comparison is text=text and needs no cast.

create or replace function public.admin_review_seller_application(
  p_application_id uuid,
  p_status text,
  p_reason_code text default null,
  p_note text default null
)
returns public.sellers
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.sellers%rowtype;
begin
  perform public._assert_admin_user();

  if p_status not in ('approved', 'needs_more_info', 'rejected') then
    raise exception 'invalid seller verification status';
  end if;

  if p_status in ('needs_more_info', 'rejected')
     and nullif(trim(coalesce(p_reason_code, '')), '') is null then
    raise exception 'reason code required';
  end if;

  update public.sellers
  set verification_status = p_status::public.seller_verification_status,
      review_reason_code = nullif(trim(coalesce(p_reason_code, '')), ''),
      review_note = nullif(trim(coalesce(p_note, '')), ''),
      verified_at = case when p_status = 'approved' then now() else null end,
      updated_at = now()
  where id = p_application_id
  returning * into v_row;

  if v_row.id is null then
    raise exception 'seller application not found';
  end if;

  return v_row;
end;
$$;

grant execute on function public.admin_review_seller_application(uuid, text, text, text) to authenticated;


-- ─── 8. Update _assert_approved_seller ───────────────────────────────────────
-- The 'approved' literal on the RHS of the = comparison would coerce to enum
-- implicitly in expression context, but an explicit cast makes intent
-- unambiguous and matches the pattern in
-- 20260526130000_enum_type_conversion.sql.

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
      and s.verification_status = 'approved'::public.seller_verification_status
  ) then
    raise exception 'seller approval required';
  end if;
end;
$$;


-- ─── 9. Update seller_upsert_listing_draft ───────────────────────────────────
-- Same explicit cast on the 'approved' literal comparison inside the
-- SELECT that resolves the seller_id.

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
    and s.verification_status = 'approved'::public.seller_verification_status;

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

grant execute on function public.seller_upsert_listing_draft(jsonb) to authenticated;
