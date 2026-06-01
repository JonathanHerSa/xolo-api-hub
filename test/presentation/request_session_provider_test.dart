import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/domain/entities/key_value_pair.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';

void main() {
  group('RequestSessionController', () {
    late RequestSessionController controller;

    setUp(() {
      controller = RequestSessionController('session-1');
    });

    test('initial state has empty trailing row for headers and params', () {
      expect(controller.state.id, 'session-1');
      expect(controller.state.method, 'GET');
      expect(controller.state.headers, hasLength(1));
      expect(controller.state.params, hasLength(1));
    });

    test('setters update session fields', () {
      controller.setMethod('POST');
      controller.setUrl('https://api.test');
      controller.setBody('{"ok":true}');
      controller.setName('My Request');
      controller.setAuthType('bearer');
      controller.setAuthData('{"token":"x"}');
      controller.setSchemaJson('{}');
      controller.setScriptsJson('[]');
      controller.setPreScriptsJson('[]');

      final s = controller.state;
      expect(s.method, 'POST');
      expect(s.url, 'https://api.test');
      expect(s.body, '{"ok":true}');
      expect(s.name, 'My Request');
      expect(s.authType, 'bearer');
      expect(s.authData, '{"token":"x"}');
      expect(s.schemaJson, '{}');
      expect(s.scriptsJson, '[]');
      expect(s.preScriptsJson, '[]');
    });

    test('updateHeaders and updateParams append empty row when needed', () {
      controller.updateHeaders([KeyValuePair(key: 'X-Test', value: '1')]);
      expect(controller.state.headers, hasLength(2));
      expect(controller.state.headers.last.key, isEmpty);

      controller.updateParams([KeyValuePair(key: 'q', value: 'v')]);
      expect(controller.state.params, hasLength(2));
    });

    test('loadRequest parses headers and params json', () {
      final req = SavedRequestEntity(
        id: 99,
        name: 'Loaded',
        method: 'PUT',
        url: 'https://api.test/items',
        headersJson: jsonEncode([
          {'key': 'Accept', 'value': 'application/json', 'isActive': true},
        ]),
        paramsJson: jsonEncode([
          {'key': 'page', 'value': '1', 'isActive': false},
        ]),
        body: 'body-data',
        authType: 'none',
        authData: null,
        collectionId: 5,
        scriptsJson: '[]',
        preScriptsJson: null,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        isDeleted: false,
      );

      controller.loadRequest(req);

      final s = controller.state;
      expect(s.id, 'session-1');
      expect(s.name, 'Loaded');
      expect(s.method, 'PUT');
      expect(s.url, 'https://api.test/items');
      expect(s.body, 'body-data');
      expect(s.authType, 'none');
      expect(s.collectionId, 5);
      expect(s.headers.first.key, 'Accept');
      expect(s.params.first.key, 'page');
      expect(s.headers, hasLength(2));
    });

    test('loadRequest falls back on invalid headers json', () {
      final req = SavedRequestEntity(
        id: 1,
        name: 'Bad JSON',
        method: 'GET',
        url: '/',
        headersJson: 'not-json',
        paramsJson: '',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
        isDeleted: false,
      );

      controller.loadRequest(req);

      expect(controller.state.headers, hasLength(1));
      expect(controller.state.headers.first.key, isEmpty);
      expect(controller.state.params, hasLength(1));
    });

    test('loadRequest handles null headers and params', () {
      final req = SavedRequestEntity(
        id: 2,
        name: 'Empty KV',
        method: 'GET',
        url: '/',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
        isDeleted: false,
      );

      controller.loadRequest(req);

      expect(controller.state.headers, hasLength(1));
      expect(controller.state.params, hasLength(1));
    });

    test('stream emits initial state then updates', () async {
      final values = <RequestSession>[];
      final sub = controller.stream.listen(values.add);

      await Future<void>.delayed(Duration.zero);
      expect(values, hasLength(1));
      expect(values.first.method, 'GET');

      controller.setMethod('DELETE');
      await Future<void>.delayed(Duration.zero);
      expect(values.last.method, 'DELETE');

      await sub.cancel();
    });
  });

  group('requestSession providers', () {
    test('family provider returns same controller instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final a = container.read(requestSessionControllerProvider('tab-a'));
      final b = container.read(requestSessionControllerProvider('tab-a'));
      final c = container.read(requestSessionControllerProvider('tab-b'));

      expect(identical(a, b), isTrue);
      expect(identical(a, c), isFalse);
    });
  });
}
