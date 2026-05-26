-- Convert 5 stable, closed text+CHECK columns to proper Postgres ENUM types.
-- Columns with evolving value sets (deals.status, disputes.status, reports.status,
-- admin_invites.status, listings.status, profiles.language) are intentionally left
-- as text+CHECK because ALTER TYPE ... ADD VALUE is non-transactional DDL.
--
-- After each ALTER COLUMN any function that does:
--   a) comparison:  enum_col = text_variable  → no operator exists → must update signature/body
--   b) assignment:  INSERT/UPDATE enum_col = text_variable → works via PL/pgSQL coercion,
--      but we add explicit ::type casts to make intent unambiguous.
--
-- Affected functions:
--   private.profile_immutable_fields_match  (comparison — signature change required)
--   public.handle_new_user                  (assignment — explicit cast added)
--   public.admin_create_invite              (assignment — explicit cast added)


-- ─── 1. Create enum types ─────────────────────────────────────────────────────

create type public.user_role as enum ('buyer', 'seller', 'admin', 'super_admin');
create type public.seller_type_t as enum ('individual', 'business');
create type public.device_platform as enum ('android', 'ios');
create type public.admin_role as enum ('admin', 'super_admin');
create type public.domain_catalog_type as enum ('invariant_state', 'policy_catalog');


-- ─── 2. Alter columns ─────────────────────────────────────────────────────────
-- Each statement takes an ACCESS EXCLUSIVE lock for the duration of the type cast.
-- At MVP row counts this is sub-millisecond. The inline CHECK constraint defined in
-- CREATE TABLE is dropped implicitly when the column type changes.
--
-- profiles.role has 12 dependent RLS policies across public and storage schemas.
-- Postgres refuses ALTER COLUMN while those policies exist.
-- Pattern: ARRAY['admin'::text, ...] → ARRAY['admin', 'super_admin']::public.user_role[]
--          'super_admin'::text       → 'super_admin'::public.user_role
--          'buyer'::text             → 'buyer'::public.user_role

drop policy if exists "Admins can read access logs"                      on public.admin_conversation_access_logs;
drop policy if exists "super admins read invites"                         on public.admin_invites;
drop policy if exists "Conversation participants can read conversations"  on public.conversations;
drop policy if exists "Deal participants can read deal events"            on public.deal_events;
drop policy if exists "Deal participants can read"                        on public.deals;
drop policy if exists "Dispute participants can read evidence"            on public.dispute_evidence;
drop policy if exists "Deal participants can read disputes"               on public.disputes;
drop policy if exists "Conversation participants can read messages"       on public.messages;
drop policy if exists "Buyer can create own listing reports"             on public.reports;
drop policy if exists "Reporter can read own reports"                    on public.reports;
drop policy if exists "dispute evidence owner read"                      on storage.objects;
drop policy if exists "seller verification docs owner read"              on storage.objects;
drop policy if exists "profiles_self_insert"                             on public.profiles;
drop policy if exists "profiles_update_consolidated"                     on public.profiles;

-- Drop CHECK constraints on the 5 target columns before ALTER COLUMN.
-- The ENUM type itself enforces the same value-set invariant; the CHECK is redundant.
alter table public.profiles         drop constraint if exists profiles_role_check;
alter table public.sellers          drop constraint if exists sellers_seller_type_check;
alter table public.device_tokens    drop constraint if exists device_tokens_platform_check;
alter table public.admin_invites    drop constraint if exists admin_invites_role_check;
alter table public.app_domain_catalog drop constraint if exists app_domain_catalog_domain_type_check;

alter table public.profiles
  alter column role type public.user_role using role::public.user_role;

alter table public.sellers
  alter column seller_type type public.seller_type_t using seller_type::public.seller_type_t;

alter table public.device_tokens
  alter column platform type public.device_platform using platform::public.device_platform;

alter table public.admin_invites
  alter column role type public.admin_role using role::public.admin_role;

-- The view app_domain_contracts selects domain_type; must drop before ALTER COLUMN.
drop view if exists public.app_domain_contracts;

alter table public.app_domain_catalog
  alter column domain_type type public.domain_catalog_type using domain_type::public.domain_catalog_type;

-- Recreate the view; cast domain_type back to text to keep the published column type stable.
create or replace view public.app_domain_contracts as
  select
    c.domain_key,
    c.domain_type::text as domain_type,
    d.code,
    d.sort_order,
    d.metadata
  from public.app_domain_catalog c
  join public.app_domain_codes   d on d.domain_key = c.domain_key
  where c.is_active = true
    and d.is_active = true;


