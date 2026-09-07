import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/cards/app_card.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';

class TaskCardItem extends StatelessWidget {
  const TaskCardItem({
    super.key,
    required this.task,
    required this.isDeleting,
    required this.onTap,
    required this.onDeletePressed,
  });

  final TaskEntity task;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onDeletePressed;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final priorityColor = _getPriorityColor(task.priority);

    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Status indicator
                  Icon(
                    task.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: task.isCompleted ? Colors.green : colors.subText,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Task title
                  Expanded(
                    child: Text(
                      task.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: colors.mainText,
                        fontWeight: FontWeight.bold,
                        decoration:
                            task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Actions
                  IconButton(
                    icon: Icon(
                      Icons.visibility_outlined,
                      color: colors.mainText,
                      size: 20,
                    ),
                    tooltip: 'View Details',
                    onPressed: onTap,
                  ),
                  isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: colors.error,
                            size: 20,
                          ),
                          tooltip: 'Delete Task',
                          onPressed: onDeletePressed,
                        ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // Badges & Dates Row
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.priority,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Category Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.outline.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.category,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.subText,
                      ),
                    ),
                  ),

                  // Due Date
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: colors.subText,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        'Due: ${_formatDate(task.dueDate)}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.subText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  // Created Date
                  if (task.createdAt != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: colors.subText,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          'Created: ${_formatDate(task.createdAt!)}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.subText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
