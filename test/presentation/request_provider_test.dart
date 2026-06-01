import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:xolo/core/network/http_client_provider.dart';
import 'package:xolo/core/utils/boolean_notifier.dart';
import 'package:xolo/core/utils/script_executor.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/repositories/drift_xolo_repository.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/environment_provider.dart';
import 'package:xolo/presentation/providers/incognito_provider.dart';
import 'package:xolo/presentation/providers/request_provider.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

import '../helpers/test_providers.dart';

var _tabCounter = 0;

class _HistoryFailingRepo extends DriftXoloRepository {
  _HistoryFailingRepo(super.db);

  @override
  Future<int> addHistoryItem({
    required String method,
    required String url,
    String? originalUrl,
    int? statusCode,
    int? durationMs,
    int? responseSize,
    int? workspaceId,
  }) async {
    throw StateError('history fail');
  }
}

class _CancelAwareSlowAdapter implements HttpClientAdapter {
  static const _jsonHeaders = {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  };

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path.contains('slow')) {
      final completer = Completer<void>();
      unawaited(cancelFuture?.whenComplete(completer.complete));
      await completer.future;
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.cancel,
        message: 'Superseded by a new request',
      );
    }

    return ResponseBody.fromString(
      '{"winner":"second"}',
      200,
      headers: _jsonHeaders,
    );
  }
}

String _nextTabId() => 'request-tab-${++_tabCounter}';

class _FixedBooleanNotifier extends BooleanNotifier {
  _FixedBooleanNotifier(this.value);
  final bool value;

  @override
  bool build() => value;
}

class _FixedWorkspaceNotifier extends WorkspaceNotifier {
  _FixedWorkspaceNotifier(this.initial);
  final int? initial;

  @override
  int? build() => initial;

  @override
  Future<void> setWorkspace(int? id) async {
    state = id;
  }
}

RequestOptions? _lastRequestOptions;

void _captureRequests(Dio dio) {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        _lastRequestOptions = options;
        handler.next(options);
      },
    ),
  );
}

TestHarness _createHarness({
  Map<String, String> variables = const {},
  bool incognito = false,
  int? workspaceId,
  HttpRequestMatcher? matcher,
}) {
  final harness = TestHarness.create(
    matcher: matcher,
    overrides: [
      resolvedVariablesProvider.overrideWithValue(variables),
      isIncognitoProvider.overrideWith(() => _FixedBooleanNotifier(incognito)),
      activeWorkspaceIdProvider.overrideWith(
        () => _FixedWorkspaceNotifier(workspaceId),
      ),
    ],
  );
  _captureRequests(harness.dio);
  return harness;
}

Future<void> _primeSessionStream(
  ProviderContainer container,
  String tabId,
) async {
  container.read(requestSessionControllerProvider(tabId));
  final completer = Completer<void>();
  final sub = container.listen(requestSessionProvider(tabId), (_, next) {
    if (next case AsyncData()) {
      if (!completer.isCompleted) completer.complete();
    }
  }, fireImmediately: true);
  await completer.future.timeout(const Duration(seconds: 2));
  sub.close();
}

Future<RequestController> _controller(
  TestHarness harness,
  String tabId, {
  bool primeSession = false,
}) async {
  harness.container.read(requestSessionControllerProvider(tabId));
  if (primeSession) {
    await _primeSessionStream(harness.container, tabId);
  }
  return harness.container.read(requestControllerProvider(tabId));
}

