import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/services/import_manager.dart';
import 'package:xolo/data/services/openapi_service.dart';
import 'package:xolo/data/services/postman_service.dart';

void main() {
  late ImportManager manager;
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;

  setUp(() {
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    manager = ImportManager(dio, OpenApiService(dio), PostmanService());
    db = AppDatabase.memory();
  });

  tearDown(() {
    db.close();
  });

  group('ImportManager.detectFormat', () {
    test('returns preferred format when not auto', () {
      final json = {
        'openapi': '3.0.0',
        'info': {'_postman_id': 'x'},
      };

      expect(
        manager.detectFormat(json, ImportFormat.postman),
        ImportFormat.postman,
      );
      expect(
        manager.detectFormat(json, ImportFormat.openApi),
        ImportFormat.openApi,
      );
    });

    test('detects postman by _postman_id in info', () {
      final json = {
        'info': {'_postman_id': 'abc-123', 'name': 'My Collection'},
        'item': [],
      };

      expect(
        manager.detectFormat(json, ImportFormat.auto),
        ImportFormat.postman,
      );
    });

    test('detects openapi by openapi key', () {
      final json = {
        'openapi': '3.0.3',
        'info': {'title': 'Sample API', 'version': '1.0.0'},
        'paths': {},
      };

      expect(
        manager.detectFormat(json, ImportFormat.auto),
        ImportFormat.openApi,
      );
    });

    test('detects openapi by swagger key', () {
      final json = {
        'swagger': '2.0',
        'info': {'title': 'Legacy API', 'version': '1.0.0'},
        'paths': {},
      };

      expect(
        manager.detectFormat(json, ImportFormat.auto),
        ImportFormat.openApi,
      );
    });

    test('falls back to postman when item key is present', () {
      final json = {
        'info': {'name': 'Folder-like export'},
        'item': [
          {'name': 'Request'},
        ],
      };

      expect(
        manager.detectFormat(json, ImportFormat.auto),
        ImportFormat.postman,
      );
    });

    test('falls back to openapi when paths key is present', () {
      final json = {
        'info': {'title': 'Minimal'},
        'paths': {'/health': {}},
      };

      expect(
        manager.detectFormat(json, ImportFormat.auto),
        ImportFormat.openApi,
      );
    });

    test('defaults to openapi for unknown structure', () {
      final json = {
        'metadata': {'source': 'unknown'},
      };

      expect(
        manager.detectFormat(json, ImportFormat.auto),
        ImportFormat.openApi,
      );
    });
  });

  group('ImportManager.importFromContent', () {
    test('imports postman json into memory database', () async {
      final json = {
        'info': {'_postman_id': 'abc', 'name': 'Postman Collection'},
        'item': [
          {
            'name': 'Ping',
            'request': {'method': 'GET', 'url': 'https://api.test/ping'},
          },
        ],
      };

      await manager.importFromContent(
        jsonEncode(json),
        db,
        format: ImportFormat.postman,
      );

      final root = await db.findCollectionByName('Postman Collection', null);
      expect(root, isNotNull);

      final request = await db.findRequestInCollection(
        collectionId: root!.id,
        method: 'GET',
        url: 'https://api.test/ping',
      );
      expect(request?.name, 'Ping');
    });

    test('imports openapi json into memory database', () async {
      final json = {
        'openapi': '3.0.0',
        'info': {'title': 'OpenAPI Collection', 'version': '1.0.0'},
        'servers': [
          {'url': 'https://api.test'},
        ],
        'paths': {
          '/health': {
            'get': {'summary': 'Health check'},
          },
        },
      };

      await manager.importFromContent(
        jsonEncode(json),
        db,
        format: ImportFormat.openApi,
      );

      final root = await db.findCollectionByName('OpenAPI Collection', null);
      expect(root, isNotNull);

      final request = await db.findRequestInCollection(
        collectionId: root!.id,
        method: 'GET',
        url: 'https://api.test/health',
      );
      expect(request?.name, 'Health check');
    });

    test('throws for invalid json payload', () async {
      expect(
        () => manager.importFromContent('[]', db),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ImportManager.importFromUrl', () {
    test('imports postman payload from url', () async {
      adapter.onGet(
        'https://example.com/postman.json',
        (server) => server.reply(200, {
          'info': {'_postman_id': 'id-1', 'name': 'Remote Postman'},
          'item': [
            {
              'name': 'Remote',
              'request': {'method': 'GET', 'url': 'https://api.test/remote'},
            },
          ],
        }),
      );

      await manager.importFromUrl('https://example.com/postman.json', db);

      final root = await db.findCollectionByName('Remote Postman', null);
      expect(root, isNotNull);
    });

    test('imports openapi payload from url', () async {
      adapter.onGet(
        'https://example.com/openapi.json',
        (server) => server.reply(200, {
          'openapi': '3.0.0',
          'info': {'title': 'Remote API', 'version': '1.0.0'},
          'paths': {
            '/ping': {
              'get': {'summary': 'Ping'},
            },
          },
        }),
      );

      await manager.importFromUrl('https://example.com/openapi.json', db);

      final root = await db.findCollectionByName('Remote API', null);
      expect(root, isNotNull);
    });

    test('normalizes string json payloads', () async {
      adapter.onGet(
        'https://example.com/string.json',
        (server) => server.reply(
          200,
          '{"openapi":"3.0.0","info":{"title":"String API","version":"1"},"paths":{"/x":{"get":{}}}}',
        ),
      );

      await manager.importFromUrl('https://example.com/string.json', db);
      expect(await db.findCollectionByName('String API', null), isNotNull);
    });

    test('throws for unsupported payload format', () async {
      adapter.onGet(
        'https://example.com/bad.json',
        (server) => server.reply(200, [1, 2, 3]),
      );

      expect(
        () => manager.importFromUrl('https://example.com/bad.json', db),
        throwsA(isA<Exception>()),
      );
    });
  });
}
