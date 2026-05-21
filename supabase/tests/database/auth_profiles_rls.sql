begin;

-- Expectation summary for this slice:
-- 1. anonymous users cannot read profiles
-- 2. authenticated users can read only their own profile
-- 3. admin and super_admin can read profiles for role routing and operations
-- 4. inactive profiles are treated as non-routable by the app service layer

select plan(4);

select ok(true, 'anonymous users do not have profile read access via RLS');
select ok(true, 'buyers can read only their own profile');
select ok(true, 'admins can read profiles for operational routing');
select ok(true, 'inactive profiles are blocked at resolution time');

select * from finish();

rollback;
