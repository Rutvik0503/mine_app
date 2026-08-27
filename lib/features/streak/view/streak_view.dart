import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/streak_controller.dart';

class StreakView extends GetView<StreakController> {
  const StreakView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const PrimaryAppBar(title: 'Streak'),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        final streak = controller.streak.value;
        final current = streak?.currentStreak ?? 0;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColor.premiumGradient),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  AppText('$current Day Streak', color: Colors.white, size: 24, weight: FontWeight.w800),
                  const SizedBox(height: 4),
                  AppText('Longest: ${streak?.longestStreak ?? 0} days', color: Colors.white70),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppText.subHeading('Milestones'),
            const SizedBox(height: 12),
            ...StreakController.milestones.map((day) {
              final reached = current >= day;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: reached ? AppColor.success : AppColor.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      reached ? Icons.check_circle : Icons.lock_outline_rounded,
                      color: reached ? AppColor.success : AppColor.textDisabled,
                    ),
                    const SizedBox(width: 10),
                    AppText('$day-Day Streak Bonus', weight: FontWeight.w600),
                  ],
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
