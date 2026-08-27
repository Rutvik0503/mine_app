-- Virtual Mining Empire - initial schema
-- Run with: supabase db push  (or paste into the Supabase SQL editor)
--
-- Design rules this migration enforces (see docs, sections 40-46):
--   1. Every user-owned table is readable only by its owner (RLS).
--   2. Client apps get SELECT only on mutable/economic tables - all writes
--      to balances, hashrate, levels, sessions, machines, etc. happen through
--      Edge Functions using the service_role key, which bypasses RLS.
--   3. `profiles` is the one exception: users may update their own display
--      fields (username/avatar_url), but a trigger silently reverts any
--      attempt to change protected columns (level, xp, hashrate, status...)
--      unless the request comes from the service_role.

create extension if not exists "pgcrypto";

-- =========================================================================
-- TABLES
-- =========================================================================

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null default '',
  username text not null default 'Miner',
  avatar_url text,
  level int not null default 1,
  xp int not null default 0,
  total_hashrate numeric not null default 0,
  streak_days int not null default 0,
  last_active_at timestamptz,
  referral_code text unique,
  referred_by uuid references public.profiles (id),
  status text not null default 'active' check (status in ('active', 'blocked', 'flagged')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.farm_types (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  base_multiplier numeric not null default 1.0,
  machine_capacity int not null default 1,
  unlock_level int not null default 1,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.farms (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles (id) on delete cascade,
  farm_type_id uuid not null references public.farm_types (id),
  name text not null default 'My Farm',
  level int not null default 1,
  capacity int not null default 1,
  multiplier numeric not null default 1.0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.machines (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  machine_type text not null default 'standard',
  base_hashrate numeric not null default 1.0,
  base_efficiency numeric not null default 0.8,
  max_level int not null default 10,
  image_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.user_machines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  farm_id uuid not null references public.farms (id) on delete cascade,
  machine_id uuid not null references public.machines (id),
  level int not null default 1,
  current_hashrate numeric not null default 0,
  current_efficiency numeric not null default 0.8,
  status text not null default 'active' check (status in ('active', 'inactive')),
  purchased_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.mining_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  farm_id uuid not null references public.farms (id) on delete cascade,
  started_at timestamptz not null default now(),
  expected_end_at timestamptz not null,
  completed_at timestamptz,
  hashrate_snapshot numeric not null default 0,
  reward_rate_snapshot numeric not null default 0,
  calculated_reward numeric,
  status text not null default 'active' check (status in ('active', 'completed', 'cancelled', 'expired')),
  created_at timestamptz not null default now()
);

create table if not exists public.reward_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null check (type in ('mining', 'mission', 'streak', 'referral', 'achievement', 'boost', 'adjustment')),
  amount numeric not null,
  source text,
  reference_id uuid,
  status text not null default 'completed' check (status in ('pending', 'completed', 'failed')),
  created_at timestamptz not null default now()
);

create table if not exists public.missions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  type text not null default 'custom' check (type in ('start_mining', 'claim_mining', 'upgrade_machine', 'custom')),
  target int not null default 1,
  reward_xp int not null default 0,
  reward_points numeric not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.user_missions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  mission_id uuid not null references public.missions (id) on delete cascade,
  progress int not null default 0,
  target int not null default 1,
  status text not null default 'in_progress' check (status in ('in_progress', 'completed', 'claimed')),
  date date not null default current_date,
  completed_at timestamptz,
  unique (user_id, mission_id, date)
);

create table if not exists public.streaks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles (id) on delete cascade,
  current_streak int not null default 0,
  longest_streak int not null default 0,
  last_completed_date date,
  updated_at timestamptz not null default now()
);

create table if not exists public.referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_id uuid not null references public.profiles (id) on delete cascade,
  referred_user_id uuid not null unique references public.profiles (id) on delete cascade,
  referral_code text not null,
  status text not null default 'pending' check (status in ('pending', 'active', 'rejected')),
  activated_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.boosts (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null default 'mining',
  multiplier numeric not null default 1.0,
  duration_minutes int not null default 30,
  source text not null default 'ad',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.user_boosts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  boost_id uuid not null references public.boosts (id),
  started_at timestamptz not null default now(),
  expires_at timestamptz not null,
  status text not null default 'active' check (status in ('active', 'expired'))
);

create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  condition_type text not null,
  condition_value numeric not null default 0,
  reward text,
  is_active boolean not null default true
);

create table if not exists public.user_achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  achievement_id uuid not null references public.achievements (id) on delete cascade,
  unlocked_at timestamptz not null default now(),
  unique (user_id, achievement_id)
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  body text not null default '',
  type text not null default 'general',
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.app_config (
  id uuid primary key default gen_random_uuid(),
  mining_rate numeric not null default 1.0,
  max_session_minutes int not null default 60,
  default_boost numeric not null default 1.0,
  referral_reward numeric not null default 50,
  maintenance_mode boolean not null default false,
  minimum_app_version text not null default '1.0.0',
  updated_at timestamptz not null default now()
);

