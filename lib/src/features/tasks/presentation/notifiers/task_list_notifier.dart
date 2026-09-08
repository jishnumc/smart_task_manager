import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_update_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:smart_task_manager/src/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:smart_task_manager/src/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/create_task_notifier.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/task_filter_enums.dart';
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

      final existingIds = state.tasks.map((t) => t.id).toSet();
      final newTasks =
          result.tasks.where((t) => !existingIds.contains(t.id)).toList();
      final updatedTasks = [...state.tasks, ...newTasks];
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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(TaskStatusFilter filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void setCategoryFilter(String? category) {
    state = state.copyWith(categoryFilter: category);
  }

  void setPriorityFilter(String? priority) {
    state = state.copyWith(priorityFilter: priority);
  }

  void setSortBy(TaskSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void toggleSortDirection() {
    state = state.copyWith(isSortAscending: !state.isSortAscending);
  }

  void resetFilters() {
    state = state.copyWith(
      searchQuery: '',
      statusFilter: TaskStatusFilter.all,
      categoryFilter: null,
      priorityFilter: null,
      sortBy: TaskSortBy.createdAt,
      isSortAscending: false,
    );
  }

  Future<bool> updateTask({
    required String taskId,
    required TaskUpdateRequestModel payload,
  }) async {
    try {
      final repository = ref.read(taskRepositoryProvider);
      final useCase = UpdateTaskUseCase(repository);

      final updatedEntity = await useCase(
        taskId: taskId,
        payload: payload,
      );

      final updatedTasks = state.tasks.map((t) {
        if (t.id == taskId) return updatedEntity;
        return t;
      }).toList();

      state = state.copyWith(tasks: updatedTasks);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  void addTask(TaskEntity task) {
    // Avoid duplicate task insertion if task already exists
    final exists = state.tasks.any((t) => t.id == task.id);
    if (!exists) {
      state = state.copyWith(
        tasks: [task, ...state.tasks],
        total: state.total + 1,
      );
    }
  }
}


