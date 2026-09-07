import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/primary_button.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/secondary_button.dart';
import 'package:smart_task_manager/src/design_system/widgets/cards/app_card.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/task_list_notifier.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/widgets/update_task_bottom_sheet.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  final TaskEntity task;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late TaskEntity _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _openUpdateBottomSheet() {
    UpdateTaskBottomSheet.show(
      context,
      task: _currentTask,
      onUpdate: (payload) async {
        final notifier = ref.read(taskListProvider.notifier);
        final success = await notifier.updateTask(
          taskId: _currentTask.id,
          payload: payload,
        );

        if (mounted && success) {
          final updatedState = ref.read(taskListProvider);
          final updatedTask = updatedState.tasks.firstWhere(
            (t) => t.id == _currentTask.id,
            orElse: () => TaskEntity(
              id: _currentTask.id,
              userId: _currentTask.userId,
              title: payload.title ?? _currentTask.title,
              description: payload.description ?? _currentTask.description,
              isCompleted: payload.isCompleted ?? _currentTask.isCompleted,
              dueDate: payload.dueDate != null
                  ? (DateTime.tryParse(payload.dueDate!) ?? _currentTask.dueDate)
                  : _currentTask.dueDate,
              priority: payload.priority ?? _currentTask.priority,
              category: payload.category ?? _currentTask.category,
              createdAt: _currentTask.createdAt,
              updatedAt: DateTime.now(),
            ),
          );

          setState(() {
            _currentTask = updatedTask;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return success;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final statusColor = _currentTask.isCompleted ? Colors.green : Colors.orange;

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
                          _currentTask.title,
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
                              _currentTask.isCompleted
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.pending_actions_rounded,
                              size: 16,
                              color: statusColor,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _currentTask.isCompleted ? 'Completed' : 'Pending',
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
                  if (_currentTask.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: colors.subText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _currentTask.description,
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
                        label: 'Priority: ${_currentTask.priority}',
                        icon: Icons.flag_outlined,
                        colors: colors,
                      ),
                      _DetailBadge(
                        label: 'Category: ${_currentTask.category}',
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
                    value: _formatDate(_currentTask.dueDate),
                    colors: colors,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _MetaTile(
                    icon: Icons.access_time_rounded,
                    title: 'Created At',
                    value: _currentTask.createdAt != null
                        ? _formatDate(_currentTask.createdAt!)
                        : 'N/A',
                    colors: colors,
                  ),
                  if (_currentTask.updatedAt != null) ...[
                    const Divider(height: AppSpacing.lg),
                    _MetaTile(
                      icon: Icons.update_rounded,
                      title: 'Updated At',
                      value: _formatDate(_currentTask.updatedAt!),
                      colors: colors,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Bar with Update and Back buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Back',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  text: 'Update Task',
                  icon: Icons.edit_note_rounded,
                  onPressed: _openUpdateBottomSheet,
                ),
              ),
            ],
          ),
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
