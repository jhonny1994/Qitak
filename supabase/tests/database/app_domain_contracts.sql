set search_path = public, extensions;

begin;
select plan(44);

select has_table('public', 'app_domain_catalog', 'app_domain_catalog table exists');
select has_table('public', 'app_domain_codes', 'app_domain_codes table exists');
select has_table('public', 'app_policy_options', 'app_policy_options table exists');

select col_is_pk('public', 'app_domain_catalog', 'domain_key', 'app_domain_catalog pk is domain_key');
select col_not_null('public', 'app_domain_codes', 'domain_key', 'app_domain_codes.domain_key required');
select col_not_null('public', 'app_domain_codes', 'code', 'app_domain_codes.code required');
select col_not_null('public', 'app_policy_options', 'policy_type', 'app_policy_options.policy_type required');
select col_not_null('public', 'app_policy_options', 'code', 'app_policy_options.code required');

select has_view('public', 'app_domain_contracts', 'app_domain_contracts view exists');
select has_view('public', 'app_policy_contracts', 'app_policy_contracts view exists');

select has_function('public', 'get_app_domain_contracts', array['text'], 'get_app_domain_contracts(text) exists');
select has_function('public', 'get_app_policy_contracts', array['text'], 'get_app_policy_contracts(text) exists');

select ok(
  exists (
    select 1
    from public.app_domain_catalog
    where domain_key = 'listing_status'
      and is_active = true
  ),
  'seeded listing_status domain exists and is active'
);

select ok(
  exists (
    select 1
    from public.app_domain_codes
    where domain_key = 'deal_status'
      and code = 'payment_proof_submitted'
      and is_active = true
  ),
  'seeded deal_status.payment_proof_submitted exists and is active'
);

select ok(
  not exists (
    select 1
    from public.app_domain_codes
    where domain_key = 'deal_status'
      and code = 'intent_created'
      and is_active = true
  ),
  'deprecated deal_status.intent_created is no longer active'
);

select ok(
  exists (
    select 1
    from public.app_policy_options
    where policy_type = 'buyer_payment_method'
      and code = 'baridimob'
      and is_active = true
  ),
  'seeded buyer_payment_method.baridimob exists and is active'
);

select ok(
  exists (
    select 1
    from public.app_policy_options
    where policy_type = 'seller_document_type'
      and code = 'business_registration'
      and is_active = true
  ),
  'seeded seller_document_type.business_registration exists and is active'
);

select ok(
  exists (
    select 1
    from public.app_domain_codes
    where domain_key = 'reported_entity_type'
      and code = 'support'
      and is_active = true
  ),
  'seeded reported_entity_type.support exists and is active'
);

select ok(
  exists (
    select 1
    from public.app_policy_options
    where policy_type = 'support_reason_code'
      and is_active = true
  ),
  'support_reason_code policy options exist'
);

do $$
declare
  v_support_user_id uuid := gen_random_uuid();
begin
  insert into auth.users (id, email)
  values (v_support_user_id, 'support_contract_test@example.com');

  update public.profiles
  set full_name = 'Support Contract User',
      phone = '0551112233',
      role = 'buyer'
  where id = v_support_user_id;

  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', v_support_user_id)::text,
    true
  );
end;
$$;

set local role authenticated;

select lives_ok(
  $sql$
    insert into public.reports (
      reporter_id,
      reported_entity_type,
      reported_entity_id,
      report_type,
      description
    )
    values (
      (select auth.uid()),
      'support',
      (select auth.uid()),
      'payment_issue',
      'Support contract ticket created from pgTAP.'
    )
  $sql$,
  'authenticated users can create support-backed reports'
);

set local role postgres;

