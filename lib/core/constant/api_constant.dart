/// Supabase project configuration.
///
/// The anon/publishable key is safe to ship in the client - it only grants
/// the access allowed by Row Level Security policies (see
/// supabase/migrations/0001_init.sql). Never put the service_role key here.
class ApiConstant {
  ApiConstant._();

  static const String supabaseUrl = 'https://tqnalbpqbitabuxuldhq.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_ChUZddTxDAGZ1z3SbvwHEw_l3_zWX8Y';

  /// Google OAuth "Web application" Client ID (NOT the Android client ID).
  /// Required for google_sign_in to return a usable idToken on Android, and
  /// must match the Client ID entered in Supabase Auth > Providers > Google.
  /// See README "Google Sign-In setup".
  static const String googleWebClientId =
      '1094723467852-jkmlalossbmcpafht1m7nvsso8j16csp.apps.googleusercontent.com';


  // Edge Functions (supabase/functions/*)
  static const String fnCreateProfile = 'create-profile';
  static const String fnStartMining = 'start-mining';
  static const String fnClaimMining = 'claim-mining';
  static const String fnUpgradeMachine = 'upgrade-machine';
  static const String fnUpgradeFarm = 'upgrade-farm';
  static const String fnCompleteMission = 'complete-mission';
  static const String fnUpdateStreak = 'update-streak';
  static const String fnActivateReferral = 'activate-referral';
  static const String fnGetDashboard = 'get-dashboard';
  static const String fnRequestWithdrawal = 'request-withdrawal';
  static const String fnGrantAdBoost = 'grant-ad-boost';
  static const String fnExtendMiningSession = 'extend-mining-session';
  static const String fnRentMachine = 'rent-machine';
  static const String fnSpinWheel = 'spin-wheel';
  static const String fnDeleteAccount = 'delete-account';
  static const String fnVerifyPlayPurchase = 'verify-play-purchase';
  static const String fnGrantAdReward = 'grant-ad-reward';
}
