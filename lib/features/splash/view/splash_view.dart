import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/mining_visuals.dart';
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
            const MiningLogo(size: 104),
            const SizedBox(height: 24),
            const AppText.heading(AppString.appName, align: TextAlign.center),
            const SizedBox(height: 8),
            const AppText.caption('Build your virtual mining empire'),
            const SizedBox(height: 40),
            const GearLoader(size: 36),
          ],
        ),
      ),
    );
  }
}
