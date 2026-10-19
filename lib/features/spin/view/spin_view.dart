import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/error_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/server_model/spin/model/spin_status_model.dart';
import '../../../core/utils/formatters.dart';
import '../view_model/spin_controller.dart';
import 'spin_wheel.dart';

class SpinView extends StatefulWidget {
  const SpinView({super.key});

  @override
  State<SpinView> createState() => _SpinViewState();
}

class _SpinViewState extends State<SpinView> {
  final SpinController controller = Get.find<SpinController>();
  final GlobalKey<SpinWheelState> _wheelKey = GlobalKey<SpinWheelState>();

  Future<void> _run(Future<SpinStatusModel?> Function() spin) async {
    final result = await spin();
    if (result?.segment == null) return;
    await _wheelKey.currentState?.spinTo(result!.segment!);
    await controller.onSpinLanded(result!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PrimaryAppBar(
        title: 'Fortune Wheel'.tr,
        actions: [
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: AppColor.warning, size: 18),
                  const SizedBox(width: 6),
                  AppText(Formatters.points(controller.coins.value), weight: FontWeight.w700, size: 13),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        if (controller.hasError.value) return ErrorStateWidget(onRetry: controller.load);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppText.caption(
              'Lucky numbers are 1, 3, 5 and 7 - land on one to win coins. Spend coins on farm upgrades and miners.'.tr,
              align: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(child: SpinWheel(key: _wheelKey)),
            const SizedBox(height: 24),
            Obx(
              () => AppButton(
                label: 'Spin the Wheel'.tr,
                icon: Icons.casino_rounded,
                color: Colors.white,
                loading: controller.isSpinning.value,
                onPressed: controller.freeSpinsLeft.value > 0 ? () => _run(controller.spinFree) : null,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => AppText.caption(
                'freeSpinsLeft'.trParams({'count': '${controller.freeSpinsLeft.value}'}),
                align: TextAlign.center,
              ),
            ),
            const SizedBox(height: 14),
            Obx(
              () => AppButton(
                label: 'adSpinsLeft'.trParams({'count': '${controller.adSpinsLeft.value}'}),
                icon: Icons.ondemand_video_rounded,
                outlined: true,
                onPressed: controller.adSpinsLeft.value > 0 && !controller.isSpinning.value
                    ? () => _run(controller.spinWithAd)
                    : null,
              ),
            ),
            const SizedBox(height: 28),
            Center(child: AppText.subHeading('Score Table'.tr)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                children: [
                  for (var segment = 0; segment <= 8; segment++)
                    _ScoreRow(
                      segment: segment,
                      reward: controller.rewardFor(segment),
                      showDivider: segment < 8,
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int segment;
  final double reward;
  final bool showDivider;
  const _ScoreRow({required this.segment, required this.reward, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final wins = reward > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider ? Border(bottom: BorderSide(color: AppColor.border)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: AppText('$segment', size: 12, weight: FontWeight.w800, color: AppColor.primary),
          ),
          const SizedBox(width: 14),
          Text(kSegmentEmoji[segment]!, style: const TextStyle(fontSize: 20)),
          const Spacer(),
          AppText(
            wins ? 'coinsAmount'.trParams({'coins': reward.toStringAsFixed(0)}) : '— N/A',
            weight: FontWeight.w800,
            size: 13,
            color: wins ? AppColor.primary : AppColor.error,
          ),
        ],
      ),
    );
  }
}
