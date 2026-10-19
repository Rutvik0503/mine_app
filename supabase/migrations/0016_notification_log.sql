-- The in-app Notifications screen lists everything the player was sent:
-- server pushes are inserted server-side (_shared/fcm.ts), and reminders the
-- phone schedules itself (ReminderService) are logged by the app once they
-- have fired, through log_my_notification below.

-- Dedupe key for app-logged reminders, e.g. "local:100:2026-10-20T19:00".
alter table public.notifications add column if not exists client_ref text;
create unique index if not exists uq_notifications_user_client_ref
  on public.notifications (user_id, client_ref) where client_ref is not null;

create or replace function public.log_my_notification(
  p_title text,
  p_body text,
  p_type text,
  p_created_at timestamptz,
  p_client_ref text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in';
  end if;
  -- Only reminders that already went off, and not ancient ones.
  if p_created_at > now() + interval '5 minutes' or p_created_at < now() - interval '30 days' then
    return;
  end if;
  insert into public.notifications (user_id, title, body, type, created_at, client_ref)
  values (auth.uid(), left(p_title, 200), left(coalesce(p_body, ''), 500), left(coalesce(p_type, 'general'), 40),
          p_created_at, p_client_ref)
  on conflict (user_id, client_ref) where client_ref is not null do nothing;
end;
$$;
grant execute on function public.log_my_notification(text, text, text, timestamptz, text) to authenticated;
