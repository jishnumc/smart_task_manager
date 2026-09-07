import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_data_model.dart';
import 'package:smart_task_manager/src/outer_layer/database/sqlite_database_client.dart';
import 'package:smart_task_manager/src/system/exceptions/app_exception.dart';

/// Abstract contract for local SQLite task storage operations.
abstract class TaskLocalDataSource {
  Future<TaskDataModel> saveTask({
    required String userId,
    required TaskCreateRequestModel payload,
    String? remoteId,
    bool isSynced = false,
  });
}

/// Implementation of [TaskLocalDataSource] using [SqliteDatabaseClient].
class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl(this._sqliteClient);

  final SqliteDatabaseClient _sqliteClient;

  @override
  Future<TaskDataModel> saveTask({
    required String userId,
    required TaskCreateRequestModel payload,
    String? remoteId,
    bool isSynced = false,
  }) async {
    try {
      final nowStr = DateTime.now().toIso8601String();
      final map = <String, dynamic>{
        'user_id': userId,
        'remote_id': remoteId,
        'title': payload.title,
        'description': payload.description,
        'is_completed': payload.isCompleted ? 1 : 0,
        'due_date': payload.dueDate,
        'priority': payload.priority,
        'category': payload.category,
        'is_synced': isSynced ? 1 : 0,
        'created_at': nowStr,
        'updated_at': nowStr,
      };

      final insertedId = await _sqliteClient.insertTask(map);

      return TaskDataModel(
        id: remoteId ?? insertedId,
        userId: userId,
        title: payload.title,
        description: payload.description,
        isCompleted: payload.isCompleted,
        dueDate: payload.dueDate,
        priority: payload.priority,
        category: payload.category,
        createdAt: nowStr,
        updatedAt: nowStr,
      );
    } catch (e) {
      throw CacheException('Failed to save task to local database: $e');
    }
  }
}
