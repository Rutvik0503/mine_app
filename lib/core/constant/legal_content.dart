/// Draft legal/help copy for the in-app Privacy Policy, Terms of Service and
/// Help & Support pages (Settings screen). Written to be safe for a virtual/
/// simulated mining game with real-money purchases of virtual currency only
/// (no real crypto, no real withdrawal) - have this reviewed by a lawyer
/// before shipping to production, this is a functional draft, not legal
/// advice.
class LegalContent {
  LegalContent._();

  static const String supportEmail = 'virtualminingempire1@gmail.com';

  static const String privacyPolicy = '''
Last updated: 19 October 2026

We collect only what's needed to run your account and the game:

• Account info: your email address, username, and - if you sign in with Google - the name and email Google shares with us.
• Gameplay data: mining sessions, coin balance, miners, farm progress, missions, streaks, referrals and leaderboard standing.
• Purchase records: which coin packs or extra mining time you bought and when. Payments are handled by Google Play - we never see or store your card, UPI or bank details.
• Device and usage data: crash reports and basic analytics, used to fix bugs and improve the app.
• Advertising ID: used by Google AdMob to show and measure ads.
• Notification token: so we can send you reminders and news, if you allow notifications.

We do not sell your data. It is shared only with the services that run the app for us: Supabase (accounts and database), Google Play (payments), Google AdMob (ads) and Firebase (notifications, analytics and crash reports), each under its own privacy policy.

You can delete your account and its data at any time via Settings → Delete Account, or by emailing us.

This app is not directed at children under 13.

Full policy: https://virtual-mining-empire.web.app/privacy-policy.html
Questions: virtualminingempire1@gmail.com
''';

  static const String termsOfService = '''
Last updated: 19 October 2026

1. Virtual game, not real mining. "Mining", "hashrate", "farms" and "miners" in this app are game mechanics only. No real cryptocurrency mining takes place on your device or anywhere else, and this app is not affiliated with Bitcoin or any cryptocurrency network or exchange.

2. Coins have no real-world value. In-game coins are virtual, exist only inside this app, and cannot be exchanged, redeemed, transferred or withdrawn for real money, cryptocurrency or anything else of value.

3. Purchases. In-app purchases are processed by Google Play and buy virtual coins or extra mining time for entertainment only. Refunds follow Google Play's refund policy and applicable law.

4. Ads. The app shows ads. Watching an optional rewarded ad gives small in-game rewards (coins, boosts or mining time) - never real money.

5. No guaranteed earnings. Nothing in this app promises or implies real income, returns or profit, and it is not an investment of any kind.

6. Your responsibility. You are responsible for using this app in line with the laws where you live.

7. Changes to the game. We may change prices, rewards, session length or any other part of the virtual economy at any time to keep the game balanced.

8. Account suspension. Accounts found exploiting bugs, manipulating rewards or breaking these terms may be suspended or closed.

9. Disclaimer. The app is provided "as is" without warranties of any kind. To the extent the law allows, we are not liable for indirect, incidental or consequential damages from using the app.

Questions: virtualminingempire1@gmail.com
''';

  static const String helpFaq = '''
How does mining work?
Tap Start Mining on the Mine tab and pick which miners to use. When the session finishes, claim your coins - or watch an ad to claim 2x.

How do I increase my mining power?
Rent more miners and upgrade your farm from the Farm tab. More hashrate means more coins per session.

What can I spend coins on?
Renting miners, farm upgrades and machine upgrades. Coins are virtual and have no real-world value - see Terms of Service.

Can I buy coins?
Yes, from the Store, using Google Play. This buys virtual coins only - not real cryptocurrency.

How do I get free coins?
Daily spins, missions, streaks, inviting friends, and the "Free coins" card (watch a short ad).

Is this real Bitcoin or real crypto mining?
No. Everything here is a simulation for entertainment - no real mining or real crypto is involved.

How do I delete my account?
Settings → Delete Account. It is deleted straight away.

I found a bug or have another question.
Tap Contact Support below, or email virtualminingempire1@gmail.com.
''';
}
