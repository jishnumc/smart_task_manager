import 'package:smart_task_manager/src/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:smart_task_manager/src/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/domain/repositories/task_repository.dart';
import 'package:smart_task_manager/src/outer_layer/clients/storage_client.dart';
import 'package:smart_task_manager/src/outer_layer/network/network_info.dart';
import 'package:smart_task_manager/src/system/exceptions/app_exception.dart';

/// Implementation of [TaskRepository] orchestrating remote API and local SQLite data sources.
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required TaskRemoteDataSource remoteDataSource,
    required TaskLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required StorageClient storageClient,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _storageClient = storageClient;

  final TaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final StorageClient _storageClient;

  @override
  Future<CreateTaskResult> createTask(TaskCreateRequestModel payload) async {
    final userId = _storageClient.read<String>('user_id') ?? 'default_user';

    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final apiResponse = await _remoteDataSource.createTask(
          userId: userId,
          payload: payload,
        );

        final remoteTaskModel = apiResponse.data;
        if (remoteTaskModel != null) {
          // Store copy in local DB marked as synced
          try {
            await _localDataSource.saveTask(
              userId: userId,
              payload: payload,
              remoteId: remoteTaskModel.id.toString(),
              isSynced: true,
            );
          } catch (_) {
            // Ignore non-fatal local cache write errors when remote API succeeds
          }

          return CreateTaskResult(
            task: remoteTaskModel.toEntity(),
            isOfflineSaved: false,
          );
        }
      } on NetworkException {
        // Fallback to local offline storage if network fails mid-request
        final localTask = await _localDataSource.saveTask(
          userId: userId,
          payload: payload,
          isSynced: false,
        );
        return CreateTaskResult(
          task: localTask.toEntity(),
          isOfflineSaved: true,
        );
      } catch (e) {
        // Rethrow server, auth, cache, or app exceptions
        if (e is AppException) rethrow;
        throw ServerException(e.toString());
      }
    }

    // Device is offline - save to local SQLite database
    final localTask = await _localDataSource.saveTask(
      userId: userId,
      payload: payload,
      isSynced: false,
    );

    return CreateTaskResult(task: localTask.toEntity(), isOfflineSaved: true);
  }
}
