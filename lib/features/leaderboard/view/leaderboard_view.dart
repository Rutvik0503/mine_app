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
      appBar: PrimaryAppBar(title: 'Leaderboard'.tr),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                children: [
                  _CategoryChip(
                    label: 'Weekly XP'.tr,
                    selected: controller.category.value == LeaderboardCategory.weeklyXp,
                    onTap: () => controller.changeCategory(LeaderboardCategory.weeklyXp),
                  ),
                  _CategoryChip(
                    label: 'Monthly XP'.tr,
                    selected: controller.category.value == LeaderboardCategory.monthlyXp,
                    onTap: () => controller.changeCategory(LeaderboardCategory.monthlyXp),
                  ),
                  _CategoryChip(
                    label: 'Hashrate'.tr,
                    selected: controller.category.value == LeaderboardCategory.hashrate,
                    onTap: () => controller.changeCategory(LeaderboardCategory.hashrate),
                  ),
                  _CategoryChip(
                    label: 'Level'.tr,
                    selected: controller.category.value == LeaderboardCategory.level,
                    onTap: () => controller.changeCategory(LeaderboardCategory.level),
                  ),
                  _CategoryChip(
                    label: 'Streak'.tr,
                    selected: controller.category.value == LeaderboardCategory.streak,
                    onTap: () => controller.changeCategory(LeaderboardCategory.streak),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingOverlay();
              if (controller.entries.isEmpty) {
                return EmptyStateWidget(message: 'Leaderboard is empty.'.tr);
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
                              ? Icon(Icons.person, size: 16, color: AppColor.textSecondary)
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColor.primary,
        backgroundColor: AppColor.surface,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColor.textPrimary),
        side: BorderSide(color: selected ? AppColor.primary : AppColor.border),
      ),
    );
  }
}
