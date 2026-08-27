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
      await _authRepository.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        username: usernameController.text.trim().isEmpty ? null : usernameController.text.trim(),
      );
      await AnalyticsService.logSignup('email');
      AppSnackbar.success('Account created! Check your email to verify.');
      Get.offAllNamed(AppRoutes.mainNav);
    } on AuthException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Sign up failed. Please try again.');
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
