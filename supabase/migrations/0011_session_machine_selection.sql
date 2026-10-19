-- Lets the player pick which of their miners a session runs on.
-- machine_ids holds the user_machines ids whose hashrate went into
-- hashrate_snapshot; null on sessions started before this existed (those
-- used every active machine).

alter table public.mining_sessions
  add column if not exists machine_ids uuid[];
