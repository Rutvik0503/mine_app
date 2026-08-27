-- Admin panel access. Rows here are separate from `profiles` (players) on
-- purpose - an admin's Supabase Auth user is never a game character.
--
-- There is no self-service signup for admins: after deploying, create your
-- first admin from the Supabase SQL editor:
--
--   insert into public.admin_users (id, role)
--   values ('<the auth.users.id of your admin account>', 'superadmin');
--
-- (Create that auth user first via Authentication -> Users -> Add user.)

create table if not exists public.admin_users (
  id uuid primary key references auth.users (id) on delete cascade,
  role text not null default 'admin' check (role in ('admin', 'superadmin')),
  created_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;

-- An admin may only read their own membership row (used by the admin panel
-- to decide whether to let them in - see admin_panel/lib/requireAdmin.ts).
-- All actual admin reads/writes to game tables go through the service_role
-- key from Next.js Server Actions, which bypasses RLS entirely.
create policy "admin_users_select_own" on public.admin_users for select using (auth.uid() = id);
