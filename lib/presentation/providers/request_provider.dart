import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../core/utils/variable_parser.dart';
import '../providers/environment_provider.dart';
import '../providers/database_providers.dart';
import '../providers/workspace_provider.dart';

// --- State ---
class RequestState {
  final bool isLoading;
  final dynamic data;
  final String? error;
  final int? statusCode;
  final int? durationMs;

  RequestState({
    this.isLoading = false,
    this.data,
    this.error,
    this.statusCode,
    this.durationMs,
  });

  RequestState copyWith({
    bool? isLoading,
    dynamic data,
    String? error,
    int? statusCode,
    int? durationMs,
  }) {
    return RequestState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
      statusCode: statusCode ?? this.statusCode,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}

// --- Manual Controller (Logic) ---
class RequestController {
  final Ref ref;
  final String tabId;
  final Dio _dio = Dio();

  final StreamController<RequestState> _controller =
      StreamController<RequestState>.broadcast();
  RequestState _state = RequestState();

  RequestController(this.ref, this.tabId);

  RequestState get state => _state;

  Stream<RequestState> get stream async* {
    yield _state;
    yield* _controller.stream;
  }

  void _update(RequestState newState) {
    _state = newState;
    _controller.add(newState);
  }

  Future<void> fetchData({
    required String method,
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    Object? body,
  }) async {
    // 1. Loading
    _update(_state.copyWith(isLoading: true, error: null, statusCode: null));

    final stopwatch = Stopwatch()..start();

    // Variables for error handling scope
    String attemptUrl = url;
    String? errorMsg;
    int? statusCode;
    dynamic responseData;

    try {
      // 2. Variable Parsing (Global + Env + Chains)
      final resolvedVars = ref.read(resolvedVariablesProvider);

      // Parse URL
      final parsedUrl = VariableParser.parse(url, resolvedVars);
      attemptUrl = parsedUrl;

      // Parse Headers
      final Map<String, dynamic> parsedHeaders = {};
      if (headers != null) {
        for (final entry in headers.entries) {
          final key = VariableParser.parse(entry.key, resolvedVars);
          final val = VariableParser.parse(
            entry.value.toString(),
            resolvedVars,
          );
          parsedHeaders[key] = val;
        }
      }

      // Parse Params
      final Map<String, dynamic> parsedParams = {};
      if (queryParams != null) {
        for (final entry in queryParams.entries) {
          final key = VariableParser.parse(entry.key, resolvedVars);
          final val = VariableParser.parse(
            entry.value.toString(),
            resolvedVars,
          );
          parsedParams[key] = val;
        }
      }

      // Parse Body (si es String)
      Object? finalBody = body;
      if (body is String && body.isNotEmpty) {
        finalBody = VariableParser.parse(body, resolvedVars);
      }

      // 3. Execution
      final response = await _dio.request(
        parsedUrl,
        data: finalBody,
        queryParameters: parsedParams,
        options: Options(
          method: method,
          headers: parsedHeaders,
          validateStatus: (status) => true, // No lanzar error por status code
        ),
      );

      stopwatch.stop();
      statusCode = response.statusCode;
      responseData = response.data;

      // 4. Success State
      _update(
        _state.copyWith(
          isLoading: false,
          data: response.data,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
        ),
      );
    } on DioException catch (e) {
      stopwatch.stop();
      statusCode = e.response?.statusCode;
      responseData = e.response?.data;

      final errorPrefix = e.message ?? 'Error de red';
      errorMsg = '$errorPrefix\n(URL: $attemptUrl)';

      _update(
        _state.copyWith(
          isLoading: false,
          error: errorMsg,
          statusCode: statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
        ),
      );
    } catch (e, stack) {
      stopwatch.stop();
      _update(
        _state.copyWith(
          isLoading: false,
          error: e.toString(),
          durationMs: stopwatch.elapsedMilliseconds,
        ),
      );
      print('Error en request ($tabId): $e\n$stack');
    }

    // Save History
    try {
      final db = ref.read(databaseProvider);
      final activeWorkspaceId = ref.read(activeWorkspaceIdProvider);

      String? responseBodyStr;
      if (responseData != null) {
        responseBodyStr = responseData.toString();
      }

      await db.addHistoryItem(
        method: method,
        url: attemptUrl,
        statusCode: statusCode ?? 0,
        durationMs: stopwatch.elapsedMilliseconds,
        workspaceId: activeWorkspaceId,
      );
    } catch (e) {
      print('Error guardando historial: $e');
    }
  }

  void reset() {
    _update(RequestState());
  }

  void restoreResponse(dynamic data, int? statusCode) {
    _update(
      RequestState(
        data: data,
        statusCode: statusCode,
        isLoading: false,
        error: null,
      ),
    );
  }
}

// --- Providers ---

final _requestControllers = <String, RequestController>{};

final requestControllerProvider = Provider.family<RequestController, String>((
  ref,
  id,
) {
  return _requestControllers.putIfAbsent(id, () => RequestController(ref, id));
});

final requestProvider = StreamProvider.family<RequestState, String>((ref, id) {
  final controller = ref.watch(requestControllerProvider(id));
  return controller.stream;
});
