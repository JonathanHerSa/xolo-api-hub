import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_path/json_path.dart';
import 'package:xolo/core/network/http_client_provider.dart';
import 'package:xolo/core/services/app_logger.dart';
import 'package:xolo/core/services/auth_resolver_service.dart';
import 'package:xolo/core/utils/script_executor.dart';
import 'package:xolo/core/utils/variable_parser.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/environment_provider.dart';
import 'package:xolo/presentation/providers/incognito_provider.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

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
  late final Dio _dio;

  final StreamController<RequestState> _controller =
      StreamController<RequestState>.broadcast();
  RequestState _state = RequestState();
  CancelToken? _activeCancelToken;

  RequestController(this.ref, this.tabId) {
    _dio = ref.read(dioProvider);
  }

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
    String? authType,
    String? authData,
    int? collectionId,
  }) async {
    _activeCancelToken?.cancel('Superseded by a new request');
    final cancelToken = CancelToken();
    _activeCancelToken = cancelToken;

    // 1. Loading
    _update(_state.copyWith(isLoading: true, error: null, statusCode: null));

    final stopwatch = Stopwatch()..start();

    // Variables for error handling scope
    String attemptUrl = url;
    String? errorMsg;
    int? statusCode;

    try {
      // 2. Variable Parsing (Global + Env + Chains)
      final baseVars = ref.read(resolvedVariablesProvider);
      final session = ref.read(requestSessionProvider(tabId)).asData?.value;

      // Execute Pre-Request Scripts
      final preVars = ScriptExecutor.executePreScripts(
        session?.preScriptsJson,
        baseVars,
      );
      final resolvedVars = {...baseVars, ...preVars};

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

      // 2.1 INJECT AUTH HEADERS (With Inheritance)
      // Resolve Auth
      final authResolver = ref.read(authResolverServiceProvider);
      final resolvedAuth = await authResolver.resolveAuth(
        requestAuthType: authType,
        requestAuthData: authData,
        collectionId: collectionId,
      );

      final effectiveAuthType = resolvedAuth.type;
      final effectiveAuthData = resolvedAuth.data;

      if (effectiveAuthType != null && effectiveAuthData != null) {
        try {
          final authMap = _parseAuthData(effectiveAuthData);

          if (effectiveAuthType == 'bearer') {
            final token = VariableParser.parse(
              authMap['token'] ?? '',
              resolvedVars,
            );
            if (token.isNotEmpty) {
              parsedHeaders['Authorization'] = 'Bearer $token';
            }
          } else if (effectiveAuthType == 'oauth2') {
            final token = VariableParser.parse(
              authMap['accessToken'] ?? '',
              resolvedVars,
            );
            if (token.isNotEmpty) {
              parsedHeaders['Authorization'] = 'Bearer $token';
            }
          } else if (effectiveAuthType == 'basic') {
            final user = VariableParser.parse(
              authMap['username'] ?? '',
              resolvedVars,
            );
            final pass = VariableParser.parse(
              authMap['password'] ?? '',
              resolvedVars,
            );
            if (user.isNotEmpty || pass.isNotEmpty) {
              final bytes = utf8.encode('$user:$pass');
              final base64Str = base64.encode(bytes);
              parsedHeaders['Authorization'] = 'Basic $base64Str';
            }
          } else if (effectiveAuthType == 'api_key') {
            final key = VariableParser.parse(
              authMap['key'] ?? '',
              resolvedVars,
            );
            final val = VariableParser.parse(
              authMap['value'] ?? '',
              resolvedVars,
            );
            final addTo = authMap['in'] ?? 'header';

            if (key.isNotEmpty && val.isNotEmpty) {
              if (addTo == 'header') {
                parsedHeaders[key] = val;
              } else if (addTo == 'query') {
                // Should inject into params
              }
            }
          }
        } catch (e) {
          AppLogger.warn('Error injecting auth');
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

      // 2.2 INJECT AUTH PARAMS (API Key Query)
      if (effectiveAuthType == 'api_key' && effectiveAuthData != null) {
        try {
          final authMap = _parseAuthData(effectiveAuthData);
          final addTo = authMap['in'] ?? 'header';
          if (addTo == 'query') {
            final key = VariableParser.parse(
              authMap['key'] ?? '',
              resolvedVars,
            );
            final val = VariableParser.parse(
              authMap['value'] ?? '',
              resolvedVars,
            );
            if (key.isNotEmpty && val.isNotEmpty) {
              parsedParams[key] = val;
            }
          }
        } catch (_) {}
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
        cancelToken: cancelToken,
        options: Options(
          method: method,
          headers: parsedHeaders,
          validateStatus: (status) => true, // No lanzar error por status code
        ),
      );

      stopwatch.stop();
      statusCode = response.statusCode;

      // 4. Success State
      _update(
        _state.copyWith(
          isLoading: false,
          data: response.data,
          statusCode: response.statusCode,
          durationMs: stopwatch.elapsedMilliseconds,
        ),
      );

      // 5. Execute Scripts (Request Chaining)
      await _executeScripts(response.data);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _update(
          _state.copyWith(
            isLoading: false,
            error: 'Request canceled',
            durationMs: stopwatch.elapsedMilliseconds,
          ),
        );
        return;
      }
      stopwatch.stop();
      statusCode = e.response?.statusCode;

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
      AppLogger.error('Error en request ($tabId)', e, stack);
    }

    // Save History (if not Incognito)
    try {
      final isIncognito = ref.read(isIncognitoProvider);
      if (isIncognito) {
        // Skip history
        return;
      }

      final repo = ref.read(xoloRepositoryProvider);
      final activeWorkspaceId = ref.read(activeWorkspaceIdProvider);

      await repo.addHistoryItem(
        method: method,
        url: attemptUrl, // Parsed/Resolved URL
        originalUrl: url, // Template URL
        statusCode: statusCode ?? 0,
        durationMs: stopwatch.elapsedMilliseconds,
        workspaceId: activeWorkspaceId,
      );
    } catch (e) {
      AppLogger.warn('Error guardando historial: $e');
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

  Map<String, dynamic> _parseAuthData(String jsonStr) {
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _executeScripts(dynamic responseData) async {
    final session = ref.read(requestSessionProvider(tabId)).asData?.value;
    final scriptsJson = session?.scriptsJson;
    if (scriptsJson == null || scriptsJson.isEmpty) return;

    try {
      final List<dynamic> rules = jsonDecode(scriptsJson);
      final db = ref.read(xoloRepositoryProvider);
      final activeEnvId = ref.read(activeEnvironmentIdProvider).asData?.value;
      final workspaceId = ref.read(activeWorkspaceIdProvider);

      for (final rule in rules) {
        final varName = rule['key'];
        final pathStr = rule['path'];
        if (varName == null || pathStr == null || pathStr.isEmpty) continue;

        try {
          final jsonPath = JsonPath(pathStr);
          final matches = jsonPath.read(responseData);

          if (matches.isNotEmpty) {
            final firstValue = matches.first.value;
            if (firstValue != null) {
              await db.upsertVariable(
                key: varName,
                value: firstValue.toString(),
                environmentId: activeEnvId,
                workspaceId: workspaceId,
              );
            }
          }
        } catch (e) {
          AppLogger.warn('Error parsing JSON Path for scripts');
        }
      }
    } catch (e) {
      AppLogger.warn('Error executing scripts');
    }
  }

  /// Tests scripts against a specific response data without saving to DB
  Map<String, String> testScripts(dynamic responseData, String scriptsJson) {
    return ScriptExecutor.testPostScripts(responseData, scriptsJson);
  }

  void dispose() {
    _activeCancelToken?.cancel('Controller disposed');
    _controller.close();
  }
}

// --- Providers ---

final _requestControllers = <String, RequestController>{};

final requestControllerProvider = Provider.family<RequestController, String>((
  ref,
  id,
) {
  final controller = _requestControllers.putIfAbsent(
    id,
    () => RequestController(ref, id),
  );
  ref.onDispose(() {
    controller.dispose();
    _requestControllers.remove(id);
  });
  return controller;
});

final requestProvider = StreamProvider.family<RequestState, String>((ref, id) {
  final controller = ref.watch(requestControllerProvider(id));
  return controller.stream;
});