do $$
begin
  insert into auth.users (id, email)
  values
    ('00000000-0000-0000-0000-000000000000', 'admin_contract_test@example.com'),
    ('00000000-0000-0000-0000-000000000111', 'listing_report_buyer@example.com'),
    ('00000000-0000-0000-0000-000000000222', 'listing_report_seller@example.com');

  update public.profiles
  set full_name = 'Admin Contract User',
      phone = '0550000000',
      role = 'admin'
  where id = '00000000-0000-0000-0000-000000000000';

  update public.profiles
  set full_name = 'Listing Report Buyer',
      phone = '0552223344',
      role = 'buyer'
  where id = '00000000-0000-0000-0000-000000000111';

  update public.profiles
  set full_name = 'Listing Report Seller',
      phone = '0553334455',
      role = 'seller'
  where id = '00000000-0000-0000-0000-000000000222';

  insert into public.listings (
    id,
    seller_user_id,
    title,
    description,
    price
  )
  values (
    '00000000-0000-0000-0000-000000000333',
    '00000000-0000-0000-0000-000000000222',
    'Support contract listing',
    'Listing used to validate report insert protections.',
    5000
  );

  insert into public.reports (
    id,
    reporter_id,
    reported_entity_type,
    reported_entity_id,
    report_type,
    description,
    status
  )
  values
    (
      '10000000-0000-0000-0000-000000000001',
      (
        select id
        from auth.users
        where email = 'support_contract_test@example.com'
      ),
      'support',
      (
        select id
        from auth.users
        where email = 'support_contract_test@example.com'
      ),
      'payment_issue',
      'Support report used to verify resolve -> actioned.',
      'open'
    ),
    (
      '10000000-0000-0000-0000-000000000002',
      (
        select id
        from auth.users
        where email = 'support_contract_test@example.com'
      ),
      'support',
      (
        select id
        from auth.users
        where email = 'support_contract_test@example.com'
      ),
      'technical_issue',
      'Support report used to verify close -> dismissed.',
      'open'
    ),
    (
      '10000000-0000-0000-0000-000000000003',
      '00000000-0000-0000-0000-000000000111',
      'listing',
      '00000000-0000-0000-0000-000000000333',
      'spam',
      'Listing report used to verify moderation resolution validation.',
      'open'
    );
end;
$$;

select set_config(
  'request.jwt.claims',
  json_build_object('sub', '00000000-0000-0000-0000-000000000111')::text,
  false
);

set local role authenticated;

select ok(
  exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'reports'
      and policyname = 'Authenticated users can create supported reports'
      and coalesce(with_check, '') like '%reported_entity_type = ''listing''%'
      and coalesce(with_check, '') like '%p.role = ''buyer''%'
      and coalesce(with_check, '') like '%seller_user_id <>%'
  ),
  'listing report branch remains enforced in the supported report insert policy'
);

set local role postgres;

select throws_ok(
  $sql$
    do $$
    begin
      insert into public.reports (
        reporter_id,
        reported_entity_type,
        reported_entity_id,
        report_type,
        description
      ) values (
        '00000000-0000-0000-0000-000000000111',
        'listing',
        '00000000-0000-0000-0000-000000000333',
        'spam',
        'Duplicate listing report should be blocked (first insert).'
      );

      insert into public.reports (
        reporter_id,
        reported_entity_type,
        reported_entity_id,
        report_type,
        description
      ) values (
        '00000000-0000-0000-0000-000000000111',
        'listing',
        '00000000-0000-0000-0000-000000000333',
        'spam',
        'Duplicate listing report should be blocked (second insert).'
      );
    end;
    $$
  $sql$,
  23505,
  null,
  'duplicate non-support reports remain blocked'
);

select set_config(
  'request.jwt.claims',
  json_build_object('sub', '00000000-0000-0000-0000-000000000111')::text,
  false
);

set local role authenticated;

select throws_ok(
  $sql$
    insert into public.reports (
      reporter_id,
      reported_entity_type,
      reported_entity_id,
      report_type,
      description
    )
    values (
      auth.uid(),
      'support',
      gen_random_uuid(),
      'payment_issue',
      'Support report must anchor to the authenticated user.'
    )
  $sql$,
  42501,
  null,
  'support-backed reports require reported_entity_id to equal auth.uid()'
);

select lives_ok(
  $sql$
    insert into public.reports (
      reporter_id,
      reported_entity_type,
      reported_entity_id,
      report_type,
      description
    )
    values
      (auth.uid(), 'support', auth.uid(), 'payment_issue', 'First duplicate-safe support ticket.'),
      (auth.uid(), 'support', auth.uid(), 'technical_issue', 'Second duplicate-safe support ticket.')
  $sql$,
  'support-backed reports allow multiple tickets from the same user'
);

select set_config(
  'request.jwt.claims',
  json_build_object('sub', '00000000-0000-0000-0000-000000000000')::text,
  false
);

select lives_ok(
  $sql$
    select public.admin_resolve_report(
      '10000000-0000-0000-0000-000000000001',
      'resolve',
      'verified_and_resolved',
      'Support issue confirmed and resolved.'
    )
  $sql$,
  'support report accepts resolve through admin_resolve_report'
);

select ok(
  exists (
    select 1
    from public.reports
    where id = '10000000-0000-0000-0000-000000000001'
      and status = 'actioned'
      and resolution_action = 'resolve'
      and resolution_reason_code = 'verified_and_resolved'
      and resolved_by = '00000000-0000-0000-0000-000000000000'
  ),
  'support resolve persists actioned status and support resolution metadata'
);

