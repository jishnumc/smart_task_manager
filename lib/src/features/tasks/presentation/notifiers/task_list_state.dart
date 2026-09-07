import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';

class TaskListState {
  const TaskListState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.tasks = const [],
    this.total = 0,
    this.skip = 0,
    this.limit = 10,
    this.hasMore = true,
    this.isOffline = false,
    this.errorMessage,
    this.deletingTaskId,
  });

  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final List<TaskEntity> tasks;
  final int total;
  final int skip;
  final int limit;
  final bool hasMore;
  final bool isOffline;
  final String? errorMessage;
  final String? deletingTaskId;

  TaskListState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    List<TaskEntity>? tasks,
    int? total,
    int? skip,
    int? limit,
    bool? hasMore,
    bool? isOffline,
    String? errorMessage,
    String? deletingTaskId,
  }) {
    return TaskListState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      tasks: tasks ?? this.tasks,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage,
      deletingTaskId: deletingTaskId,
    );
  }
}
