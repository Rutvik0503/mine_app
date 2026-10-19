-- Server-sent pushes (Firebase Cloud Messaging) go out in the language the
-- player picked in the app, so each device token remembers it.
alter table public.device_tokens add column if not exists language text not null default 'en'
  check (language in ('en', 'gu', 'hi'));

-- Re-engagement pushes: when this device last got one, so a player is
-- nudged at most once per step (3 days idle, 7 days idle).
alter table public.device_tokens add column if not exists last_reengaged_at timestamptz;

drop function if exists public.save_device_token(text, text);
create or replace function public.save_device_token(p_token text, p_platform text, p_language text default 'en')
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.device_tokens (user_id, token, platform, language, updated_at)
  values (
    auth.uid(),
    p_token,
    p_platform,
    case when p_language in ('en', 'gu', 'hi') then p_language else 'en' end,
    now()
  )
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        language = excluded.language,
        updated_at = now();
end;
$$;
grant execute on function public.save_device_token(text, text, text) to authenticated;
