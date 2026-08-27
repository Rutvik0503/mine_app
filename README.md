# Virtual Mining Empire

An original virtual mining/farm progression app. Flutter + GetX client,
Supabase (Postgres + Auth + Edge Functions + Storage) backend, Next.js admin
panel. Built from `Virtual Mining Empire — Complete Master Project
Documentation.pdf` / `Virtual_Mining_Empire_Full_Development_Documentation.pdf`.

This is **not** a copy of MiningPeria/GoMining/PowerMine/BitCloudFarm - those
were used only as product inspiration; all UI, copy, branding and the game
economy here are original (see doc section 1).

## Repository layout

```
mining/                  Flutter app (this is also the Flutter project root)
  lib/
    core/                constants, theme, routing, services, shared widgets,
                          and the server_model layer (model/service/repository
                          per feature, talking to Supabase)
    features/             one folder per screen (view + GetX controller)
supabase/
  migrations/            Postgres schema, RLS policies, seed data
  functions/              Edge Functions (Deno/TypeScript) - all sensitive
                          writes (mining, upgrades, rewards) happen here,
                          never directly from Flutter
admin_panel/              Next.js admin panel (App Router + Server Actions)
```

## 1. Supabase backend

Project is already created and wired into the app:
`https://tqnalbpqbitabuxuldhq.supabase.co` (anon/publishable key is in
`lib/core/constant/api_constant.dart` - that key is safe to ship, it only
grants what RLS allows).

To finish setting it up:

1. Install the Supabase CLI (`brew install supabase/tap/supabase`) and log in.
2. Link the project: `supabase link --project-ref tqnalbpqbitabuxuldhq`
3. Push the schema: `supabase db push` (runs everything in
   `supabase/migrations/`, including RLS policies and starter seed data for
   farm types, machines, missions, achievements and boosts).
4. Deploy the Edge Functions: `supabase functions deploy` (deploys every
   function under `supabase/functions/`). These use `SUPABASE_URL` and
   `SUPABASE_SERVICE_ROLE_KEY`, which Supabase injects automatically in
   production - you don't set them manually in the dashboard.
5. Create your first admin: Authentication → Users → Add user (email +
   password), then in the SQL editor:
   ```sql
   insert into public.admin_users (id, role)
   values ('<that user''s id>', 'superadmin');
   ```

Everything that changes balances, hashrate, levels or session state runs
through an Edge Function using the service_role key - Flutter only ever gets
read access via Row Level Security (see docs sections 42-46, "Security Rule",
"Row Level Security", "Anti-Cheat").

## 2. Flutter app

```bash
flutter pub get
flutter run
```

Auth (email/password) and every game feature (mining, farm, machines,
missions, streak, referral, achievements, leaderboard, rewards, notifications,
profile) work as soon as the Supabase backend above is set up. The following
are wired in but need your own credentials before they do anything (the app
runs fine without them - they fail silently/no-op until configured):

- **Google/Apple Sign-In** - create OAuth clients in Google Cloud Console /
  Apple Developer, then enable those providers in Supabase Auth →
  Providers. `google_sign_in` / `sign_in_with_apple` are already in
  `pubspec.yaml` and `LoginController.loginWithGoogle()`.
- **Firebase** (push notifications, analytics) - create a Firebase project,
  drop `google-services.json` into `android/app/`, `GoogleService-Info.plist`
  into `ios/Runner/`, and call `Firebase.initializeApp()` +
  `PushNotificationService.init()` / `AnalyticsService.markReady()` at the top
  of `main()`.
- **AdMob** - create an AdMob app, replace the test ad unit IDs in
  `lib/core/services/ads_service.dart`, and add your AdMob App ID to
  `android/app/src/main/AndroidManifest.xml` / `ios/Runner/Info.plist`.
- **Sentry** - create a Sentry project and wrap `runApp()` with
  `SentryFlutter.init` using your DSN.

### Branding & assets

`assets/images/`, `assets/icons/`, `assets/lottie/` and `assets/fonts/` exist
but are empty placeholders - drop in your own logo, onboarding illustrations,
machine/farm art and a font family (e.g. Poppins), then uncomment the `fonts:`
block in `pubspec.yaml`. Everything currently renders with Material icons and
the system font so the app runs without any of this.

## 3. Admin panel

```bash
cd admin_panel
cp .env.local.example .env.local   # fill in SUPABASE_SERVICE_ROLE_KEY
npm install
npm run dev
```

Sign in with the admin account you created above. Covers Phase 6 from the
docs: live dashboard (DAU/WAU/MAU, sessions, rewards, active referrals), user
search + block/unblock/flag, mining economy settings (reward rate, session
length, referral reward, maintenance mode - all take effect immediately, no
app release needed), machine/farm-type catalog management, mission
management, and referral review. Every mutation writes an
`admin_audit_logs` row.

Not yet built (straightforward to add following the same pattern): boost
management, achievement management, admin-sent notifications, wallet/
withdrawal review (that whole feature is V1-out-of-scope - see below).

## 4. What's intentionally NOT here (see docs sections 2, 35-36, 73)

- Real cryptocurrency mining, wallets or withdrawals. The `wallet_accounts` /
  `withdrawals` tables and the `request-withdrawal` function exist to match
  the documented future schema, but the function just returns "not
  available yet" - wire it up only after legal/compliance review and a real
  blockchain/payment integration.
- On-device crypto mining of any kind (Google Play disallows it).
- NFTs, GameFi, a marketplace, clans - documented as V2+/V4, not V1.

## 5. Where the game economy lives

Nothing is hardcoded in Flutter. Reward rate, session duration, upgrade
costs, XP curve, referral reward and streak bonuses are computed in the Edge
Functions (`supabase/functions/_shared/*.ts`) and the admin-editable
`app_config` table - tune them from the admin panel or by editing the shared
TS helpers, not by shipping a new app build.
