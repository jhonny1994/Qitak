set search_path = public, extensions;

begin;

select plan(4);

create temp table test_contract_ids (
  test_key text primary key,
  buyer_id uuid not null,
  seller_id uuid not null,
  listing_id uuid not null
);

grant select on test_contract_ids to authenticated;

-- Buyers should not gain direct visibility into seller application rows just
-- because a listing is active.
set local role postgres;

do $$
declare
  v_buyer_id uuid := gen_random_uuid();
  v_seller_user_id uuid := gen_random_uuid();
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
    (v_buyer_id, 'privacy_buyer@example.com'),
    (v_seller_user_id, 'privacy_seller@example.com');

  update public.profiles
  set full_name = 'Privacy Buyer',
      phone = '0550000001',
      role = 'buyer'
  where id = v_buyer_id;

  update public.profiles
  set full_name = 'Privacy Seller',
      phone = '0550000002',
      role = 'seller'
  where id = v_seller_user_id;

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
    'Privacy Seller Garage',
    'Trusted seller profile',
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
    'Privacy-safe listing',
    'Listing used for seller privacy regression coverage',
    1000,
    v_wilaya_id::text,
    v_commune_id,
    v_wilaya_id,
    v_commune_id,
    v_category_id,
    'used',
    1,
    'Privacy Seller Garage',
    'active',
    true
  from public.sellers s
  where s.user_id = v_seller_user_id;

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', v_buyer_id)::text,
    true
  );

  insert into test_contract_ids (test_key, buyer_id, seller_id, listing_id)
  values ('deal_contract', v_buyer_id, v_seller_user_id, v_listing_id);
end;
$$;

set local role authenticated;

select is(
  (select count(*)::int from public.sellers),
  0,
  'authenticated buyers cannot read other sellers directly'
);

-- Deals should be creatable from the runtime contract: listing id + buyer user
-- id + seller user id. The RPC must not expect the seller row UUID here.
set local role postgres;

do $$
declare
  v_buyer_id uuid := gen_random_uuid();
  v_seller_user_id uuid := gen_random_uuid();
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
    (v_buyer_id, 'deal_buyer@example.com'),
    (v_seller_user_id, 'deal_seller@example.com');

  update public.profiles
  set full_name = 'Deal Buyer',
      phone = '0551000001',
      role = 'buyer'
  where id = v_buyer_id;

  update public.profiles
  set full_name = 'Deal Seller',
      phone = '0551000002',
      role = 'seller'
  where id = v_seller_user_id;

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
    'Deal Seller Garage',
    'Seller application row for deal test',
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
    'Deal contract listing',
    'Listing used for create_deal_request contract coverage',
    2500,
    v_wilaya_id::text,
    v_commune_id,
    v_wilaya_id,
    v_commune_id,
    v_category_id,
    'used',
    1,
    'Deal Seller Garage',
    'active',
    true
  from public.sellers s
  where s.user_id = v_seller_user_id;

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', v_buyer_id)::text,
    true
  );
end;
$$;

set local role authenticated;

select lives_ok(
  $$
    do $inner$
    declare
      v_buyer_id uuid;
    begin
      select buyer_id
      into v_buyer_id
      from test_contract_ids
      where test_key = 'deal_contract';

      perform set_config(
        'request.jwt.claims',
        json_build_object('sub', v_buyer_id)::text,
        true
      );

      perform public.create_deal_request(
        (
          select listing_id
          from test_contract_ids
          where test_key = 'deal_contract'
        ),
        v_buyer_id,
        (
          select seller_id
          from test_contract_ids
          where test_key = 'deal_contract'
        ),
        'buy',
        null
      );
    end
    $inner$
  $$,
  'create_deal_request accepts the seller profile id used by the app contract'
);

select is(
  (
    select seller_id
    from public.deals
    where listing_id = (
      select listing_id
      from test_contract_ids
      where test_key = 'deal_contract'
    )
    order by created_at desc
    limit 1
  ),
  (
    select seller_id
    from test_contract_ids
    where test_key = 'deal_contract'
  ),
  'deals persist the seller profile id as their seller participant id'
);

-- Completed-deal rating should succeed without public reads on sellers, even
-- when the listing is no longer active.
select lives_ok(
  $$
  do $inner$
  declare
    v_buyer_id uuid;
    v_seller_id uuid;
    v_deal_id uuid;
    v_listing_id uuid;
  begin
    select buyer_id, seller_id, listing_id
    into v_buyer_id, v_seller_id, v_listing_id
    from test_contract_ids
    where test_key = 'deal_contract';

    perform set_config(
      'request.jwt.claims',
      json_build_object('sub', v_buyer_id)::text,
      true
    );
    select id into v_deal_id
    from public.deals
    where listing_id = v_listing_id
    order by created_at desc
    limit 1;

    perform set_config(
      'request.jwt.claims',
      json_build_object('sub', v_seller_id)::text,
      true
    );

    perform public.transition_deal(v_deal_id, 'seller_confirmed');
    perform set_config(
      'request.jwt.claims',
      json_build_object('sub', v_buyer_id)::text,
      true
    );

    perform public.select_deal_payment_method(v_deal_id, 'cash');

    perform set_config(
      'request.jwt.claims',
      json_build_object('sub', v_seller_id)::text,
      true
    );

    perform public.transition_deal(v_deal_id, 'completed');

    perform set_config(
      'request.jwt.claims',
      json_build_object('sub', v_buyer_id)::text,
      true
    );

    update public.listings
    set status = 'closed',
        is_available = false
    where id = v_listing_id;

    perform public.submit_seller_review(v_deal_id, 5, 'Stable after close');
  end
  $inner$;
  $$,
  'submit_seller_review works for completed deals without requiring public seller reads'
);

select * from finish();

rollback;
