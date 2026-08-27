import 'package:shared_preferences/shared_preferences.dart';

/// Local, non-sensitive cache only (onboarding flag, last-seen values for
/// optimistic UI). Never used as the source of truth for balances or
/// progression - that always comes from Supabase.
class SessionService {
  SessionService._();

  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyReferralCodePending = 'referral_code_pending';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get hasSeenOnboarding => _prefs.getBool(_keyOnboardingSeen) ?? false;

  static Future<void> setOnboardingSeen() => _prefs.setBool(_keyOnboardingSeen, true);

  static String? get pendingReferralCode => _prefs.getString(_keyReferralCodePending);

  static Future<void> setPendingReferralCode(String? code) {
    if (code == null) return _prefs.remove(_keyReferralCodePending);
    return _prefs.setString(_keyReferralCodePending, code);
  }
}
