import 'package:flutter/material.dart';
import '../constant/app_color.dart';
import 'app_text.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({super.key, required this.message, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColor.textDisabled),
            const SizedBox(height: 12),
            AppText.caption(message, align: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
