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
      appBar: PrimaryAppBar(title: 'Invite Friends'.tr),
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
                  AppText.caption('Your Referral Code'.tr),
                  const SizedBox(height: 8),
                  AppText(code, size: 28, weight: FontWeight.w800, color: AppColor.primary),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Copy'.tr,
                          outlined: true,
                          icon: Icons.copy_rounded,
                          onPressed: controller.copyCode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Share'.tr,
                          icon: Icons.share_rounded,
                          onPressed: controller.shareCode,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (controller.canEnterFriendCode) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColor.primary.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText("Have a friend's code?".tr, weight: FontWeight.w800),
                    const SizedBox(height: 4),
                    AppText.caption('friendCodeHint'.tr),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.friendCodeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'Enter code'.tr,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 110,
                          child: AppButton(
                            label: 'Apply'.tr,
                            loading: controller.isApplyingCode.value,
                            onPressed: controller.applyFriendCode,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // What both sides get - granted as soon as the friend signs up.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColor.warning.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('How it works'.tr, weight: FontWeight.w800, color: AppColor.warning),
                  const SizedBox(height: 10),
                  _RewardLine(emoji: '⚡', text: 'referralYouGet'.tr),
                  const SizedBox(height: 8),
                  _RewardLine(emoji: '🎁', text: 'referralFriendGets'.tr),
                  const SizedBox(height: 8),
                  _RewardLine(emoji: '♾️', text: 'referralStack'.tr),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Invites'.tr,
                    value: '${controller.referrals.length}',
                    icon: Icons.person_add_alt_1_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Active Referrals'.tr,
                    value: '${controller.activeCount}',
                    icon: Icons.verified_rounded,
                    accent: AppColor.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppText.subHeading('Referral Activity'.tr),
            const SizedBox(height: 12),
            if (controller.referrals.isEmpty)
              EmptyStateWidget(message: 'No referrals yet. Share your code!'.tr)
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
                      AppText(r.status.tr.toUpperCase(), weight: FontWeight.w600),
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

class _RewardLine extends StatelessWidget {
  final String emoji;
  final String text;
  const _RewardLine({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: AppText(text, size: 13)),
      ],
    );
  }
}
