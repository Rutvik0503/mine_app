import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/stat_card.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/utils/formatters.dart';
import '../view_model/rewards_controller.dart';

class RewardsView extends GetView<RewardsController> {
  const RewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(title: const AppText.subHeading('Rewards'), automaticallyImplyLeading: false),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColor.primary,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Available Balance',
                      value: Formatters.points(controller.availableBalance.value),
                      icon: Icons.account_balance_wallet_rounded,
                      accent: AppColor.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Pending Balance',
                      value: Formatters.points(controller.pendingBalance.value),
                      icon: Icons.hourglass_top_rounded,
                      accent: AppColor.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: "Today's Rewards",
                      value: Formatters.points(controller.todayEarned),
                      icon: Icons.today_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Total Earned',
                      value: Formatters.points(controller.totalEarned),
                      icon: Icons.emoji_events_rounded,
                      accent: AppColor.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const AppText.subHeading('Reward History'),
              const SizedBox(height: 12),
              if (controller.history.isEmpty)
                const EmptyStateWidget(message: 'No rewards yet. Start mining!')
              else
                ...controller.history.map((t) => _RewardTile(transaction: t)),
            ],
          ),
        );
      }),
    );
  }
}

class _RewardTile extends StatelessWidget {
  final dynamic transaction;
  const _RewardTile({required this.transaction});

  IconData get _icon {
    switch (transaction.type) {
      case 'mining':
        return Icons.bolt_rounded;
      case 'mission':
        return Icons.checklist_rounded;
      case 'streak':
        return Icons.local_fire_department_rounded;
      case 'referral':
        return Icons.people_alt_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'boost':
        return Icons.rocket_launch_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Icon(_icon, color: AppColor.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(transaction.type.toString().toUpperCase(), size: 13, weight: FontWeight.w600),
                AppText.caption(Formatters.dateTime(transaction.createdAt)),
              ],
            ),
          ),
          AppText('+${Formatters.points(transaction.amount)}',
              color: AppColor.secondary, weight: FontWeight.w700),
        ],
      ),
    );
  }
}
