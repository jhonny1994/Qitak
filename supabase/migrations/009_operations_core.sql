create table if not exists public.transaction_disputes (
  id uuid primary key default gen_random_uuid(),
  transaction_id uuid not null references public.transaction_records(id) on delete cascade,
  created_by_user_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null,
  description text not null check (length(trim(description)) > 0),
  status text not null default 'open'
    check (status in ('open', 'reviewing', 'resolved', 'dismissed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists tx_open_dispute_unique
on public.transaction_disputes (transaction_id)
where status in ('open', 'reviewing');

create table if not exists public.user_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_user_id uuid not null references public.profiles(id) on delete cascade,
  entity_type text not null check (entity_type in ('listing', 'seller', 'message')),
  entity_id text not null,
  reason text not null,
  description text not null default '',
  status text not null default 'open'
    check (status in ('open', 'reviewing', 'resolved', 'dismissed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notification_reads (
  user_id uuid not null references public.profiles(id) on delete cascade,
  source_type text not null,
  source_id text not null,
  read_at timestamptz not null default now(),
  primary key (user_id, source_type, source_id)
);

alter table public.transaction_disputes enable row level security;
alter table public.user_reports enable row level security;
alter table public.notification_reads enable row level security;

create policy "transactions_admin_read"
on public.transaction_records
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

create policy "threads_admin_read"
on public.conversation_threads
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

create policy "messages_admin_read"
on public.conversation_messages
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

create policy "disputes_participant_or_admin_read"
on public.transaction_disputes
for select
to authenticated
using (
  created_by_user_id = auth.uid()
  or exists (
    select 1
    from public.transaction_records t
    where t.id = transaction_id
      and (t.buyer_user_id = auth.uid() or t.seller_user_id = auth.uid())
  )
  or exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
);

create policy "disputes_participant_insert"
on public.transaction_disputes
for insert
to authenticated
with check (
  created_by_user_id = auth.uid()
  and exists (
    select 1
    from public.transaction_records t
    where t.id = transaction_id
      and (t.buyer_user_id = auth.uid() or t.seller_user_id = auth.uid())
  )
);

create policy "disputes_admin_update"
on public.transaction_disputes
for update
to authenticated
using (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
)
with check (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
);

create policy "reports_owner_or_admin_read"
on public.user_reports
for select
to authenticated
using (
  reporter_user_id = auth.uid()
  or exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
);

create policy "reports_owner_insert"
on public.user_reports
for insert
to authenticated
with check (reporter_user_id = auth.uid());

create policy "reports_admin_update"
on public.user_reports
for update
to authenticated
using (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
)
with check (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('admin', 'super_admin')
      and p.is_active = true
  )
);

create policy "notification_reads_owner_read"
on public.notification_reads
for select
to authenticated
using (user_id = auth.uid());

create policy "notification_reads_owner_insert"
on public.notification_reads
for insert
to authenticated
with check (user_id = auth.uid());

create policy "notification_reads_owner_update"
on public.notification_reads
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());
