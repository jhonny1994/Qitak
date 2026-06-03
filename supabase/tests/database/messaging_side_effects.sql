set search_path = public, extensions;

begin;

select plan(4);

create temp table test_message_contract_ids (
  conversation_id uuid not null,
  buyer_id uuid not null,
  seller_id uuid not null
);

create temp table test_message_contract_results (
  direct_notification_insert_blocked boolean not null
);

grant select on test_message_contract_ids to authenticated;
grant insert, select on test_message_contract_results to authenticated;

set local role postgres;

do $$
declare
  v_buyer_id uuid := gen_random_uuid();
  v_seller_user_id uuid := gen_random_uuid();
  v_listing_id uuid := gen_random_uuid();
  v_conversation_id uuid := gen_random_uuid();
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
    (v_buyer_id, 'message_buyer@example.com'),
    (v_seller_user_id, 'message_seller@example.com');

  update public.profiles
  set full_name = 'Message Buyer',
      phone = '0551000011',
      role = 'buyer'
  where id = v_buyer_id;

  update public.profiles
  set full_name = 'Message Seller',
      phone = '0551000012',
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
    'Messaging Seller Garage',
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
    'Messaging-safe listing',
    'Listing used for messaging regression coverage',
    1000,
    v_wilaya_id::text,
    v_commune_id,
    v_wilaya_id,
    v_commune_id,
    v_category_id,
    'used',
    1,
    'Messaging Seller Garage',
    'active',
    true
  from public.sellers s
  where s.user_id = v_seller_user_id;

  insert into public.conversations (
    id,
    listing_id,
    buyer_id,
    seller_id
  )
  values (
    v_conversation_id,
    v_listing_id,
    v_buyer_id,
    v_seller_user_id
  );

  insert into test_message_contract_ids (conversation_id, buyer_id, seller_id)
  values (v_conversation_id, v_buyer_id, v_seller_user_id);
end;
$$;

set local role authenticated;

do $$
declare
  v_conversation_id uuid;
  v_buyer_id uuid;
begin
  select conversation_id, buyer_id
  into v_conversation_id, v_buyer_id
  from test_message_contract_ids;

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', v_buyer_id)::text,
    true
  );

  insert into public.messages (
    conversation_id,
    sender_id,
    content
  )
  values (
    v_conversation_id,
    v_buyer_id,
    'Is this still available?'
  );
end;
$$;

select is(
  (
    select count(*)::int
    from public.messages m
    join test_message_contract_ids t on t.conversation_id = m.conversation_id
    where m.sender_id = t.buyer_id
      and m.content = 'Is this still available?'
  ),
  1,
  'participants can insert a message into their conversation'
);

select ok(
  (
    select last_message_at is not null
    from public.conversations c
    join test_message_contract_ids t on t.conversation_id = c.id
  ),
  'message insert updates conversation last_message_at'
);

set local role postgres;

select is(
  (
    select count(*)::int
    from public.notifications n
    join test_message_contract_ids t on t.seller_id = n.user_id
    where n.type = 'message_received'
      and n.data->>'conversation_id' = t.conversation_id::text
  ),
  1,
  'message insert creates a notification for the recipient'
);

set local role authenticated;

do $$
declare
  v_buyer_id uuid;
  v_seller_id uuid;
  v_blocked boolean := false;
begin
  select buyer_id, seller_id
  into v_buyer_id, v_seller_id
  from test_message_contract_ids;

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', v_buyer_id)::text,
    true
  );

  begin
    insert into public.notifications (user_id, type, data)
    values (
      v_seller_id,
      'message_received',
      jsonb_build_object('source', 'direct-client-test')
    );
  exception
    when insufficient_privilege then
      v_blocked := true;
  end;

  insert into test_message_contract_results (direct_notification_insert_blocked)
  values (v_blocked);
end;
$$;

select ok(
  (
    select direct_notification_insert_blocked
    from test_message_contract_results
    limit 1
  ),
  'direct client notification inserts remain blocked by RLS'
);

select * from finish();

rollback;
