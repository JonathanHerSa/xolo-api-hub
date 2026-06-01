import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/services/openapi_service.dart';

void main() {
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;
  late OpenApiService service;

  setUp(() {
    db = AppDatabase.memory();
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    service = OpenApiService(dio);
  });

  tearDown(() {
    db.close();
  });

  Map<String, dynamic> openApi3Spec() => {
    'openapi': '3.0.3',
    'info': {
      'title': 'Pets API',
      'description': 'Sample pets service',
      'version': '1.0.0',
    },
    'servers': [
      {'url': 'https://api.test/v1'},
    ],
    'paths': {
      '/pets': {
        'get': {
          'tags': ['Pets'],
          'summary': 'List pets',
          'parameters': [
            {'name': 'limit', 'in': 'query'},
            {'name': 'X-Request-Id', 'in': 'header'},
          ],
        },
        'post': {
          'tags': ['Pets'],
          'summary': 'Create pet',
          'requestBody': {
            'content': {
              'application/json': {
                'schema': {
                  'type': 'object',
                  'properties': {
                    'name': {'type': 'string', 'example': 'Milo'},
                    'species': {'type': 'string', 'example': 'cat'},
                  },
                  'required': ['name'],
                },
              },
            },
          },
        },
      },
      '/pets/{id}': {
        'get': {
          'summary': 'Get pet by id',
          'parameters': [
            {'name': 'id', 'in': 'path'},
          ],
        },
      },
    },
  };

  Map<String, dynamic> swagger2Spec() => {
    'swagger': '2.0',
    'info': {'title': 'Legacy Orders', 'version': '1.0.0'},
    'host': 'legacy.test',
    'basePath': '/v2',
    'schemes': ['https'],
    'paths': {
      '/orders': {
        'post': {
          'summary': 'Create order',
          'parameters': [
            {
              'in': 'body',
              'name': 'body',
              'schema': {
                'type': 'object',
                'properties': {
                  'sku': {'type': 'string', 'example': 'SKU-1'},
                  'qty': {'type': 'integer', 'example': 2},
                },
              },
            },
          ],
        },
      },
    },
  };

  group('OpenApiService.importFromJson', () {
    test(
      'creates root, tag folders, params, body, and path variables',
      () async {
        await service.importFromJson(openApi3Spec(), null, db);

        final root = await db.findCollectionByName('Pets API', null);
        expect(root, isNotNull);

        final petsFolder = await db.findCollectionByName('Pets', root!.id);
        expect(petsFolder, isNotNull);

        final listPets = await db.findRequestInCollection(
          collectionId: petsFolder!.id,
          method: 'GET',
          url: 'https://api.test/v1/pets',
        );
        expect(listPets?.name, 'List pets');
        final params = jsonDecode(listPets!.paramsJson!) as List;
        expect(params.map((p) => p['key']), contains('limit'));
        final headers = jsonDecode(listPets.headersJson!) as List;
        expect(headers.map((h) => h['key']), contains('X-Request-Id'));

        final createPet = await db.findRequestInCollection(
          collectionId: petsFolder.id,
          method: 'POST',
          url: 'https://api.test/v1/pets',
        );
        expect(createPet?.body, isNotNull);
        expect(createPet?.schemaJson, isNotNull);
        final body = jsonDecode(createPet!.body!) as Map<String, dynamic>;
        expect(body['name'], 'Milo');

        final getById = await db.findRequestInCollection(
          collectionId: root.id,
          method: 'GET',
          url: 'https://api.test/v1/pets/{{id}}',
        );
        expect(getById?.name, 'Get pet by id');
      },
    );

    test('imports swagger 2 host/basePath and body parameters', () async {
      await service.importFromJson(swagger2Spec(), null, db);

      final root = await db.findCollectionByName('Legacy Orders', null);
      expect(root, isNotNull);

      final createOrder = await db.findRequestInCollection(
        collectionId: root!.id,
        method: 'POST',
        url: 'https://legacy.test/v2/orders',
      );
      expect(createOrder?.name, 'Create order');
      expect(createOrder?.body, isNotNull);
      expect(createOrder?.schemaJson, isNotNull);

      final body = jsonDecode(createOrder!.body!) as Map<String, dynamic>;
      expect(body['sku'], 'SKU-1');
      expect(body['qty'], 2);
    });

    test('merges existing requests by method and url', () async {
      await service.importFromJson(openApi3Spec(), null, db);
      final root = await db.findCollectionByName('Pets API', null);
      final petsFolder = await db.findCollectionByName('Pets', root!.id);
      final original = await db.findRequestInCollection(
        collectionId: petsFolder!.id,
        method: 'GET',
        url: 'https://api.test/v1/pets',
      );

      final updated = openApi3Spec();
      ((updated['paths'] as Map)['/pets'] as Map)['get'] = {
        'tags': ['Pets'],
        'summary': 'List pets v2',
      };

      await service.importFromJson(updated, null, db);

      final merged = await db.findRequestInCollection(
        collectionId: petsFolder.id,
        method: 'GET',
        url: 'https://api.test/v1/pets',
      );
      expect(merged?.id, original?.id);
      expect(merged?.name, 'List pets v2');
    });

    test(
      'imports into targetCollectionId without creating a new root',
      () async {
        final targetId = await db.createCollection(name: 'Target');

        await service.importFromJson(
          openApi3Spec(),
          null,
          db,
          targetCollectionId: targetId,
        );

        final roots = await db.watchRootCollections().first;
        expect(roots, hasLength(1));
        expect(roots.single.id, targetId);

        final petsFolder = await db.findCollectionByName('Pets', targetId);
        expect(petsFolder, isNotNull);
      },
    );
  });

  group('OpenApiService.importFromUrl', () {
    test('fetches spec with Dio and imports collections', () async {
      const url = 'https://example.test/openapi.json';
      adapter.onGet(
        url,
        (server) => server.reply(200, openApi3Spec()),
        data: null,
      );

      await service.importFromUrl(url, null, db);

      final root = await db.findCollectionByName('Pets API', null);
      expect(root, isNotNull);

      final petsFolder = await db.findCollectionByName('Pets', root!.id);
      expect(petsFolder, isNotNull);
    });

    test('wraps network failures in a friendly exception', () async {
      const url = 'https://example.test/missing.json';
      adapter.onGet(
        url,
        (server) => server.reply(404, {'error': 'not found'}),
        data: null,
      );

      expect(
        () => service.importFromUrl(url, null, db),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when url returns non-object json', () async {
      const url = 'https://example.test/list.json';
      adapter.onGet(url, (server) => server.reply(200, []));

      expect(
        () => service.importFromUrl(url, null, db),
        throwsA(isA<Exception>()),
      );
    });
  });
}
