import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/machine_controller.dart';

class MachineDetailView extends GetView<MachineController> {
  const MachineDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const PrimaryAppBar(title: 'Machine Details'),
      body: Obx(() {
        final m = controller.selected.value;
        if (m == null) return const SizedBox.shrink();
        final isMax = m.level >= (m.machine?.maxLevel ?? 10);
        return Padding(
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
                  child: const Icon(Icons.memory_rounded, color: AppColor.secondary, size: 44),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: AppText.heading(m.machine?.name ?? 'Machine')),
              const SizedBox(height: 4),
              Center(child: AppText.caption('Level ${m.level} / ${m.machine?.maxLevel ?? 10}')),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(label: 'Hashrate', value: '${m.currentHashrate.toStringAsFixed(1)} TH/s'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                        label: 'Efficiency', value: '${(m.currentEfficiency * 100).toStringAsFixed(0)}%'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (isMax)
                const AppText.caption('This machine has reached its maximum level.')
              else
                Obx(
                  () => AppButton(
                    label: 'UPGRADE',
                    loading: controller.upgradingId.value == m.id,
                    onPressed: () => controller.upgrade(m),
                  ),
                ),
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
