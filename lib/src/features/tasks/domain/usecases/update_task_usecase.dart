import 'package:smart_task_manager/src/features/tasks/data/models/task_update_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';

/// Use case for updating an existing task.
class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<TaskEntity> call({
    required String taskId,
    required TaskUpdateRequestModel payload,
  }) {
    return _repository.updateTask(
      taskId: taskId,
      payload: payload,
    );
  }
}
