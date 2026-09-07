import 'package:dio/dio.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_api_response_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_list_api_response_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_update_request_model.dart';
import 'package:smart_task_manager/src/outer_layer/clients/api_client.dart';
import 'package:smart_task_manager/src/system/exceptions/app_exception.dart';

/// Abstract contract for remote task operations.
abstract class TaskRemoteDataSource {
  Future<TaskApiResponseModel> createTask({
    required String userId,
    required TaskCreateRequestModel payload,
  });

  Future<TaskListApiResponseModel> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  });

  Future<void> deleteTask({
    required String taskId,
    required String userId,
  });

  Future<TaskApiResponseModel> updateTask({
    required String taskId,
    required String userId,
    required TaskUpdateRequestModel payload,
  });
}

/// Implementation of [TaskRemoteDataSource] using Dio via [ApiClient].
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<TaskApiResponseModel> createTask({
    required String userId,
    required TaskCreateRequestModel payload,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/tasks/',
        queryParameters: {'user_id': userId},
        data: payload.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response received from server.');
      }
      return TaskApiResponseModel.fromJson(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TaskListApiResponseModel> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/tasks/',
        queryParameters: {
          'user_id': userId,
          'skip': skip,
          'limit': limit,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response received from server.');
      }
      return TaskListApiResponseModel.fromJson(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTask({
    required String taskId,
    required String userId,
  }) async {
    try {
      final response = await _apiClient.dio.delete<Map<String, dynamic>>(
        '/tasks/$taskId',
        queryParameters: {
          'user_id': userId,
        },
      );

      final data = response.data;
      if (data != null && data['status'] == 'error') {
        final msg = data['message']?.toString() ?? 'Failed to delete task.';
        throw ServerException(msg);
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TaskApiResponseModel> updateTask({
    required String taskId,
    required String userId,
    required TaskUpdateRequestModel payload,
  }) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/tasks/$taskId',
        queryParameters: {
          'user_id': userId,
        },
        data: payload.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response received from server.');
      }
      return TaskApiResponseModel.fromJson(data);
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }



  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw const NetworkException('No internet connection or network timeout.');
    }

    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    String? extractedMessage;

    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null && responseData['message'].toString().isNotEmpty) {
        extractedMessage = responseData['message'].toString();
      } else if (responseData['detail'] != null) {
        final detail = responseData['detail'];
        if (detail is List && detail.isNotEmpty) {
          final messages = <String>[];
          for (final item in detail) {
            if (item is Map<String, dynamic>) {
              final loc = item['loc'] is List && (item['loc'] as List).isNotEmpty
                  ? (item['loc'] as List).last.toString()
                  : null;
              final msg = item['msg']?.toString();
              if (loc != null && msg != null) {
                messages.add('$loc: $msg');
              } else if (msg != null) {
                messages.add(msg);
              }
            } else if (item != null) {
              messages.add(item.toString());
            }
          }
          if (messages.isNotEmpty) {
            extractedMessage = messages.join('\n');
          }
        } else if (detail is String && detail.isNotEmpty) {
          extractedMessage = detail;
        }
      }
    }

    final String finalMessage = extractedMessage ??
        (statusCode == 422
            ? 'Validation error: Please check your input parameters.'
            : statusCode == 404
                ? 'Requested resource not found.'
                : 'Server error occurred (${statusCode ?? "unknown"}).');

    if (statusCode == 401 || statusCode == 403) {
      throw AuthException(finalMessage, statusCode?.toString());
    }
    throw ServerException(finalMessage, statusCode?.toString());
  }
}


