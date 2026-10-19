-- Lets a farm upgrade be paid for with real money (Razorpay) as an
-- alternative to points, not just as a fallback when points run out - the
-- upgrade dialog now always offers both. Cost is computed dynamically per
-- level (farmUpgradeCostForLevel), so unlike points/session_extension this
-- kind has no store_packages row - purchases.package_id stays null and
-- razorpay-webhook upgrades the buyer's farm directly on payment.captured.
alter table public.purchases drop constraint if exists purchases_kind_check;
alter table public.purchases add constraint purchases_kind_check
  check (kind in ('points', 'session_extension', 'farm_upgrade'));
