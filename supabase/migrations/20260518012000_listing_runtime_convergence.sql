alter table public.listings
  add column if not exists seller_id uuid references public.sellers(id) on delete restrict,
  add column if not exists brand text,
  add column if not exists currency text not null default 'DZD',
  add column if not exists oem_part_number text,
  add column if not exists manufacturer_ref text,
  add column if not exists defect_notes text,
  add column if not exists missing_pieces text,
  add column if not exists wilaya_id integer references public.wilayas(id),
  add column if not exists commune_id text references public.communes(id),
  add column if not exists vehicle_fitment jsonb not null default '[]'::jsonb,
  add column if not exists fulfillment_mode text not null default 'pickup',
  add column if not exists exchange_description text,
  add column if not exists is_available boolean not null default true;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'listings_fulfillment_mode_check'
  ) then
    alter table public.listings
      add constraint listings_fulfillment_mode_check
      check (fulfillment_mode in ('pickup'));
  end if;
end $$;

update public.listings l
set seller_id = s.id
from public.sellers s
where s.user_id = l.seller_user_id
  and l.seller_id is null;

update public.listings
set wilaya_id = nullif(wilaya_code, '')::integer
where wilaya_id is null
  and nullif(wilaya_code, '') is not null;

update public.listings
set commune_id = nullif(commune_code, '')
where commune_id is null
  and nullif(commune_code, '') is not null;

update public.listings l
set brand = lf.brand_code,
    vehicle_fitment = jsonb_build_array(
      jsonb_build_object(
        'make', lf.brand_code,
        'model', lf.model_code,
        'year', lf.model_year
      )
    )
from public.listing_fitments lf
where lf.listing_id = l.id
  and (
    l.brand is null
    or l.brand = ''
    or l.vehicle_fitment = '[]'::jsonb
  );

create index if not exists idx_listings_seller_runtime on public.listings(seller_id);
create index if not exists idx_listings_wilaya_runtime on public.listings(wilaya_id);
create index if not exists idx_listings_commune_runtime on public.listings(commune_id);
create index if not exists idx_listings_brand_runtime on public.listings(brand);
create index if not exists idx_listings_vehicle_fitment_runtime
  on public.listings using gin(vehicle_fitment);
