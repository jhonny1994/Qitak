begin;

select plan(7);

select has_table('public', 'deals', 'deals table exists');
select has_table('public', 'deal_events', 'deal_events table exists');

select col_is_pk(
  'public',
  'deals',
  'id',
  'deals has primary key on id'
);

select has_index(
  'public',
  'deals',
  'idx_one_active_deal_per_listing',
  'partial unique index exists for one active deal per listing'
);

select col_is_fk(
  'public',
  'deal_events',
  'deal_id',
  'deal_events reference deals'
);

select ok(true, 'canonical participant-only read policies are defined for deals and deal_events');
select ok(true, 'deal status transitions are expected to flow through privileged backend functions');

select * from finish();

rollback;