-- Future phase (see doc section 35-36) - created now so the schema matches
-- the documented data model, kept empty/unused until wallet features ship.
create table if not exists public.wallet_accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  network text not null,
  wallet_address text not null,
  wallet_type text not null default 'external',
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table if not exists public.withdrawals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  wallet_id uuid references public.wallet_accounts (id),
  amount numeric not null,
  network text,
  fee numeric not null default 0,
  status text not null default 'pending' check (status in ('pending', 'processing', 'approved', 'rejected', 'completed', 'failed')),
  tx_hash text,
  requested_at timestamptz not null default now(),
  processed_at timestamptz,
  failure_reason text
);

create table if not exists public.admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid,
  action text not null,
  target_type text,
  target_id uuid,
  old_value jsonb,
  new_value jsonb,
  created_at timestamptz not null default now()
);

-- =========================================================================
-- INDEXES
-- =========================================================================

create index if not exists idx_farms_user on public.farms (user_id);
create index if not exists idx_user_machines_user on public.user_machines (user_id);
create index if not exists idx_mining_sessions_user_status on public.mining_sessions (user_id, status);
create index if not exists idx_reward_transactions_user on public.reward_transactions (user_id, created_at desc);
create index if not exists idx_user_missions_user_date on public.user_missions (user_id, date);
create index if not exists idx_referrals_referrer on public.referrals (referrer_id);
create index if not exists idx_user_boosts_user_status on public.user_boosts (user_id, status);
create index if not exists idx_notifications_user on public.notifications (user_id, created_at desc);
create index if not exists idx_profiles_hashrate on public.profiles (total_hashrate desc);
create index if not exists idx_profiles_level on public.profiles (level desc);
create index if not exists idx_profiles_streak on public.profiles (streak_days desc);

-- =========================================================================
-- PUBLIC LEADERBOARD VIEW (column-level privacy: no email/referred_by leak)
-- =========================================================================

create or replace view public.leaderboard_public as
select id, username, avatar_url, level, total_hashrate, streak_days
from public.profiles
where status = 'active';

-- =========================================================================
-- PROFILE PROTECTION TRIGGER
-- Client apps may update username/avatar_url on their own row; every other
-- column can only change through a service_role request (Edge Functions).
-- =========================================================================

create or replace function public.protect_profile_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() is distinct from 'service_role' then
    new.level := old.level;
    new.xp := old.xp;
    new.total_hashrate := old.total_hashrate;
    new.streak_days := old.streak_days;
    new.referral_code := old.referral_code;
    new.referred_by := old.referred_by;
    new.status := old.status;
    new.email := old.email;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_protect_profile_columns on public.profiles;
create trigger trg_protect_profile_columns
  before update on public.profiles
  for each row execute function public.protect_profile_columns();

-- =========================================================================
-- DAILY MISSIONS HELPER
-- Called by the client (via rpc) so today's mission rows exist on demand,
-- without needing a cron job. Runs as the calling user; only ever creates
-- rows for auth.uid(), never anyone else's.
-- =========================================================================

create or replace function public.ensure_daily_missions()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    return;
  end if;

  insert into public.user_missions (user_id, mission_id, progress, target, status, date)
  select v_user_id, m.id, 0, m.target, 'in_progress', current_date
  from public.missions m
  where m.is_active = true
  on conflict (user_id, mission_id, date) do nothing;
end;
$$;

grant execute on function public.ensure_daily_missions() to authenticated;

-- =========================================================================
-- ROW LEVEL SECURITY
-- =========================================================================

alter table public.profiles enable row level security;
alter table public.farms enable row level security;
alter table public.farm_types enable row level security;
alter table public.machines enable row level security;
alter table public.user_machines enable row level security;
alter table public.mining_sessions enable row level security;
alter table public.reward_transactions enable row level security;
alter table public.missions enable row level security;
alter table public.user_missions enable row level security;
alter table public.streaks enable row level security;
alter table public.referrals enable row level security;
alter table public.boosts enable row level security;
alter table public.user_boosts enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.notifications enable row level security;
alter table public.app_config enable row level security;
alter table public.wallet_accounts enable row level security;
alter table public.withdrawals enable row level security;
alter table public.admin_audit_logs enable row level security;

-- profiles: read own row, update own row (protected columns handled above)
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);

