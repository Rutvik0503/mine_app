-- Coins for levelling up: grantXp records them as a 'level_up' reward.
alter table public.reward_transactions drop constraint if exists reward_transactions_type_check;
alter table public.reward_transactions add constraint reward_transactions_type_check
  check (type = any (array['mining', 'mission', 'streak', 'referral', 'achievement', 'boost',
                           'adjustment', 'purchase', 'spin', 'ad_reward', 'level_up']));
