set search_path = public, extensions;

begin;

select plan(16);

create temp table test_marketplace_ids (
  buyer_id uuid not null,
  seller_id uuid not null,
  outsider_id uuid not null,
  active_listing_id uuid not null,
  closed_listing_id uuid not null,
  buyer_conversation_id uuid,
  second_buyer_id uuid,
  stock_deal_id uuid
);

grant select, update on test_marketplace_ids to authenticated;
grant select on test_marketplace_ids to anon;

set local role postgres;

do $$
declare
  v_buyer_id uuid := gen_random_uuid();
  v_seller_user_id uuid := gen_random_uuid();
  v_outsider_id uuid := gen_random_uuid();
  v_second_buyer_id uuid := gen_random_uuid();
  v_active_listing_id uuid := gen_random_uuid();
  v_closed_listing_id uuid := gen_random_uuid();
  v_wilaya_id integer;
  v_commune_id text;
  v_category_id text;
begin
  select id into v_wilaya_id
  from public.wilayas
  order by id
  limit 1;

  select id into v_commune_id
  from public.communes
  where wilaya_id = v_wilaya_id
  order by id
  limit 1;

  select id into v_category_id
  from public.part_categories
  order by id
  limit 1;

  insert into auth.users (id, email)
  values
    (v_buyer_id, 'marketplace_buyer@example.com'),
    (v_seller_user_id, 'marketplace_seller@example.com'),
    (v_outsider_id, 'marketplace_outsider@example.com'),
    (v_second_buyer_id, 'marketplace_second_buyer@example.com');

  update public.profiles
  set full_name = 'Marketplace Buyer',
      phone = '0553000001',
      role = 'buyer'
  where id = v_buyer_id;

  update public.profiles
  set full_name = 'Marketplace Seller',
      phone = '0553000002',
      role = 'seller'
  where id = v_seller_user_id;

  update public.profiles
  set full_name = 'Marketplace Outsider',
      phone = '0553000003',
      role = 'buyer'
  where id = v_outsider_id;

  update public.profiles
  set full_name = 'Marketplace Second Buyer',
      phone = '0553000004',
      role = 'buyer'
  where id = v_second_buyer_id;

  insert into public.sellers (
    id,
    user_id,
    seller_type,
    business_name,
    bio,
    wilaya_id,
    commune_id,
    verification_status,
    policy_accepted_at,
    verified_at
  )
  values (
    gen_random_uuid(),
    v_seller_user_id,
    'individual',
    'Marketplace Seller Garage',
    'Seller row used for marketplace RLS coverage.',
    v_wilaya_id,
    v_commune_id,
    'approved',
    now(),
    now()
  );

  insert into public.listings (
    id,
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
    seller_display_name,
    status,
    is_available
  )
  select
    v_active_listing_id,
    v_seller_user_id,
    s.id,
    'Marketplace active listing',
    'Active listing used for public marketplace proof.',
    4500,
    v_wilaya_id::text,
    v_commune_id,
    v_wilaya_id,
    v_commune_id,
    v_category_id,
    'used',
    2,
    'Marketplace Seller Garage',
    'active',
    true
  from public.sellers s
  where s.user_id = v_seller_user_id;

  insert into public.listings (
    id,
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
    seller_display_name,
    status,
    is_available
  )
  select
    v_closed_listing_id,
    v_seller_user_id,
    s.id,
    'Marketplace closed listing',
    'Closed listing used for owner-only marketplace proof.',
    4700,
    v_wilaya_id::text,
    v_commune_id,
    v_wilaya_id,
    v_commune_id,
    v_category_id,
    'used',
    1,
    'Marketplace Seller Garage',
    'closed',
    false
  from public.sellers s
  where s.user_id = v_seller_user_id;

  insert into public.listing_media (
    listing_id,
    storage_path,
    public_url,
    mime_type,
    sort_order
  )
  values
    (
      v_active_listing_id,
      'listing-media/marketplace-active.jpg',
      'https://example.com/marketplace-active.jpg',
      'image/jpeg',
      0
    ),
    (
      v_closed_listing_id,
      'listing-media/marketplace-closed.jpg',
      'https://example.com/marketplace-closed.jpg',
      'image/jpeg',
      0
    );

  insert into test_marketplace_ids (
    buyer_id,
    seller_id,
    outsider_id,
    active_listing_id,
    closed_listing_id,
    second_buyer_id
  )
  values (
    v_buyer_id,
    v_seller_user_id,
    v_outsider_id,
    v_active_listing_id,
    v_closed_listing_id,
    v_second_buyer_id
  );
end;
$$;

select set_config('request.jwt.claims', '{}'::text, false);

set local role anon;

