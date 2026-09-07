import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';

part 'task_data_model.freezed.dart';
part 'task_data_model.g.dart';

@freezed
abstract class TaskDataModel with _$TaskDataModel {
  const TaskDataModel._();

  const factory TaskDataModel({
    required dynamic id,
    @JsonKey(name: 'user_id') String? userId,
    required String title,
    required String description,
    @JsonKey(name: 'is_completed') required bool isCompleted,
    @JsonKey(name: 'due_date') required String dueDate,
    required String priority,
    required String category,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _TaskDataModel;

  factory TaskDataModel.fromJson(Map<String, dynamic> json) =>
      _$TaskDataModelFromJson(json);

  TaskEntity toEntity() {
    return TaskEntity(
      id: id.toString(),
      userId: userId ?? '',
      title: title,
      description: description,
      isCompleted: isCompleted,
      dueDate: DateTime.tryParse(dueDate) ?? DateTime.now(),
      priority: priority,
      category: category,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}
