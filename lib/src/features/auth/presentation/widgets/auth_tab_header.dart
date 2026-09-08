import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';

class AuthTabHeader extends StatelessWidget {
  const AuthTabHeader({
    super.key,
    required this.isSignUp,
    required this.onTabChanged,
  });

  final bool isSignUp;
  final ValueChanged<bool> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onTabChanged(false),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: !isSignUp ? colors.primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                'Sign In',
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  color: !isSignUp ? colors.primary : colors.subText,
                  fontWeight:
                      !isSignUp ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onTabChanged(true),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSignUp ? colors.primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                'Register',
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  color: isSignUp ? colors.primary : colors.subText,
                  fontWeight: isSignUp ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
