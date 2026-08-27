import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common_widget/app_snackbar.dart';
import '../../../../core/server_model/auth/repository/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final emailSent = false.obs;

  Future<void> sendResetEmail() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _authRepository.forgotPassword(emailController.text.trim());
      emailSent.value = true;
      AppSnackbar.success('Password reset email sent.');
    } catch (e) {
      AppSnackbar.error('Could not send reset email. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
