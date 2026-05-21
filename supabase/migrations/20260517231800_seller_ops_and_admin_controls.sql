alter table public.sellers
  add column if not exists review_reason_code text,
  add column if not exists review_note text;

insert into storage.buckets (id, name, public)
select 'verification-docs', 'verification-docs', true
where not exists (
  select 1 from storage.buckets where id = 'verification-docs'
);

drop policy if exists "seller verification docs owner insert" on storage.objects;
create policy "seller verification docs owner insert"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'verification-docs'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "seller verification docs owner read" on storage.objects;
create policy "seller verification docs owner read"
on storage.objects for select
to authenticated
using (
  bucket_id = 'verification-docs'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or exists (
      select 1
      from public.profiles p
      where p.id = auth.uid()
        and p.role in ('admin', 'super_admin')
        and p.is_active = true
    )
  )
);

alter table public.reports
  add column if not exists resolution_action text,
  add column if not exists resolution_reason_code text,
  add column if not exists resolution_note text,
  add column if not exists resolved_by uuid references public.profiles(id) on delete set null,
  add column if not exists resolved_at timestamptz;

alter table public.disputes
  add column if not exists resolution_action text,
  add column if not exists resolution_reason_code text,
  add column if not exists resolution_note text,
  add column if not exists resolved_by uuid references public.profiles(id) on delete set null,
  add column if not exists resolved_at timestamptz;

create table if not exists public.admin_invites (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  role text not null check (role in ('admin', 'super_admin')),
  status text not null default 'pending' check (status in ('pending', 'sent', 'accepted', 'revoked')),
  created_by uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.admin_invites enable row level security;

drop policy if exists "super admins read invites" on public.admin_invites;
create policy "super admins read invites"
on public.admin_invites for select
to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and p.role = 'super_admin'
      and p.is_active = true
  )
);

create or replace function public.seller_manage_listing(
  p_listing_id uuid,
  p_action text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner uuid;
  v_status text;
  v_media_count integer;
begin
  perform public._assert_approved_seller();

  select seller_user_id, status
  into v_owner, v_status
  from public.listings
  where id = p_listing_id;

  if v_owner is distinct from auth.uid() then
    raise exception 'listing ownership mismatch';
  end if;

  if p_action = 'pause' then
    update public.listings set status = 'paused', updated_at = now() where id = p_listing_id and status = 'active';
  elsif p_action = 'resume' then
    update public.listings set status = 'active', updated_at = now() where id = p_listing_id and status = 'paused';
  elsif p_action = 'close' then
    update public.listings set status = 'closed', updated_at = now() where id = p_listing_id and status in ('active', 'paused');
  elsif p_action = 'delete_draft' then
    delete from public.listing_media where listing_id = p_listing_id;
    delete from public.listing_fitments where listing_id = p_listing_id;
    delete from public.listings where id = p_listing_id and status = 'draft';
  elsif p_action = 'resubmit' then
    select count(*) into v_media_count from public.listing_media where listing_id = p_listing_id;
    if v_media_count < 2 then
      raise exception 'at least two photos are required for review submission';
    end if;
    update public.listings
    set status = 'pending_review',
        submitted_at = now(),
        rejection_reason = null,
        moderated_at = null,
        moderated_by = null,
        updated_at = now()
    where id = p_listing_id
      and status in ('draft', 'rejected');
  else
    raise exception 'invalid listing action';
  end if;

  return jsonb_build_object('listing_id', p_listing_id, 'action', p_action);
end;
$$;

create or replace function public.admin_resolve_report(
  p_report_id uuid,
  p_decision text,
  p_reason_code text,
  p_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public._assert_admin_user();

  update public.reports
  set status = case when p_decision = 'dismiss' then 'closed' else 'actioned' end,
      resolution_action = p_decision,
      resolution_reason_code = p_reason_code,
      resolution_note = nullif(trim(coalesce(p_note, '')), ''),
      resolved_by = auth.uid(),
      resolved_at = now()
  where id = p_report_id;

  return jsonb_build_object('report_id', p_report_id, 'decision', p_decision);
end;
$$;

create or replace function public.admin_resolve_dispute(
  p_dispute_id uuid,
  p_decision text,
  p_reason_code text,
  p_outcome_action text,
  p_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public._assert_admin_user();

  update public.disputes
  set status = case when p_decision = 'dismiss' then 'dismissed' else 'resolved' end,
      resolution_action = p_outcome_action,
      resolution_reason_code = p_reason_code,
      resolution_note = nullif(trim(coalesce(p_note, '')), ''),
      resolved_by = auth.uid(),
      resolved_at = now()
  where id = p_dispute_id;

  return jsonb_build_object('dispute_id', p_dispute_id, 'decision', p_decision);
end;
$$;

create or replace function public.admin_manage_account(
  p_target_user_id uuid,
  p_action text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_super_admin_count integer;
begin
  perform public._assert_admin_user();

  if not exists (
    select 1 from public.profiles where id = auth.uid() and role = 'super_admin' and is_active = true
  ) then
    raise exception 'super admin privileges required';
  end if;

  if p_action = 'suspend' then
    update public.profiles set is_active = false where id = p_target_user_id;
  elsif p_action = 'reactivate' then
    update public.profiles set is_active = true where id = p_target_user_id;
  elsif p_action = 'promote' then
    update public.profiles set role = 'super_admin' where id = p_target_user_id;
  elsif p_action = 'demote' then
    select count(*) into v_super_admin_count
    from public.profiles
    where role = 'super_admin' and is_active = true;
    if v_super_admin_count <= 1 and exists (
      select 1 from public.profiles where id = p_target_user_id and role = 'super_admin'
    ) then
      raise exception 'at least one super admin must remain active';
    end if;
    update public.profiles set role = 'admin' where id = p_target_user_id;
  else
    raise exception 'invalid admin account action';
  end if;

  return jsonb_build_object('user_id', p_target_user_id, 'action', p_action);
end;
$$;

create or replace function public.admin_create_invite(
  p_email text,
  p_role text
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

  if not exists (
    select 1 from public.profiles where id = auth.uid() and role = 'super_admin' and is_active = true
  ) then
    raise exception 'super admin privileges required';
  end if;

  insert into public.admin_invites (email, role, created_by)
  values (lower(trim(p_email)), p_role, auth.uid())
  returning id into v_id;

  return v_id;
end;
$$;

grant execute on function public.seller_manage_listing(uuid, text) to authenticated;
grant execute on function public.admin_resolve_report(uuid, text, text, text) to authenticated;
grant execute on function public.admin_resolve_dispute(uuid, text, text, text, text) to authenticated;
grant execute on function public.admin_manage_account(uuid, text) to authenticated;
grant execute on function public.admin_create_invite(text, text) to authenticated;
