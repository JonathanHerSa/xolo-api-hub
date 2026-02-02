import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_path/json_path.dart';

import '../../core/utils/variable_parser.dart';
import '../../core/services/auth_resolver_service.dart';
import '../providers/environment_provider.dart';
import '../providers/request_session_provider.dart';
import '../providers/database_providers.dart';
import '../providers/workspace_provider.dart';
import '../providers/incognito_provider.dart';

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
    String? authType,
    String? authData,
    int? collectionId,
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
      final baseVars = ref.read(resolvedVariablesProvider);
      final session = ref.read(requestSessionProvider(tabId)).asData?.value;

      // Execute Pre-Request Scripts
      final preVars = _executePreScripts(session?.preScriptsJson, baseVars);
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
          print('Error injecting auth: $e');
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

      // 5. Execute Scripts (Request Chaining)
      await _executeScripts(response.data);
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

    // Save History (if not Incognito)
    try {
      final isIncognito = ref.read(isIncognitoProvider);
      if (isIncognito) {
        // Skip history
        return;
      }

      final db = ref.read(databaseProvider);
      final activeWorkspaceId = ref.read(activeWorkspaceIdProvider);

      String? responseBodyStr;
      if (responseData != null) {
        responseBodyStr = responseData.toString();
      }

      await db.addHistoryItem(
        method: method,
        url: attemptUrl, // Parsed/Resolved URL
        originalUrl: url, // Template URL
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
      final db = ref.read(databaseProvider);
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
          print('Error parsing JSON Path "$pathStr": $e');
        }
      }
    } catch (e) {
      print('Error executing scripts: $e');
    }
  }

  Map<String, String> _executePreScripts(
    String? preScriptsJson,
    Map<String, String> baseVars,
  ) {
    if (preScriptsJson == null || preScriptsJson.isEmpty) return {};
    final results = <String, String>{};

    try {
      final List<dynamic> rules = jsonDecode(preScriptsJson);
      for (final rule in rules) {
        final varName = rule['key'];
        final template = rule['value']; // E.g. "order_{{$timestamp}}"
        if (varName == null || template == null || template.isEmpty) continue;

        try {
          // Evaluar el template usando las variables base
          final evaluated = VariableParser.parse(template, baseVars);
          results[varName] = evaluated;
        } catch (e) {
          print('Error evaluating pre-script rule "$varName": $e');
        }
      }
    } catch (e) {
      print('Error parsing pre-scripts JSON: $e');
    }
    return results;
  }

  /// Tests scripts against a specific response data without saving to DB
  Map<String, String> testScripts(dynamic responseData, String scriptsJson) {
    if (scriptsJson.isEmpty) return {};
    final results = <String, String>{};

    try {
      final List<dynamic> rules = jsonDecode(scriptsJson);
      for (final rule in rules) {
        final varName = rule['key'];
        final pathStr = rule['path'];
        if (varName == null || pathStr == null || pathStr.isEmpty) continue;

        try {
          final jsonPath = JsonPath(pathStr);
          final matches = jsonPath.read(responseData);

          if (matches.isNotEmpty) {
            final firstValue = matches.first.value;
            results[varName] = firstValue?.toString() ?? 'null';
          } else {
            results[varName] = '[No Match]';
          }
        } catch (e) {
          results[varName] = '[Error: $e]';
        }
      }
    } catch (e) {
      print('Error testing scripts: $e');
    }
    return results;
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
