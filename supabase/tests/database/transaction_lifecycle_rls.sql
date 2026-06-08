set search_path = public, extensions;

begin;

select plan(12);

create temp table test_transaction_ids (
  buyer_id uuid not null,
  seller_id uuid not null,
  outsider_id uuid not null,
  listing_id uuid not null,
  deal_id uuid
);

grant select, update on test_transaction_ids to authenticated;

set local role postgres;

do $$
declare
  v_buyer_id uuid := gen_random_uuid();
  v_seller_user_id uuid := gen_random_uuid();
  v_outsider_id uuid := gen_random_uuid();
  v_listing_id uuid := gen_random_uuid();
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
    (v_buyer_id, 'transaction_buyer@example.com'),
    (v_seller_user_id, 'transaction_seller@example.com'),
    (v_outsider_id, 'transaction_outsider@example.com');

  update public.profiles
  set full_name = 'Transaction Buyer',
      phone = '0554000001',
      role = 'buyer'
  where id = v_buyer_id;

  update public.profiles
  set full_name = 'Transaction Seller',
      phone = '0554000002',
      role = 'seller'
  where id = v_seller_user_id;

  update public.profiles
  set full_name = 'Transaction Outsider',
      phone = '0554000003',
      role = 'buyer'
  where id = v_outsider_id;

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
    'Transaction Seller Garage',
    'Seller row used for transaction lifecycle proof.',
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
    v_listing_id,
    v_seller_user_id,
    s.id,
    'Transaction lifecycle listing',
    'Listing used for payment-proof lifecycle coverage.',
    9800,
    v_wilaya_id::text,
    v_commune_id,
    v_wilaya_id,
    v_commune_id,
    v_category_id,
    'used',
    1,
    'Transaction Seller Garage',
    'active',
    true
  from public.sellers s
  where s.user_id = v_seller_user_id;

  insert into test_transaction_ids (
    buyer_id,
    seller_id,
    outsider_id,
    listing_id
  )
  values (
    v_buyer_id,
    v_seller_user_id,
    v_outsider_id,
    v_listing_id
  );
end;
$$;

set local role authenticated;

select lives_ok(
  $sql$
    do $inner$
    declare
      v_deal public.deals%rowtype;
    begin
      perform set_config(
        'request.jwt.claims',
        json_build_object('sub', (select buyer_id from test_transaction_ids))::text,
        true
      );

      select *
      into v_deal
      from public.create_deal_request(
        (select listing_id from test_transaction_ids),
        (select buyer_id from test_transaction_ids),
        (select seller_id from test_transaction_ids),
        'buy',
        null
      );

      update test_transaction_ids
      set deal_id = v_deal.id;
    end
    $inner$
  $sql$,
  'buyers can create deal requests through the production RPC'
);

select set_config(
  'request.jwt.claims',
  json_build_object('sub', (select buyer_id from test_transaction_ids))::text,
  false
);

select is(
  (
    select status
    from public.deals
    where id = (select deal_id from test_transaction_ids)
  ),
  'pending_seller_response',
  'deal requests start in pending_seller_response'
);

set local role postgres;

select ok(
  exists (
    select 1
    from public.listings
    where id = (select listing_id from test_transaction_ids)
      and is_available = false
  ),
  'deal requests make the listing unavailable'
);

set local role authenticated;

select set_config(
  'request.jwt.claims',
  json_build_object('sub', (select outsider_id from test_transaction_ids))::text,
  false
);

select is(
  (
    select count(*)::int
    from public.deals
    where id = (select deal_id from test_transaction_ids)
  ),
  0,
  'non-participants cannot read another deal'
);

select set_config(
  'request.jwt.claims',
  json_build_object('sub', (select buyer_id from test_transaction_ids))::text,
  false
);

select throws_ok(
  $sql$
    select public.submit_deal_payment_proof(
      (select deal_id from test_transaction_ids),
      'buyer/payment-proof-before-confirmation.png'
    )
  $sql$,
  null,
  'transition denied',
  'buyers cannot submit payment proof before seller confirmation'
);

