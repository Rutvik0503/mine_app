import '../../../services/session_service.dart';
import '../model/profile_model.dart';
import '../service/auth_service.dart';

class AuthRepository {
  final AuthService _service = AuthService();

  Future<void> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    await _service.signUpWithEmail(email: email, password: password);
    await _service.createProfile(
      referralCode: SessionService.pendingReferralCode,
      username: username,
    );
    await SessionService.setPendingReferralCode(null);
  }

  Future<void> login({required String email, required String password}) {
    return _service.signInWithEmail(email: email, password: password);
  }

  Future<void> forgotPassword(String email) => _service.sendPasswordResetEmail(email);

  Future<void> resetPassword(String newPassword) => _service.updatePassword(newPassword);

  Future<void> logout() => _service.signOut();

  Future<ProfileModel?> currentProfile() => _service.fetchProfile();
}
