import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _numberFormat = NumberFormat.decimalPattern();

  static String hashrate(num value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(2)} PH/s';
    return '${value.toStringAsFixed(2)} TH/s';
  }

  static String points(num value) => _numberFormat.format(value.round());

  static String duration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String date(DateTime dt) => DateFormat('MMM d, yyyy').format(dt.toLocal());

  static String dateTime(DateTime dt) => DateFormat('MMM d, yyyy • h:mm a').format(dt.toLocal());

  /// "3 days left", "5 hours left", "Ends in under an hour" until [end].
  static String timeLeft(DateTime end) {
    final left = end.difference(DateTime.now());
    if (left.isNegative) return 'Rental expired'.tr;
    if (left.inDays >= 2) return 'daysLeft'.trParams({'n': '${left.inDays}'});
    if (left.inDays == 1) return '1 day left'.tr;
    if (left.inHours >= 1) return 'hoursLeft'.trParams({'n': '${left.inHours}'});
    return 'Ends in under an hour'.tr;
  }

  /// Play's localized price without a zero fraction ("₹9,999.00" -> "₹9,999")
  /// so it fits on one line in price buttons.
  static String storePrice(String price) => price.replaceFirst(RegExp(r'[.,]00(?=\D*$)'), '');

  static String percent(double value) => '${(value * 100).clamp(0, 100).toStringAsFixed(0)}%';
}
