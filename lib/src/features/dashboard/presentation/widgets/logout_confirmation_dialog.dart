import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({
    super.key,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => LogoutConfirmationDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout_rounded,
              color: colors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Sign Out',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.mainText,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to sign out of Smart Task Manager?',
        style: context.textTheme.bodyMedium?.copyWith(
          color: colors.subText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: colors.subText)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}
