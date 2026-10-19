-- 1. Close a real race: start-mining checks for an existing active session
-- then inserts a new one in two separate steps, so two concurrent calls
-- could both pass the check and create two active sessions for one user.
-- A partial unique index makes the second insert fail atomically instead;
-- start-mining/index.ts now catches that failure and returns the same
-- friendly "already active" error it already returns for the checked case.
create unique index if not exists uq_mining_sessions_one_active_per_user
  on public.mining_sessions (user_id)
  where status = 'active';

-- 2. Post-session engagement: once a session is ready to claim, the app
-- offers "watch an ad for +time" (free, capped) or "buy more time"
-- (Razorpay) before the user claims. See README "Session extension".
alter table public.mining_sessions add column if not exists ad_extensions_used int not null default 0;

alter table public.store_packages add column if not exists kind text not null default 'points'
  check (kind in ('points', 'session_extension'));
alter table public.store_packages add column if not exists extension_minutes int;

alter table public.purchases add column if not exists kind text not null default 'points'
  check (kind in ('points', 'session_extension'));
alter table public.purchases add column if not exists session_id uuid references public.mining_sessions (id);

insert into public.store_packages (name, description, points, price_cents, currency, kind, extension_minutes)
values ('Extra Mining Time', 'Extend your current session by 60 minutes.', 0, 1900, 'inr', 'session_extension', 60)
on conflict do nothing;
