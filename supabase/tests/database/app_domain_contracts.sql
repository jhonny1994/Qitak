set search_path = public, extensions;

begin;
select plan(21);

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
      and code = 'dispute_resolved'
      and is_active = true
  ),
  'seeded deal_status.dispute_resolved exists and is active'
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
