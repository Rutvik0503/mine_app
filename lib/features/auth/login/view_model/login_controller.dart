import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/common_widget/app_snackbar.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/server_model/auth/repository/auth_repository.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/supabase_service.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  void toggleObscure() => obscurePassword.value = !obscurePassword.value;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await AnalyticsService.logLogin('email');
      Get.offAllNamed(AppRoutes.mainNav);
    } on AuthException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      // Requires Web/iOS OAuth client IDs configured in Google Cloud Console
      // and registered as a Supabase Auth provider. See README "Auth setup".
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      if (account == null) return;
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Missing Google ID token');
      await SupabaseService.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: auth.accessToken,
      );
      await AnalyticsService.logLogin('google');
      Get.offAllNamed(AppRoutes.mainNav);
    } catch (e) {
      AppSnackbar.error('Google sign-in failed. Make sure it is configured in Supabase Auth.');
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignup() => Get.toNamed(AppRoutes.signup);

  void goToForgotPassword() => Get.toNamed(AppRoutes.forgotPassword);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
