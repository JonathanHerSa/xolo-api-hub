import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/services/postman_service.dart';

void main() {
  late AppDatabase db;
  late PostmanService service;

  setUp(() {
    db = AppDatabase.memory();
    service = PostmanService();
  });

  tearDown(() {
    db.close();
  });

  Map<String, dynamic> samplePostmanJson() => {
    'info': {
      '_postman_id': 'sample-id',
      'name': 'Sample API',
      'description': 'Imported collection',
    },
    'item': [
      {
        'name': 'Users',
        'description': 'User folder',
        'item': [
          {
            'name': 'List Users',
            'request': {
              'method': 'get',
              'header': [
                {'key': 'Accept', 'value': 'application/json'},
              ],
              'url': 'https://api.test/users',
            },
          },
          {
            'name': 'Create User',
            'request': {
              'method': 'POST',
              'header': [],
              'url': {
                'raw': 'https://api.test/users?page=1',
                'host': ['api', 'test'],
                'path': ['users'],
                'query': [
                  {'key': 'page', 'value': '1'},
                  {'key': 'limit', 'value': '10'},
                ],
              },
              'body': {'mode': 'raw', 'raw': '{"name":"Ada"}'},
            },
          },
          {
            'name': 'Login',
            'request': {
              'method': 'POST',
              'url': 'https://api.test/login',
              'body': {
                'mode': 'urlencoded',
                'urlencoded': [
                  {'key': 'username', 'value': 'ada'},
                  {'key': 'password', 'value': 'secret'},
                ],
              },
            },
          },
        ],
      },
    ],
  };

  group('PostmanService.importFromJson', () {
    test('creates root, folders, and requests from sample export', () async {
      await service.importFromJson(samplePostmanJson(), null, db);

      final root = await db.findCollectionByName('Sample API', null);
      expect(root, isNotNull);

      final folder = await db.findCollectionByName('Users', root!.id);
      expect(folder, isNotNull);

      final listUsers = await db.findRequestInCollection(
        collectionId: folder!.id,
        method: 'GET',
        url: 'https://api.test/users',
      );
      expect(listUsers?.name, 'List Users');
      expect(jsonDecode(listUsers!.headersJson!) as List, isNotEmpty);

      final createUser = await db.findRequestInCollection(
        collectionId: folder.id,
        method: 'POST',
        url: 'https://api.test/users?page=1',
      );
      expect(createUser?.body, '{"name":"Ada"}');
      final params = jsonDecode(createUser!.paramsJson!) as List;
      expect(params.map((p) => p['key']), containsAll(['page', 'limit']));

      final login = await db.findRequestInCollection(
        collectionId: folder.id,
        method: 'POST',
        url: 'https://api.test/login',
      );
      final loginBody = jsonDecode(login!.body!) as Map<String, dynamic>;
      expect(loginBody['username'], 'ada');
      expect(loginBody['password'], 'secret');
    });

    test(
      'imports into targetCollectionId without creating a new root',
      () async {
        final targetId = await db.createCollection(name: 'Existing Root');

        await service.importFromJson(
          samplePostmanJson(),
          null,
          db,
          targetCollectionId: targetId,
        );

        final roots = await db.watchRootCollections().first;
        expect(roots, hasLength(1));
        expect(roots.single.id, targetId);

        final folder = await db.findCollectionByName('Users', targetId);
        expect(folder, isNotNull);
      },
    );

    test(
      'merges into existing folders and updates matching requests',
      () async {
        await service.importFromJson(samplePostmanJson(), null, db);
        final root = await db.findCollectionByName('Sample API', null);
        final folder = await db.findCollectionByName('Users', root!.id);
        final original = await db.findRequestInCollection(
          collectionId: folder!.id,
          method: 'GET',
          url: 'https://api.test/users',
        );

        final updatedJson = samplePostmanJson();
        final usersFolder = (updatedJson['item'] as List).first as Map;
        final listItem = (usersFolder['item'] as List).first as Map;
        listItem['name'] = 'List Users v2';
        (listItem['request'] as Map)['header'] = [
          {'key': 'X-Trace', 'value': '1'},
        ];

        await service.importFromJson(updatedJson, null, db);

        final folders = await db.watchSubCollections(root.id).first;
        expect(folders, hasLength(1));

        final updated = await db.findRequestInCollection(
          collectionId: folder.id,
          method: 'GET',
          url: 'https://api.test/users',
        );
        expect(updated?.id, original?.id);
        expect(updated?.name, 'List Users v2');
        expect(updated?.headersJson, contains('X-Trace'));
      },
    );

    test('reconstructs URL from host and path when raw is missing', () async {
      final json = {
        'info': {'name': 'Host Path API'},
        'item': [
          {
            'name': 'Health',
            'request': {
              'method': 'GET',
              'url': {
                'host': ['api', 'example', 'com'],
                'path': ['v1', 'health'],
              },
            },
          },
        ],
      };

      await service.importFromJson(json, null, db);
      final root = await db.findCollectionByName('Host Path API', null);
      final req = await db.findRequestInCollection(
        collectionId: root!.id,
        method: 'GET',
        url: 'api.example.com/v1/health',
      );
      expect(req, isNotNull);
    });

    test('wraps parsing failures in a friendly exception', () async {
      expect(
        () => service.importFromJson({'item': 'invalid'}, null, db),
        throwsA(isA<Exception>()),
      );
    });
  });
}
