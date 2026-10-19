-- Mining Farm store + Fortune spin wheel.
--
-- 1. Rentable miners grouped by farm category (Air / Hydro / Premium), each
--    with fixed-duration plans (1 week / 1 month / 3 months). A plan is paid
--    once - either with coins (the app's existing points balance) or with
--    money via Razorpay - and grants a user_machines row that stops counting
--    towards hashrate at expires_at. No auto-renew.
-- 2. A daily spin wheel that pays out coins: a few free spins per day plus
--    extra spins unlocked by rewarded ads, all decided server-side in the
--    spin-wheel Edge Function.

-- ---------------------------------------------------------------------------
-- Miners + plans
-- ---------------------------------------------------------------------------

alter table public.machines add column if not exists farm_category text
  check (farm_category in ('air', 'hydro', 'premium'));
alter table public.machines add column if not exists power_watts int;

create table if not exists public.machine_plans (
  id uuid primary key default gen_random_uuid(),
  machine_id uuid not null references public.machines (id) on delete cascade,
  label text not null,
  duration_days int not null check (duration_days > 0),
  price_paise int not null check (price_paise > 0),
  price_coins numeric not null check (price_coins > 0),
  is_popular boolean not null default false,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists idx_machine_plans_machine on public.machine_plans (machine_id, sort_order);

alter table public.machine_plans enable row level security;
drop policy if exists "machine_plans_select" on public.machine_plans;
create policy "machine_plans_select" on public.machine_plans
  for select using (auth.role() = 'authenticated');

-- Rented machines expire; owned/starter machines keep expires_at null.
alter table public.user_machines add column if not exists expires_at timestamptz;
alter table public.user_machines add column if not exists plan_id uuid references public.machine_plans (id);

-- Machine rentals can be paid for through Razorpay too.
alter table public.purchases add column if not exists plan_id uuid references public.machine_plans (id);
alter table public.purchases drop constraint if exists purchases_kind_check;
alter table public.purchases add constraint purchases_kind_check
  check (kind in ('points', 'session_extension', 'farm_upgrade', 'machine_rental'));

-- Seed the catalogue. Hashrate is in the same unit as the starter Miner X1
-- (1.0 = 1 coin/hour at mining_rate 1.0), so these are tuned to the existing
-- economy rather than copied from real-world TH/s figures. Prices live in
-- machine_plans and can be edited from the SQL editor / admin panel.
insert into public.machines (name, machine_type, base_hashrate, base_efficiency, max_level, farm_category, power_watts, description)
select v.name, v.machine_type, v.base_hashrate, v.base_efficiency, 1, v.farm_category, v.power_watts, v.description
from (values
  ('AirCore T1',     'standard', 3.0,  0.80, 'air',     950,  'Entry air-cooled miner.'),
  ('AeroMine 12',    'standard', 5.0,  0.82, 'air',     1100, 'Compact air-cooled miner with better airflow.'),
  ('Volt A9',        'standard', 8.0,  0.84, 'air',     1350, 'Balanced air-cooled workhorse.'),
  ('Volt A9 Pro',    'standard', 10.0, 0.85, 'air',     1450, 'Tuned Volt A9 with higher clock speeds.'),
  ('Aero M30',       'standard', 14.0, 0.86, 'air',     1700, 'Top of the air-cooled range.'),
  ('Hydra H1',       'advanced', 18.0, 0.87, 'hydro',   2100, 'Entry water-cooled miner.'),
  ('Hydra H2',       'advanced', 22.0, 0.88, 'hydro',   2300, 'Quiet water-cooled miner.'),
  ('Hydra XP',       'advanced', 26.0, 0.89, 'hydro',   2600, 'High-pressure loop for steady output.'),
  ('Aqua M6',        'advanced', 30.0, 0.90, 'hydro',   2800, 'Dual-loop water-cooled miner.'),
  ('Hydra H5',       'advanced', 35.0, 0.90, 'hydro',   3100, 'Flagship hydro miner.'),
  ('Titan P1',       'advanced', 45.0, 0.91, 'premium', 3400, 'Premium miner with auto-maintenance.'),
  ('Titan P2',       'advanced', 60.0, 0.92, 'premium', 3800, 'Premium miner with extra cooling.'),
  ('Nova X',         'advanced', 75.0, 0.93, 'premium', 4200, 'High-end premium miner.'),
  ('Nova Ultra',     'advanced', 90.0, 0.94, 'premium', 4600, 'Ultra-tier premium miner.'),
  ('Quantum Titan',  'advanced', 120.0, 0.95, 'premium', 5200, 'The fastest miner in the store.')
) as v(name, machine_type, base_hashrate, base_efficiency, farm_category, power_watts, description)
where not exists (select 1 from public.machines m where m.name = v.name);

-- Three plans per store miner. Price scales with hashrate: the 1-month plan
-- is the "popular" best per-day value, 3 months is cheapest per day.
insert into public.machine_plans (machine_id, label, duration_days, price_paise, price_coins, is_popular, sort_order)
select m.id, p.label, p.duration_days,
       greatest(4900, round(m.base_hashrate * p.paise_per_th / 100) * 100)::int,
       round(m.base_hashrate * p.coins_per_th),
       p.is_popular, p.sort_order
from public.machines m
cross join (values
  ('1 Week',   7,  3000,  60,  false, 1),
  ('1 Month',  30, 9000,  200, true,  2),
  ('3 Months', 90, 22000, 500, false, 3)
) as p(label, duration_days, paise_per_th, coins_per_th, is_popular, sort_order)
where m.farm_category is not null
  and not exists (select 1 from public.machine_plans mp where mp.machine_id = m.id);

-- ---------------------------------------------------------------------------
-- Spin wheel
-- ---------------------------------------------------------------------------

alter table public.reward_transactions drop constraint if exists reward_transactions_type_check;
alter table public.reward_transactions add constraint reward_transactions_type_check
  check (type in ('mining', 'mission', 'streak', 'referral', 'achievement', 'boost', 'adjustment', 'purchase', 'spin'));

create table if not exists public.spin_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  source text not null check (source in ('free', 'ad')),
  segment int not null check (segment between 0 and 8),
  reward numeric not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists idx_spin_logs_user_day on public.spin_logs (user_id, created_at desc);

alter table public.spin_logs enable row level security;
drop policy if exists "spin_logs_select_own" on public.spin_logs;
create policy "spin_logs_select_own" on public.spin_logs
  for select using (auth.uid() = user_id);
