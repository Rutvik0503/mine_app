import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/machine_controller.dart';

class MachineListView extends GetView<MachineController> {
  const MachineListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const PrimaryAppBar(title: 'My Machines'),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        if (controller.myMachines.isEmpty) {
          return const EmptyStateWidget(message: 'No machines yet.', icon: Icons.memory_rounded);
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColor.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.myMachines.length,
            itemBuilder: (context, index) {
              final m = controller.myMachines[index];
              return GestureDetector(
                onTap: () => controller.openDetail(m),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColor.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColor.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.memory_rounded, color: AppColor.secondary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(m.machine?.name ?? 'Machine', weight: FontWeight.w700),
                            const SizedBox(height: 4),
                            AppText.caption(
                                'Level ${m.level} • ${m.currentHashrate.toStringAsFixed(1)} TH/s • ${(m.currentEfficiency * 100).toStringAsFixed(0)}% eff.'),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColor.textDisabled),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
