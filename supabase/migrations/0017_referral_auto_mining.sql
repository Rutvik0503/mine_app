-- Referral reward: the player whose code was used gets a "24h Auto Mining"
-- pass - their next mining session runs 24 hours instead of the usual
-- length (and pays for 24 hours). Granted at the friend's signup
-- (create-profile); start-mining spends one pass per session.

alter table public.profiles add column if not exists auto_mining_passes int not null default 0;
alter table public.mining_sessions add column if not exists auto_mining boolean not null default false;

-- Only the server may hand out passes (same rule as level, xp, etc.).
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
    new.auto_mining_passes := old.auto_mining_passes;
  end if;
  new.updated_at := now();
  return new;
end;
$$;
