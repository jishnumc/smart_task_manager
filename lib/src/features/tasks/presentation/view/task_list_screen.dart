import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/primary_button.dart';
import 'package:smart_task_manager/src/design_system/widgets/cards/app_card.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/sync_notifier.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/task_list_notifier.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/widgets/sync_prompt_dialog.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/widgets/task_card_item.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/widgets/task_filter_chips.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/widgets/task_list_empty_view.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/widgets/task_search_bar.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/widgets/task_sort_sheet.dart';

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
    Future.microtask(() async {
      await ref.read(syncNotifierProvider.notifier).checkAndPromptSync();
      if (mounted) {
        final syncState = ref.read(syncNotifierProvider);
        if (syncState.isPromptVisible) {
          SyncPromptDialog.show(context, unsyncedCount: syncState.unsyncedCount);
        }
      }
    });
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
            'Are you sure you want to delete "${task.title}"? This will delete the task from server and update local database.',
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
                      content: Text('Task deleted and local database updated.'),
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
    ref.listen<SyncNotifierState>(syncNotifierProvider, (previous, next) {
      if (next.isPromptVisible && (previous?.isPromptVisible != true)) {
        SyncPromptDialog.show(context, unsyncedCount: next.unsyncedCount);
      }
    });

    final colors = context.appColors;
    final state = ref.watch(taskListProvider);
    final notifier = ref.read(taskListProvider.notifier);
    final syncState = ref.watch(syncNotifierProvider);

    final displayTasks = state.filteredAndSortedTasks;
    final isFiltered = state.searchQuery.isNotEmpty ||
        state.categoryFilter != null ||
        state.priorityFilter != null;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Tasks Manager'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (syncState.unsyncedCount > 0)
            IconButton(
              icon:
                  const Icon(Icons.sync_problem_rounded, color: Colors.orange),
              tooltip: 'Sync Offline Tasks (${syncState.unsyncedCount})',
              onPressed: () => SyncPromptDialog.show(
                context,
                unsyncedCount: syncState.unsyncedCount,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Task',
            onPressed: () async {
              await context.push('/create-task');
              if (mounted) {
                ref.read(taskListProvider.notifier).refreshTasks();
              }
            },
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
                    'Offline Mode — Viewing saved local data',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Column(
              children: [
                TaskSearchBar(
                  onSearchChanged: (query) => notifier.setSearchQuery(query),
                ),
                const SizedBox(height: AppSpacing.xs),
                TaskFilterChips(
                  selectedStatus: state.statusFilter,
                  onStatusSelected: (filter) =>
                      notifier.setStatusFilter(filter),
                  selectedCategory: state.categoryFilter,
                  onCategorySelected: (cat) => notifier.setCategoryFilter(cat),
                  selectedPriority: state.priorityFilter,
                  onPrioritySelected: (prio) =>
                      notifier.setPriorityFilter(prio),
                  onOpenSortModal: () => TaskSortSheet.show(
                    context,
                    selectedSort: state.sortBy,
                    isAscending: state.isSortAscending,
                    onSortSelected: (sort) => notifier.setSortBy(sort),
                    onToggleDirection: () => notifier.toggleSortDirection(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Body with Refresh & Paginated List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.refreshTasks(),
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
                              title: const Text('Loading task title placeholder...'),
                              subtitle: const Text('Work • High • Due: 2026-09-08'),
                              trailing: const Icon(Icons.chevron_right_rounded),
                            ),
                          );
                        },
                      )
                    : state.errorMessage != null && state.tasks.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
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
                                        onPressed: () => notifier.fetchInitialTasks(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : displayTasks.isEmpty
                            ? TaskListEmptyView(
                                isFiltered: isFiltered,
                                onResetFilters: () => notifier.resetFilters(),
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: displayTasks.length +
                                    (state.isLoadingMore ? 1 : 0),
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  if (index == displayTasks.length) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: AppSpacing.md),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final task = displayTasks[index];
                                  final isDeleting =
                                      state.deletingTaskId == task.id;

                                  return TaskCardItem(
                                    task: task,
                                    isDeleting: isDeleting,
                                    onTap: () => context.push(
                                      '/task-detail',
                                      extra: task,
                                    ),
                                    onDeletePressed: () =>
                                        _showDeleteConfirmation(context, task),
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
