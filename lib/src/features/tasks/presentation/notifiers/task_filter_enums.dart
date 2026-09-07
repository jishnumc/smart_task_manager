enum TaskStatusFilter {
  all,
  pending,
  completed,
}

enum TaskSortBy {
  dueDate,
  priority,
  createdAt,
}

extension TaskStatusFilterX on TaskStatusFilter {
  String get label {
    switch (this) {
      case TaskStatusFilter.all:
        return 'All';
      case TaskStatusFilter.pending:
        return 'Pending';
      case TaskStatusFilter.completed:
        return 'Completed';
    }
  }
}

extension TaskSortByX on TaskSortBy {
  String get label {
    switch (this) {
      case TaskSortBy.dueDate:
        return 'Due Date';
      case TaskSortBy.priority:
        return 'Priority';
      case TaskSortBy.createdAt:
        return 'Created Date';
    }
  }
}
