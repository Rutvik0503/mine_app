import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/routes/app_routes.dart';

/// Shown when app_config.maintenance_mode is on (admin-controlled, takes
/// effect immediately with no app release - spec section 44). Retry simply
/// re-enters Splash, which re-checks app_config fresh.
class MaintenanceView extends StatelessWidget {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.build_circle_outlined, size: 64, color: AppColor.warning),
              const SizedBox(height: 20),
              AppText.heading('Under Maintenance'.tr, align: TextAlign.center),
              const SizedBox(height: 10),
              AppText.caption(
                'We are making some improvements. Please check back shortly.'.tr,
                align: TextAlign.center,
              ),
              const SizedBox(height: 28),
              AppButton(label: 'Retry'.tr, onPressed: () => Get.offAllNamed(AppRoutes.splash)),
            ],
          ),
        ),
      ),
    );
  }
}
