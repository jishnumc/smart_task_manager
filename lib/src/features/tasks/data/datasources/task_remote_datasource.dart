import 'package:dio/dio.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_api_response_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_create_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_list_api_response_model.dart';
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
  }) async {
    try {
      await _apiClient.dio.delete<void>(
        '/tasks/$taskId',
      );
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
    String errorMessage = 'Server error occurred.';

    if (responseData is Map<String, dynamic> && responseData['message'] != null) {
      errorMessage = responseData['message'].toString();
    } else if (e.message != null && e.message!.isNotEmpty) {
      errorMessage = e.message!;
    }

    if (statusCode == 401 || statusCode == 403) {
      throw AuthException(errorMessage, statusCode?.toString());
    }
    throw ServerException(errorMessage, statusCode?.toString());
  }
}

