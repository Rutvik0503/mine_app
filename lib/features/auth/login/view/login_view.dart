import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common_widget/app_button.dart';
import '../../../../core/common_widget/app_text.dart';
import '../../../../core/common_widget/mining_visuals.dart';
import '../../../../core/common_widget/app_text_field.dart';
import '../../../../core/constant/app_color.dart';
import '../../../../core/constant/app_string.dart';
import '../../../../core/utils/validators.dart';
import '../view_model/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: MiningLogo(size: 76)),
                const SizedBox(height: 24),
                AppText.heading('Welcome back'.tr),
                const SizedBox(height: 6),
                AppText.caption('Login to continue mining'.tr),
                const SizedBox(height: 32),
                AppTextField(
                  controller: controller.emailController,
                  label: 'Email'.tr,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => AppTextField(
                    controller: controller.passwordController,
                    label: 'Password'.tr,
                    hint: '••••••••',
                    obscure: controller.obscurePassword.value,
                    validator: Validators.password,
                    suffix: IconButton(
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColor.textSecondary,
                      ),
                      onPressed: controller.toggleObscure,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.goToForgotPassword,
                    child: AppText(AppString.forgotPassword.tr, color: AppColor.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => AppButton(
                    label: AppString.login.tr,
                    loading: controller.isEmailLoading.value,
                    onPressed: controller.isGoogleLoading.value ? null : controller.login,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColor.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AppText.caption('or'.tr),
                    ),
                    Expanded(child: Divider(color: AppColor.border)),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(
                  () => AppButton(
                    label: AppString.continueWithGoogle.tr,
                    outlined: true,
                    icon: Icons.g_mobiledata_rounded,
                    loading: controller.isGoogleLoading.value,
                    onPressed: controller.isEmailLoading.value ? null : controller.loginWithGoogle,
                  ),
                ),
                // Sign in with Apple stays hidden until it's configured (Apple
                // Developer account). Turn it on with the iOS release - App
                // Store guideline 4.8 requires it there next to Google login.
                if (LoginController.appleSignInEnabled) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    label: AppString.continueWithApple.tr,
                    outlined: true,
                    icon: Icons.apple_rounded,
                    onPressed: controller.loginWithApple,
                  ),
                ],
                const SizedBox(height: 28),
                Center(
                  child: TextButton(
                    onPressed: controller.goToSignup,
                    child: AppText.caption("Don't have an account? Sign Up".tr),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
