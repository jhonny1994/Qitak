-- When email confirmation is enabled, Supabase does not return a session on
-- signUp(), so the client has no user JWT to satisfy the profiles INSERT RLS
-- policy. This trigger creates the profile row from sanitized signup metadata.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_full_name text;
  v_phone text;
  v_role text;
  v_language text;
begin
  v_full_name := nullif(trim(coalesce(new.raw_user_meta_data->>'full_name', '')), '');
  v_phone := nullif(trim(coalesce(new.raw_user_meta_data->>'phone', '')), '');
  v_role := case
    when new.raw_user_meta_data->>'role' = 'seller' then 'seller'
    else 'buyer'
  end;
  v_language := case
    when new.raw_user_meta_data->>'language' in ('ar', 'en', 'fr')
      then new.raw_user_meta_data->>'language'
    else 'ar'
  end;

  insert into public.profiles (
    id,
    email,
    full_name,
    phone,
    role,
    language,
    is_active
  )
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(v_full_name, split_part(coalesce(new.email, 'user'), '@', 1)),
    coalesce(v_phone, '-'),
    v_role,
    v_language,
    true
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
