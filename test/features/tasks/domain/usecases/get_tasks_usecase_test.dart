import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_update_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';
import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';
import 'package:smart_task_manager/src/features/tasks/domain/usecases/get_tasks_usecase.dart';

class FakeTaskRepository implements TaskRepository {
  int lastSkip = -1;
  int lastLimit = -1;
  bool lastForceRefresh = false;

  @override
  Future<GetTasksResult> getTasks({
    int skip = 0,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    lastSkip = skip;
    lastLimit = limit;
    lastForceRefresh = forceRefresh;

    return GetTasksResult(
      tasks: [
        TaskEntity(
          id: '1',
          userId: 'user_1',
          title: 'Sample Task',
          description: 'Description',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: 'Medium',
          category: 'Personal',
        ),
      ],
      total: 1,
      isOfflineSaved: false,
    );
  }

  @override
  Future<CreateTaskResult> createTask(TaskCreateRequestModel payload) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String taskId) {
    throw UnimplementedError();
  }

  @override
  Future<List<TaskEntity>> getUnsyncedTasks() {
    throw UnimplementedError();
  }

  @override
  Future<SyncResult> syncOfflineTasks() {
    throw UnimplementedError();
  }

  @override
  Future<TaskEntity> updateTask({
    required String taskId,
    required TaskUpdateRequestModel payload,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  late FakeTaskRepository fakeRepository;
  late GetTasksUseCase useCase;

  setUp(() {
    fakeRepository = FakeTaskRepository();
    useCase = GetTasksUseCase(fakeRepository);
  });

  test('should call repository.getTasks with correct parameters and return GetTasksResult', () async {
    final result = await useCase.call(
      skip: 10,
      limit: 20,
      forceRefresh: true,
    );

    expect(fakeRepository.lastSkip, equals(10));
    expect(fakeRepository.lastLimit, equals(20));
    expect(fakeRepository.lastForceRefresh, isTrue);
    expect(result.tasks.length, equals(1));
    expect(result.tasks.first.title, equals('Sample Task'));
    expect(result.isOfflineSaved, isFalse);
  });
}
