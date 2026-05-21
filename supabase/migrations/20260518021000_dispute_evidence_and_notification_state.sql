insert into storage.buckets (id, name, public)
select 'dispute-evidence', 'dispute-evidence', false
where not exists (
  select 1 from storage.buckets where id = 'dispute-evidence'
);

drop policy if exists "dispute evidence owner insert" on storage.objects;
create policy "dispute evidence owner insert"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'dispute-evidence'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "dispute evidence owner read" on storage.objects;
create policy "dispute evidence owner read"
on storage.objects for select
to authenticated
using (
  bucket_id = 'dispute-evidence'
  and (
    auth.uid()::text = (storage.foldername(name))[1]
    or exists (
      select 1
      from public.profiles p
      where p.id = auth.uid()
        and p.role in ('admin', 'super_admin')
        and p.is_active = true
    )
  )
);

create table if not exists public.dispute_evidence (
  id uuid primary key default gen_random_uuid(),
  dispute_id uuid not null references public.disputes(id) on delete cascade,
  uploaded_by uuid not null references public.profiles(id) on delete cascade,
  storage_path text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_dispute_evidence_dispute
on public.dispute_evidence(dispute_id, created_at desc);

alter table public.dispute_evidence enable row level security;

drop policy if exists "Dispute participants can read evidence" on public.dispute_evidence;
create policy "Dispute participants can read evidence"
  on public.dispute_evidence for select
  using (
    exists (
      select 1
      from public.disputes d
      join public.deals deal on deal.id = d.deal_id
      where d.id = dispute_id
        and (
          deal.buyer_id = auth.uid()
          or deal.seller_id = auth.uid()
          or exists (
            select 1
            from public.profiles p
            where p.id = auth.uid()
              and p.role in ('admin', 'super_admin')
              and p.is_active = true
          )
        )
    )
  );

drop policy if exists "Dispute filer can upload evidence" on public.dispute_evidence;
create policy "Dispute filer can upload evidence"
  on public.dispute_evidence for insert
  with check (
    uploaded_by = auth.uid()
    and exists (
      select 1
      from public.disputes d
      where d.id = dispute_id
        and d.filed_by = auth.uid()
    )
  );

create or replace function public.mark_notification_state(
  p_notification_id uuid,
  p_is_read boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.notifications
  set is_read = p_is_read
  where user_id = auth.uid()
    and id = p_notification_id;
end;
$$;

grant execute on function public.mark_notification_state(uuid, boolean) to authenticated;
