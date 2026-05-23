begin;

-- Verifies the profiles RLS policies:
-- 1. Anonymous users cannot read any profile
-- 2. Authenticated users can read only their own profile
-- 3. Admin/super_admin can read all profiles
-- 4. Privilege escalation via self-update is blocked (role field is immutable via RLS)

select plan(5);

-- ── Test 1: Anonymous SELECT is rejected ────────────────────────────────────
set local role anon;

select is(
  (select count(*)::int from public.profiles),
  0,
  'anonymous users cannot read any profiles'
);

-- ── Test 2: Authenticated buyer reads only own row ───────────────────────────
-- Create a test buyer and a second user, verify buyer cannot see the second user.
set local role postgres;

do $$
declare
  v_buyer_id  uuid := gen_random_uuid();
  v_other_id  uuid := gen_random_uuid();
begin
  insert into auth.users (id, email) values (v_buyer_id, 'buyer_rls_test@example.com');
  insert into auth.users (id, email) values (v_other_id, 'other_rls_test@example.com');

  update public.profiles
  set full_name = 'Test Buyer',
      phone = '0551234567',
      role = 'buyer'
  where id = v_buyer_id;

  update public.profiles
  set full_name = 'Other User',
      phone = '0559876543',
      role = 'buyer'
  where id = v_other_id;

  -- Simulate the buyer's JWT
  perform set_config('request.jwt.claims', json_build_object('sub', v_buyer_id)::text, true);
end;
$$;

set local role authenticated;

select is(
  (select count(*)::int from public.profiles),
  1,
  'authenticated buyer sees only their own profile row'
);

-- ── Test 3: Buyer cannot escalate role to super_admin ───────────────────────
-- The profiles_self_update_mutable_fields policy must reject role changes.
select throws_ok(
  $$update public.profiles set role = 'super_admin' where email = 'buyer_rls_test@example.com'$$,
  42501,
  null,
  'buyer cannot change their own role via direct UPDATE (privilege escalation blocked)'
);

-- ── Test 4: Buyer cannot change is_active ───────────────────────────────────
select throws_ok(
  $$update public.profiles set is_active = false where email = 'buyer_rls_test@example.com'$$,
  42501,
  null,
  'buyer cannot change their own is_active via direct UPDATE'
);

-- ── Test 5: Admin can read all profiles ─────────────────────────────────────
set local role postgres;

do $$
declare
  v_admin_id uuid := gen_random_uuid();
begin
  insert into auth.users (id, email) values (v_admin_id, 'admin_rls_test@example.com');

  update public.profiles
  set full_name = 'Test Admin',
      phone = '0550000001',
      role = 'admin'
  where id = v_admin_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_admin_id)::text, true);
end;
$$;

set local role authenticated;

select ok(
  (select count(*)::int from public.profiles) > 1,
  'admin can read more than one profile row'
);

select * from finish();

rollback;
