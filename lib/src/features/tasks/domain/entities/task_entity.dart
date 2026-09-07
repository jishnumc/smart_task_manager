/// Domain entity representing a Task.
class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.dueDate,
    required this.priority,
    required this.category,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime dueDate;
  final String priority;
  final String category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
