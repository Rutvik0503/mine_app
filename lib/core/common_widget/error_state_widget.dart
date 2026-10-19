import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/app_color.dart';
import 'app_button.dart';
import 'app_text.dart';

/// Shown when an initial load fails (network error, server error) so the
/// user gets a clear reason and a way to recover, instead of a silently
/// empty screen.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    this.message = "Couldn't load this. Check your connection and try again.",
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: AppColor.textDisabled),
            const SizedBox(height: 12),
            AppText.caption(message.tr, align: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(label: 'Retry'.tr, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
