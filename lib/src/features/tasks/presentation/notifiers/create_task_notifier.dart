import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_task_manager/src/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:smart_task_manager/src/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';
import 'package:smart_task_manager/src/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/create_task_state.dart';
import 'package:smart_task_manager/src/outer_layer/clients/api_client.dart';
import 'package:smart_task_manager/src/outer_layer/clients/storage_client.dart';
import 'package:smart_task_manager/src/outer_layer/database/sqlite_database_client.dart';
import 'package:smart_task_manager/src/outer_layer/network/network_info.dart';
import 'package:smart_task_manager/src/system/exceptions/app_exception.dart';

part 'create_task_notifier.g.dart';

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) {
  return TaskRepositoryImpl(
    remoteDataSource: TaskRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    localDataSource: TaskLocalDataSourceImpl(ref.watch(sqliteDatabaseClientProvider)),
    networkInfo: ref.watch(networkInfoProvider),
    storageClient: ref.watch(storageClientProvider),
  );
}

@riverpod
class CreateTaskNotifier extends _$CreateTaskNotifier {
  @override
  CreateTaskState build() {
    return const CreateTaskState.initial();
  }

  Future<void> submitTask({
    required String title,
    required String description,
    required bool isCompleted,
    required DateTime dueDate,
    required String priority,
    required String category,
  }) async {
    state = const CreateTaskState.loading();

    try {
      final repository = ref.read(taskRepositoryProvider);
      final useCase = CreateTaskUseCase(repository);

      final isoDueDate = dueDate.toUtc().toIso8601String();

      final payload = TaskCreateRequestModel(
        title: title,
        description: description,
        isCompleted: isCompleted,
        dueDate: isoDueDate,
        priority: priority,
        category: category,
      );

      final result = await useCase(payload);

      state = CreateTaskState.success(
        task: result.task,
        isOfflineSaved: result.isOfflineSaved,
      );
    } on AppException catch (e) {
      state = CreateTaskState.error(exception: e);
    } catch (e) {
      state = CreateTaskState.error(
        exception: ServerException('Unexpected error occurred: $e'),
      );
    }
  }
}
