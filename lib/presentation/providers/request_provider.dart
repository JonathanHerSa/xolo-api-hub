import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/local/database.dart';
import 'database_providers.dart';

// =============================================================================
// ESTADO
// =============================================================================

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

// =============================================================================
// NOTIFIER
// =============================================================================

class RequestNotifier extends StateNotifier<RequestState> {
  final Dio _dio = Dio();
  final AppDatabase _db;

  RequestNotifier(this._db) : super(RequestState());

  Future<void> fetchData({
    required String method,
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic body,
  }) async {
    if (url.trim().isEmpty) {
      state = state.copyWith(error: 'La URL no puede estar vacía.');
      return;
    }

    state = RequestState(isLoading: true);
    final stopwatch = Stopwatch()..start();

    int? statusCode;
    String? responseBody;
    String? errorMsg;
    dynamic responseData;

    try {
      final response = await _dio.request(
        url,
        queryParameters: queryParams,
        data: body,
        options: Options(
          method: method,
          headers: headers,
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      stopwatch.stop();

      statusCode = response.statusCode;
      responseData = response.data;
      responseBody = _encodeResponse(response.data);

      state = RequestState(
        isLoading: false,
        data: response.data,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      errorMsg = e.message ?? 'Error de red';
      responseData = e.response?.data;
      statusCode = e.response?.statusCode;
      responseBody = _encodeResponse(e.response?.data);

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Tiempo de conexión agotado.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMsg = 'Error del servidor: ${e.response?.statusCode}';
      }

      state = RequestState(
        isLoading: false,
        error: errorMsg,
        statusCode: statusCode,
        data: responseData,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      state = RequestState(isLoading: false, error: e.toString());
    }

    // =========================================================================
    // GUARDAR EN HISTORIAL (siempre, éxito o error)
    // =========================================================================
    try {
      await _db.insertHistory(
        method: method,
        url: url,
        headersJson: headers != null ? jsonEncode(headers) : null,
        paramsJson: queryParams != null ? jsonEncode(queryParams) : null,
        body: body is String ? body : (body != null ? jsonEncode(body) : null),
        statusCode: statusCode,
        responseBody: responseBody,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (_) {
      // Silenciosamente ignorar errores de guardado en historial
      // No queremos que falle el request por problemas de persistencia
    }
  }

  /// Reejecutar un request desde el historial
  Future<void> replayFromHistory(HistoryEntry entry) async {
    Map<String, dynamic>? headers;
    Map<String, dynamic>? params;

    if (entry.headersJson != null) {
      try {
        headers = Map<String, dynamic>.from(jsonDecode(entry.headersJson!));
      } catch (_) {}
    }

    if (entry.paramsJson != null) {
      try {
        params = Map<String, dynamic>.from(jsonDecode(entry.paramsJson!));
      } catch (_) {}
    }

    await fetchData(
      method: entry.method,
      url: entry.url,
      headers: headers,
      queryParams: params,
      body: entry.body,
    );
  }

  String? _encodeResponse(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }
}

// =============================================================================
// PROVIDER
// =============================================================================

final requestProvider = StateNotifierProvider<RequestNotifier, RequestState>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return RequestNotifier(db);
});
