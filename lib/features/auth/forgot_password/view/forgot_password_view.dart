import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common_widget/app_button.dart';
import '../../../../core/common_widget/app_text.dart';
import '../../../../core/common_widget/app_text_field.dart';
import '../../../../core/constant/app_color.dart';
import '../../../../core/utils/validators.dart';
import '../view_model/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(backgroundColor: AppColor.background, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText.heading('Reset your password'),
                const SizedBox(height: 6),
                const AppText.caption(
                  "Enter your email and we'll send you a link to reset your password.",
                ),
                const SizedBox(height: 28),
                AppTextField(
                  controller: controller.emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 28),
                Obx(
                  () => AppButton(
                    label: 'Send Reset Link',
                    loading: controller.isLoading.value,
                    onPressed: controller.sendResetEmail,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => controller.emailSent.value
                      ? const AppText.caption(
                          'Check your inbox for the reset link.',
                          color: AppColor.success,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
