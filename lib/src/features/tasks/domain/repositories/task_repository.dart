import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_update_request_model.dart';
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

/// Result object returned after fetching tasks list.
class GetTasksResult {
  const GetTasksResult({
    required this.tasks,
    required this.total,
    required this.isOfflineSaved,
  });

  final List<TaskEntity> tasks;
  final int total;
  final bool isOfflineSaved;
}

/// Result object returned after syncing offline tasks.
class SyncResult {
  const SyncResult({
    required this.syncedCount,
    required this.failedCount,
  });

  final int syncedCount;
  final int failedCount;
}

/// Abstract contract for Task repository.
abstract class TaskRepository {
  Future<CreateTaskResult> createTask(TaskCreateRequestModel payload);

  Future<GetTasksResult> getTasks({
    int skip = 0,
    int limit = 10,
    bool forceRefresh = false,
  });

  Future<void> deleteTask(String taskId);

  Future<TaskEntity> updateTask({
    required String taskId,
    required TaskUpdateRequestModel payload,
  });

  Future<List<TaskEntity>> getUnsyncedTasks();

  Future<SyncResult> syncOfflineTasks();
}


