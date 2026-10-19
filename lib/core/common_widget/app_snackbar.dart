import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/app_color.dart';

/// App-wide toast: a floating card that slides up from the bottom, above the
/// tab bar and banner ad. One at a time - a new message replaces the old.
class AppSnackbar {
  AppSnackbar._();

  static void success(String message) =>
      _show(title: 'Success'.tr, message: message, color: AppColor.success, icon: Icons.check_rounded);

  static void error(String message) =>
      _show(title: 'Oops!'.tr, message: _clean(message), color: AppColor.error, icon: Icons.close_rounded);

  static void info(String message) =>
      _show(title: 'Info'.tr, message: message, color: AppColor.accent, icon: Icons.info_outline_rounded);

  /// Clears room above the bottom tab bar + banner ad.
  static const double _bottomGap = 92;

  /// Exceptions arrive as "Exception: ..." / "EdgeFunctionException: ..." -
  /// players only need the message itself.
  static String _clean(String message) {
    var text = message.trim();
    final prefix = RegExp(r'^[A-Za-z]*(Exception|Error)\s*:\s*');
    while (prefix.hasMatch(text)) {
      text = text.replaceFirst(prefix, '');
    }
    return text.isEmpty ? 'Something went wrong. Please try again.'.tr : text;
  }

  static void _show({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, _bottomGap),
        duration: const Duration(milliseconds: 2800),
        animationDuration: const Duration(milliseconds: 380),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInCubic,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        messageText: _SnackCard(title: title, message: message, color: color, icon: icon),
      ),
    );
  }
}

class _SnackCard extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  const _SnackCard({required this.title, required this.message, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6)),
          BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 14),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colour stripe on the left edge.
            Container(width: 5, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.18),
                        border: Border.all(color: color.withValues(alpha: 0.6)),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColor.textPrimary, fontSize: 13, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
