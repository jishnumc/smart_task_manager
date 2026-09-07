import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/cards/app_card.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  final TaskEntity task;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final statusColor = task.isCompleted ? Colors.green : Colors.orange;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Task Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: colors.mainText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              task.isCompleted
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.pending_actions_rounded,
                              size: 16,
                              color: statusColor,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              task.isCompleted ? 'Completed' : 'Pending',
                              style: context.textTheme.labelMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (task.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: colors.subText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      task.description,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.mainText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _DetailBadge(
                        label: 'Priority: ${task.priority}',
                        icon: Icons.flag_outlined,
                        colors: colors,
                      ),
                      _DetailBadge(
                        label: 'Category: ${task.category}',
                        icon: Icons.folder_outlined,
                        colors: colors,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  _MetaTile(
                    icon: Icons.calendar_today_rounded,
                    title: 'Due Date',
                    value: _formatDate(task.dueDate),
                    colors: colors,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _MetaTile(
                    icon: Icons.access_time_rounded,
                    title: 'Created At',
                    value: task.createdAt != null
                        ? _formatDate(task.createdAt!)
                        : 'N/A',
                    colors: colors,
                  ),
                  if (task.updatedAt != null) ...[
                    const Divider(height: AppSpacing.lg),
                    _MetaTile(
                      icon: Icons.update_rounded,
                      title: 'Updated At',
                      value: _formatDate(task.updatedAt!),
                      colors: colors,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.outline.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.subText),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.mainText,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final String value;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.subText),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.subText,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.mainText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
