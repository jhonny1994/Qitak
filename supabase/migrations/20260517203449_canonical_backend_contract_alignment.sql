create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  buyer_id uuid not null references public.profiles(id) on delete cascade,
  seller_id uuid not null references public.profiles(id) on delete cascade,
  last_message_at timestamptz,
  created_at timestamptz not null default now(),
  unique (listing_id, buyer_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  content text not null,
  media_url text,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_messages_conversation
on public.messages (conversation_id, created_at);

create table if not exists public.deals (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  buyer_id uuid not null references public.profiles(id) on delete cascade,
  seller_id uuid not null references public.profiles(id) on delete cascade,
  deal_type text not null default 'buy'
    check (deal_type in ('buy', 'exchange')),
  status text not null default 'intent_created'
    check (
      status in (
        'intent_created',
        'pending_seller_response',
        'seller_confirmed',
        'expired',
        'cancelled',
        'completed',
        'dispute_opened',
        'dispute_resolved'
      )
    ),
  exchange_offer text,
  expires_at timestamptz not null default (now() + interval '24 hours'),
  confirmed_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  cancelled_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_deals_listing on public.deals (listing_id);
create index if not exists idx_deals_buyer on public.deals (buyer_id);
create index if not exists idx_deals_seller on public.deals (seller_id);
create index if not exists idx_deals_status on public.deals (status);
create unique index if not exists idx_one_active_deal_per_listing
on public.deals (listing_id)
where status in ('intent_created', 'pending_seller_response', 'seller_confirmed');

create table if not exists public.deal_events (
  id uuid primary key default gen_random_uuid(),
  deal_id uuid not null references public.deals(id) on delete cascade,
  event_type text not null,
  actor_id uuid references public.profiles(id),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.disputes (
  id uuid primary key default gen_random_uuid(),
  deal_id uuid not null unique references public.deals(id) on delete cascade,
  filed_by uuid not null references public.profiles(id),
  dispute_type text not null
    check (
      dispute_type in (
        'wrong_part',
        'condition_misrepresented',
        'not_received',
        'seller_unresponsive',
        'other'
      )
    ),
  description text not null,
  status text not null default 'open'
    check (status in ('open', 'under_review', 'resolved_buyer', 'resolved_seller', 'dismissed')),
  resolved_by uuid references public.profiles(id),
  resolution_notes text,
  resolution_reason_code text,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reported_entity_type text not null
    check (reported_entity_type in ('listing', 'seller', 'message')),
  reported_entity_id uuid not null,
  report_type text not null,
  description text,
  status text not null default 'open'
    check (status in ('open', 'under_review', 'actioned', 'dismissed')),
  reviewed_by uuid references public.profiles(id),
  resolution_notes text,
  resolution_reason_code text,
  resolved_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type text not null,
  data jsonb not null default '{}'::jsonb,
  is_read boolean not null default false,
  push_sent boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_notifications_user
on public.notifications (user_id, created_at desc);
create index if not exists idx_notifications_unread
on public.notifications (user_id)
where is_read = false;

create table if not exists public.notification_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  push_messages_enabled boolean not null default true,
  push_deal_updates_enabled boolean not null default true,
  push_saved_listing_updates_enabled boolean not null default true,
  email_account_updates_enabled boolean not null default true,
  email_deal_updates_enabled boolean not null default true,
  quiet_hours_start time,
  quiet_hours_end time,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.seller_reviews (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.sellers(id) on delete cascade,
  deal_id uuid not null unique references public.deals(id) on delete cascade,
  buyer_id uuid not null references public.profiles(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now()
);

create index if not exists idx_seller_reviews_seller
on public.seller_reviews (seller_id, created_at desc);

insert into public.conversations (id, listing_id, buyer_id, seller_id, created_at)
select
  t.id,
  t.listing_id,
  t.buyer_user_id,
  t.seller_user_id,
  t.created_at
from public.conversation_threads t
on conflict (id) do nothing;

insert into public.messages (id, conversation_id, sender_id, content, created_at)
select
  m.id,
  m.thread_id,
  m.sender_user_id,
  m.body,
  m.created_at
from public.conversation_messages m
on conflict (id) do nothing;

update public.conversations c
set last_message_at = latest.created_at
from (
  select conversation_id, max(created_at) as created_at
  from public.messages
  group by conversation_id
) latest
where latest.conversation_id = c.id
  and (c.last_message_at is null or c.last_message_at <> latest.created_at);

insert into public.deals (
  id,
  listing_id,
  buyer_id,
  seller_id,
  deal_type,
  status,
  expires_at,
  confirmed_at,
  completed_at,
  cancelled_at,
  created_at,
  updated_at
)
select
  r.id,
  r.listing_id,
  r.buyer_user_id,
  r.seller_user_id,
  'buy',
  case r.state
    when 'requested' then 'pending_seller_response'
    when 'accepted' then 'seller_confirmed'
    when 'completed' then 'completed'
    when 'cancelled' then 'cancelled'
    when 'rejected' then 'cancelled'
    else 'intent_created'
  end,
  coalesce(r.created_at + interval '24 hours', now() + interval '24 hours'),
  case when r.state in ('accepted', 'completed') then r.updated_at end,
  case when r.state = 'completed' then r.updated_at end,
  case when r.state in ('cancelled', 'rejected') then r.updated_at end,
  r.created_at,
  r.updated_at
from public.transaction_records r
on conflict (id) do nothing;

insert into public.deal_events (deal_id, event_type, actor_id, metadata, created_at)
select
  d.id,
  case d.status
    when 'pending_seller_response' then 'intent_created'
    when 'seller_confirmed' then 'seller_confirmed'
    when 'completed' then 'completed'
    when 'cancelled' then 'cancelled'
    else 'migrated'
  end,
  null,
  jsonb_build_object('source', 'transaction_records_migration'),
  d.created_at
from public.deals d
on conflict do nothing;

insert into public.disputes (
  id,
  deal_id,
  filed_by,
  dispute_type,
  description,
  status,
  resolution_notes,
  created_at,
  updated_at
)
select
  d.id,
  d.transaction_id,
  d.created_by_user_id,
  case d.reason
    when 'wrong_part' then 'wrong_part'
    when 'condition_misrepresented' then 'condition_misrepresented'
    when 'not_received' then 'not_received'
    when 'seller_unresponsive' then 'seller_unresponsive'
    else 'other'
  end,
  d.description,
  case d.status
    when 'open' then 'open'
    when 'reviewing' then 'under_review'
    when 'resolved' then 'dismissed'
    when 'dismissed' then 'dismissed'
    else 'open'
  end,
  case
    when d.status = 'resolved'
      then 'Migrated from legacy dispute record without outcome fidelity.'
    else null
  end,
  d.created_at,
  d.updated_at
from public.transaction_disputes d
join public.deals deal on deal.id = d.transaction_id
on conflict (id) do nothing;

insert into public.reports (
  id,
  reporter_id,
  reported_entity_type,
  reported_entity_id,
  report_type,
  description,
  status,
  created_at
)
select
  r.id,
  r.reporter_user_id,
  r.entity_type,
  case
    when r.entity_id ~* '^[0-9a-f-]{36}$' then r.entity_id::uuid
    else '00000000-0000-0000-0000-000000000000'::uuid
  end,
  r.reason,
  r.description,
  case r.status
    when 'open' then 'open'
    when 'reviewing' then 'under_review'
    when 'resolved' then 'actioned'
    when 'dismissed' then 'dismissed'
    else 'open'
  end,
  r.created_at
from public.user_reports r
where r.entity_id ~* '^[0-9a-f-]{36}$'
on conflict (id) do nothing;

insert into public.notifications (id, user_id, type, data, is_read, created_at)
select
  gen_random_uuid(),
  case
    when m.sender_user_id = t.buyer_user_id then t.seller_user_id
    else t.buyer_user_id
  end as user_id,
  'message_received',
  jsonb_build_object(
    'conversation_id', t.id,
    'listing_id', t.listing_id,
    'message_id', m.id,
    'deep_link', '/messages/thread/' || t.id
  ),
  exists (
    select 1
    from public.notification_reads nr
    where nr.user_id = case
        when m.sender_user_id = t.buyer_user_id then t.seller_user_id
        else t.buyer_user_id
      end
      and nr.source_type = 'message'
      and nr.source_id = m.id::text
  ),
  m.created_at
from public.conversation_messages m
join public.conversation_threads t on t.id = m.thread_id
where m.sender_user_id <> t.buyer_user_id
   or m.sender_user_id <> t.seller_user_id;

insert into public.seller_reviews (id, seller_id, deal_id, buyer_id, rating, comment, created_at)
select
  r.id,
  s.id,
  r.transaction_id,
  r.from_user_id,
  r.score,
  r.comment,
  r.created_at
from public.transaction_ratings r
join public.sellers s on s.user_id = r.to_user_id
join public.deals d on d.id = r.transaction_id
on conflict (id) do nothing;

alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.deals enable row level security;
alter table public.deal_events enable row level security;
alter table public.disputes enable row level security;
alter table public.reports enable row level security;
alter table public.notifications enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.seller_reviews enable row level security;

drop policy if exists "Conversation participants can read conversations" on public.conversations;
create policy "Conversation participants can read conversations"
  on public.conversations for select
  using (
    buyer_id = auth.uid() or seller_id = auth.uid()
    or exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'super_admin')
    )
  );

drop policy if exists "Buyer can create listing-anchored conversation" on public.conversations;
create policy "Buyer can create listing-anchored conversation"
  on public.conversations for insert
  with check (buyer_id = auth.uid());

drop policy if exists "Conversation participants can read messages" on public.messages;
create policy "Conversation participants can read messages"
  on public.messages for select
  using (
    conversation_id in (
      select id from public.conversations
      where buyer_id = auth.uid() or seller_id = auth.uid()
    )
    or exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'super_admin')
    )
  );

drop policy if exists "Conversation participants can send messages" on public.messages;
create policy "Conversation participants can send messages"
  on public.messages for insert
  with check (
    sender_id = auth.uid()
    and conversation_id in (
      select id from public.conversations
      where buyer_id = auth.uid() or seller_id = auth.uid()
    )
  );

drop policy if exists "Deal participants can read" on public.deals;
create policy "Deal participants can read"
  on public.deals for select
  using (
    buyer_id = auth.uid() or seller_id = auth.uid()
    or exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'super_admin')
    )
  );

