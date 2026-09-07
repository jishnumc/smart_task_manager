import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/primary_button.dart';
import 'package:smart_task_manager/src/design_system/widgets/cards/app_card.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/task_list_notifier.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(taskListProvider.notifier).loadMoreTasks();
    }
  }

  String _formatCreatedDate(DateTime? date) {
    if (date == null) return 'Created: N/A';
    return 'Created: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext parentContext, TaskEntity task) {
    final colors = parentContext.appColors;

    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Delete Task',
            style: parentContext.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.mainText,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
            style: parentContext.textTheme.bodyMedium?.copyWith(
              color: colors.subText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.subText),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await ref
                    .read(taskListProvider.notifier)
                    .deleteTask(task.id);
                if (parentContext.mounted && success) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('All Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Task',
            onPressed: () => context.push('/create-task'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline Banner
          if (state.isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xs,
                horizontal: AppSpacing.md,
              ),
              color: Colors.orange.withValues(alpha: 0.15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Offline Mode — Showing local cached tasks',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(taskListProvider.notifier).refreshTasks(),
              child: Skeletonizer(
                enabled: state.isLoading,
                child: state.isLoading
                    ? ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: 5,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          return AppCard(
                            child: ListTile(
                              title: const Text('Loading task item title...'),
                              subtitle: const Text('Created: 2026-09-08'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.visibility_outlined),
                                  SizedBox(width: 8),
                                  Icon(Icons.delete_outline_rounded),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : state.errorMessage != null && state.tasks.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        size: 64,
                                        color: colors.error,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        'Failed to load tasks',
                                        style: context.textTheme.titleMedium
                                            ?.copyWith(
                                          color: colors.mainText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        state.errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: colors.subText,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      PrimaryButton(
                                        text: 'Retry',
                                        fullWidth: false,
                                        icon: Icons.refresh_rounded,
                                        onPressed: () => ref
                                            .read(
                                                taskListProvider.notifier)
                                            .fetchInitialTasks(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : state.tasks.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  child: Center(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(AppSpacing.xl),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.assignment_outlined,
                                            size: 72,
                                            color: colors.subText
                                                .withValues(alpha: 0.5),
                                          ),
                                          const SizedBox(height: AppSpacing.md),
                                          Text(
                                            'No Tasks Available',
                                            style: context.textTheme.titleLarge
                                                ?.copyWith(
                                              color: colors.mainText,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'Create your first task to get started',
                                            style: context.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: colors.subText,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xl),
                                          PrimaryButton(
                                            text: 'Create New Task',
                                            fullWidth: false,
                                            icon: Icons.add_rounded,
                                            onPressed: () =>
                                                context.push('/create-task'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: state.tasks.length +
                                    (state.isLoadingMore ? 1 : 0),
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  if (index == state.tasks.length) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: AppSpacing.md),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  }

                                  final task = state.tasks[index];
                                  final isDeleting =
                                      state.deletingTaskId == task.id;

                                  return AppCard(
                                    child: InkWell(
                                      onTap: () => context.push(
                                        '/task-detail',
                                        extra: task,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(AppSpacing.xs),
                                        child: Row(
                                          children: [
                                            // Priority indicator bar
                                            Container(
                                              width: 4,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: task.isCompleted
                                                    ? Colors.green
                                                    : colors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: AppSpacing.md),

                                            // Task Title and Created Date
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    task.title,
                                                    style: context
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      color: colors.mainText,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      decoration: task.isCompleted
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : null,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(
                                                      height: AppSpacing.xxs),
                                                  Text(
                                                    _formatCreatedDate(
                                                        task.createdAt),
                                                    style: context
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: colors.subText,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // View Details Icon Button
                                            IconButton(
                                              icon: Icon(
                                                Icons.visibility_outlined,
                                                color: colors.mainText,
                                                size: 20,
                                              ),
                                              tooltip: 'View Details',
                                              onPressed: () => context.push(
                                                '/task-detail',
                                                extra: task,
                                              ),
                                            ),

                                            // Delete Icon Button
                                            isDeleting
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : IconButton(
                                                    icon: Icon(
                                                      Icons.delete_outline_rounded,
                                                      color: colors.error,
                                                      size: 20,
                                                    ),
                                                    tooltip: 'Delete Task',
                                                    onPressed: () =>
                                                        _showDeleteConfirmation(
                                                      context,
                                                      task,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
