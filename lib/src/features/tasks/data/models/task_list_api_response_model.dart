import 'package:smart_task_manager/src/features/tasks/data/models/task_data_model.dart';

class TaskListApiResponseModel {
  const TaskListApiResponseModel({
    this.status,
    this.message,
    this.data,
    this.total,
  });

  final String? status;
  final String? message;
  final List<TaskDataModel>? data;
  final int? total;

  factory TaskListApiResponseModel.fromJson(Map<String, dynamic> json) {
    return TaskListApiResponseModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TaskDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.map((e) => e.toJson()).toList(),
        'total': total,
      };
}
