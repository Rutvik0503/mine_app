import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/common_widget/app_snackbar.dart';
import '../../../../core/constant/api_constant.dart';
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
      debugPrint('Login AuthException (status ${e.statusCode}): ${e.message}');
      AppSnackbar.error(e.message);
    } catch (e) {
      debugPrint('Login failed: $e');
      AppSnackbar.error('Login failed. Please try again.'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    if (ApiConstant.googleWebClientId.startsWith('REPLACE_WITH_')) {
      AppSnackbar.info('Google Sign-In is not configured yet - see README "Google Sign-In setup".'.tr);
      return;
    }

    isLoading.value = true;
    try {
      // Requires a Google Cloud "Web application" OAuth client (registered in
      // Supabase Auth > Providers > Google) plus an "Android" OAuth client
      // matching this app's package name + SHA-1. See README "Google Sign-In setup".
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: ApiConstant.googleWebClientId,
      );
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
      await _authRepository.completeSignIn();
      await AnalyticsService.logLogin('google');
      Get.offAllNamed(AppRoutes.mainNav);
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      AppSnackbar.error('Google sign-in failed. Make sure it is configured in Supabase Auth.'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Real Sign In with Apple needs an Apple Developer account (Service ID +
  /// return URL registered with Supabase Auth) - a paid, external
  /// credential this repo can't provide on its own. The button exists so
  /// the affordance is there per spec, but honestly says what's missing
  /// instead of pretending to work. See README "Apple Sign-In setup".
  static const bool appleSignInEnabled = false;

  void loginWithApple() {
    AppSnackbar.info(
      'Apple Sign-In requires an Apple Developer account - see README "Apple Sign-In setup".'.tr,
    );
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
