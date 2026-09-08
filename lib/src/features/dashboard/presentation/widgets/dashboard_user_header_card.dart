import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/cards/app_card.dart';
import 'package:smart_task_manager/src/features/auth/domain/entities/user_entity.dart';

class DashboardUserHeaderCard extends StatelessWidget {
  const DashboardUserHeaderCard({
    super.key,
    required this.user,
  });

  final UserEntity user;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colors.primary.withValues(alpha: 0.2),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: context.textTheme.headlineMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.toUpperCase(),
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.mainText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.subText,
                  ),
                ),
                if (user.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Member since: ${_formatDate(user.createdAt!)}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.subText.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
