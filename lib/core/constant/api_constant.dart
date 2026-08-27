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
}
