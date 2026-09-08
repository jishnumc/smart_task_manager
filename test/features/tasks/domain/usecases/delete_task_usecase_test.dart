import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_update_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';
import 'package:smart_task_manager/src/features/tasks/domain/usecases/delete_task_usecase.dart';

class FakeTaskRepositoryForDelete implements TaskRepository {
  String? deletedTaskId;

  @override
  Future<void> deleteTask(String taskId) async {
    deletedTaskId = taskId;
  }

  @override
  Future<CreateTaskResult> createTask(TaskCreateRequestModel payload) => throw UnimplementedError();

  @override
  Future<GetTasksResult> getTasks({int skip = 0, int limit = 10, bool forceRefresh = false}) =>
      throw UnimplementedError();

  @override
  Future<List<TaskEntity>> getUnsyncedTasks() => throw UnimplementedError();

  @override
  Future<SyncResult> syncOfflineTasks() => throw UnimplementedError();

  @override
  Future<TaskEntity> updateTask({required String taskId, required TaskUpdateRequestModel payload}) =>
      throw UnimplementedError();
}

void main() {
  late FakeTaskRepositoryForDelete fakeRepo;
  late DeleteTaskUseCase useCase;

  setUp(() {
    fakeRepo = FakeTaskRepositoryForDelete();
    useCase = DeleteTaskUseCase(fakeRepo);
  });

  test('should call repository.deleteTask with correct taskId', () async {
    await useCase.call('task_999');

    expect(fakeRepo.deletedTaskId, equals('task_999'));
  });
}
