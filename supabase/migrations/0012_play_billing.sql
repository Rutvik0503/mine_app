-- Google Play Billing replaces Razorpay for everything sold in the app.
-- Google Play's payments policy requires Play Billing for in-app digital
-- goods, so real money now only buys coin packs and Extra Mining Time;
-- miners, farm upgrades and machine upgrades are bought with coins.

-- Each sellable package maps to one Play Console in-app product (consumable).
alter table public.store_packages add column if not exists play_product_id text unique;

-- Play purchases have no Razorpay order.
alter table public.purchases alter column razorpay_order_id drop not null;
alter table public.purchases add column if not exists provider text not null default 'razorpay'
  check (provider in ('razorpay', 'google_play'));
-- Google's purchase token - unique, so one Play purchase can only ever be
-- granted once (verify-play-purchase relies on this).
alter table public.purchases add column if not exists play_purchase_token text unique;
alter table public.purchases add column if not exists play_order_id text;

-- Coin packs priced to match the miner plans (Rs 1 ~ 2 coins), with a bigger
-- bonus on bigger packs. The old Razorpay-era packs (Rs 1 ~ 5 coins) are
-- retired rather than deleted so past purchases keep their package row.
update public.store_packages set is_active = false where kind = 'points' and play_product_id is null;

insert into public.store_packages (name, description, points, price_cents, currency, kind, play_product_id)
values
  ('200 Coins', 'A small top-up for your next miner.', 200, 9900, 'inr', 'points', 'coins_200'),
  ('650 Coins', '+9% bonus coins.', 650, 29900, 'inr', 'points', 'coins_650'),
  ('1,800 Coins', '+13% bonus coins.', 1800, 79900, 'inr', 'points', 'coins_1800'),
  ('4,800 Coins', '+20% bonus coins.', 4800, 199900, 'inr', 'points', 'coins_4800'),
  ('12,500 Coins', '+25% bonus coins.', 12500, 499900, 'inr', 'points', 'coins_12500'),
  ('26,000 Coins', '+30% bonus coins - best value.', 26000, 999900, 'inr', 'points', 'coins_26000')
on conflict (play_product_id) do nothing;

update public.store_packages
  set play_product_id = 'extra_time_60'
  where kind = 'session_extension' and play_product_id is null and is_active;
