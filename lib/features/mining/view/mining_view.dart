import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/error_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/mining_visuals.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/server_model/mining/model/mining_session_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/type_icons.dart';
import '../view_model/mining_controller.dart';

class MiningView extends GetView<MiningController> {
  const MiningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: AppText.subHeading('Mining'.tr),
        automaticallyImplyLeading: false,
      ),
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
              _StatusCard(controller: controller),
              const SizedBox(height: 20),
              AppText.subHeading('Active Boosts'.tr),
              const SizedBox(height: 10),
              if (controller.activeBoosts.isEmpty)
                AppText.caption(
                  'No active boosts. Watch an ad to get one!'.tr,
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.activeBoosts
                      .map(
                        (b) => Chip(
                          label: Text(
                            '${b.boost?.name ?? 'Boost'} x${b.boost?.multiplier ?? 1}',
                          ),
                          backgroundColor: AppColor.surfaceElevated,
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 12),
              Obx(
                () => AppButton(
                  label: 'Watch Ad for Boost'.tr,
                  outlined: true,
                  color: AppColor.accent,
                  icon: Icons.ondemand_video_rounded,
                  loading: controller.isWatchingAd.value,
                  onPressed: controller.isWatchingAd.value ? null : controller.watchAdForBoost,
                ),
              ),
              const SizedBox(height: 24),
              AppText.subHeading('Mining History'.tr),
              const SizedBox(height: 10),
              if (controller.history.isEmpty)
                EmptyStateWidget(message: 'No mining sessions yet.'.tr)
              else
                ...controller.history.map((s) => _HistoryTile(session: s)),
            ],
          ),
        );
      }),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final MiningController controller;
  const _StatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Everything here must be read inside this Obx - remaining.value ticks
    // every second from a Timer, and without an enclosing Obx nothing tells
    // Flutter to rebuild this widget when it changes.
    return Obx(() {
      final session = controller.session.value;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColor.miningGradient),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            MiningRigHero(
              state: session == null
                  ? MiningHeroState.idle
                  : (controller.canClaim ? MiningHeroState.ready : MiningHeroState.mining),
            ),
            const SizedBox(height: 12),
            AppText(
              (session != null
                      ? (controller.canClaim ? 'SESSION COMPLETED 🎉' : 'MINING IN PROGRESS')
                      : 'NO ACTIVE SESSION')
                  .tr,
              color: Colors.white,
              weight: FontWeight.w700,
            ),
            const SizedBox(height: 8),
            if (session != null && !controller.canClaim)
              AppText(
                Formatters.duration(controller.remaining.value),
                color: Colors.white,
                size: 34,
                weight: FontWeight.w800,
              ),
            if (session != null)
              AppText(
                'hashrateLabel'.trParams({'value': Formatters.hashrate(session.hashrateSnapshot)}),
                color: Colors.white70,
                size: 13,
              ),
            if (session != null && controller.farm.value?.farmType != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(TypeIcons.farmType(controller.farm.value!.farmType!.name), color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  AppText(
                    'miningViaFarm'.trParams({'farm': controller.farm.value!.farmType!.name}),
                    color: Colors.white70,
                    size: 12,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            if (session == null)
              AppButton(
                label: 'START MINING'.tr,
                loading: controller.isStarting.value,
                color: Colors.white,
                onPressed: controller.startMining,
              )
            else if (!controller.canClaim) ...[
              AppButton(
                label: 'MINING...'.tr,
                color: Colors.white,
                onPressed: null,
              ),
              if (session.canSpeedUpWithAd && (controller.speedUpsLeft.value ?? 0) > 0) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.isSpeedingUp.value ? null : controller.speedUpWithAd,
                    icon: controller.isSpeedingUp.value
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.fast_forward_rounded, size: 18, color: Colors.white),
                    label: Text(
                      'speedUpButton'.trParams({
                        'left': '${controller.speedUpsLeft.value}',
                      }),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ]
            else
              _SessionCompleteActions(controller: controller, session: session),
          ],
        ),
      );
    });
  }
}

/// Shown once a session's countdown hits zero: claim now, or keep mining for
/// free (rewarded ad, capped) or for a small Razorpay purchase - never both
/// forced, claiming stays one tap away the whole time.
class _SessionCompleteActions extends StatelessWidget {
  final MiningController controller;
  final MiningSessionModel session;
  const _SessionCompleteActions({required this.controller, required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: 'CLAIM REWARD'.tr,
          loading: controller.isClaiming.value && !controller.isClaimingDouble.value,
          color: Colors.white,
          onPressed: controller.isClaimingDouble.value ? null : controller.claimReward,
        ),
        const SizedBox(height: 10),
        // Opt-in rewarded ad - the best-paying ad format, and players like
        // it because they choose it.
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.isClaiming.value || controller.isClaimingDouble.value
                ? null
                : controller.claimDoubleWithAd,
            icon: controller.isClaimingDouble.value
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                  )
                : const Icon(Icons.ondemand_video_rounded, size: 18),
            label: Text('Watch ad · Claim 2x'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.warning,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppText('or keep mining a little longer'.tr, color: Colors.white70, size: 12),
        const SizedBox(height: 10),
        Row(
          children: [
            if (session.canExtendWithAd)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.isExtendingWithAd.value ? null : controller.watchAdForMoreTime,
                  icon: controller.isExtendingWithAd.value
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.ondemand_video_rounded, size: 16, color: Colors.white),
                  label: Text('+15 min free'.tr, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
                ),
              ),
            if (session.canExtendWithAd) const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.isBuyingTime.value ? null : controller.buyMoreTime,
                icon: controller.isBuyingTime.value
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                label: Text(
                  'extraTimeButton'.trParams({'price': controller.extraTimePrice.value}),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final dynamic session;
  const _HistoryTile({required this.session});

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
          Icon(
            session.status == 'completed'
                ? Icons.check_circle
                : Icons.timelapse,
            color: session.status == 'completed'
                ? AppColor.success
                : AppColor.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(Formatters.dateTime(session.startedAt), size: 13),
                AppText.caption(Formatters.hashrate(session.hashrateSnapshot)),
              ],
            ),
          ),
          if (session.calculatedReward != null)
            AppText(
              '+${Formatters.points(session.calculatedReward)}',
              color: AppColor.secondary,
              weight: FontWeight.w700,
            ),
        ],
      ),
    );
  }
}
