-- Closes gaps found cross-checking the master spec against the shipped app:
-- 1. device_tokens (spec section 30, "store device tokens securely") - no
--    table existed at all, so FCM tokens had nowhere to go once Firebase is
--    configured.
-- 2. xp_events - a per-grant XP ledger, needed for Weekly/Monthly XP
--    leaderboards (spec section 27 lists 5 categories; only Hashrate/Level/
--    Streak existed - profiles.xp alone can't answer "how much XP in the
--    last 7 days").
-- 3. Boost seed fixes: Efficiency Boost was seeded with source='mission' but
--    no code path ever granted a mission-sourced boost, so it was dead data.
--    Moved it to source='ad' (reachable via grant-ad-boost) alongside a new
--    Lucky Reward Boost, completing the 4 boost types from spec section 24.

create table if not exists public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  token text not null unique,
  platform text not null default 'android' check (platform in ('android', 'ios')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_device_tokens_user on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;
create policy "device_tokens_select_own" on public.device_tokens for select using (auth.uid() = user_id);
-- No client insert/update/delete policy - tokens are written by the
-- save-device-token path using the user's own JWT via a security-definer
-- RPC below (simpler than a whole Edge Function for a one-row upsert).

create or replace function public.save_device_token(p_token text, p_platform text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.device_tokens (user_id, token, platform, updated_at)
  values (auth.uid(), p_token, p_platform, now())
  on conflict (token) do update
    set user_id = excluded.user_id, platform = excluded.platform, updated_at = now();
end;
$$;
grant execute on function public.save_device_token(text, text) to authenticated;

create table if not exists public.xp_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  amount numeric not null,
  created_at timestamptz not null default now()
);
create index if not exists idx_xp_events_user_created on public.xp_events (user_id, created_at desc);

alter table public.xp_events enable row level security;
create policy "xp_events_select_own" on public.xp_events for select using (auth.uid() = user_id);
-- No client write policy - only grantXp() (service_role, inside Edge
-- Functions) ever inserts here.

create or replace function public.leaderboard_xp(period text, limit_count int default 50)
returns table(id uuid, username text, avatar_url text, value numeric)
language sql
security definer
set search_path = public
stable
as $$
  select p.id, p.username, p.avatar_url, coalesce(sum(e.amount), 0) as value
  from public.profiles p
  join public.xp_events e on e.user_id = p.id
  where p.status = 'active'
    and e.created_at >= case
      when period = 'weekly' then date_trunc('week', now())
      when period = 'monthly' then date_trunc('month', now())
      else '-infinity'::timestamptz
    end
  group by p.id, p.username, p.avatar_url
  order by value desc
  limit limit_count;
$$;
grant execute on function public.leaderboard_xp(text, int) to authenticated;

update public.boosts set source = 'ad' where name = 'Efficiency Boost';
insert into public.boosts (name, type, multiplier, duration_minutes, source)
values ('Lucky Reward Boost', 'lucky', 1.5, 45, 'ad')
on conflict do nothing;

-- 4. Splash must check maintenance mode / minimum version before the user
--    is even logged in (spec section 9), but app_config's original policy
--    only allowed auth.role() = 'authenticated' - a logged-out client (anon
--    key, no session) is role 'anon' and got zero rows back, silently. Not
--    sensitive data (game-balance numbers), safe to also expose to 'anon'.
drop policy if exists "app_config_select" on public.app_config;
create policy "app_config_select" on public.app_config
  for select using (auth.role() in ('authenticated', 'anon'));
