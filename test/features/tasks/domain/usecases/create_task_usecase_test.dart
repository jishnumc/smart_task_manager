import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_update_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';
import 'package:smart_task_manager/src/features/tasks/domain/usecases/create_task_usecase.dart';

class FakeTaskRepositoryForCreate implements TaskRepository {
  TaskCreateRequestModel? passedPayload;
  bool isOfflineSaved = false;

  @override
  Future<CreateTaskResult> createTask(TaskCreateRequestModel payload) async {
    passedPayload = payload;
    return CreateTaskResult(
      task: TaskEntity(
        id: '123',
        userId: 'user_1',
        title: payload.title,
        description: payload.description,
        isCompleted: payload.isCompleted,
        dueDate: DateTime.parse(payload.dueDate),
        priority: payload.priority,
        category: payload.category,
      ),
      isOfflineSaved: isOfflineSaved,
    );
  }

  @override
  Future<GetTasksResult> getTasks({int skip = 0, int limit = 10, bool forceRefresh = false}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteTask(String taskId) => throw UnimplementedError();

  @override
  Future<List<TaskEntity>> getUnsyncedTasks() => throw UnimplementedError();

  @override
  Future<SyncResult> syncOfflineTasks() => throw UnimplementedError();

  @override
  Future<TaskEntity> updateTask({required String taskId, required TaskUpdateRequestModel payload}) =>
      throw UnimplementedError();
}

void main() {
  late FakeTaskRepositoryForCreate fakeRepo;
  late CreateTaskUseCase useCase;

  setUp(() {
    fakeRepo = FakeTaskRepositoryForCreate();
    useCase = CreateTaskUseCase(fakeRepo);
  });

  test('should call repository.createTask and return CreateTaskResult when online', () async {
    final payload = TaskCreateRequestModel(
      title: 'New Offline Task',
      description: 'Task details',
      isCompleted: false,
      dueDate: '2026-09-10T00:00:00.000Z',
      priority: 'High',
      category: 'Work',
    );

    final result = await useCase.call(payload);

    expect(fakeRepo.passedPayload?.title, equals('New Offline Task'));
    expect(result.task.id, equals('123'));
    expect(result.isOfflineSaved, isFalse);
  });

  test('should return isOfflineSaved true when offline task is saved', () async {
    fakeRepo.isOfflineSaved = true;
    final payload = TaskCreateRequestModel(
      title: 'Offline Task',
      description: 'Saved locally',
      isCompleted: false,
      dueDate: '2026-09-10T00:00:00.000Z',
      priority: 'Medium',
      category: 'Personal',
    );

    final result = await useCase.call(payload);

    expect(result.isOfflineSaved, isTrue);
    expect(result.task.title, equals('Offline Task'));
  });
}