void main() {
  group('RequestController', () {
    test(
      'successful GET substitutes variables in url, headers, params and body',
      () async {
        final tabId = _nextTabId();
        final harness = _createHarness(
          incognito: true,
          variables: {
            'host': 'api.example.com',
            'userId': '42',
            'q': 'search',
            'payload': '{"name":"Ada"}',
          },
        );
        addTearDown(harness.dispose);

        const resolvedUrl = 'https://api.example.com/users/42';
        harness.adapter.onGet(
          resolvedUrl,
          (server) => server.reply(200, {'ok': true}),
          queryParameters: {'q': 'search'},
          data: '{"name":"Ada"}',
        );

        final controller = await _controller(harness, tabId);
        await controller.fetchData(
          method: 'GET',
          url: 'https://{{host}}/users/{{userId}}',
          queryParams: {'q': '{{q}}'},
          headers: {'X-User': '{{userId}}'},
          body: '{{payload}}',
        );

        expect(controller.state.isLoading, isFalse);
        expect(controller.state.statusCode, 200);
        expect(controller.state.data, {'ok': true});
        expect(controller.state.error, isNull);
        expect(_lastRequestOptions?.uri.toString(), '$resolvedUrl?q=search');
        expect(_lastRequestOptions?.queryParameters, {'q': 'search'});
        expect(_lastRequestOptions?.headers['X-User'], '42');
        expect(_lastRequestOptions?.data, '{"name":"Ada"}');
      },
    );

    test('injects bearer auth from resolved auth data', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/secure',
        (server) => server.reply(200, {'secure': true}),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/secure',
        authType: 'bearer',
        authData: '{"token":"secret-token"}',
      );

      expect(
        _lastRequestOptions?.headers['Authorization'],
        'Bearer secret-token',
      );
    });

    test('injects basic auth header', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/basic',
        (server) => server.reply(200, {}),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/basic',
        authType: 'basic',
        authData: '{"username":"alice","password":"secret"}',
      );

      final expected = 'Basic ${base64.encode(utf8.encode('alice:secret'))}';
      expect(_lastRequestOptions?.headers['Authorization'], expected);
    });

    test('injects oauth2 bearer token', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/oauth',
        (server) => server.reply(200, {}),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/oauth',
        authType: 'oauth2',
        authData: '{"accessToken":"oauth-access"}',
      );

      expect(
        _lastRequestOptions?.headers['Authorization'],
        'Bearer oauth-access',
      );
    });

    test('injects api_key auth in header', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/key-header',
        (server) => server.reply(200, {}),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/key-header',
        authType: 'api_key',
        authData: '{"key":"X-Api-Key","value":"abc123","in":"header"}',
      );

      expect(_lastRequestOptions?.headers['X-Api-Key'], 'abc123');
    });

    test('injects api_key auth in query params', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/key-query',
        (server) => server.reply(200, {}),
        queryParameters: {'api_key': 'query-value'},
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/key-query',
        authType: 'api_key',
        authData: '{"key":"api_key","value":"query-value","in":"query"}',
      );

      expect(_lastRequestOptions?.queryParameters['api_key'], 'query-value');
    });

    test(
      'inherits auth from collection when request auth is inherit',
      () async {
        final tabId = _nextTabId();
        final harness = _createHarness(incognito: true);
        addTearDown(harness.dispose);

        final collectionId = await harness.repo.createCollection(
          name: 'Auth Project',
          authType: 'bearer',
          authData: '{"token":"inherited-token"}',
        );

        harness.adapter.onGet(
          'https://api.example.com/inherit',
          (server) => server.reply(200, {}),
        );

        final controller = await _controller(harness, tabId);
        await controller.fetchData(
          method: 'GET',
          url: 'https://api.example.com/inherit',
          authType: 'inherit',
          collectionId: collectionId,
        );

        expect(
          _lastRequestOptions?.headers['Authorization'],
          'Bearer inherited-token',
        );
      },
    );

    test('executes pre-request scripts before sending request', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(
        incognito: true,
        variables: {'base': 'api.example.com'},
      );
      addTearDown(harness.dispose);

      harness.container
          .read(requestSessionControllerProvider(tabId))
          .setPreScriptsJson(
            r'[{"key":"host","value":"{{base}}"},{"key":"version","value":"v2"}]',
          );

      harness.adapter.onGet(
        'https://api.example.com/v2/ping',
        (server) => server.reply(200, {'pong': true}),
      );

      final controller = await _controller(harness, tabId, primeSession: true);
      await controller.fetchData(
        method: 'GET',
        url: 'https://{{host}}/{{version}}/ping',
      );

      expect(_lastRequestOptions?.uri.host, 'api.example.com');
      expect(_lastRequestOptions?.uri.path, '/v2/ping');
      expect(controller.state.data, {'pong': true});
    });

    test('post-scripts upsert extracted json path variable to db', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      final envId = await harness.repo.createEnvironment('Dev', null);
      await harness.repo.setActiveEnvironment(envId, null);

      harness.container
          .read(requestSessionControllerProvider(tabId))
          .setScriptsJson(r'[{"key":"access_token","path":"$.token"}]');

      harness.adapter.onGet(
        'https://api.example.com/token',
        (server) => server.reply(200, {'token': 'stored-token'}),
      );

      final controller = await _controller(harness, tabId, primeSession: true);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/token',
      );

      final vars = await harness.repo.watchVariables(null, null).first;
      expect(
        vars.any((v) => v.key == 'access_token' && v.value == 'stored-token'),
        isTrue,
      );
      expect(controller.state.statusCode, 200);
    });

    test('incognito mode skips history persistence', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/no-history',
        (server) => server.reply(200, {}),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/no-history',
      );

      final history = await harness.repo.watchRecentHistory(null).first;
      expect(history, isEmpty);
      expect(controller.state.statusCode, 200);
    });

    test('persists history on successful request', () async {
      final tabId = _nextTabId();
      final harness = _createHarness();
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/history',
        (server) => server.reply(201, {'saved': true}),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/history',
      );

      final history = await harness.repo.watchRecentHistory(null).first;
      expect(history, hasLength(1));
      expect(history.first.method, 'GET');
      expect(history.first.url, 'https://api.example.com/history');
      expect(history.first.originalUrl, 'https://api.example.com/history');
      expect(history.first.statusCode, 201);
      expect(history.first.durationMs, isNotNull);
      expect(controller.state.statusCode, 201);
    });

    test('handles DioException network errors', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/network-error',
        (server) => server.throws(
          0,
          DioException(
            requestOptions: RequestOptions(
              path: 'https://api.example.com/network-error',
            ),
            type: DioExceptionType.connectionError,
            message: 'Connection failed',
          ),
        ),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/network-error',
      );

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.error, contains('Error de red'));
      expect(
        controller.state.error,
        contains('https://api.example.com/network-error'),
      );
      expect(controller.state.durationMs, isNotNull);
    });

    test('cancels superseded in-flight request', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);
      harness.dio.httpClientAdapter = _CancelAwareSlowAdapter();

      final controller = await _controller(harness, tabId);

      final slow = controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/slow/race',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final fast = controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/fast/race',
      );

      await slow;
      expect(controller.state.error, 'Request canceled');
      await fast;
    });

    test('reset clears controller state', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      final controller = await _controller(harness, tabId);
      controller.restoreResponse({'cached': true}, 200);

      controller.reset();

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.data, isNull);
      expect(controller.state.error, isNull);
      expect(controller.state.statusCode, isNull);
      expect(controller.state.durationMs, isNull);
    });

    test('restoreResponse sets data and status without loading', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      final controller = await _controller(harness, tabId);

      controller.restoreResponse({'fromHistory': true}, 418);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.data, {'fromHistory': true});
      expect(controller.state.statusCode, 418);
      expect(controller.state.error, isNull);
    });

    test('testScripts delegates to ScriptExecutor.testPostScripts', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      const scriptsJson = r'[{"key":"id","path":"$.data.id"}]';
      final response = {
        'data': {'id': 42},
      };

      final controller = await _controller(harness, tabId);
      final viaController = controller.testScripts(response, scriptsJson);
      final viaExecutor = ScriptExecutor.testPostScripts(response, scriptsJson);

      expect(viaController, viaExecutor);
      expect(viaController, {'id': '42'});
    });

    test('testScripts returns empty map for empty scripts json', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      final controller = await _controller(harness, tabId);
      expect(controller.testScripts({'ok': true}, ''), isEmpty);
    });

    test('handles invalid auth json gracefully', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/invalid-auth',
        (server) => server.reply(200, {}),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/invalid-auth',
        authType: 'bearer',
        authData: 'not-valid-json',
      );

      expect(
        _lastRequestOptions?.headers.containsKey('Authorization'),
        isFalse,
      );
      expect(controller.state.statusCode, 200);
    });

    test('handles non-map auth json without crashing', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/list-auth',
        (server) => server.reply(200, {}),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/list-auth',
        authType: 'bearer',
        authData: '["unexpected","array"]',
      );

      expect(
        _lastRequestOptions?.headers.containsKey('Authorization'),
        isFalse,
      );
      expect(controller.state.statusCode, 200);
    });

    test('handles unexpected errors during request execution', () async {
      final tabId = _nextTabId();
      final harness = TestHarness.create(
        overrides: [
          resolvedVariablesProvider.overrideWith((ref) {
            throw StateError('boom');
          }),
          isIncognitoProvider.overrideWith(() => _FixedBooleanNotifier(true)),
          activeWorkspaceIdProvider.overrideWith(
            () => _FixedWorkspaceNotifier(null),
          ),
        ],
      );
      addTearDown(harness.dispose);

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/unexpected',
      );

      expect(controller.state.error, contains('boom'));
      expect(controller.state.isLoading, isFalse);
    });

    test('ignores invalid post-script rules without failing request', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.container
          .read(requestSessionControllerProvider(tabId))
          .setScriptsJson('not-json');

      harness.adapter.onGet(
        'https://api.example.com/scripts',
        (server) => server.reply(200, {'token': 'ignored'}),
      );

      final controller = await _controller(harness, tabId, primeSession: true);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/scripts',
      );

      expect(controller.state.statusCode, 200);
    });

    test('dispose cancels active request', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(
        incognito: true,
        matcher: const UrlRequestMatcher(matchMethod: true),
      );

      harness.adapter.onGet(
        'https://api.example.com/dispose',
        (server) => server.reply(200, {}, delay: const Duration(seconds: 5)),
      );

      final controller = await _controller(harness, tabId);
      final pending = controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/dispose',
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(() => harness.container.dispose(), returnsNormally);

      try {
        await pending;
      } catch (_) {
        // Stream may already be closed when cancel handler updates state.
      }
    });

    test('stream emits initial and updated states', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/stream',
        (server) => server.reply(200, {'ok': true}),
      );

      final controller = await _controller(harness, tabId);
      final states = <RequestState>[];
      final subscription = controller.stream.listen(states.add);

      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/stream',
      );
      await subscription.cancel();

      expect(states, isNotEmpty);
      expect(states.last.statusCode, 200);
    });

    test('requestProvider mirrors controller stream', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/provider-stream',
        (server) => server.reply(200, {'via': 'provider'}),
      );

      final controller = await _controller(harness, tabId);
      final completer = Completer<RequestState>();
      final subscription = harness.container.listen(requestProvider(tabId), (
        _,
        next,
      ) {
        if (next case AsyncData(
          value: final state,
        ) when state.statusCode == 200) {
          if (!completer.isCompleted) {
            completer.complete(state);
          }
        }
      }, fireImmediately: true);

      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/provider-stream',
      );

      final state = await completer.future.timeout(const Duration(seconds: 2));
      subscription.close();

      expect(state.statusCode, 200);
      expect(state.data, {'via': 'provider'});
    });

    test('RequestState copyWith preserves unspecified fields', () {
      final original = RequestState(
        isLoading: true,
        data: {'keep': true},
        error: 'err',
        statusCode: 500,
        durationMs: 10,
      );

      final updated = original.copyWith(statusCode: 200);

      expect(updated.isLoading, isTrue);
      expect(updated.data, {'keep': true});
      expect(updated.error, 'err');
      expect(updated.statusCode, 200);
      expect(updated.durationMs, 10);
    });

    test('handles auth map processing exceptions gracefully', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.adapter.onGet(
        'https://api.example.com/auth-type-error',
        (server) => server.reply(200, {}),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/auth-type-error',
        authType: 'bearer',
        authData: '{"token":12345}',
      );

      expect(
        _lastRequestOptions?.headers.containsKey('Authorization'),
        isFalse,
      );
      expect(controller.state.statusCode, 200);
    });

    test('continues when history persistence fails', () async {
      final tabId = _nextTabId();
      final db = AppDatabase.memory();
      final failingRepo = _HistoryFailingRepo(db);
      final dio = Dio();
      final adapter = DioAdapter(dio: dio);
      final harness = TestHarness(
        db: db,
        repo: failingRepo,
        container: ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            xoloRepositoryProvider.overrideWithValue(failingRepo),
            dioProvider.overrideWithValue(dio),
            resolvedVariablesProvider.overrideWithValue(const {}),
            isIncognitoProvider.overrideWith(
              () => _FixedBooleanNotifier(false),
            ),
            activeWorkspaceIdProvider.overrideWith(
              () => _FixedWorkspaceNotifier(null),
            ),
          ],
        ),
        dio: dio,
        adapter: adapter,
      );
      addTearDown(harness.dispose);
      _captureRequests(harness.dio);

      harness.adapter.onGet(
        'https://api.example.com/history-fail',
        (server) => server.reply(200, {}),
      );

      final controller = await _controller(harness, tabId);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/history-fail',
      );

      expect(controller.state.statusCode, 200);
    });

    test('ignores invalid json path entries in post-scripts', () async {
      final tabId = _nextTabId();
      final harness = _createHarness(incognito: true);
      addTearDown(harness.dispose);

      harness.container
          .read(requestSessionControllerProvider(tabId))
          .setScriptsJson(
            r'[{"key":"bad","path":"$invalid[["},{"key":"good","path":"$.id"}]',
          );

      harness.adapter.onGet(
        'https://api.example.com/script-path',
        (server) => server.reply(200, {'id': '42'}),
      );

      final controller = await _controller(harness, tabId, primeSession: true);
      await controller.fetchData(
        method: 'GET',
        url: 'https://api.example.com/script-path',
      );

      final vars = await harness.repo.watchVariables(null, null).first;
      expect(vars.any((v) => v.key == 'good' && v.value == '42'), isTrue);
      expect(controller.state.statusCode, 200);
    });
  });
}
