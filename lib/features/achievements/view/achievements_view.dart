import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/achievements_controller.dart';

class AchievementsView extends GetView<AchievementsController> {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const PrimaryAppBar(title: 'Achievements'),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        if (controller.all.isEmpty) {
          return const EmptyStateWidget(message: 'No achievements yet.', icon: Icons.emoji_events_rounded);
        }
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: controller.all.length,
          itemBuilder: (context, index) {
            final achievement = controller.all[index];
            final unlocked = controller.isUnlocked(achievement.id);
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: unlocked ? AppColor.primary : AppColor.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    unlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
                    color: unlocked ? AppColor.primary : AppColor.textDisabled,
                    size: 32,
                  ),
                  const SizedBox(height: 10),
                  AppText(achievement.name, weight: FontWeight.w700, size: 14),
                  const SizedBox(height: 4),
                  Expanded(child: AppText.caption(achievement.description, maxLines: 3)),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
