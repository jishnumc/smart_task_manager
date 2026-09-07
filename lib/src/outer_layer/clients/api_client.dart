import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_task_manager/src/system/utils/enviornment.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

part 'api_client.g.dart';

/// Exposes the global singleton instance provider for [ApiClient].
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient();
}

/// The central API Client managing Dio HTTP client and interceptors.
class ApiClient {
  /// Creates the [ApiClient].
  ApiClient({String? baseUrl, Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? Environment.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: const <String, dynamic>{
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            )..interceptors.add(
                TalkerDioLogger(
                  settings: const TalkerDioLoggerSettings(
                    printRequestHeaders: true,
                    printResponseHeaders: false,
                    printResponseMessage: true,
                  ),
                ),
              );

  /// The underlying [Dio] instance.
  final Dio dio;
}
