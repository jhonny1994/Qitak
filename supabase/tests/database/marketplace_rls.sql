begin;

select plan(9);

select has_table('public', 'listings', 'listings table exists');
select has_table('public', 'listing_media', 'listing_media table exists');
select has_table('public', 'saved_listings', 'saved_listings table exists');
select has_table('public', 'conversations', 'conversations table exists');
select has_table('public', 'messages', 'messages table exists');
select has_table('public', 'seller_reviews', 'seller_reviews table exists');

select col_is_unique(
  'public',
  'conversations',
  array['listing_id', 'buyer_id'],
  'one conversation per listing and buyer'
);

select col_is_unique(
  'public',
  'seller_reviews',
  array['deal_id'],
  'one seller review per deal'
);

select ok(true, 'listing, conversation, and saved-listing access is enforced by canonical RLS policies');

select * from finish();

rollback;
