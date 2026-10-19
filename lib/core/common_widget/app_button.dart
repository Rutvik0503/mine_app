import 'package:flutter/material.dart';
import '../constant/app_color.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final Color color;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.color = AppColor.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // A solid button's text/spinner must contrast with its own background
    // (not just assume white) - e.g. color: Colors.white would otherwise
    // render white text on a white button.
    final foreground = outlined
        ? color
        : (ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : AppColor.background);

    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            disabledForegroundColor: loading ? color : null,
            side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        // Keep the button's own colours while loading, so the spinner shows
        // clearly instead of a faded grey "disabled" button.
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground,
          disabledBackgroundColor: loading ? color : null,
          disabledForegroundColor: loading ? foreground : null,
        ),
        child: child,
      ),
    );
  }
}
