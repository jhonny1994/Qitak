set search_path = public, extensions;

begin;
select plan(7);

select has_table('public', 'deals', 'deals table exists');
select has_table('public', 'deal_events', 'deal_events table exists');

select col_type_is('public', 'deals', 'status', 'text', 'deals.status is text');
select col_is_pk('public', 'deals', 'id', 'deals primary key is id');

select ok(
  exists (
    select 1
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'deal_events'
      and c.contype = 'f'
      and pg_get_constraintdef(c.oid) like '%FOREIGN KEY (deal_id) REFERENCES deals(id)%'
  ),
  'catalog confirms deal_events.deal_id FK to deals.id'
);

select col_not_null('public', 'deal_events', 'event_type', 'deal_events.event_type required');
select col_not_null('public', 'deal_events', 'created_at', 'deal_events.created_at required');

select * from finish();
rollback;
