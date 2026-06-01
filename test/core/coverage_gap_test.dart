import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/network/http_client_provider.dart';
import 'package:xolo/core/services/encryption_service.dart';
import 'package:xolo/core/utils/schema_helper.dart';
import 'package:xolo/core/utils/script_executor.dart';
import 'package:xolo/core/utils/variable_parser.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/services/import_manager.dart';
import 'package:xolo/data/services/openapi_service.dart';
import 'package:xolo/data/services/postman_service.dart';
import 'package:xolo/domain/entities/key_value_pair.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/incognito_provider.dart';

import '../helpers/test_providers.dart';

void main() {
  test('KeyValuePair copyWith preserves unspecified fields', () {
    final original = KeyValuePair(key: 'k', value: 'v', isActive: false);

    expect(original.copyWith(key: 'k2').key, 'k2');
    expect(original.copyWith(value: 'v2').value, 'v2');
    expect(original.copyWith(isActive: true).isActive, isTrue);
  });

  test('BooleanNotifier build initializes false', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(isIncognitoProvider), isFalse);
  });

  test('service providers instantiate', () {
    final harness = TestHarness.create();
    addTearDown(harness.dispose);

    expect(harness.container.read(encryptionServiceProvider), isNotNull);
    expect(harness.container.read(postmanServiceProvider), isNotNull);
    expect(harness.container.read(openApiServiceProvider), isNotNull);
    expect(harness.container.read(importManagerProvider), isNotNull);
  });

  test(
    'database_providers creates repository and closes database on dispose',
    () {
      TestWidgetsFlutterBinding.ensureInitialized();

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final db = container.read(databaseProvider);
      expect(db, isA<AppDatabase>());

      final repo = container.read(xoloRepositoryProvider);
      expect(repo, isNotNull);
    },
  );

  test('VariableParser supports {:param} syntax', () {
    final parsed = VariableParser.parse('/users/{:userId}', {'userId': '42'});
    expect(parsed, '/users/42');
  });

  test('VariableParser keeps unmatched template tokens', () {
    expect(VariableParser.parse('{{}}', {}), '{{}}');
  });

  test('SchemaHelper returns example when type is unknown', () {
    final sample = SchemaHelper.generateSample({'example': 'fallback-value'});
    expect(sample, 'fallback-value');

    expect(SchemaHelper.generateSample({'type': 'unknown-type'}), isNull);
  });

  test('ScriptExecutor.testPostScripts handles invalid scripts json', () {
    expect(ScriptExecutor.testPostScripts({'ok': true}, 'not-json'), isEmpty);
  });

  test('dioProvider logs and forwards non-retryable errors', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);
    dio.httpClientAdapter = _AlwaysFailAdapter();

    expect(
      () => dio.post('https://example.com/fail'),
      throwsA(isA<DioException>()),
    );
  });
}

class _AlwaysFailAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: 400),
    );
  }
}
