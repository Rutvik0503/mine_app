import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/utils/formatters.dart';
import '../view_model/mining_controller.dart';

class MiningView extends GetView<MiningController> {
  const MiningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(title: const AppText.subHeading('Mining'), automaticallyImplyLeading: false),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColor.primary,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _StatusCard(controller: controller),
              const SizedBox(height: 20),
              const AppText.subHeading('Active Boosts'),
              const SizedBox(height: 10),
              if (controller.activeBoosts.isEmpty)
                const AppText.caption('No active boosts. Watch an ad to get one!')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.activeBoosts
                      .map((b) => Chip(
                            label: Text('${b.boost?.name ?? 'Boost'} x${b.boost?.multiplier ?? 1}'),
                            backgroundColor: AppColor.surfaceElevated,
                          ))
                      .toList(),
                ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Watch Ad for Boost',
                outlined: true,
                color: AppColor.accent,
                icon: Icons.ondemand_video_rounded,
                onPressed: controller.watchAdForBoost,
              ),
              const SizedBox(height: 24),
              const AppText.subHeading('Mining History'),
              const SizedBox(height: 10),
              if (controller.history.isEmpty)
                const EmptyStateWidget(message: 'No mining sessions yet.')
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
    final session = controller.session.value;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColor.miningGradient),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            session != null ? Icons.bolt_rounded : Icons.bolt_outlined,
            color: Colors.white,
            size: 56,
          ),
          const SizedBox(height: 12),
          AppText(
            session != null
                ? (controller.canClaim ? 'READY TO CLAIM' : 'MINING IN PROGRESS')
                : 'NO ACTIVE SESSION',
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
            AppText('Hashrate: ${Formatters.hashrate(session.hashrateSnapshot)}',
                color: Colors.white70, size: 13),
          const SizedBox(height: 20),
          if (session == null)
            Obx(
              () => AppButton(
                label: 'START MINING',
                loading: controller.isStarting.value,
                color: Colors.white,
                onPressed: controller.startMining,
              ),
            )
          else
            Obx(
              () => AppButton(
                label: controller.canClaim ? 'CLAIM REWARD' : 'MINING...',
                loading: controller.isClaiming.value,
                color: Colors.white,
                onPressed: controller.canClaim ? controller.claimReward : null,
              ),
            ),
        ],
      ),
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
            session.status == 'completed' ? Icons.check_circle : Icons.timelapse,
            color: session.status == 'completed' ? AppColor.success : AppColor.textSecondary,
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
            AppText('+${Formatters.points(session.calculatedReward)}',
                color: AppColor.secondary, weight: FontWeight.w700),
        ],
      ),
    );
  }
}
