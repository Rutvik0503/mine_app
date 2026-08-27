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

  static String percent(double value) => '${(value * 100).clamp(0, 100).toStringAsFixed(0)}%';
}
