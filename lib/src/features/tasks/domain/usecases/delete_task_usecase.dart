import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';

/// Use case for deleting a task.
class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(String taskId) {
    return _repository.deleteTask(taskId);
  }
}