-- ─── 3. Fix private.profile_immutable_fields_match ────────────────────────────
-- The old signature takes expected_role text and does: where role = expected_role
-- After profiles.role becomes user_role, the expression "user_role = text" has no
-- operator and would raise: ERROR: operator does not exist: user_role = text
-- Fix: change the parameter type to user_role. Callers pass NEW.role (now user_role)
-- which is a direct type match. Enum→text implicit cast means any existing callers
-- passing a text literal still work.
-- Must drop the old signature first because Postgres treats different arg types as
-- distinct function overloads.

drop function if exists private.profile_immutable_fields_match(uuid, text, text, boolean);

create or replace function private.profile_immutable_fields_match(
  target_user_id    uuid,
  expected_role     public.user_role,
  expected_email    text,
  expected_is_active boolean
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id             = target_user_id
      and role           = expected_role
      and email          = expected_email
      and is_active      = expected_is_active
  );
$$;

revoke all   on function private.profile_immutable_fields_match(uuid, public.user_role, text, boolean) from public;
grant execute on function private.profile_immutable_fields_match(uuid, public.user_role, text, boolean) to authenticated;
grant execute on function private.profile_immutable_fields_match(uuid, public.user_role, text, boolean) to service_role;


-- ─── 4. Fix handle_new_user ───────────────────────────────────────────────────
-- v_role was declared as text; now declared as user_role so the INSERT is type-safe
-- without needing a cast at the call site. The CASE branches use ::user_role casts
-- on the string literals to make the assignment unambiguous.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_full_name text;
  v_phone     text;
  v_role      public.user_role;
  v_language  text;
begin
  v_full_name := nullif(trim(coalesce(new.raw_user_meta_data->>'full_name', '')), '');
  v_phone     := nullif(trim(coalesce(new.raw_user_meta_data->>'phone', '')), '');
  v_role      := case
    when new.raw_user_meta_data->>'role' = 'seller' then 'seller'::public.user_role
    else 'buyer'::public.user_role
  end;
  v_language  := case
    when new.raw_user_meta_data->>'language' in ('ar', 'en', 'fr')
      then new.raw_user_meta_data->>'language'
    else 'ar'
  end;

  insert into public.profiles (
    id, email, full_name, phone, role, language, is_active
  )
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(v_full_name, split_part(coalesce(new.email, 'user'), '@', 1)),
    coalesce(v_phone, '-'),
    v_role,
    v_language,
    true
  )
  on conflict (id) do nothing;

  return new;
end;
$$;


-- ─── 5. Fix admin_create_invite ───────────────────────────────────────────────
-- p_role text is passed by callers as a runtime string. Add an explicit ::admin_role
-- cast at the INSERT so Postgres does not rely on implicit coercion in PL/pgSQL.
-- The WHERE clause comparison "role = 'super_admin'" uses a string literal (unknown
-- type) which Postgres implicitly casts to user_role → no change needed there.

create or replace function public.admin_create_invite(p_email text, p_role text)
returns uuid
language plpgsql
security definer
set search_path = 'public'
as $$
declare
  v_id uuid;
begin
  perform public._assert_admin_user();

  if not exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'super_admin'::public.user_role
      and is_active = true
  ) then
    raise exception 'super admin privileges required';
  end if;

  insert into public.admin_invites (email, role, created_by)
  values (lower(trim(p_email)), p_role::public.admin_role, auth.uid())
  returning id into v_id;

  return v_id;
end;
$$;


-- ─── 6. Recreate the 12 policies that depended on profiles.role ──────────────
-- Only the type cast changes: 'value'::text → 'value'::public.user_role
-- and ARRAY[...]::text[] → ARRAY[...]::public.user_role[]
-- All other logic (subquery structure, is_active checks) is preserved verbatim.

create policy "Admins can read access logs"
  on public.admin_conversation_access_logs for select
  using (
    exists (
      select 1 from profiles p
      where p.id = (select auth.uid())
        and p.role = any (array['admin', 'super_admin']::public.user_role[])
        and p.is_active = true
    )
  );

create policy "super admins read invites"
  on public.admin_invites for select
  using (
    exists (
      select 1 from profiles p
      where p.id = (select auth.uid())
        and p.role = 'super_admin'::public.user_role
        and p.is_active = true
    )
  );

