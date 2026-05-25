import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_logger.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.info('HTTP ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.info(
          'HTTP ${response.requestOptions.method} ${response.requestOptions.uri} -> ${response.statusCode}',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        _retryRequest(dio, error).then((response) {
          if (response != null) {
            handler.resolve(response);
            return;
          }
          AppLogger.error(
            'HTTP error ${error.requestOptions.method} ${error.requestOptions.uri}',
            error,
            error.stackTrace,
          );
          handler.next(error);
        });
      },
    ),
  );

  return dio;
});

Future<Response<dynamic>?> _retryRequest(Dio dio, DioException error) async {
  final options = error.requestOptions;
  final method = options.method.toUpperCase();
  final canRetryMethod =
      method == 'GET' || method == 'HEAD' || method == 'OPTIONS';
  final shouldRetryStatus =
      error.response?.statusCode == 429 ||
      (error.response?.statusCode != null &&
          error.response!.statusCode! >= 500);
  final isTransient =
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError;

  if (!canRetryMethod || (!shouldRetryStatus && !isTransient)) {
    return null;
  }

  final retries = (options.extra['retry_count'] as int?) ?? 0;
  if (retries >= 2) {
    return null;
  }

  final delay = Duration(milliseconds: 300 * (retries + 1));
  await Future<void>.delayed(delay);

  final retryOptions = Options(
    method: options.method,
    headers: options.headers,
    responseType: options.responseType,
    contentType: options.contentType,
    sendTimeout: options.sendTimeout,
    receiveTimeout: options.receiveTimeout,
    extra: {...options.extra, 'retry_count': retries + 1},
    validateStatus: options.validateStatus,
  );

  AppLogger.warn(
    'Retrying ${options.method} ${options.uri} (attempt ${retries + 2})',
  );

  return dio.request<dynamic>(
    options.path,
    data: options.data,
    queryParameters: options.queryParameters,
    cancelToken: options.cancelToken,
    options: retryOptions,
  );
}
