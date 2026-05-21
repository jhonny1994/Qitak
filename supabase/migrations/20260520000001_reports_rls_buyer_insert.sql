drop policy if exists "Reporter can create own reports" on public.reports;

create policy "Buyer can create own listing reports"
on public.reports
for insert
to authenticated
with check (
  reporter_id = auth.uid()
  and reported_entity_type = 'listing'
  and exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'buyer'
      and p.is_active = true
  )
  and exists (
    select 1
    from public.listings l
    where l.id = reported_entity_id
      and l.seller_user_id <> auth.uid()
  )
);
