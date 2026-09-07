import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_task_manager/src/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:smart_task_manager/src/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/create_task_notifier.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/task_list_state.dart';

part 'task_list_notifier.g.dart';

@riverpod
class TaskListNotifier extends _$TaskListNotifier {
  @override
  TaskListState build() {
    Future.microtask(() => fetchInitialTasks());
    return const TaskListState();
  }

  Future<void> fetchInitialTasks() async {
    state = state.copyWith(isLoading: true, errorMessage: null, skip: 0);

    try {
      final repository = ref.read(taskRepositoryProvider);
      final useCase = GetTasksUseCase(repository);

      final result = await useCase(skip: 0, limit: state.limit);

      final newSkip = result.tasks.length;
      final hasMore = result.tasks.length >= state.limit;

      state = state.copyWith(
        isLoading: false,
        tasks: result.tasks,
        total: result.total,
        skip: newSkip,
        hasMore: hasMore,
        isOffline: result.isOfflineSaved,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshTasks() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);

    try {
      final repository = ref.read(taskRepositoryProvider);
      final useCase = GetTasksUseCase(repository);

      final result = await useCase(
        skip: 0,
        limit: state.limit,
        forceRefresh: true,
      );

      final newSkip = result.tasks.length;
      final hasMore = result.tasks.length >= state.limit;

      state = state.copyWith(
        isRefreshing: false,
        tasks: result.tasks,
        total: result.total,
        skip: newSkip,
        hasMore: hasMore,
        isOffline: result.isOfflineSaved,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMoreTasks() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repository = ref.read(taskRepositoryProvider);
      final useCase = GetTasksUseCase(repository);

      final result = await useCase(skip: state.skip, limit: state.limit);

      final updatedTasks = [...state.tasks, ...result.tasks];
      final newSkip = state.skip + result.tasks.length;
      final hasMore = result.tasks.length >= state.limit;

      state = state.copyWith(
        isLoadingMore: false,
        tasks: updatedTasks,
        skip: newSkip,
        hasMore: hasMore,
        isOffline: result.isOfflineSaved,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
      );
    }
  }

  Future<bool> deleteTask(String taskId) async {
    state = state.copyWith(deletingTaskId: taskId);

    try {
      final repository = ref.read(taskRepositoryProvider);
      final useCase = DeleteTaskUseCase(repository);

      await useCase(taskId);

      final updatedTasks = state.tasks.where((t) => t.id != taskId).toList();
      final newTotal = state.total > 0 ? state.total - 1 : 0;

      state = state.copyWith(
        deletingTaskId: null,
        tasks: updatedTasks,
        total: newTotal,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        deletingTaskId: null,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}
