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

  Future<void> saveTasks({
    required List<TaskDataModel> tasks,
    required String userId,
  });

  Future<List<TaskDataModel>> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  });

  Future<List<TaskDataModel>> getUnsyncedTasks({
    required String userId,
  });

  Future<void> markTaskAsSynced({
    required String localOrRemoteId,
    required String remoteId,
  });

  Future<void> deleteTask(String id);

  Future<void> updateTaskInLocal({
    required TaskDataModel task,
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

  @override
  Future<void> saveTasks({
    required List<TaskDataModel> tasks,
    required String userId,
  }) async {
    try {
      for (final task in tasks) {
        final map = <String, dynamic>{
          'user_id': task.userId ?? userId,
          'remote_id': task.id.toString(),
          'title': task.title,
          'description': task.description,
          'is_completed': task.isCompleted ? 1 : 0,
          'due_date': task.dueDate,
          'priority': task.priority,
          'category': task.category,
          'is_synced': 1,
          'created_at': task.createdAt ?? DateTime.now().toIso8601String(),
          'updated_at': task.updatedAt ?? DateTime.now().toIso8601String(),
        };
        await _sqliteClient.insertTask(map);
      }
    } catch (e) {
      throw CacheException('Failed to cache tasks in local database: $e');
    }
  }

  @override
  Future<List<TaskDataModel>> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final rows = await _sqliteClient.getTasks(
        userId: userId,
        limit: limit,
        offset: skip,
      );

      final seenIds = <String>{};
      final uniqueModels = <TaskDataModel>[];

      for (final row in rows) {
        final id = row['remote_id']?.toString() ?? row['id'].toString();
        if (seenIds.add(id)) {
          uniqueModels.add(
            TaskDataModel(
              id: id,
              userId: row['user_id']?.toString() ?? userId,
              title: row['title']?.toString() ?? '',
              description: row['description']?.toString() ?? '',
              isCompleted: (row['is_completed'] as int?) == 1,
              dueDate: row['due_date']?.toString() ??
                  DateTime.now().toIso8601String(),
              priority: row['priority']?.toString() ?? 'Medium',
              category: row['category']?.toString() ?? 'Work',
              createdAt: row['created_at']?.toString(),
              updatedAt: row['updated_at']?.toString(),
            ),
          );
        }
      }

      return uniqueModels;
    } catch (e) {
      throw CacheException('Failed to fetch tasks from local database: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _sqliteClient.deleteTaskByRemoteOrLocalId(id);
    } catch (e) {
      throw CacheException('Failed to delete task from local database: $e');
    }
  }

  @override
  Future<void> updateTaskInLocal({
    required TaskDataModel task,
  }) async {
    try {
      final map = <String, dynamic>{
        'user_id': task.userId,
        'remote_id': task.id.toString(),
        'title': task.title,
        'description': task.description,
        'is_completed': task.isCompleted ? 1 : 0,
        'due_date': task.dueDate,
        'priority': task.priority,
        'category': task.category,
        'is_synced': 1,
        'updated_at': task.updatedAt ?? DateTime.now().toIso8601String(),
      };
      await _sqliteClient.insertTask(map);
    } catch (e) {
      throw CacheException('Failed to update task in local database: $e');
    }
  }

  @override
  Future<List<TaskDataModel>> getUnsyncedTasks({
    required String userId,
  }) async {
    try {
      final rows = await _sqliteClient.getUnsyncedTasks(userId: userId);
      return rows.map((row) {
        return TaskDataModel(
          id: row['remote_id'] ?? row['id'].toString(),
          userId: row['user_id']?.toString() ?? userId,
          title: row['title']?.toString() ?? '',
          description: row['description']?.toString() ?? '',
          isCompleted: (row['is_completed'] as int?) == 1,
          dueDate: row['due_date']?.toString() ??
              DateTime.now().toIso8601String(),
          priority: row['priority']?.toString() ?? 'Medium',
          category: row['category']?.toString() ?? 'Work',
          createdAt: row['created_at']?.toString(),
          updatedAt: row['updated_at']?.toString(),
        );
      }).toList();
    } catch (e) {
      throw CacheException('Failed to fetch unsynced tasks: $e');
    }
  }

  @override
  Future<void> markTaskAsSynced({
    required String localOrRemoteId,
    required String remoteId,
  }) async {
    try {
      await _sqliteClient.markTaskAsSynced(localOrRemoteId, remoteId);
    } catch (e) {
      throw CacheException('Failed to mark task as synced: $e');
    }
  }
}