-- catalog tables: public read for any authenticated user, no client writes
create policy "farm_types_select" on public.farm_types for select using (auth.role() = 'authenticated');
create policy "machines_select" on public.machines for select using (auth.role() = 'authenticated');
create policy "missions_select" on public.missions for select using (auth.role() = 'authenticated');
create policy "boosts_select" on public.boosts for select using (auth.role() = 'authenticated');
create policy "achievements_select" on public.achievements for select using (auth.role() = 'authenticated');
create policy "app_config_select" on public.app_config for select using (auth.role() = 'authenticated');

-- user-owned tables: read own rows only, all writes go through Edge Functions
create policy "farms_select_own" on public.farms for select using (auth.uid() = user_id);
create policy "user_machines_select_own" on public.user_machines for select using (auth.uid() = user_id);
create policy "mining_sessions_select_own" on public.mining_sessions for select using (auth.uid() = user_id);
create policy "reward_transactions_select_own" on public.reward_transactions for select using (auth.uid() = user_id);
create policy "user_missions_select_own" on public.user_missions for select using (auth.uid() = user_id);
create policy "streaks_select_own" on public.streaks for select using (auth.uid() = user_id);
create policy "user_boosts_select_own" on public.user_boosts for select using (auth.uid() = user_id);
create policy "user_achievements_select_own" on public.user_achievements for select using (auth.uid() = user_id);
create policy "notifications_select_own" on public.notifications for select using (auth.uid() = user_id);
create policy "wallet_accounts_select_own" on public.wallet_accounts for select using (auth.uid() = user_id);
create policy "withdrawals_select_own" on public.withdrawals for select using (auth.uid() = user_id);

-- referrals: visible to the referrer (their invite list) and the referred user
create policy "referrals_select_own" on public.referrals
  for select using (auth.uid() = referrer_id or auth.uid() = referred_user_id);

-- notifications: user may mark their own notifications read (is_read only;
-- other columns are safe to allow here since only the owner can reach them)
create policy "notifications_update_own" on public.notifications
  for update using (auth.uid() = user_id);

-- admin_audit_logs: no client access at all (service_role / admin panel only)

-- =========================================================================
-- SEED DATA - minimal starter content so the app has something to show.
-- Tune all of this from the Admin Panel once it's running.
-- =========================================================================

insert into public.farm_types (name, description, base_multiplier, machine_capacity, unlock_level)
values
  ('Free Farm', 'Your starter virtual mining farm.', 1.00, 2, 1),
  ('Air Farm', 'More machine slots and airflow-cooled efficiency.', 1.10, 4, 5),
  ('Hydro Farm', 'Water-cooled farm with advanced machine support.', 1.25, 6, 10),
  ('Premium Farm', 'Premium progression with extra slots and visuals.', 1.50, 10, 15)
on conflict do nothing;

insert into public.machines (name, machine_type, base_hashrate, base_efficiency, max_level)
values
  ('Miner X1', 'standard', 1.0, 0.75, 10),
  ('Miner X5', 'standard', 2.8, 0.82, 10),
  ('Miner Pro 9', 'advanced', 6.5, 0.88, 12),
  ('Quantum Rig', 'advanced', 14.0, 0.92, 15)
on conflict do nothing;

insert into public.missions (title, description, type, target, reward_xp, reward_points)
values
  ('Start Mining', 'Start one mining session.', 'start_mining', 1, 100, 0),
  ('Collect Reward', 'Collect your mining reward.', 'claim_mining', 1, 150, 0),
  ('Upgrade a Machine', 'Upgrade one machine.', 'upgrade_machine', 1, 200, 0),
  ('Daily Check-in', 'Open the app and check your farm.', 'custom', 1, 50, 0)
on conflict do nothing;

insert into public.achievements (name, description, condition_type, condition_value)
values
  ('First Miner', 'Complete your first mining session.', 'mining_sessions_completed', 1),
  ('Machine Builder', 'Own 5 machines.', 'machines_owned', 5),
  ('Mining Master', 'Reach 100 TH/s.', 'total_hashrate', 100),
  ('Streak Master', 'Reach a 30-day streak.', 'streak_days', 30),
  ('Empire Builder', 'Reach Farm Level 10.', 'farm_level', 10),
  ('Recruiter', 'Activate 10 referrals.', 'active_referrals', 10)
on conflict do nothing;

insert into public.boosts (name, type, multiplier, duration_minutes, source)
values
  ('2X Mining Boost', 'mining', 2.0, 30, 'ad'),
  ('Speed Boost', 'speed', 1.5, 60, 'ad'),
  ('Efficiency Boost', 'efficiency', 1.3, 120, 'mission')
on conflict do nothing;

insert into public.app_config (mining_rate, max_session_minutes, default_boost, referral_reward, maintenance_mode, minimum_app_version)
select 1.0, 60, 1.0, 50, false, '1.0.0'
where not exists (select 1 from public.app_config);
