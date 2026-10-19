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

- **Google Sign-In** - see "Google Sign-In setup" below.
- **Apple Sign-In** - button is wired in (login screen, shows an honest
  "requires an Apple Developer account" message) but not functional yet -
  see "Apple Sign-In setup" below.
- **Firebase** (push notifications, analytics) - create a Firebase project,
  drop `google-services.json` into `android/app/`, `GoogleService-Info.plist`
  into `ios/Runner/`, and call `Firebase.initializeApp()` before
  `runApp()` in `main()`. `PushNotificationService.init()` is already called
  there and `AnalyticsService` calls are already wired throughout the app -
  both are safe no-ops until the Firebase config files above exist. Once
  Firebase works, device tokens save themselves automatically after login
  (`save_device_token` RPC → `device_tokens` table).
- **AdMob** - `AndroidManifest.xml`/`Info.plist` already carry Google's
  public TEST AdMob App ID (required or the app crashes on launch - see
  `google_mobile_ads` docs). Before release: create a real AdMob app, replace
  the test ad unit IDs in `lib/core/services/ads_service.dart`, and the test
  App ID in both manifests.
- **Sentry** - create a Sentry project and wrap `runApp()` with
  `SentryFlutter.init` using your DSN.

### Google Sign-In setup

Email/password auth works out of the box; the "Continue with Google" button
shows "not configured yet" until you do this (it needs a Google Cloud
project, which only you can create):

1. **Google Cloud Console** → APIs & Services → Credentials → Create
   Credentials → OAuth client ID, twice:
   - **Web application** - no redirect URI needed for this flow. Copy its
     Client ID.
   - **Android** - package name `com.virtualminingempire.app`, SHA-1 certificate
     fingerprint (debug keystore, already extracted for you):
     `A9:95:F0:37:10:A8:10:DB:AB:6D:53:BC:40:28:BA:39:5B:13:28:B6`
     (get this yourself anytime with
     `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`;
     you'll need a second Android client with your **release** keystore's
     SHA-1 before shipping to Play Store).
2. **Supabase Dashboard** → Authentication → Providers → Google → enable it,
   paste the **Web** client's Client ID and Client Secret.
3. **This repo**: paste the same **Web** Client ID into
   `googleWebClientId` in `lib/core/constant/api_constant.dart`.
4. Rebuild and try the button again.

(The Android OAuth client isn't referenced anywhere in code - Google
verifies the request using your app's package name + SHA-1 against it
automatically. Only the Web client ID is ever used by the app itself.)

### Apple Sign-In setup

The "Continue with Apple" button always shows "requires an Apple Developer
account" until you do this (it needs a paid Apple Developer Program
membership, which only you can buy):

1. **Apple Developer** → Certificates, Identifiers & Profiles → enable
   "Sign In with Apple" for this app's Bundle ID, then create a **Services
   ID** for the web/Android flow with a return URL pointing at your
   Supabase project (`https://<project-ref>.supabase.co/auth/v1/callback`).
2. **Supabase Dashboard** → Authentication → Providers → Apple → enable it,
   fill in the Services ID, Team ID, Key ID and private key from your Apple
   Developer account.
3. **This repo**: replace `LoginController.loginWithApple()`'s guard with a
   real `SignInWithApple.getAppleIDCredential(...)` call (the
   `sign_in_with_apple` package is already in `pubspec.yaml`) followed by
   `SupabaseService.auth.signInWithIdToken(provider: OAuthProvider.apple, ...)`
   and `_authRepository.completeSignIn()`, the same pattern
   `loginWithGoogle()` already uses.
4. Rebuild and try the button again.

### Razorpay setup

Lets users buy point packs with a card/UPI/netbanking (Profile/Rewards →
"Buy Points"), which spend through the same upgrade flow as mining rewards.
Razorpay was chosen over Stripe because Stripe does not accept new direct
merchant sign-ups from India (RBI Payment Aggregator rules) and lacks UPI,
which is how most Indian users actually pay. **Read this first:** Google
Play and the App Store both require their own in-app billing (Google Play
Billing / Apple IAP) for real-money purchases of virtual currency consumed
inside the app - this applies no matter which payment gateway is used
server-side, so Razorpay here is fine for direct-APK or web distribution,
but will get a store listing rejected/suspended if shipped through Play
Store or App Store as-is (see the comment in
`supabase/migrations/0004_razorpay.sql`).

1. Create a [Razorpay account](https://dashboard.razorpay.com/signup) -
   instant for an individual/proprietorship/company, Test Mode is on by
   default (no real charges, no KYC needed yet). Full KYC (PAN, bank
   account) is only required later to switch to Live Mode and accept real
   payments.
2. **Settings → API Keys → Generate Test Key**: copy the **Key Id**
   (`rzp_test_...`) into `razorpayKeyId` in
   `lib/core/constant/api_constant.dart`, and set the **Key Secret** as an
   Edge Function secret:
   ```bash
   supabase secrets set RAZORPAY_KEY_ID=rzp_test_... RAZORPAY_KEY_SECRET=...
   ```
3. **Settings → Webhooks → Add New Webhook**, URL:
   `https://tqnalbpqbitabuxuldhq.supabase.co/functions/v1/razorpay-webhook`,
   active events: `payment.captured` and `payment.failed`. Set a webhook
   **Secret** there and add the same value here:
   ```bash
   supabase secrets set RAZORPAY_WEBHOOK_SECRET=...
   ```
4. Rebuild the app. Edit prices/points in the `store_packages` table (SQL
   editor or a future admin panel page) - three starter packages are seeded
   in INR (`price_cents` is paise, e.g. `9900` = ₹99).

Points only ever get granted by `razorpay-webhook` after Razorpay confirms
the payment (`payment.captured`) - never by the app directly - so a closed
app or lost connection mid-payment can't create free points, and Razorpay
retrying the webhook can't double-grant them (`purchases.status` is checked
before crediting).

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
