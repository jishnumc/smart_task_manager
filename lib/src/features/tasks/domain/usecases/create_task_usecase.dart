import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';

/// Use case for creating a new task.
class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<CreateTaskResult> call(TaskCreateRequestModel payload) {
    return _repository.createTask(payload);
  }
}
