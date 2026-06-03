-- Algeria offline payment workflow for deals.

insert into public.app_domain_codes (domain_key, code, sort_order)
values
  ('deal_status', 'payment_proof_submitted', 35),
  ('deal_status', 'payment_confirmed', 45)
on conflict (domain_key, code) do update
set sort_order = excluded.sort_order,
    is_active = true,
    updated_at = now();

insert into public.app_policy_options (policy_type, code, label_key, sort_order)
values
  ('buyer_payment_method', 'ccp', 'transactionPaymentMethodCcp', 10),
  ('buyer_payment_method', 'baridimob', 'transactionPaymentMethodBaridiMob', 20),
  ('buyer_payment_method', 'cash', 'transactionPaymentMethodCash', 30)
on conflict (policy_type, code) do update
set label_key = excluded.label_key,
    sort_order = excluded.sort_order,
    is_active = true,
    updated_at = now();

alter table public.deals
  add column if not exists payment_method text,
  add column if not exists payment_proof_path text,
  add column if not exists payment_proof_submitted_at timestamptz,
  add column if not exists payment_confirmed_at timestamptz;

alter table public.deals
  drop constraint if exists deals_payment_method_check;

alter table public.deals
  add constraint deals_payment_method_check
  check (
    payment_method is null
    or payment_method in ('ccp', 'baridimob', 'cash')
  );

alter table public.deals
  drop constraint if exists deals_status_check;

alter table public.deals
  add constraint deals_status_check
  check (
    status in (
      'intent_created',
      'pending_seller_response',
      'seller_confirmed',
      'payment_proof_submitted',
      'payment_confirmed',
      'expired',
      'cancelled',
      'completed',
      'dispute_opened',
      'dispute_resolved'
    )
  );

drop index if exists idx_one_active_deal_per_listing;
create unique index if not exists idx_one_active_deal_per_listing
on public.deals (listing_id)
where status in (
  'intent_created',
  'pending_seller_response',
  'seller_confirmed',
  'payment_proof_submitted',
  'payment_confirmed'
);

insert into storage.buckets (id, name, public)
select 'deal-payment-proofs', 'deal-payment-proofs', false
where not exists (
  select 1 from storage.buckets where id = 'deal-payment-proofs'
);

