import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';

/// Use case for fetching paginated tasks.
class GetTasksUseCase {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<GetTasksResult> call({
    int skip = 0,
    int limit = 10,
    bool forceRefresh = false,
  }) {
    return _repository.getTasks(
      skip: skip,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
