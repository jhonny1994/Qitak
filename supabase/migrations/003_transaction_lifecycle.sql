create table if not exists public.transaction_records (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  buyer_user_id uuid not null references public.profiles(id) on delete cascade,
  seller_user_id uuid not null references public.profiles(id) on delete cascade,
  state text not null check (state in ('requested', 'accepted', 'completed', 'cancelled', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists tx_open_intent_unique
on public.transaction_records (listing_id, buyer_user_id)
where state in ('requested', 'accepted');

alter table public.transaction_records enable row level security;

create policy "transactions_participant_read"
on public.transaction_records
for select
to authenticated
using (buyer_user_id = auth.uid() or seller_user_id = auth.uid());

create policy "transactions_buyer_insert"
on public.transaction_records
for insert
to authenticated
with check (
  buyer_user_id = auth.uid()
  and state = 'requested'
);

create policy "transactions_participant_update"
on public.transaction_records
for update
to authenticated
using (buyer_user_id = auth.uid() or seller_user_id = auth.uid())
with check (
  buyer_user_id = auth.uid() or seller_user_id = auth.uid()
);

