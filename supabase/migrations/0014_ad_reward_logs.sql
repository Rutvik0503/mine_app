-- Log of rewarded-ad grants that don't move coins (e.g. "speed up"), so
-- grant-ad-reward can cap them per day across all sessions. Server-only:
-- RLS on with no policies, so only the service role reads or writes it.
create table if not exists public.ad_reward_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  kind text not null,
  reference_id uuid,
  created_at timestamptz not null default now()
);

create index if not exists idx_ad_reward_logs_user_kind_day
  on public.ad_reward_logs (user_id, kind, created_at desc);

alter table public.ad_reward_logs enable row level security;
