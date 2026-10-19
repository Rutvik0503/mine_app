import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/app_color.dart';
import '../server_model/machine/model/user_machine_model.dart';
import '../utils/formatters.dart';
import 'app_text.dart';

/// "⏳ 3 days left · Ends Oct 22, 11:43 AM" for a rented miner - green while
/// there's time, orange in the last day, red once it has ended. Renders
/// nothing for miners owned outright.
class RentalTimeLeft extends StatelessWidget {
  final UserMachineModel machine;

  /// Show the end date and time as well as the time left.
  final bool showDate;
  const RentalTimeLeft({super.key, required this.machine, this.showDate = true});

  @override
  Widget build(BuildContext context) {
    final end = machine.expiresAt;
    if (end == null) return const SizedBox.shrink();
    final color = machine.isExpired
        ? AppColor.error
        : (machine.endsSoon ? AppColor.warning : AppColor.primary);
    final label = machine.isExpired
        ? 'Rental expired'.tr
        : showDate
            ? '${Formatters.timeLeft(end)} · ${'endsOn'.trParams({'date': Formatters.dateTime(end)})}'
            : Formatters.timeLeft(end);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(machine.isExpired ? Icons.timer_off_rounded : Icons.hourglass_bottom_rounded, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(child: AppText(label, size: 11, weight: FontWeight.w600, color: color, maxLines: 1)),
      ],
    );
  }
}
