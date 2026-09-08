import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_task_manager/src/system/utils/enviornment.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

part 'api_client.g.dart';

/// Exposes the global singleton instance provider for [ApiClient].
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient();
}

/// Custom Dio Interceptor for request headers, response parsing, and error handling.
class CustomApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add default content headers if missing
    options.headers.putIfAbsent('Content-Type', () => 'application/json');
    options.headers.putIfAbsent('Accept', () => 'application/json');

    if (kDebugMode) {
      debugPrint('➡️ [DIO REQ] [${options.method}] ${options.uri}');
      if (options.data != null) {
        debugPrint('   Payload: ${options.data}');
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '⬅️ [DIO RES] [${response.statusCode}] ${response.requestOptions.uri}',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final statusCode = err.response?.statusCode;
      final uri = err.requestOptions.uri;
      final errorMessage = err.response?.data ?? err.message;
      debugPrint('⚠️ [DIO ERR] [$statusCode] $uri — $errorMessage');
    }
    super.onError(err, handler);
  }
}

/// The central API Client managing Dio HTTP client and interceptors.
class ApiClient {
  /// Creates the [ApiClient].
  ApiClient({String? baseUrl, Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? Environment.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: const <String, dynamic>{
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _setupInterceptors();
  }

  /// The underlying [Dio] instance.
  final Dio dio;

  /// Configures custom and logging interceptors for Dio.
  void _setupInterceptors() {
    dio.interceptors.addAll([
      CustomApiInterceptor(),
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
          printRequestData: true,
          printResponseData: true,
        ),
      ),
    ]);
  }
}
