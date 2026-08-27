import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/server_model/leaderboard/model/leaderboard_entry_model.dart';
import '../view_model/leaderboard_controller.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const PrimaryAppBar(title: 'Leaderboard'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Obx(
              () => SegmentedButton<LeaderboardCategory>(
                segments: const [
                  ButtonSegment(value: LeaderboardCategory.hashrate, label: Text('Hashrate')),
                  ButtonSegment(value: LeaderboardCategory.level, label: Text('Level')),
                  ButtonSegment(value: LeaderboardCategory.streak, label: Text('Streak')),
                ],
                selected: {controller.category.value},
                onSelectionChanged: (s) => controller.changeCategory(s.first),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingOverlay();
              if (controller.entries.isEmpty) {
                return const EmptyStateWidget(message: 'Leaderboard is empty.');
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.entries.length,
                itemBuilder: (context, index) {
                  final e = controller.entries[index];
                  final isMe = e.userId == controller.myUserId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? AppColor.primary.withValues(alpha: 0.12) : AppColor.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isMe ? AppColor.primary : AppColor.border),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: AppText('#${e.rank}', weight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColor.surfaceElevated,
                          backgroundImage: e.avatarUrl != null ? NetworkImage(e.avatarUrl!) : null,
                          child: e.avatarUrl == null
                              ? const Icon(Icons.person, size: 16, color: AppColor.textSecondary)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: AppText(e.username, weight: FontWeight.w600)),
                        AppText(e.value.toStringAsFixed(1), color: AppColor.secondary, weight: FontWeight.w700),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