select lives_ok(
  $sql$
    do $inner$
    begin
      perform set_config(
        'request.jwt.claims',
        json_build_object('sub', (select seller_id from test_transaction_ids))::text,
        true
      );

      perform public.transition_deal(
        (select deal_id from test_transaction_ids),
        'seller_confirmed'
      );
    end
    $inner$
  $sql$,
  'sellers can confirm pending requests'
);

select lives_ok(
  $sql$
    do $inner$
    begin
      perform set_config(
        'request.jwt.claims',
        json_build_object('sub', (select buyer_id from test_transaction_ids))::text,
        true
      );

      perform public.select_deal_payment_method(
        (select deal_id from test_transaction_ids),
        'baridimob'
      );

      perform public.submit_deal_payment_proof(
        (select deal_id from test_transaction_ids),
        'buyers/payment-proof-1.png'
      );
    end
    $inner$
  $sql$,
  'buyers can choose a non-cash payment method and submit proof'
);

select set_config(
  'request.jwt.claims',
  json_build_object('sub', (select buyer_id from test_transaction_ids))::text,
  false
);

select ok(
  exists (
    select 1
    from public.deals
    where id = (select deal_id from test_transaction_ids)
      and status = 'payment_proof_submitted'
      and payment_method = 'baridimob'
      and payment_proof_path = 'buyers/payment-proof-1.png'
      and payment_proof_submitted_at is not null
  )
  and exists (
    select 1
    from public.deal_events
    where deal_id = (select deal_id from test_transaction_ids)
      and event_type = 'payment_proof_submitted'
  ),
  'payment proof submission persists status, path, timestamp, and lifecycle event'
);

select lives_ok(
  $sql$
    do $inner$
    begin
      perform set_config(
        'request.jwt.claims',
        json_build_object('sub', (select seller_id from test_transaction_ids))::text,
        true
      );

      perform public.reject_deal_payment_proof(
        (select deal_id from test_transaction_ids)
      );
    end
    $inner$
  $sql$,
  'sellers can reject submitted payment proof'
);

select set_config(
  'request.jwt.claims',
  json_build_object('sub', (select seller_id from test_transaction_ids))::text,
  false
);

select ok(
  exists (
    select 1
    from public.deals
    where id = (select deal_id from test_transaction_ids)
      and status = 'seller_confirmed'
      and payment_method = 'baridimob'
      and payment_proof_path is null
      and payment_proof_submitted_at is null
      and payment_confirmed_at is null
  ),
  'payment proof rejection restores seller_confirmed and clears proof fields'
);

select lives_ok(
  $sql$
    do $inner$
    begin
      perform set_config(
        'request.jwt.claims',
        json_build_object('sub', (select buyer_id from test_transaction_ids))::text,
        true
      );

      perform public.submit_deal_payment_proof(
        (select deal_id from test_transaction_ids),
        'buyers/payment-proof-2.png'
      );

      perform set_config(
        'request.jwt.claims',
        json_build_object('sub', (select seller_id from test_transaction_ids))::text,
        true
      );

      perform public.transition_deal(
        (select deal_id from test_transaction_ids),
        'payment_confirmed'
      );

      perform set_config(
        'request.jwt.claims',
        json_build_object('sub', (select buyer_id from test_transaction_ids))::text,
        true
      );

      perform public.transition_deal(
        (select deal_id from test_transaction_ids),
        'completed'
      );

      perform public.submit_seller_review(
        (select deal_id from test_transaction_ids),
        5,
        'Lifecycle proof review'
      );
    end
    $inner$
  $sql$,
  'participants can complete the non-cash workflow and submit the final seller review'
);

select set_config(
  'request.jwt.claims',
  json_build_object('sub', (select buyer_id from test_transaction_ids))::text,
  false
);

select throws_ok(
  $sql$
    select public.submit_seller_review(
      (select deal_id from test_transaction_ids),
      5,
      'Duplicate lifecycle review'
    )
  $sql$,
  23505,
  null,
  'completed deals still block duplicate seller reviews'
);

select * from finish();

rollback;
