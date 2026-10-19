import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/common_widget/app_snackbar.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/server_model/auth/repository/auth_repository.dart';
import '../../../../core/services/analytics_service.dart';

class SignupController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final referralCodeController = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  void toggleObscure() => obscurePassword.value = !obscurePassword.value;

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final active = await _authRepository.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        username: usernameController.text.trim().isEmpty ? null : usernameController.text.trim(),
        referralCode: referralCodeController.text.trim().isEmpty ? null : referralCodeController.text.trim(),
      );
      await AnalyticsService.logSignup('email');
      if (active) {
        Get.offAllNamed(AppRoutes.mainNav);
      } else {
        // Supabase "Confirm email" is on - no session yet, so there's no
        // profile/farm/machine to enter yet either. They'll be created on
        // first login once the user clicks the confirmation link.
        AppSnackbar.success('Account created! Check your email, then log in.'.tr);
        Get.offAllNamed(AppRoutes.login);
      }
    } on AuthException catch (e) {
      debugPrint('Sign up AuthException (status ${e.statusCode}): ${e.message}');
      AppSnackbar.error(e.message);
    } catch (e) {
      debugPrint('Sign up failed: $e');
      AppSnackbar.error('Sign up failed. Please try again.'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.back();

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralCodeController.dispose();
    super.onClose();
  }
}
