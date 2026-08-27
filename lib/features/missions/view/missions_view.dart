import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/missions_controller.dart';

class MissionsView extends GetView<MissionsController> {
  const MissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const PrimaryAppBar(title: "Today's Missions"),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        if (controller.missions.isEmpty) {
          return const EmptyStateWidget(message: 'No missions today. Check back tomorrow!');
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColor.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.missions.length,
            itemBuilder: (context, index) {
              final m = controller.missions[index];
              final progressValue = m.target == 0 ? 0.0 : (m.progress / m.target).clamp(0.0, 1.0);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          m.isClaimed
                              ? Icons.check_circle
                              : m.isCompleted
                                  ? Icons.stars_rounded
                                  : Icons.radio_button_unchecked,
                          color: m.isCompleted ? AppColor.success : AppColor.textDisabled,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppText(m.mission?.title ?? 'Mission', weight: FontWeight.w600),
                        ),
                        AppText.caption('+${m.mission?.rewardXp ?? 0} XP'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AppText.caption(m.mission?.description ?? ''),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 6,
                        backgroundColor: AppColor.border,
                        valueColor: const AlwaysStoppedAnimation(AppColor.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppText.caption('${m.progress}/${m.target}'),
                    if (m.status == 'completed') ...[
                      const SizedBox(height: 12),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.claimingId.value == m.id
                                ? null
                                : () => controller.claim(m),
                            child: controller.claimingId.value == m.id
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Claim Reward'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
