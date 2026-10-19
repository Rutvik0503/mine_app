import 'dart:async';

import '../../../services/play_billing_service.dart';
import '../../../services/push_notification_service.dart';
import '../../../services/session_service.dart';
import '../model/profile_model.dart';
import '../service/auth_service.dart';

class AuthRepository {
  final AuthService _service = AuthService();

  /// Returns true if the account is immediately active (profile created,
  /// ready to use). Returns false when Supabase's "Confirm email" setting is
  /// on - signUp() then returns no session, so there's no user JWT to call
  /// create-profile with yet. In that case profile creation is deferred to
  /// [ensureProfileExists], called on the next successful login.
  Future<bool> signUp({
    required String email,
    required String password,
    String? username,
    String? referralCode,
  }) async {
    // A manually-typed code (signup form) takes precedence over one carried
    // by a referral deep link, but either way it's saved to SessionService
    // first so it survives the "confirm email" gap below.
    final trimmedCode = referralCode?.trim();
    if (trimmedCode != null && trimmedCode.isNotEmpty) {
      await SessionService.setPendingReferralCode(trimmedCode);
    }

    final response = await _service.signUpWithEmail(email: email, password: password);

    if (response.session == null) {
      // Supabase "Confirm email" is on - no session yet, so there's no JWT
      // to call create-profile with. The pending referral code stays saved
      // and is applied by ensureProfileExists() on first login instead.
      return false;
    }

    await _service.createProfile(referralCode: SessionService.pendingReferralCode, username: username);
    await SessionService.setPendingReferralCode(null);
    await PushNotificationService.saveTokenForCurrentUser();
    return true;
  }

  /// Creates the profile/starter farm/machine if they don't exist yet.
  /// Safe to call on every login - create-profile is idempotent server-side.
  /// Every sign-in path (email, Google, Apple) must call this - it's the
  /// only place a first-time social-login user actually gets a profile/farm/
  /// starter machine.
  Future<void> ensureProfileExists() async {
    final profile = await _service.fetchProfile();
    if (profile == null) {
      await _service.createProfile(referralCode: SessionService.pendingReferralCode);
      await SessionService.setPendingReferralCode(null);
    }
  }

  /// Common post-sign-in bootstrap for every auth method (email, Google,
  /// Apple): make sure the profile/farm/machine exist, then register this
  /// device for push notifications.
  Future<void> completeSignIn() async {
    await ensureProfileExists();
    await PushNotificationService.saveTokenForCurrentUser();
    // Grants any Play purchase paid for but not yet verified.
    unawaited(PlayBillingService.instance.recoverUnfinishedPurchases());
  }

  Future<void> login({required String email, required String password}) async {
    await _service.signInWithEmail(email: email, password: password);
    await completeSignIn();
  }

  Future<void> forgotPassword(String email) => _service.sendPasswordResetEmail(email);

  Future<void> resetPassword(String newPassword) => _service.updatePassword(newPassword);

  Future<void> logout() => _service.signOut();

  Future<void> deleteAccount() => _service.deleteAccount();

  Future<ProfileModel?> currentProfile() => _service.fetchProfile();
}
