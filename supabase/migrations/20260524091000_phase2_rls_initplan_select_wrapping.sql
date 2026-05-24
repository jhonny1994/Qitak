-- Phase 2: RLS initplan performance remediation
-- Pattern per Supabase docs: wrap auth helpers in SELECT to avoid per-row re-evaluation
-- NOTE: this migration is intentionally generated as dynamic SQL from live policy text
-- so semantics stay identical while only replacing auth helper invocation forms.

do $$
declare
  r record;
  new_qual text;
  new_with_check text;
  stmt text;
begin
  for r in
    select schemaname, tablename, policyname, cmd, permissive, roles, qual, with_check
    from pg_policies
    where schemaname = 'public'
      and (coalesce(qual,'') ilike '%auth.uid(%'
        or coalesce(qual,'') ilike '%auth.role(%'
        or coalesce(with_check,'') ilike '%auth.uid(%'
        or coalesce(with_check,'') ilike '%auth.role(%')
  loop
    new_qual := r.qual;
    new_with_check := r.with_check;

    if new_qual is not null then
      new_qual := replace(new_qual, 'auth.uid()', '(select auth.uid())');
      new_qual := replace(new_qual, 'auth.role()', '(select auth.role())');
    end if;

    if new_with_check is not null then
      new_with_check := replace(new_with_check, 'auth.uid()', '(select auth.uid())');
      new_with_check := replace(new_with_check, 'auth.role()', '(select auth.role())');
    end if;

    stmt := format('alter policy %I on %I.%I', r.policyname, r.schemaname, r.tablename);

    if r.roles is not null and array_length(r.roles,1) > 0 then
      stmt := stmt || ' to ' || array_to_string(r.roles, ', ');
    end if;

    if r.cmd = 'SELECT' then
      if new_qual is not null and length(new_qual) > 0 then
        stmt := stmt || ' using (' || new_qual || ')';
      end if;
    elsif r.cmd = 'INSERT' then
      if new_with_check is not null and length(new_with_check) > 0 then
        stmt := stmt || ' with check (' || new_with_check || ')';
      end if;
    elsif r.cmd = 'UPDATE' then
      if new_qual is not null and length(new_qual) > 0 then
        stmt := stmt || ' using (' || new_qual || ')';
      end if;
      if new_with_check is not null and length(new_with_check) > 0 then
        stmt := stmt || ' with check (' || new_with_check || ')';
      end if;
    elsif r.cmd = 'DELETE' then
      if new_qual is not null and length(new_qual) > 0 then
        stmt := stmt || ' using (' || new_qual || ')';
      end if;
    end if;

    execute stmt;
  end loop;
end $$;
