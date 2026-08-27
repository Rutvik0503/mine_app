import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/farm_controller.dart';

class FarmView extends GetView<FarmController> {
  const FarmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(title: const AppText.subHeading('Farm'), automaticallyImplyLeading: false),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        final farm = controller.farm.value;
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColor.primary,
          child: ListView(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(farm?.farmType?.name ?? 'Free Farm', size: 18, weight: FontWeight.w700),
                    const SizedBox(height: 6),
                    AppText.caption('Level ${farm?.level ?? 1} • Capacity ${farm?.capacity ?? 1}'),
                    const SizedBox(height: 4),
                    AppText.caption('Multiplier x${(farm?.multiplier ?? 1).toStringAsFixed(2)}'),
                    const SizedBox(height: 16),
                    Obx(
                      () => AppButton(
                        label: 'Upgrade Farm',
                        loading: controller.isUpgrading.value,
                        onPressed: controller.upgradeFarm,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText.subHeading('My Machines'),
                  TextButton(onPressed: controller.goToMachines, child: const Text('View all')),
                ],
              ),
              const SizedBox(height: 10),
              ...controller.myMachines.take(3).map(
                    (m) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColor.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColor.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.memory_rounded, color: AppColor.secondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(m.machine?.name ?? 'Machine', weight: FontWeight.w600),
                                AppText.caption('Level ${m.level} • ${m.currentHashrate.toStringAsFixed(1)} TH/s'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (controller.myMachines.isEmpty)
                const AppText.caption('No machines yet. Complete onboarding to get a starter machine.'),
              const SizedBox(height: 24),
              const AppText.subHeading('Available Farm Types'),
              const SizedBox(height: 10),
              ...controller.farmTypes.map(
                (ft) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(ft.name, weight: FontWeight.w600),
                            AppText.caption(ft.description ?? ''),
                          ],
                        ),
                      ),
                      AppText.caption('Unlocks Lv.${ft.unlockLevel}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
