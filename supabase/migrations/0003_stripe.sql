-- Stripe-powered points store. Users buy point packs with real money; those
-- points spend through the existing upgrade-machine/upgrade-farm Edge
-- Functions unchanged - Stripe never touches upgrade logic directly.
--
-- IMPORTANT (read before shipping to Play Store / App Store): both
-- platforms require their own in-app billing (Google Play Billing / Apple
-- IAP) for real-money purchases of virtual currency or upgrades consumed
-- inside the app - using Stripe directly for this is a policy violation and
-- will get the app rejected or suspended. This is safe to ship as a direct
-- APK / web build, not through the app stores, unless Stripe is later
-- swapped/added alongside platform billing for store builds.

create table if not exists public.store_packages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  points numeric not null,
  price_cents int not null,
  currency text not null default 'usd',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  package_id uuid references public.store_packages (id),
  stripe_payment_intent_id text not null unique,
  amount_cents int not null,
  currency text not null,
  points_granted numeric not null default 0,
  status text not null default 'pending' check (status in ('pending', 'succeeded', 'failed', 'refunded')),
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create index if not exists idx_purchases_user on public.purchases (user_id, created_at desc);

-- reward_transactions.type didn't include 'purchase' in 0001_init.sql.
alter table public.reward_transactions drop constraint if exists reward_transactions_type_check;
alter table public.reward_transactions add constraint reward_transactions_type_check
  check (type in ('mining', 'mission', 'streak', 'referral', 'achievement', 'boost', 'adjustment', 'purchase'));

alter table public.store_packages enable row level security;
alter table public.purchases enable row level security;

create policy "store_packages_select" on public.store_packages for select using (auth.role() = 'authenticated');
create policy "purchases_select_own" on public.purchases for select using (auth.uid() = user_id);
-- No client insert/update policies - only create-payment-intent and
-- stripe-webhook (service_role) ever write to purchases.

insert into public.store_packages (name, description, points, price_cents, currency)
values
  ('Starter Pack', '500 points to spend on upgrades.', 500, 299, 'usd'),
  ('Miner Pack', '2,000 points to spend on upgrades.', 2000, 999, 'usd'),
  ('Empire Pack', '6,000 points to spend on upgrades.', 6000, 2499, 'usd')
on conflict do nothing;
