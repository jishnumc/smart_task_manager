import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/system/exceptions/app_exception.dart';

part 'create_task_state.freezed.dart';

@freezed
abstract class CreateTaskState with _$CreateTaskState {
  const factory CreateTaskState.initial() = _CreateTaskInitial;
  const factory CreateTaskState.loading() = _CreateTaskLoading;
  const factory CreateTaskState.success({
    required TaskEntity task,
    required bool isOfflineSaved,
  }) = _CreateTaskSuccess;
  const factory CreateTaskState.error({
    required AppException exception,
  }) = _CreateTaskError;
}
