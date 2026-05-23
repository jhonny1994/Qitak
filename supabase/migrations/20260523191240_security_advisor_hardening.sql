-- Address Supabase security advisor findings without breaking authenticated
-- mobile app workflows that call RPC functions directly.

-- seller_documents contains verification evidence metadata. Sellers can manage
-- their own document rows through their seller application, and admins can read
-- them for review.
drop policy if exists "seller_documents_owner_read" on public.seller_documents;
create policy "seller_documents_owner_read"
on public.seller_documents
for select
to authenticated
using (
  exists (
    select 1
    from public.sellers s
    where s.id = seller_id
      and s.user_id = auth.uid()
  )
);

drop policy if exists "seller_documents_admin_read" on public.seller_documents;
create policy "seller_documents_admin_read"
on public.seller_documents
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

drop policy if exists "seller_documents_owner_insert" on public.seller_documents;
create policy "seller_documents_owner_insert"
on public.seller_documents
for insert
to authenticated
with check (
  exists (
    select 1
    from public.sellers s
    where s.id = seller_id
      and s.user_id = auth.uid()
      and s.verification_status in (
        'not_started',
        'draft',
        'submitted',
        'needs_more_info',
        'rejected'
      )
  )
);

drop policy if exists "seller_documents_owner_delete" on public.seller_documents;
create policy "seller_documents_owner_delete"
on public.seller_documents
for delete
to authenticated
using (
  exists (
    select 1
    from public.sellers s
    where s.id = seller_id
      and s.user_id = auth.uid()
      and s.verification_status in (
        'not_started',
        'draft',
        'submitted',
        'needs_more_info',
        'rejected'
      )
  )
);

-- Public listing media is served by public object URLs. The broad storage
-- SELECT policy lets clients list bucket paths and is unnecessary for serving
-- public assets.
drop policy if exists "listing_media_public_read" on storage.objects;

-- Keep verification documents private and allow sellers to delete replaced
-- files from their own folder during resubmission.
drop policy if exists "seller verification docs owner delete" on storage.objects;
create policy "seller verification docs owner delete"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'verification-docs'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Pin trigger function search_path.
create or replace function public.update_device_tokens_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Trigger/helper functions are not API endpoints. Revoke public and anonymous
-- execution; trigger execution and SECURITY DEFINER internal calls still work.
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public._assert_admin_user() from public, anon, authenticated;
revoke execute on function public._assert_approved_seller() from public, anon, authenticated;

-- Only signed-in users should call app RPCs. The functions perform their own
-- role/ownership checks before mutating data.
revoke execute on function public.admin_create_invite(text, text) from public, anon;
revoke execute on function public.admin_log_conversation_access(uuid, text, text) from public, anon;
revoke execute on function public.admin_manage_account(uuid, text) from public, anon;
revoke execute on function public.admin_resolve_dispute(uuid, text, text, text, text) from public, anon;
revoke execute on function public.admin_resolve_report(uuid, text, text, text) from public, anon;
revoke execute on function public.admin_review_listing(uuid, text, text) from public, anon;
revoke execute on function public.admin_review_seller_application(uuid, text, text, text) from public, anon;
revoke execute on function public.create_deal_intent(uuid, uuid, uuid, text, text) from public, anon;
revoke execute on function public.mark_notification_read(uuid[]) from public, anon;
revoke execute on function public.mark_notification_state(uuid, boolean) from public, anon;
revoke execute on function public.self_deactivate_account() from public, anon;
revoke execute on function public.seller_manage_listing(uuid, text) from public, anon;
revoke execute on function public.seller_submit_listing(jsonb) from public, anon;
revoke execute on function public.seller_submit_listing_for_review(jsonb) from public, anon;
revoke execute on function public.seller_upsert_listing_draft(jsonb) from public, anon;
revoke execute on function public.transition_deal(uuid, text) from public, anon;

grant execute on function public.admin_create_invite(text, text) to authenticated;
grant execute on function public.admin_log_conversation_access(uuid, text, text) to authenticated;
grant execute on function public.admin_manage_account(uuid, text) to authenticated;
grant execute on function public.admin_resolve_dispute(uuid, text, text, text, text) to authenticated;
grant execute on function public.admin_resolve_report(uuid, text, text, text) to authenticated;
grant execute on function public.admin_review_listing(uuid, text, text) to authenticated;
grant execute on function public.admin_review_seller_application(uuid, text, text, text) to authenticated;
grant execute on function public.create_deal_intent(uuid, uuid, uuid, text, text) to authenticated;
grant execute on function public.mark_notification_read(uuid[]) to authenticated;
grant execute on function public.mark_notification_state(uuid, boolean) to authenticated;
grant execute on function public.self_deactivate_account() to authenticated;
grant execute on function public.seller_manage_listing(uuid, text) to authenticated;
grant execute on function public.seller_submit_listing(jsonb) to authenticated;
grant execute on function public.seller_submit_listing_for_review(jsonb) to authenticated;
grant execute on function public.seller_upsert_listing_draft(jsonb) to authenticated;
grant execute on function public.transition_deal(uuid, text) to authenticated;
