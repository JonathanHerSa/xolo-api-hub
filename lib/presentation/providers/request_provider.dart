import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_path/json_path.dart';
import 'package:xolo/core/network/request_pipeline.dart';
import 'package:xolo/core/services/app_logger.dart';
import 'package:xolo/core/services/auth_resolver_service.dart';
import 'package:xolo/core/utils/script_executor.dart';
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
  RequestController(this.ref, this.tabId);

  final Ref ref;
  final String tabId;

  final StreamController<RequestState> _controller =
      StreamController<RequestState>.broadcast();
  RequestState _state = RequestState();
  CancelToken? _activeCancelToken;

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

    _update(_state.copyWith(isLoading: true, error: null, statusCode: null));

    var attemptUrl = url;
    int? statusCode;

    try {
      final baseVars = ref.read(resolvedVariablesProvider);
      final session = ref.read(requestSessionProvider(tabId)).asData?.value;

      final preVars = ScriptExecutor.executePreScripts(
        session?.preScriptsJson,
        baseVars,
      );
      final resolvedVars = {...baseVars, ...preVars};

      final output = await ref.read(requestPipelineProvider).send(
        method: method,
        url: url,
        queryParams: queryParams,
        headers: headers,
        body: body,
        authType: authType,
        authData: authData,
        collectionId: collectionId,
        variables: resolvedVars,
        authResolver: ref.read(authResolverServiceProvider),
        cancelToken: cancelToken,
      );

      attemptUrl = output.resolvedUrl;
      statusCode = output.statusCode;

      if (output.cancelled) {
        _update(
          _state.copyWith(
            isLoading: false,
            error: 'Request canceled',
            durationMs: output.durationMs,
          ),
        );
        return;
      }

      if (output.error != null) {
        _update(
          _state.copyWith(
            isLoading: false,
            error: output.error,
            statusCode: statusCode,
            durationMs: output.durationMs,
            data: output.data,
          ),
        );
      } else {
        _update(
          _state.copyWith(
            isLoading: false,
            data: output.data,
            statusCode: output.statusCode,
            durationMs: output.durationMs,
          ),
        );
        await _executeScripts(output.data);
      }
    } catch (e, stack) {
      _update(
        _state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
      AppLogger.error('Error en request ($tabId)', e, stack);
    }

    try {
      final isIncognito = ref.read(isIncognitoProvider);
      if (isIncognito) return;

      final repo = ref.read(xoloRepositoryProvider);
      final activeWorkspaceId = ref.read(activeWorkspaceIdProvider);

      await repo.addHistoryItem(
        method: method,
        url: attemptUrl,
        originalUrl: url,
        statusCode: statusCode ?? 0,
        durationMs: _state.durationMs ?? 0,
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
