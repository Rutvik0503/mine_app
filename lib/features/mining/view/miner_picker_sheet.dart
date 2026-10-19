import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/rental_time_left.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/server_model/machine/model/user_machine_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/type_icons.dart';

/// Bottom sheet shown on Start Mining when the player has more than one
/// running miner: pick which ones this session uses. Pops with the chosen
/// user_machines ids, or null when dismissed. Everything starts selected.
class MinerPickerSheet extends StatefulWidget {
  final List<UserMachineModel> machines;
  const MinerPickerSheet({super.key, required this.machines});

  @override
  State<MinerPickerSheet> createState() => _MinerPickerSheetState();
}

class _MinerPickerSheetState extends State<MinerPickerSheet> {
  late final Set<String> _selected = widget.machines.map((m) => m.id).toSet();

  bool get _allSelected => _selected.length == widget.machines.length;

  double get _selectedHashrate => widget.machines
      .where((m) => _selected.contains(m.id))
      .fold(0.0, (sum, m) => sum + m.currentHashrate);

  void _toggle(String id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });

  void _toggleAll() => setState(() {
        if (_allSelected) {
          _selected.clear();
        } else {
          _selected.addAll(widget.machines.map((m) => m.id));
        }
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColor.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: AppText.subHeading('Choose miners'.tr)),
              TextButton(
                onPressed: _toggleAll,
                child: Text(_allSelected ? 'Clear all'.tr : 'Select all'.tr),
              ),
            ],
          ),
          AppText.caption('Pick the miners this session will run on.'.tr),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.machines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _MinerOption(
                machine: widget.machines[i],
                selected: _selected.contains(widget.machines[i].id),
                onTap: () => _toggle(widget.machines[i].id),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AppText.caption('minersSelected'.trParams({
                'count': '${_selected.length}',
                'total': '${widget.machines.length}',
              })),
              const Spacer(),
              AppText(
                Formatters.hashrate(_selectedHashrate),
                weight: FontWeight.w700,
                color: AppColor.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'START MINING'.tr,
            onPressed: _selected.isEmpty ? null : () => Get.back(result: _selected.toList()),
          ),
        ],
      ),
    );
  }
}

class _MinerOption extends StatelessWidget {
  final UserMachineModel machine;
  final bool selected;
  final VoidCallback onTap;
  const _MinerOption({required this.machine, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary.withValues(alpha: 0.08) : AppColor.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColor.primary : AppColor.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? AppColor.primary.withValues(alpha: 0.15) : AppColor.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                TypeIcons.machine(machine.machine?.machineType ?? ''),
                color: selected ? AppColor.primary : AppColor.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(machine.machine?.name ?? 'Machine'.tr, weight: FontWeight.w700, size: 14),
                  const SizedBox(height: 2),
                  AppText.caption(Formatters.hashrate(machine.currentHashrate)),
                  if (machine.isRental) ...[
                    const SizedBox(height: 2),
                    RentalTimeLeft(machine: machine, showDate: false),
                  ],
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColor.primary : AppColor.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
