import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/rental_time_left.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/error_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/server_model/machine/model/machine_model.dart';
import '../../../core/server_model/machine/model/user_machine_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/type_icons.dart';
import '../view_model/farm_controller.dart';

class FarmView extends GetView<FarmController> {
  const FarmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: AppText.subHeading('Mining Farm'.tr),
        centerTitle: true,
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
              _MyFarmCard(controller: controller),
              const SizedBox(height: 20),
              _CategoryTabs(controller: controller),
              const SizedBox(height: 20),
              const _SectionTitle('Available Miners'),
              const SizedBox(height: 12),
              ..._storeList(),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _storeList() {
    final machines = controller.visibleStoreMachines;
    if (controller.isStoreLoading.value && machines.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: AppColor.primary)),
        ),
      ];
    }
    if (machines.isEmpty) {
      return [AppText.caption('No miners in this farm yet.'.tr, align: TextAlign.center)];
    }
    return machines
        .map((m) {
          final owned = controller.ownedCopyOf(m.id);
          return _MinerTile(
            machine: m,
            owned: owned,
            status: controller.minerStatus(owned),
            onBuy: () => controller.openPlans(m),
          );
        })
        .toList();
  }
}

class _MyFarmCard extends StatelessWidget {
  final FarmController controller;
  const _MyFarmCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final farm = controller.farm.value;
    final active = controller.activeMachines;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  TypeIcons.farmType(farm?.farmType?.name ?? 'Free Farm'),
                  color: AppColor.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(farm?.farmType?.name ?? 'Free Farm', weight: FontWeight.w700),
                    AppText.caption(
                      'farmLevelCapacity'.trParams({
                        'level': '${farm?.level ?? 1}',
                        'capacity': '${farm?.capacity ?? 1}',
                      }),
                    ),
                  ],
                ),
              ),
              Obx(
                () => TextButton.icon(
                  onPressed: controller.isUpgrading.value
                      ? null
                      : controller.onUpgradeTap,
                  icon: const Icon(Icons.upgrade_rounded, size: 18),
                  label: Text('Upgrade'.tr),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Slots used'.tr,
                  value: '${active.length}/${farm?.capacity ?? 1}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Est. per hour'.tr,
                  value: controller.estimatedPointsPerHour.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Multiplier'.tr,
                  value: 'x${(farm?.multiplier ?? 1).toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: controller.goToMachines,
            child: Row(
              children: [
                AppText.caption('myMachinesCount'.trParams({'count': '${active.length}'})),
                const Spacer(),
                AppText('View all'.tr, size: 12, weight: FontWeight.w600, color: AppColor.primary),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColor.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColor.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.caption(label, maxLines: 1),
          const SizedBox(height: 4),
          AppText(value, weight: FontWeight.w700, size: 14),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  final FarmController controller;
  const _CategoryTabs({required this.controller});

  static String _label(String category) => switch (category) {
        'air' => 'Air Farm'.tr,
        'hydro' => 'Hydro Farm'.tr,
        _ => 'Premium'.tr,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Obx(
        () => Row(
          children: FarmController.storeCategories.map((c) {
            final selected = controller.selectedCategory.value == c;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectCategory(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: selected ? AppColor.primary.withValues(alpha: 0.18) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? AppColor.primary : Colors.transparent),
                  ),
                  child: AppText(
                    _label(c),
                    align: TextAlign.center,
                    size: 13,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColor.primary : AppColor.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 18, color: AppColor.primary),
        const SizedBox(width: 10),
        AppText(text.tr, weight: FontWeight.w700),
      ],
    );
  }
}

class _MinerTile extends StatelessWidget {
  final MachineModel machine;
  final UserMachineModel? owned;
  final MinerStatus status;
  final VoidCallback onBuy;
  const _MinerTile({required this.machine, required this.owned, required this.status, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    final cheapest = machine.plans.isEmpty
        ? null
        : machine.plans.reduce((a, b) => a.pricePaise <= b.pricePaise ? a : b);
    final isActive = owned != null && status != MinerStatus.expired;
    final isExpired = status == MinerStatus.expired;
    // Green while the miner is in the running session, amber while it waits
    // for the next one, neutral when no session is running.
    final accent = switch (status) {
      MinerStatus.nextSession => AppColor.warning,
      MinerStatus.idle || MinerStatus.notSelected => AppColor.textSecondary,
      _ => AppColor.primary,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? accent.withValues(alpha: 0.06) : AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? accent.withValues(alpha: 0.7) : AppColor.border,
          width: isActive ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? accent.withValues(alpha: 0.14) : AppColor.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              TypeIcons.machine(machine.machineType),
              color: isActive ? accent : AppColor.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: AppText(machine.name, weight: FontWeight.w700, size: 14, maxLines: 1)),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      _StatusChip(
                        label: switch (status) {
                          MinerStatus.mining => 'MINING'.tr,
                          MinerStatus.nextSession => 'NEXT SESSION'.tr,
                          MinerStatus.notSelected => 'NOT SELECTED'.tr,
                          _ => 'ACTIVE'.tr,
                        },
                        color: accent,
                        dot: status == MinerStatus.mining,
                      ),
                    ] else if (isExpired) ...[
                      const SizedBox(width: 6),
                      _StatusChip(label: 'EXPIRED'.tr, color: AppColor.error),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                AppText(
                  Formatters.hashrate(machine.baseHashrate),
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColor.primary,
                ),
                if (isActive) ...[
                  // Mining rentals need no status line - the time left says it all.
                  if (status != MinerStatus.mining || !owned!.isRental)
                    AppText.caption(
                      switch (status) {
                        MinerStatus.nextSession => 'Starts mining next session'.tr,
                        MinerStatus.notSelected => 'Not in this session'.tr,
                        MinerStatus.idle => 'Start mining to use it'.tr,
                        _ => 'Mining in your farm'.tr,
                      },
                      color: accent,
                    ),
                  if (owned!.isRental) ...[
                    const SizedBox(height: 2),
                    RentalTimeLeft(machine: owned!, showDate: false),
                  ],
                ] else if (cheapest != null)
                  AppText.caption('fromPrice'.trParams({'price': '${cheapest.priceRupees}'})),
              ],
            ),
          ),
          if (isActive)
            OutlinedButton(
              // Renting again adds time to the running rental (see rental.ts).
              onPressed: machine.plans.isEmpty || !owned!.isRental ? null : onBuy,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.primary,
                side: const BorderSide(color: AppColor.primary),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              child: Text(owned!.isRental ? 'Renew'.tr : 'Owned'.tr),
            )
          else
            ElevatedButton(
              onPressed: machine.plans.isEmpty ? null : onBuy,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              child: Text(isExpired ? 'Buy Again'.tr : 'Buy Now'.tr),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool dot;
  const _StatusChip({required this.label, required this.color, this.dot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
          ],
          AppText(label, size: 10, weight: FontWeight.w800, color: color),
        ],
      ),
    );
  }
}
