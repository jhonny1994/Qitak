create or replace function public.self_deactivate_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  update public.profiles
  set
    is_active = false,
    updated_at = now()
  where id = v_user_id;
end;
$$;

grant execute on function public.self_deactivate_account() to authenticated;
