import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common_widget/app_button.dart';
import '../../../../core/common_widget/app_text.dart';
import '../../../../core/common_widget/mining_visuals.dart';
import '../../../../core/common_widget/app_text_field.dart';
import '../../../../core/constant/app_color.dart';
import '../../../../core/constant/app_string.dart';
import '../../../../core/utils/validators.dart';
import '../view_model/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(backgroundColor: AppColor.background, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: MiningLogo(size: 68)),
                const SizedBox(height: 20),
                AppText.heading('Create your account'.tr),
                const SizedBox(height: 6),
                AppText.caption('Start building your mining empire'.tr),
                const SizedBox(height: 28),
                AppTextField(
                  controller: controller.usernameController,
                  label: 'Username'.tr,
                  hint: 'Miner123',
                  validator: Validators.username,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller.confirmPasswordController,
                  label: 'Confirm Password'.tr,
                  hint: '••••••••',
                  obscure: true,
                  validator: (v) =>
                      Validators.confirmPassword(v, controller.passwordController.text),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller.referralCodeController,
                  label: 'Referral Code (optional)'.tr,
                  hint: 'e.g. URVI4829',
                ),
                const SizedBox(height: 28),
                Obx(
                  () => AppButton(
                    label: AppString.signup.tr,
                    loading: controller.isLoading.value,
                    onPressed: controller.signup,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: controller.goToLogin,
                    child: AppText.caption('Already have an account? Login'.tr),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
