-- Lets a machine upgrade be paid for with money (Razorpay) as an
-- alternative to points, same as farm upgrades (0008). The price is worked
-- out per level at order time; razorpay-webhook applies the upgrade to
-- purchases.user_machine_id on payment.captured.
alter table public.purchases add column if not exists user_machine_id uuid
  references public.user_machines (id) on delete set null;

alter table public.purchases drop constraint if exists purchases_kind_check;
alter table public.purchases add constraint purchases_kind_check
  check (kind in ('points', 'session_extension', 'farm_upgrade', 'machine_rental', 'machine_upgrade'));
