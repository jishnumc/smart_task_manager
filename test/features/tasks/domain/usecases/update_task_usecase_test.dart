import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_update_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';
import 'package:smart_task_manager/src/features/tasks/domain/usecases/update_task_usecase.dart';

class FakeTaskRepositoryForUpdate implements TaskRepository {
  String? updatedTaskId;
  TaskUpdateRequestModel? updatedPayload;

  @override
  Future<TaskEntity> updateTask({
    required String taskId,
    required TaskUpdateRequestModel payload,
  }) async {
    updatedTaskId = taskId;
    updatedPayload = payload;
    return TaskEntity(
      id: taskId,
      userId: 'user_1',
      title: payload.title ?? 'Updated Title',
      description: payload.description ?? 'Updated Desc',
      isCompleted: payload.isCompleted ?? true,
      dueDate: DateTime.parse(payload.dueDate ?? '2026-09-15T00:00:00.000Z'),
      priority: payload.priority ?? 'High',
      category: payload.category ?? 'Work',
    );
  }

  @override
  Future<CreateTaskResult> createTask(TaskCreateRequestModel payload) => throw UnimplementedError();

  @override
  Future<void> deleteTask(String taskId) => throw UnimplementedError();

  @override
  Future<GetTasksResult> getTasks({int skip = 0, int limit = 10, bool forceRefresh = false}) =>
      throw UnimplementedError();

  @override
  Future<List<TaskEntity>> getUnsyncedTasks() => throw UnimplementedError();

  @override
  Future<SyncResult> syncOfflineTasks() => throw UnimplementedError();
}

void main() {
  late FakeTaskRepositoryForUpdate fakeRepo;
  late UpdateTaskUseCase useCase;

  setUp(() {
    fakeRepo = FakeTaskRepositoryForUpdate();
    useCase = UpdateTaskUseCase(fakeRepo);
  });

  test('should call repository.updateTask with correct parameters and return updated TaskEntity', () async {
    final payload = TaskUpdateRequestModel(
      title: 'Updated Title',
      isCompleted: true,
    );

    final result = await useCase.call(
      taskId: 'task_555',
      payload: payload,
    );

    expect(fakeRepo.updatedTaskId, equals('task_555'));
    expect(fakeRepo.updatedPayload?.title, equals('Updated Title'));
    expect(result.id, equals('task_555'));
    expect(result.isCompleted, isTrue);
  });
}
