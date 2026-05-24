-- Phase 4: Add covering indexes for advisor-flagged foreign keys
-- Safe, idempotent index creation

create index if not exists idx_admin_conv_access_logs_admin_user_id
  on public.admin_conversation_access_logs(admin_user_id);

create index if not exists idx_admin_conv_access_logs_conversation_id
  on public.admin_conversation_access_logs(conversation_id);

create index if not exists idx_admin_invites_created_by
  on public.admin_invites(created_by);

create index if not exists idx_conversations_buyer_id
  on public.conversations(buyer_id);

create index if not exists idx_conversations_seller_id
  on public.conversations(seller_id);

create index if not exists idx_deal_events_actor_id
  on public.deal_events(actor_id);

create index if not exists idx_deal_events_deal_id
  on public.deal_events(deal_id);

create index if not exists idx_deals_cancelled_by
  on public.deals(cancelled_by);

create index if not exists idx_dispute_evidence_uploaded_by
  on public.dispute_evidence(uploaded_by);

create index if not exists idx_disputes_filed_by
  on public.disputes(filed_by);

create index if not exists idx_disputes_resolved_by
  on public.disputes(resolved_by);

create index if not exists idx_listings_moderated_by
  on public.listings(moderated_by);

create index if not exists idx_listings_seller_user_id
  on public.listings(seller_user_id);

create index if not exists idx_messages_sender_id
  on public.messages(sender_id);

create index if not exists idx_part_categories_parent_id
  on public.part_categories(parent_id);

create index if not exists idx_reports_reporter_id
  on public.reports(reporter_id);

create index if not exists idx_reports_resolved_by
  on public.reports(resolved_by);

create index if not exists idx_reports_reviewed_by
  on public.reports(reviewed_by);

create index if not exists idx_saved_listings_listing_id
  on public.saved_listings(listing_id);

create index if not exists idx_seller_documents_seller_id
  on public.seller_documents(seller_id);

create index if not exists idx_seller_reviews_buyer_id
  on public.seller_reviews(buyer_id);
