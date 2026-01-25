import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../core/utils/variable_parser.dart';
import 'database_providers.dart';
import 'environment_provider.dart';
import 'workspace_provider.dart';

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
// NOTIFIER (Riverpod 2.0+)
// =============================================================================

class RequestNotifier extends Notifier<RequestState> {
  final Dio _dio = Dio();

  // Acceso lazy a la base de datos
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  RequestState build() {
    return RequestState();
  }

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
    String attemptUrl = url;

    try {
      // 1. Obtener variables resueltas (Global + Env) de forma síncrona
      final variables = ref.read(resolvedVariablesProvider);

      print(
        'DEBUG: FetchData Start. URL: $url. Vars: ${variables.keys.length}',
      ); // Debug Log

      // 2. Parsear URL, Headers, Params y Body
      final parsedUrl = VariableParser.parse(url, variables);
      attemptUrl = parsedUrl;

      final parsedParams = queryParams != null
          ? VariableParser.parseMap(queryParams, variables)
          : null;

      final parsedHeaders = headers != null
          ? VariableParser.parseMap(headers, variables)
          : null;

      dynamic parsedBody = body;
      if (body is String) {
        parsedBody = VariableParser.parse(body, variables);
      } else if (body is Map<String, dynamic>) {
        parsedBody = VariableParser.parseMap(body, variables);
      }

      final response = await _dio.request(
        parsedUrl,
        queryParameters: parsedParams,
        data: parsedBody,
        options: Options(
          method: method,
          headers: parsedHeaders,
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
      final errorPrefix = e.message ?? 'Error de red';
      errorMsg = '$errorPrefix\n(URL: $attemptUrl)';

      if (e.message?.contains('is not a valid URI') ?? false) {
        errorMsg = 'URL inválida después de variables:\n$attemptUrl';
      }

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
      state = RequestState(isLoading: false, error: '$e\n(URL: $attemptUrl)');
    }

    // =========================================================================
    // GUARDAR EN HISTORIAL (siempre, éxito o error)
    // =========================================================================
    try {
      final workspaceId = ref.read(activeWorkspaceIdProvider);

      await _db.insertHistory(
        method: method,
        url: url, // Guardamos la URL ORIGINAL con {{variables}}
        headersJson: headers != null ? jsonEncode(headers) : null,
        paramsJson: queryParams != null ? jsonEncode(queryParams) : null,
        body: body is String ? body : (body != null ? jsonEncode(body) : null),
        statusCode: statusCode,
        responseBody: responseBody,
        durationMs: stopwatch.elapsedMilliseconds,
        workspaceId: workspaceId,
      );
    } catch (_) {
      // Silenciosamente ignorar errores de guardado en historial
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

final requestProvider = NotifierProvider<RequestNotifier, RequestState>(
  RequestNotifier.new,
);
