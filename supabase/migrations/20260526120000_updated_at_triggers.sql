-- Auto-update updated_at on row modification for all tables that carry the column.
-- A single shared trigger function replaces the per-table functions that existed before.
-- Verified against live DB: 11 tables have updated_at; device_tokens already had a
-- bespoke trigger (device_tokens_updated_at / update_device_tokens_updated_at) which
-- is consolidated here.

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- profiles
create or replace trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.handle_updated_at();

-- listings
create or replace trigger trg_listings_updated_at
  before update on public.listings
  for each row execute function public.handle_updated_at();

-- sellers
create or replace trigger trg_sellers_updated_at
  before update on public.sellers
  for each row execute function public.handle_updated_at();

-- deals
create or replace trigger trg_deals_updated_at
  before update on public.deals
  for each row execute function public.handle_updated_at();

-- disputes
create or replace trigger trg_disputes_updated_at
  before update on public.disputes
  for each row execute function public.handle_updated_at();

-- notification_preferences
create or replace trigger trg_notification_preferences_updated_at
  before update on public.notification_preferences
  for each row execute function public.handle_updated_at();

-- part_categories
create or replace trigger trg_part_categories_updated_at
  before update on public.part_categories
  for each row execute function public.handle_updated_at();

-- device_tokens: replace the old per-table trigger with the shared function
drop trigger if exists device_tokens_updated_at on public.device_tokens;
create or replace trigger trg_device_tokens_updated_at
  before update on public.device_tokens
  for each row execute function public.handle_updated_at();

-- contract tables (admin-managed, but still benefit from accurate timestamps)
create or replace trigger trg_app_domain_catalog_updated_at
  before update on public.app_domain_catalog
  for each row execute function public.handle_updated_at();

create or replace trigger trg_app_domain_codes_updated_at
  before update on public.app_domain_codes
  for each row execute function public.handle_updated_at();

create or replace trigger trg_app_policy_options_updated_at
  before update on public.app_policy_options
  for each row execute function public.handle_updated_at();