drop policy if exists "deal payment proof owner insert" on storage.objects;
create policy "deal payment proof owner insert"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'deal-payment-proofs'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "deal payment proof owner read" on storage.objects;
create policy "deal payment proof owner read"
on storage.objects for select
to authenticated
using (
  bucket_id = 'deal-payment-proofs'
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

drop policy if exists "Buyer can create dispute for own deal" on public.disputes;
create policy "Buyer or seller can create dispute for own deal"
  on public.disputes
  for insert
  to authenticated
  with check (
    filed_by = (select auth.uid())
    and deal_id in (
      select id from deals
      where (buyer_id = (select auth.uid()) or seller_id = (select auth.uid()))
        and status = any(
          array[
            'seller_confirmed',
            'payment_proof_submitted',
            'payment_confirmed',
            'completed',
            'dispute_opened'
          ]
        )
    )
  );

create or replace function public.transition_deal(
  p_deal_id uuid,
  p_next_status text
)
returns public.deals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deal public.deals%rowtype;
  v_previous_status text;
  v_is_buyer boolean := false;
  v_is_seller boolean := false;
  v_now timestamptz := now();
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  select *
  into v_deal
  from public.deals
  where id = p_deal_id;

  if not found then
    raise exception 'deal not found';
  end if;

  v_is_buyer := v_deal.buyer_id = auth.uid();
  v_is_seller := v_deal.seller_id = auth.uid();
  v_previous_status := v_deal.status;

  if not v_is_buyer and not v_is_seller then
    raise exception 'transition denied';
  end if;

  if v_deal.status = 'intent_created' then
    if p_next_status <> 'pending_seller_response' or not v_is_buyer then
      raise exception 'transition denied';
    end if;
  elsif v_deal.status = 'pending_seller_response' then
    if p_next_status = 'seller_confirmed' and v_is_seller then
      null;
    elsif p_next_status = 'expired' and v_is_seller then
      null;
    elsif p_next_status = 'cancelled' and (v_is_buyer or v_is_seller) then
      null;
    else
      raise exception 'transition denied';
    end if;
  elsif v_deal.status = 'seller_confirmed' then
    if p_next_status = 'completed'
       and v_is_seller
       and v_deal.payment_method = 'cash' then
      null;
    elsif p_next_status = 'cancelled' and (v_is_buyer or v_is_seller) then
      null;
    else
      raise exception 'transition denied';
    end if;
  elsif v_deal.status = 'payment_proof_submitted' then
    if p_next_status = 'payment_confirmed' and v_is_seller then
      null;
    elsif p_next_status = 'cancelled' and (v_is_buyer or v_is_seller) then
      null;
    elsif p_next_status = 'dispute_opened' and (v_is_buyer or v_is_seller) then
      null;
    else
      raise exception 'transition denied';
    end if;
  elsif v_deal.status = 'payment_confirmed' then
    if p_next_status = 'completed' and v_is_buyer then
      null;
    elsif p_next_status = 'dispute_opened' and (v_is_buyer or v_is_seller) then
      null;
    else
      raise exception 'transition denied';
    end if;
  elsif v_deal.status = 'dispute_opened' then
    if p_next_status <> 'dispute_resolved' then
      raise exception 'transition denied';
    end if;
  else
    raise exception 'transition denied';
  end if;

  update public.deals
  set status = p_next_status,
      confirmed_at = case
        when p_next_status = 'seller_confirmed' then v_now
        else confirmed_at
      end,
      payment_confirmed_at = case
        when p_next_status = 'payment_confirmed' then v_now
        else payment_confirmed_at
      end,
      completed_at = case
        when p_next_status = 'completed' then v_now
        else completed_at
      end,
      cancelled_at = case
        when p_next_status = 'cancelled' then v_now
        else cancelled_at
      end,
      cancelled_by = case
        when p_next_status = 'cancelled' then auth.uid()
        else cancelled_by
      end,
      updated_at = v_now
  where id = p_deal_id
  returning * into v_deal;

  insert into public.deal_events (
    deal_id,
    event_type,
    actor_id,
    metadata,
    created_at
  )
  values (
    p_deal_id,
    p_next_status,
    auth.uid(),
    jsonb_build_object('from_status', v_previous_status),
    v_now
  );

  if p_next_status in ('cancelled', 'expired') then
    update public.listings
    set is_available = true,
        updated_at = v_now
    where id = v_deal.listing_id
      and status = 'active';
  end if;

  return v_deal;
end;
$$;

grant execute on function public.transition_deal(uuid, text) to authenticated;

create or replace function public.select_deal_payment_method(
  p_deal_id uuid,
  p_payment_method text
)
returns public.deals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deal public.deals%rowtype;
  v_now timestamptz := now();
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  if p_payment_method not in ('ccp', 'baridimob', 'cash') then
    raise exception 'invalid payment method';
  end if;

  select *
  into v_deal
  from public.deals
  where id = p_deal_id;

  if not found then
    raise exception 'deal not found';
  end if;

  if v_deal.buyer_id <> auth.uid() or v_deal.status <> 'seller_confirmed' then
    raise exception 'transition denied';
  end if;

  update public.deals
  set payment_method = p_payment_method,
      payment_proof_path = null,
      payment_proof_submitted_at = null,
      payment_confirmed_at = null,
      updated_at = v_now
  where id = p_deal_id
  returning * into v_deal;

  insert into public.deal_events (
    deal_id,
    event_type,
    actor_id,
    metadata,
    created_at
  )
  values (
    p_deal_id,
    'payment_method_selected',
    auth.uid(),
    jsonb_build_object('payment_method', p_payment_method),
    v_now
  );

  return v_deal;
end;
$$;

grant execute on function public.select_deal_payment_method(uuid, text) to authenticated;

create or replace function public.submit_deal_payment_proof(
  p_deal_id uuid,
  p_storage_path text
)
returns public.deals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deal public.deals%rowtype;
  v_now timestamptz := now();
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  select *
  into v_deal
  from public.deals
  where id = p_deal_id;

  if not found then
    raise exception 'deal not found';
  end if;

  if v_deal.buyer_id <> auth.uid()
     or v_deal.status <> 'seller_confirmed'
     or v_deal.payment_method not in ('ccp', 'baridimob') then
    raise exception 'transition denied';
  end if;

  update public.deals
  set status = 'payment_proof_submitted',
      payment_proof_path = nullif(trim(coalesce(p_storage_path, '')), ''),
      payment_proof_submitted_at = v_now,
      payment_confirmed_at = null,
      updated_at = v_now
  where id = p_deal_id
  returning * into v_deal;

  insert into public.deal_events (
    deal_id,
    event_type,
    actor_id,
    metadata,
    created_at
  )
  values (
    p_deal_id,
    'payment_proof_submitted',
    auth.uid(),
    jsonb_build_object('storage_path', p_storage_path),
    v_now
  );

  return v_deal;
end;
$$;

grant execute on function public.submit_deal_payment_proof(uuid, text) to authenticated;

create or replace function public.reject_deal_payment_proof(
  p_deal_id uuid
)
returns public.deals
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deal public.deals%rowtype;
  v_now timestamptz := now();
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  select *
  into v_deal
  from public.deals
  where id = p_deal_id;

  if not found then
    raise exception 'deal not found';
  end if;

  if v_deal.seller_id <> auth.uid()
     or v_deal.status <> 'payment_proof_submitted' then
    raise exception 'transition denied';
  end if;

  update public.deals
  set status = 'seller_confirmed',
      payment_proof_path = null,
      payment_proof_submitted_at = null,
      payment_confirmed_at = null,
      updated_at = v_now
  where id = p_deal_id
  returning * into v_deal;

  insert into public.deal_events (
    deal_id,
    event_type,
    actor_id,
    metadata,
    created_at
  )
  values (
    p_deal_id,
    'payment_proof_rejected',
    auth.uid(),
    jsonb_build_object('from_status', 'payment_proof_submitted'),
    v_now
  );

  return v_deal;
end;
$$;

grant execute on function public.reject_deal_payment_proof(uuid) to authenticated;
