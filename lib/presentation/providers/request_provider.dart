import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

// --- ESTADO ---
class RequestState {
  final bool isLoading;
  final dynamic data;
  final int? statusCode;
  final String? error;
  final int? durationMs;

  RequestState({
    this.isLoading = false,
    this.data,
    this.statusCode,
    this.error,
    this.durationMs,
  });

  RequestState copyWith({
    bool? isLoading,
    dynamic data,
    int? statusCode,
    String? error,
    int? durationMs,
  }) {
    return RequestState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      statusCode: statusCode ?? this.statusCode,
      error: error ?? this.error,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}

// --- NOTIFIER ---
class RequestNotifier extends StateNotifier<RequestState> {
  final Dio _dio = Dio();

  RequestNotifier() : super(RequestState());

  Future<void> fetchData({
    required String method,
    required String url,
    Map<String, dynamic>? queryParams, // Nuevo
    Map<String, dynamic>? headers, // Nuevo
    dynamic body, // Nuevo
  }) async {
    if (url.trim().isEmpty) {
      state = state.copyWith(error: 'La URL no puede estar vacía.');
      return;
    }

    state = RequestState(isLoading: true);
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.request(
        url,
        queryParameters: queryParams, // Enviamos params
        data: body, // Enviamos body
        options: Options(
          method: method,
          headers: headers, // Enviamos headers
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      stopwatch.stop();

      state = RequestState(
        isLoading: false,
        data: response.data,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      String errorMsg = e.message ?? 'Error de red';
      dynamic errorData = e.response?.data;

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Tiempo de conexión agotado.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMsg = 'Error del servidor: ${e.response?.statusCode}';
      }

      state = RequestState(
        isLoading: false,
        error: errorMsg,
        statusCode: e.response?.statusCode,
        data: errorData,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      state = RequestState(isLoading: false, error: e.toString());
    }
  }
}

// --- PROVIDER ---
final requestProvider = StateNotifierProvider<RequestNotifier, RequestState>((
  ref,
) {
  return RequestNotifier();
});
