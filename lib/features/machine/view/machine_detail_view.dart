import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/rental_time_left.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/mining_visuals.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/utils/type_icons.dart';
import '../view_model/machine_controller.dart';

class MachineDetailView extends GetView<MachineController> {
  const MachineDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PrimaryAppBar(title: 'Machine Details'.tr),
      body: Obx(() {
        final m = controller.selected.value;
        if (m == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.memory_outlined, color: AppColor.textSecondary, size: 48),
                  const SizedBox(height: 12),
                  AppText.caption('This machine could not be found.'.tr),
                  const SizedBox(height: 20),
                  AppButton(label: 'Go Back'.tr, onPressed: () => Get.back()),
                ],
              ),
            ),
          );
        }
        final isMax = m.level >= (m.machine?.maxLevel ?? 10);
        final isAdvanced = (m.machine?.machineType ?? 'standard').toLowerCase() == 'advanced';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColor.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SpinningGear(
                        size: 84,
                        color: AppColor.secondary.withValues(alpha: 0.15),
                        seconds: 14,
                      ),
                      Icon(
                        TypeIcons.machine(m.machine?.machineType ?? 'standard'),
                        color: AppColor.secondary,
                        size: 44,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: AppText.heading(m.machine?.name ?? 'Machine')),
              const SizedBox(height: 4),
              Center(
                child: AppText.caption(
                  'machineRigLevel'.trParams({
                    'rig': (isAdvanced ? 'Advanced Rig' : 'Standard Rig').tr,
                    'level': '${m.level}',
                    'maxLevel': '${m.machine?.maxLevel ?? 10}',
                  }),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                        label: 'Hashrate'.tr, value: '${m.currentHashrate.toStringAsFixed(1)} TH/s'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                        label: 'Efficiency'.tr, value: '${(m.currentEfficiency * 100).toStringAsFixed(0)}%'),
                  ),
                ],
              ),
              if (m.machine?.description != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.caption('About this machine'.tr),
                      const SizedBox(height: 6),
                      AppText(m.machine!.description!, size: 13),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              if (m.isRental) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: m.endsSoon ? AppColor.warning : AppColor.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.caption('Rental'.tr),
                      const SizedBox(height: 6),
                      RentalTimeLeft(machine: m),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppText.caption(
                  "Rented miners run at their listed hashrate for the plan period and can't be upgraded.".tr,
                ),
              ]
              else if (isMax)
                AppText.caption('This machine has reached its maximum level.'.tr)
              else ...[
                Center(
                  child: AppText.caption(
                    'upgradeCostCoins'.trParams({'cost': '${controller.upgradeCost(m)}'}),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => AppButton(
                    label: 'UPGRADE'.tr,
                    loading: controller.upgradingId.value == m.id,
                    onPressed: () => controller.onUpgradeTap(m),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.caption(label),
          const SizedBox(height: 6),
          AppText(value, size: 18, weight: FontWeight.w700),
        ],
      ),
    );
  }
}
