create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  seller_user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text not null default '',
  price numeric(12, 2) not null check (price >= 0),
  wilaya_code text,
  commune_code text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.listing_fitments (
  listing_id uuid primary key references public.listings(id) on delete cascade,
  brand_code text not null,
  model_code text not null,
  model_year int not null check (model_year >= 1950 and model_year <= 2100),
  created_at timestamptz not null default now()
);

create table if not exists public.conversation_threads (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  buyer_user_id uuid not null references public.profiles(id) on delete cascade,
  seller_user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (listing_id, buyer_user_id, seller_user_id)
);

create table if not exists public.conversation_messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.conversation_threads(id) on delete cascade,
  sender_user_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (length(trim(body)) > 0),
  created_at timestamptz not null default now()
);

create table if not exists public.transaction_ratings (
  id uuid primary key default gen_random_uuid(),
  transaction_id uuid not null,
  from_user_id uuid not null references public.profiles(id) on delete cascade,
  to_user_id uuid not null references public.profiles(id) on delete cascade,
  score int not null check (score between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  unique (transaction_id, from_user_id)
);

alter table public.listings enable row level security;
alter table public.listing_fitments enable row level security;
alter table public.conversation_threads enable row level security;
alter table public.conversation_messages enable row level security;
alter table public.transaction_ratings enable row level security;

create policy "listings_public_read"
on public.listings
for select
to authenticated
using (true);

create policy "listings_seller_insert"
on public.listings
for insert
to authenticated
with check (
  seller_user_id = auth.uid()
  and exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'seller'
      and p.is_active = true
  )
);

create policy "listings_owner_update"
on public.listings
for update
to authenticated
using (seller_user_id = auth.uid())
with check (seller_user_id = auth.uid());

create policy "listing_fitments_public_read"
on public.listing_fitments
for select
to authenticated
using (true);

create policy "listing_fitments_owner_write"
on public.listing_fitments
for insert
to authenticated
with check (
  exists (
    select 1
    from public.listings l
    where l.id = listing_id
      and l.seller_user_id = auth.uid()
  )
);

create policy "listing_fitments_owner_update"
on public.listing_fitments
for update
to authenticated
using (
  exists (
    select 1
    from public.listings l
    where l.id = listing_id
      and l.seller_user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.listings l
    where l.id = listing_id
      and l.seller_user_id = auth.uid()
  )
);

create policy "threads_participant_read"
on public.conversation_threads
for select
to authenticated
using (buyer_user_id = auth.uid() or seller_user_id = auth.uid());

create policy "threads_participant_insert"
on public.conversation_threads
for insert
to authenticated
with check (buyer_user_id = auth.uid() or seller_user_id = auth.uid());

create policy "messages_participant_read"
on public.conversation_messages
for select
to authenticated
using (
  exists (
    select 1
    from public.conversation_threads t
    where t.id = thread_id
      and (t.buyer_user_id = auth.uid() or t.seller_user_id = auth.uid())
  )
);

create policy "messages_sender_insert_if_participant"
on public.conversation_messages
for insert
to authenticated
with check (
  sender_user_id = auth.uid()
  and exists (
    select 1
    from public.conversation_threads t
    where t.id = thread_id
      and (t.buyer_user_id = auth.uid() or t.seller_user_id = auth.uid())
  )
);

create policy "ratings_public_read"
on public.transaction_ratings
for select
to authenticated
using (true);

create policy "ratings_self_insert"
on public.transaction_ratings
for insert
to authenticated
with check (from_user_id = auth.uid());
