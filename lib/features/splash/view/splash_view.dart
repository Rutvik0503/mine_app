import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/app_string.dart';
import '../view_model/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: AppColor.miningGradient),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const AppText.heading(AppString.appName, align: TextAlign.center),
            const SizedBox(height: 8),
            const AppText.caption('Build your virtual mining empire'),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColor.primary),
            ),
          ],
        ),
      ),
    );
  }
}
