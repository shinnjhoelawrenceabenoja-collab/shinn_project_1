import 'package:flutter/material.dart';

/// Shared action button used across screens (Home, Report Form, ...).
/// Pass `onPressed: null` to disable it, or `isLoading: true` to show a
/// spinner and block duplicate taps.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    final Widget content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    const minSize = Size(180, 48);

    return outlined
        ? OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(minimumSize: minSize),
            child: content,
          )
        : ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(minimumSize: minSize),
            child: content,
          );
  }
}
