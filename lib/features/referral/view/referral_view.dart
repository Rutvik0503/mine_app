import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/common_widget/stat_card.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/referral_controller.dart';

class ReferralView extends GetView<ReferralController> {
  const ReferralView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const PrimaryAppBar(title: 'Invite Friends'),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        final code = controller.profile.value?.referralCode ?? '';
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                children: [
                  const AppText.caption('Your Referral Code'),
                  const SizedBox(height: 8),
                  AppText(code, size: 28, weight: FontWeight.w800, color: AppColor.primary),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Copy',
                          outlined: true,
                          icon: Icons.copy_rounded,
                          onPressed: controller.copyCode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Share',
                          icon: Icons.share_rounded,
                          onPressed: controller.shareCode,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Invites',
                    value: '${controller.referrals.length}',
                    icon: Icons.person_add_alt_1_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Active Referrals',
                    value: '${controller.activeCount}',
                    icon: Icons.verified_rounded,
                    accent: AppColor.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const AppText.subHeading('Referral Activity'),
            const SizedBox(height: 12),
            if (controller.referrals.isEmpty)
              const EmptyStateWidget(message: 'No referrals yet. Share your code!')
            else
              ...controller.referrals.map(
                (r) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        r.status == 'active' ? Icons.check_circle : Icons.hourglass_top_rounded,
                        color: r.status == 'active' ? AppColor.success : AppColor.warning,
                      ),
                      const SizedBox(width: 10),
                      AppText(r.status.toUpperCase(), weight: FontWeight.w600),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
