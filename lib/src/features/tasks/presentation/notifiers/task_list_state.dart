import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/task_filter_enums.dart';

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
    this.searchQuery = '',
    this.statusFilter = TaskStatusFilter.all,
    this.categoryFilter,
    this.priorityFilter,
    this.sortBy = TaskSortBy.createdAt,
    this.isSortAscending = false,
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
  final String searchQuery;
  final TaskStatusFilter statusFilter;
  final String? categoryFilter;
  final String? priorityFilter;
  final TaskSortBy sortBy;
  final bool isSortAscending;

  List<TaskEntity> get filteredAndSortedTasks {
    // Deduplicate tasks by task ID
    final uniqueTasksMap = <String, TaskEntity>{};
    for (final task in tasks) {
      uniqueTasksMap[task.id] = task;
    }
    final uniqueTasks = uniqueTasksMap.values.toList();

    var list = uniqueTasks.where((task) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final titleMatch = task.title.toLowerCase().contains(query);
        final descMatch = task.description.toLowerCase().contains(query);
        if (!titleMatch && !descMatch) return false;
      }

      if (statusFilter == TaskStatusFilter.completed && !task.isCompleted) {
        return false;
      }
      if (statusFilter == TaskStatusFilter.pending && task.isCompleted) {
        return false;
      }

      if (categoryFilter != null &&
          categoryFilter != 'All' &&
          task.category != categoryFilter) {
        return false;
      }

      if (priorityFilter != null &&
          priorityFilter != 'All' &&
          task.priority != priorityFilter) {
        return false;
      }

      return true;
    }).toList();

    list.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case TaskSortBy.dueDate:
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case TaskSortBy.priority:
          final weightA = _priorityWeight(a.priority);
          final weightB = _priorityWeight(b.priority);
          comparison = weightA.compareTo(weightB);
          break;
        case TaskSortBy.createdAt:
          final dateA = a.createdAt ?? DateTime(1970);
          final dateB = b.createdAt ?? DateTime(1970);
          comparison = dateA.compareTo(dateB);
          break;
      }
      return isSortAscending ? comparison : -comparison;
    });

    return list;
  }

  static int _priorityWeight(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

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
    String? searchQuery,
    TaskStatusFilter? statusFilter,
    String? categoryFilter,
    String? priorityFilter,
    TaskSortBy? sortBy,
    bool? isSortAscending,
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
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      sortBy: sortBy ?? this.sortBy,
      isSortAscending: isSortAscending ?? this.isSortAscending,
    );
  }
}
