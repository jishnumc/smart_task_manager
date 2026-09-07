import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_data_model.dart';

part 'task_api_response_model.freezed.dart';
part 'task_api_response_model.g.dart';

@freezed
abstract class TaskApiResponseModel with _$TaskApiResponseModel {
  const factory TaskApiResponseModel({
    String? status,
    String? message,
    TaskDataModel? data,
    int? total,
  }) = _TaskApiResponseModel;

  factory TaskApiResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TaskApiResponseModelFromJson(json);
}
