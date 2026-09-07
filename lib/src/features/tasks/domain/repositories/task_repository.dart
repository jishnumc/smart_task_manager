import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';

/// Result object returned after creating a task.
class CreateTaskResult {
  const CreateTaskResult({
    required this.task,
    required this.isOfflineSaved,
  });

  final TaskEntity task;
  final bool isOfflineSaved;
}

/// Abstract contract for Task repository.
abstract class TaskRepository {
  Future<CreateTaskResult> createTask(TaskCreateRequestModel payload);
}
