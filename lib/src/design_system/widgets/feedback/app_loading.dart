import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';

/// Reusable Skeletonizer wrapper for shimmer loading animations.
class AppSkeletonizer extends StatelessWidget {
  const AppSkeletonizer({
    required this.child,
    super.key,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      child: child,
    );
  }
}

/// Reusable progress indicator with skeleton support.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.subText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