drop policy if exists "Buyer can create deal intent" on public.deals;
create policy "Buyer can create deal intent"
  on public.deals for insert
  with check (buyer_id = auth.uid());

drop policy if exists "Deal participants can read deal events" on public.deal_events;
create policy "Deal participants can read deal events"
  on public.deal_events for select
  using (
    deal_id in (
      select id from public.deals
      where buyer_id = auth.uid() or seller_id = auth.uid()
    )
    or exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'super_admin')
    )
  );

drop policy if exists "Deal participants can read disputes" on public.disputes;
create policy "Deal participants can read disputes"
  on public.disputes for select
  using (
    deal_id in (
      select id from public.deals
      where buyer_id = auth.uid() or seller_id = auth.uid()
    )
    or exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'super_admin')
    )
  );

drop policy if exists "Buyer can create dispute for own deal" on public.disputes;
create policy "Buyer can create dispute for own deal"
  on public.disputes for insert
  with check (
    filed_by = auth.uid()
    and deal_id in (
      select id from public.deals
      where buyer_id = auth.uid()
        and status in ('seller_confirmed', 'completed', 'dispute_opened')
    )
  );

drop policy if exists "Reporter can read own reports" on public.reports;
create policy "Reporter can read own reports"
  on public.reports for select
  using (
    reporter_id = auth.uid()
    or exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('admin', 'super_admin')
    )
  );

