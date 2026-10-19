import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../constant/api_constant.dart';
import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/profile_model.dart';

class AuthService {
  final _client = SupabaseService.client;

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Permanently deletes the signed-in user's account server-side.
  Future<void> deleteAccount() => SupabaseService.invoke(ApiConstant.fnDeleteAccount);

  /// Ensures a `profiles` row + starter farm + starter machine exist for the
  /// current user (server-side, idempotent). Must run right after signup.
  Future<void> createProfile({String? referralCode, String? username}) async {
    await SupabaseService.invoke(
      ApiConstant.fnCreateProfile,
      body: {
        if (referralCode != null) 'referral_code': referralCode,
        if (username != null) 'username': username,
      },
    );
  }

  Future<ProfileModel?> fetchProfile() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;
    final row = await _client.from(TableConstant.profiles).select().eq('id', userId).maybeSingle();
    if (row == null) return null;
    return ProfileModel.fromJson(row);
  }
}