select is(
  (
    select count(*)::int
    from public.listings
    where id = (select active_listing_id from test_marketplace_ids)
  ),
  1,
  'anonymous users can read active listings'
);

select is(
  (
    select count(*)::int
    from public.listing_media
    where listing_id = (select active_listing_id from test_marketplace_ids)
  ),
  1,
  'anonymous users can read media for active listings only'
);

set local role authenticated;

select set_config(
  'request.jwt.claims',
  json_build_object('sub', (select buyer_id from test_marketplace_ids))::text,
  false
);

select is(
  (
    select count(*)::int
    from public.listings
    where id = (select active_listing_id from test_marketplace_ids)
  ),
  1,
  'buyers can read active marketplace listings'
);

select lives_ok(
  $sql$
    do $inner$
    declare
      v_deal public.deals%rowtype;
    begin
      select *
      into v_deal
      from public.create_deal_request(
        (select active_listing_id from test_marketplace_ids),
        (select buyer_id from test_marketplace_ids),
        (select seller_id from test_marketplace_ids),
        'buy',
        null
      );

      update test_marketplace_ids
      set stock_deal_id = v_deal.id;
    end
    $inner$
  $sql$,
  'buyers can reserve one unit from a multi-stock listing'
);

select is(
  (
    select count(*)::int
    from public.listings
    where id = (select active_listing_id from test_marketplace_ids)
  ),
  1,
  'the listing stays visible while one stock unit remains'
);

select is(
  (
    select greatest(
      l.quantity - public.listing_committed_units(l.id),
      0
    )::integer
    from public.listings l
    where l.id = (select active_listing_id from test_marketplace_ids)
  ),
  1,
  'remaining stock drops by one after the first reservation'
);

select lives_ok(
  $sql$
    insert into public.saved_listings (user_id, listing_id)
    values (
      (select buyer_id from test_marketplace_ids),
      (select active_listing_id from test_marketplace_ids)
    )
  $sql$,
  'buyers can save listings for themselves'
);

select throws_ok(
  $sql$
    insert into public.saved_listings (user_id, listing_id)
    values (
      (select outsider_id from test_marketplace_ids),
      (select active_listing_id from test_marketplace_ids)
    )
  $sql$,
  42501,
  null,
  'buyers cannot write saved listings for another user'
);

select lives_ok(
  $sql$
    do $inner$
    declare
      v_conversation_id uuid := gen_random_uuid();
    begin
      insert into public.conversations (
        id,
        listing_id,
        buyer_id,
        seller_id
      )
      values (
        v_conversation_id,
        (select active_listing_id from test_marketplace_ids),
        (select buyer_id from test_marketplace_ids),
        (select seller_id from test_marketplace_ids)
      );

      update test_marketplace_ids
      set buyer_conversation_id = v_conversation_id;
    end
    $inner$
  $sql$,
  'buyers can create conversations for active listings'
);

select is(
  (
    select count(*)::int
    from public.conversations
    where id = (select buyer_conversation_id from test_marketplace_ids)
  ),
  1,
  'buyers can read their own conversation thread'
);

select set_config(
  'request.jwt.claims',
  json_build_object('sub', (select outsider_id from test_marketplace_ids))::text,
  false
);

select is(
  (
    select count(*)::int
    from public.conversations
    where id = (select buyer_conversation_id from test_marketplace_ids)
  ),
  0,
  'non-participants cannot read other conversations'
);

select set_config(
  'request.jwt.claims',
  json_build_object('sub', (select seller_id from test_marketplace_ids))::text,
  false
);

select is(
  (
    select count(*)::int
    from public.listings
    where id = (select closed_listing_id from test_marketplace_ids)
  ),
  1,
  'sellers can read their own closed listings'
);

select is(
  (
    select count(*)::int
    from public.listing_media
    where listing_id = (select closed_listing_id from test_marketplace_ids)
  ),
  1,
  'sellers can read media for their own closed listings'
);

select set_config(
  'request.jwt.claims',
  json_build_object('sub', (select second_buyer_id from test_marketplace_ids))::text,
  false
);

select lives_ok(
  $sql$
    select public.create_deal_request(
      (select active_listing_id from test_marketplace_ids),
      (select second_buyer_id from test_marketplace_ids),
      (select seller_id from test_marketplace_ids),
      'buy',
      null
    )
  $sql$,
  'a second buyer can reserve the final stock unit'
);

select is(
  (
    select count(*)::int
    from public.listings
    where id = (select active_listing_id from test_marketplace_ids)
  ),
  0,
  'sold-out listings disappear from public marketplace reads'
);

select is(
  (
    select count(*)::int
    from public.listing_media
    where listing_id = (select active_listing_id from test_marketplace_ids)
  ),
  0,
  'sold-out listings also hide their public media'
);

select * from finish();

rollback;
