import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common_widget/app_button.dart';
import '../../../../core/common_widget/app_text.dart';
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
                const AppText.heading('Welcome back'),
                const SizedBox(height: 6),
                const AppText.caption('Login to continue mining'),
                const SizedBox(height: 32),
                AppTextField(
                  controller: controller.emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => AppTextField(
                    controller: controller.passwordController,
                    label: 'Password',
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
                    child: const AppText(AppString.forgotPassword, color: AppColor.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => AppButton(
                    label: AppString.login,
                    loading: controller.isLoading.value,
                    onPressed: controller.login,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider(color: AppColor.border)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: AppText.caption('or'),
                    ),
                    Expanded(child: Divider(color: AppColor.border)),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(
                  () => AppButton(
                    label: AppString.continueWithGoogle,
                    outlined: true,
                    icon: Icons.g_mobiledata_rounded,
                    loading: controller.isLoading.value,
                    onPressed: controller.loginWithGoogle,
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: TextButton(
                    onPressed: controller.goToSignup,
                    child: const AppText.caption("Don't have an account? Sign Up"),
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