create policy "Conversation participants can read conversations"
  on public.conversations for select
  using (
    buyer_id  = (select auth.uid())
    or seller_id = (select auth.uid())
    or exists (
      select 1 from profiles
      where profiles.id   = (select auth.uid())
        and profiles.role = any (array['admin', 'super_admin']::public.user_role[])
    )
  );

create policy "Deal participants can read deal events"
  on public.deal_events for select
  using (
    deal_id in (
      select deals.id from deals
      where deals.buyer_id  = (select auth.uid())
         or deals.seller_id = (select auth.uid())
    )
    or exists (
      select 1 from profiles
      where profiles.id   = (select auth.uid())
        and profiles.role = any (array['admin', 'super_admin']::public.user_role[])
    )
  );

create policy "Deal participants can read"
  on public.deals for select
  using (
    buyer_id  = (select auth.uid())
    or seller_id = (select auth.uid())
    or exists (
      select 1 from profiles
      where profiles.id   = (select auth.uid())
        and profiles.role = any (array['admin', 'super_admin']::public.user_role[])
    )
  );

create policy "Dispute participants can read evidence"
  on public.dispute_evidence for select
  using (
    exists (
      select 1
      from disputes d
      join deals deal on deal.id = d.deal_id
      where d.id = dispute_evidence.dispute_id
        and (
          deal.buyer_id  = (select auth.uid())
          or deal.seller_id = (select auth.uid())
          or exists (
            select 1 from profiles p
            where p.id     = (select auth.uid())
              and p.role   = any (array['admin', 'super_admin']::public.user_role[])
              and p.is_active = true
          )
        )
    )
  );

create policy "Deal participants can read disputes"
  on public.disputes for select
  using (
    deal_id in (
      select deals.id from deals
      where deals.buyer_id  = (select auth.uid())
         or deals.seller_id = (select auth.uid())
    )
    or exists (
      select 1 from profiles
      where profiles.id   = (select auth.uid())
        and profiles.role = any (array['admin', 'super_admin']::public.user_role[])
    )
  );

create policy "Conversation participants can read messages"
  on public.messages for select
  using (
    conversation_id in (
      select conversations.id from conversations
      where conversations.buyer_id  = (select auth.uid())
         or conversations.seller_id = (select auth.uid())
    )
    or exists (
      select 1 from profiles
      where profiles.id   = (select auth.uid())
        and profiles.role = any (array['admin', 'super_admin']::public.user_role[])
    )
  );

create policy "Buyer can create own listing reports"
  on public.reports for insert
  with check (
    reporter_id = (select auth.uid())
    and reported_entity_type = 'listing'
    and exists (
      select 1 from profiles p
      where p.id        = (select auth.uid())
        and p.role      = 'buyer'::public.user_role
        and p.is_active = true
    )
    and exists (
      select 1 from listings l
      where l.id             = reports.reported_entity_id
        and l.seller_user_id <> (select auth.uid())
    )
  );

create policy "Reporter can read own reports"
  on public.reports for select
  using (
    reporter_id = (select auth.uid())
    or exists (
      select 1 from profiles
      where profiles.id   = (select auth.uid())
        and profiles.role = any (array['admin', 'super_admin']::public.user_role[])
    )
  );

create policy "dispute evidence owner read"
  on storage.objects for select
  using (
    bucket_id = 'dispute-evidence'
    and (
      (auth.uid())::text = (storage.foldername(name))[1]
      or exists (
        select 1 from public.profiles p
        where p.id        = auth.uid()
          and p.role      = any (array['admin', 'super_admin']::public.user_role[])
          and p.is_active = true
      )
    )
  );

create policy "seller verification docs owner read"
  on storage.objects for select
  using (
    bucket_id = 'verification-docs'
    and (
      (storage.foldername(name))[1] = (auth.uid())::text
      or exists (
        select 1 from public.profiles p
        where p.id        = auth.uid()
          and p.role      = any (array['admin', 'super_admin']::public.user_role[])
          and p.is_active = true
      )
    )
  );

create policy "profiles_self_insert"
  on public.profiles for insert
  with check (
    (select auth.uid()) = id
    and role = any (array['buyer', 'seller']::public.user_role[])
    and is_active = true
  );

create policy "profiles_update_consolidated"
  on public.profiles for update
  using (
    (select auth.uid()) = id
    or is_admin_actor((select auth.uid()))
  )
  with check (
    ((select auth.uid()) = id and private.profile_immutable_fields_match((select auth.uid()), role, email, is_active))
    or is_admin_actor((select auth.uid()))
  );