drop policy if exists "Reporter can create own reports" on public.reports;
create policy "Reporter can create own reports"
  on public.reports for insert
  with check (reporter_id = auth.uid());

drop policy if exists "Users can read own notifications" on public.notifications;
create policy "Users can read own notifications"
  on public.notifications for select
  using (user_id = auth.uid());

drop policy if exists "Users can read own notification preferences" on public.notification_preferences;
create policy "Users can read own notification preferences"
  on public.notification_preferences for select
  using (user_id = auth.uid());

drop policy if exists "Users can insert own notification preferences" on public.notification_preferences;
create policy "Users can insert own notification preferences"
  on public.notification_preferences for insert
  with check (user_id = auth.uid());

drop policy if exists "Users can update own notification preferences" on public.notification_preferences;
create policy "Users can update own notification preferences"
  on public.notification_preferences for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "Anyone can read seller reviews" on public.seller_reviews;
create policy "Anyone can read seller reviews"
  on public.seller_reviews for select
  using (true);

drop policy if exists "Buyer can insert review for own completed deal" on public.seller_reviews;
create policy "Buyer can insert review for own completed deal"
  on public.seller_reviews for insert
  with check (
    buyer_id = auth.uid()
    and deal_id in (
      select id from public.deals
      where buyer_id = auth.uid() and status = 'completed'
    )
  );

create or replace function public.mark_notification_read(
  p_notification_ids uuid[] default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_notification_ids is null or cardinality(p_notification_ids) = 0 then
    update public.notifications
    set is_read = true
    where user_id = auth.uid()
      and is_read = false;
  else
    update public.notifications
    set is_read = true
    where user_id = auth.uid()
      and id = any(p_notification_ids);
  end if;
end;
$$;

grant execute on function public.mark_notification_read(uuid[]) to authenticated;

alter table public.admin_conversation_access_logs
  drop constraint if exists admin_conversation_access_logs_thread_id_fkey;

alter table public.admin_conversation_access_logs
  rename column thread_id to conversation_id;

alter table public.admin_conversation_access_logs
  add constraint admin_conversation_access_logs_conversation_id_fkey
  foreign key (conversation_id) references public.conversations(id) on delete cascade;

drop function if exists public.admin_log_conversation_access(uuid, text, text);

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
  perform 1
  from public.profiles
  where id = auth.uid()
    and role in ('admin', 'super_admin');

  if not found then
    raise exception 'Admin privileges required.';
  end if;

  insert into public.admin_conversation_access_logs (
    admin_user_id,
    conversation_id,
    purpose,
    note
  ) values (
    auth.uid(),
    p_thread_id,
    p_purpose,
    p_note
  )
  returning id into v_id;

  return v_id;
end;
$$;
