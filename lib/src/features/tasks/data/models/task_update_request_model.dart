class TaskUpdateRequestModel {
  const TaskUpdateRequestModel({
    this.title,
    this.description,
    this.isCompleted,
    this.dueDate,
    this.priority,
    this.category,
  });

  final String? title;
  final String? description;
  final bool? isCompleted;
  final String? dueDate;
  final String? priority;
  final String? category;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (isCompleted != null) map['is_completed'] = isCompleted;
    if (dueDate != null) map['due_date'] = dueDate;
    if (priority != null) map['priority'] = priority;
    if (category != null) map['category'] = category;
    return map;
  }
}
