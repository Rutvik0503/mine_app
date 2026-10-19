-- Opt-in rewarded ad placements (grant-ad-reward):
--   * "Speed up" a running mining session by 10 minutes, capped per session.
--   * "Free coins" from Home / Store, capped per day.

alter table public.mining_sessions add column if not exists ad_speedups_used int not null default 0;

alter table public.reward_transactions drop constraint if exists reward_transactions_type_check;
alter table public.reward_transactions add constraint reward_transactions_type_check
  check (type in ('mining', 'mission', 'streak', 'referral', 'achievement', 'boost', 'adjustment', 'purchase', 'spin', 'ad_reward'));