select lives_ok(
  $sql$
    select public.admin_resolve_report(
      '10000000-0000-0000-0000-000000000002',
      'close',
      'out_of_scope',
      'Support request closed as out of scope.'
    )
  $sql$,
  'support report accepts close through admin_resolve_report'
);

select ok(
  exists (
    select 1
    from public.reports
    where id = '10000000-0000-0000-0000-000000000002'
      and status = 'dismissed'
      and resolution_action = 'close'
      and resolution_reason_code = 'out_of_scope'
      and resolved_by = '00000000-0000-0000-0000-000000000000'
  ),
  'support close persists dismissed status and support resolution metadata'
);

select throws_ok(
  $sql$
    select public.admin_resolve_report(
      '10000000-0000-0000-0000-000000000003',
      'resolve',
      'verified_and_resolved',
      null
    )
  $sql$,
  null,
  'invalid report decision',
  'non-support reports reject resolve as a support-only decision'
);

select throws_ok(
  $sql$
    select public.admin_resolve_report(
      '10000000-0000-0000-0000-000000000003',
      'close',
      'out_of_scope',
      null
    )
  $sql$,
  null,
  'invalid report decision',
  'non-support reports reject close as a support-only decision'
);

select lives_ok(
  $sql$
    select public.admin_resolve_report(
      '10000000-0000-0000-0000-000000000003',
      'dismiss',
      'spam',
      'Moderation report dismissed after review.'
    )
  $sql$,
  'moderation branch still accepts dismiss through admin_resolve_report'
);

select ok(
  exists (
    select 1
    from public.reports
    where id = '10000000-0000-0000-0000-000000000003'
      and status = 'dismissed'
      and resolution_action = 'dismiss'
      and resolution_reason_code = 'spam'
      and resolved_by = '00000000-0000-0000-0000-000000000000'
  ),
  'moderation dismiss persists dismissed status and moderation metadata'
);

set local role postgres;

select ok(
  exists (
    select 1
    from pg_constraint
    where conrelid = 'public.reports'::regclass
      and contype = 'c'
      and pg_get_constraintdef(oid) like '%support%'
  ),
  'reports entity type constraint allows support'
);

select ok(
  not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.reports'::regclass
      and conname = 'reports_reporter_entity_unique'
  ),
  'reports no longer has blanket reporter/entity uniqueness constraint'
);

select ok(
  exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'reports'
      and policyname = 'Authenticated users can create supported reports'
  ),
  'reports insert policy exists for supported authenticated report creation'
);

select ok(
  has_table_privilege('anon', 'public.app_domain_catalog', 'SELECT')
  and has_table_privilege('anon', 'public.app_domain_codes', 'SELECT')
  and has_table_privilege('anon', 'public.app_policy_options', 'SELECT'),
  'anon has select privilege on contract tables'
);

select ok(
  has_function_privilege('anon', 'public.get_app_domain_contracts(text)', 'EXECUTE')
  and has_function_privilege('anon', 'public.get_app_policy_contracts(text)', 'EXECUTE'),
  'anon has execute privilege on contract RPC functions'
);

select ok(
  (select count(*) from public.get_app_domain_contracts('listing_status')) > 0,
  'get_app_domain_contracts returns listing_status rows'
);

select ok(
  (select count(*) from public.get_app_policy_contracts('seller_verification_reason_code')) > 0,
  'get_app_policy_contracts returns seller verification reason rows'
);

select ok(
  (select count(*) from public.get_app_policy_contracts('support_reason_code')) > 0,
  'get_app_policy_contracts returns support reason rows'
);

select ok(
  (
    select array_agg(code order by sort_order, code)
    from public.get_app_policy_contracts('support_report_resolution_decision')
  ) = array['resolve', 'close']::text[],
  'support report resolution decisions remain contract-driven'
);

select ok(
  (
    select array_agg(code order by sort_order, code)
    from public.get_app_policy_contracts('support_report_resolution_reason_code')
  ) = array[
    'verified_and_resolved',
    'user_guided',
    'duplicate_ticket',
    'out_of_scope'
  ]::text[],
  'support report resolution reasons remain contract-driven'
);

select ok(
  not exists (
    select 1
    from public.get_app_domain_contracts('listing_status') c
    where coalesce(c.code, '') = ''
      or coalesce(c.sort_order, 0) <= 0
  ),
  'domain contract rows expose non-empty codes and positive sort order'
);

select ok(
  not exists (
    select 1
    from public.get_app_policy_contracts('seller_document_type') p
    where coalesce(p.code, '') = ''
      or coalesce(p.label_key, '') = ''
  ),
  'policy contract rows expose non-empty code and label_key'
);

select * from finish();
rollback;
