import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';

/// Standard secondary / outlined button using the design system theme.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: colors.primary),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                text,
                style: context.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );

    final button = OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.outline),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: child,
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: button,
      );
    }

    return SizedBox(
      height: 50,
      child: button,
    );
  }
}
