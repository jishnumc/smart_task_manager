import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_create_request_model.freezed.dart';
part 'task_create_request_model.g.dart';

@freezed
abstract class TaskCreateRequestModel with _$TaskCreateRequestModel {
  const factory TaskCreateRequestModel({
    required String title,
    required String description,
    @JsonKey(name: 'is_completed') required bool isCompleted,
    @JsonKey(name: 'due_date') required String dueDate,
    required String priority,
    required String category,
  }) = _TaskCreateRequestModel;

  factory TaskCreateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCreateRequestModelFromJson(json);
}
