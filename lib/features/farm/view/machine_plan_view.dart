import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/server_model/machine/model/machine_plan_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/type_icons.dart';
import '../view_model/machine_plan_controller.dart';

class MachinePlanView extends GetView<MachinePlanController> {
  const MachinePlanView({super.key});

  @override
  Widget build(BuildContext context) {
    final machine = controller.machine;
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PrimaryAppBar(title: machine.name),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColor.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _MinerIcon(machineType: machine.machineType),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(machine.name, weight: FontWeight.w700, size: 16),
                          const SizedBox(height: 2),
                          AppText.caption('categoryMiningMachine'
                              .trParams({'category': _categoryName(machine.farmCategory)})),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SpecRow(label: 'Hashrate'.tr, value: Formatters.hashrate(machine.baseHashrate)),
                const SizedBox(height: 8),
                _SpecRow(
                  label: 'Power Consumption'.tr,
                  value: machine.powerWatts != null ? '${machine.powerWatts}W (±5%)' : '—',
                ),
                if (machine.description != null) ...[
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: AppText.caption(machine.description!)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Obx(
            () => Row(
              children: [
                for (final plan in machine.plans) ...[
                  Expanded(
                    child: _PlanTile(
                      plan: plan,
                      selected: controller.selected.value?.id == plan.id,
                      onTap: () => controller.select(plan),
                    ),
                  ),
                  if (plan != machine.plans.last) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
          if (machine.plans.isEmpty) AppText.caption('No plans available for this miner right now.'.tr),
          const SizedBox(height: 24),
          // Miners are bought with coins only; real money buys coin packs
          // through Google Play on the Store screen.
          Obx(() {
            final plan = controller.selected.value;
            return AppButton(
              label: plan == null
                  ? 'Select a plan'.tr
                  : 'payCoins'.trParams({'coins': Formatters.points(plan.priceCoins)}),
              icon: Icons.monetization_on_rounded,
              loading: controller.isPayingCoins.value,
              onPressed: controller.canAffordCoins ? controller.payWithCoins : null,
            );
          }),
          Obx(() {
            final shortfall = controller.coinShortfall;
            if (shortfall <= 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AppButton(
                label: 'getMoreCoins'.trParams({'coins': Formatters.points(shortfall)}),
                icon: Icons.add_shopping_cart_rounded,
                outlined: true,
                color: AppColor.warning,
                onPressed: controller.goToStore,
              ),
            );
          }),
          const SizedBox(height: 8),
          Obx(
            () => AppText.caption(
              'coinBalance'.trParams({'coins': Formatters.points(controller.coins.value)}),
              align: TextAlign.center,
            ),
          ),
          const SizedBox(height: 22),
          AppText.caption(
            'The miner runs in your farm for the selected period and then stops - nothing renews automatically. Renting the same miner again adds time to it. Rented miners use a farm slot.'
                .tr,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static String _categoryName(String? category) => switch (category) {
        'air' => 'Air Farm'.tr,
        'hydro' => 'Hydro Farm'.tr,
        'premium' => 'Premium Farm'.tr,
        _ => 'Farm'.tr,
      };
}

class _MinerIcon extends StatelessWidget {
  final String machineType;
  const _MinerIcon({required this.machineType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColor.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(TypeIcons.machine(machineType), color: AppColor.primary),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText.caption(label),
        const Spacer(),
        AppText(value, weight: FontWeight.w700, size: 13),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  final MachinePlanModel plan;
  final bool selected;
  final VoidCallback onTap;
  const _PlanTile({required this.plan, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
            decoration: BoxDecoration(
              color: selected ? AppColor.primary.withValues(alpha: 0.12) : AppColor.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColor.primary : AppColor.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                AppText(plan.label, weight: FontWeight.w600, size: 13, align: TextAlign.center),
                const SizedBox(height: 6),
                AppText.caption(
                  'coinsPerDay'.trParams({'coins': (plan.priceCoins / plan.durationDays).toStringAsFixed(0)}),
                  align: TextAlign.center,
                ),
                const SizedBox(height: 10),
                AppText(
                  Formatters.points(plan.priceCoins),
                  weight: FontWeight.w800,
                  size: 16,
                  color: selected ? AppColor.primary : null,
                ),
              ],
            ),
          ),
          if (plan.isPopular)
            Positioned(
              top: -9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText('POPULAR'.tr, size: 9, weight: FontWeight.w800, color: AppColor.background),
              ),
            ),
        ],
      ),
    );
  }
}
