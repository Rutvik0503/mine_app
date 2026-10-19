-- Switch the points store from Stripe to Razorpay - India does not allow
-- new direct Stripe merchant sign-ups (RBI Payment Aggregator rules), while
-- Razorpay supports instant Indian business onboarding + UPI. See README
-- "Razorpay setup". Column names below replace the Stripe-specific ones
-- added in 0003_stripe.sql (kept as-is since it's already applied - this is
-- an incremental migration, not a rewrite of it).
--
-- IMPORTANT (unchanged from 0003): Google Play and the App Store both
-- require their own in-app billing (Google Play Billing / Apple IAP) for
-- real-money purchases of virtual currency consumed inside the app - this
-- applies no matter which payment gateway is used server-side. Razorpay
-- here is fine for direct-APK or web distribution, not a Play/App Store
-- listing, unless swapped/added alongside platform billing for store builds.

alter table public.purchases rename column stripe_payment_intent_id to razorpay_order_id;
alter table public.purchases add column if not exists razorpay_payment_id text;

alter table public.purchases alter column currency set default 'inr';
alter table public.store_packages alter column currency set default 'inr';

-- Re-price the starter packages in INR. price_cents holds the amount in the
-- currency's smallest unit (paise for INR, same role cents played for USD).
update public.store_packages set price_cents = 9900, currency = 'inr' where name = 'Starter Pack';
update public.store_packages set price_cents = 29900, currency = 'inr' where name = 'Miner Pack';
update public.store_packages set price_cents = 79900, currency = 'inr' where name = 'Empire Pack';
