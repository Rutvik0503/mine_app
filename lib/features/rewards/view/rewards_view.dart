import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/native_ad_card.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/error_state_widget.dart';
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
      appBar: AppBar(title: AppText.subHeading('Rewards'.tr), automaticallyImplyLeading: false),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        if (controller.hasError.value) {
          return ErrorStateWidget(onRetry: controller.load);
        }
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
                      label: 'Available Balance'.tr,
                      value: Formatters.points(controller.availableBalance.value),
                      icon: Icons.toll_rounded,
                      accent: AppColor.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Pending Balance'.tr,
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
                      label: "Today's Rewards".tr,
                      value: Formatters.points(controller.todayEarned),
                      icon: Icons.today_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Total Earned'.tr,
                      value: Formatters.points(controller.totalEarned),
                      icon: Icons.emoji_events_rounded,
                      accent: AppColor.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.goToStore,
                  icon: const Icon(Icons.toll_rounded),
                  label: Text('Buy Coins'.tr),
                ),
              ),
              const SizedBox(height: 24),
              AppText.subHeading('Reward History'.tr),
              const SizedBox(height: 12),
              if (controller.history.isEmpty)
                EmptyStateWidget(message: 'No rewards yet. Start mining!'.tr)
              else
                // One native ad, after the 2nd entry (or at the end of a short list).
                for (var i = 0; i < controller.history.length; i++) ...[
                  _RewardTile(transaction: controller.history[i]),
                  if (i == 1 || (i == controller.history.length - 1 && i < 1))
                    const NativeAdCard(key: ValueKey('rewards-history-native')),
                ],
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
        return Icons.hardware_rounded;
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
      case 'ad_reward':
        return Icons.card_giftcard_rounded;
      case 'level_up':
        return Icons.star_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  bool get _isNegative => (transaction.amount as num) < 0;

  // Older streak check-ins paid XP only (amount 0) - say so instead of "+0".
  String get _amountLabel => transaction.type == 'streak' && (transaction.amount as num) == 0
      ? '+XP'
      : '${_isNegative ? '' : '+'}${Formatters.points(transaction.amount)}';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showDetails(context),
      child: Container(
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
                  AppText(transaction.type.toString().tr.toUpperCase(), size: 13, weight: FontWeight.w600),
                  AppText.caption(Formatters.dateTime(transaction.createdAt)),
                ],
              ),
            ),
            AppText(
              _amountLabel,
              color: _isNegative ? AppColor.error : AppColor.secondary,
              weight: FontWeight.w700,
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: AppColor.textDisabled, size: 18),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, color: AppColor.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText.subHeading(transaction.type.toString().tr.toUpperCase()),
                ),
                AppText(
                  _amountLabel,
                  size: 18,
                  weight: FontWeight.w800,
                  color: _isNegative ? AppColor.error : AppColor.secondary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(label: 'Status'.tr, value: transaction.status.toString().tr.toUpperCase()),
            if ((transaction.source as String?)?.isNotEmpty == true)
              _DetailRow(label: 'Source'.tr, value: transaction.source.toString()),
            _DetailRow(label: 'Date'.tr, value: Formatters.dateTime(transaction.createdAt)),
            if ((transaction.referenceId as String?)?.isNotEmpty == true)
              _DetailRow(label: 'Reference ID'.tr, value: transaction.referenceId.toString()),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: AppText.caption(label)),
          Expanded(child: AppText(value, size: 13, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
