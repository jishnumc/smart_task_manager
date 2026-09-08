import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';

class AuthHeaderBranding extends StatelessWidget {
  const AuthHeaderBranding({
    super.key,
    required this.isSignUp,
  });

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Icon(
          Icons.task_alt_rounded,
          size: 64,
          color: colors.primary,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Smart Task Manager',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineMedium?.copyWith(
            color: colors.mainText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isSignUp
              ? 'Create an account to manage your tasks'
              : 'Welcome back! Please sign in to continue',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.subText,
          ),
        ),
      ],
    );
  }
}
