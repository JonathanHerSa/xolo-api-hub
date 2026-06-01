import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/data/local/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() {
    db.close();
  });

  group('CollectionQueries', () {
    test(
      'watchRootCollections emits root collections ordered by name',
      () async {
        await expectLater(
          db.watchRootCollections(),
          emits(isA<List<Collection>>()),
        );

        final alphaId = await db.createCollection(name: 'Alpha');
        final betaId = await db.createCollection(name: 'Beta');
        await db.createCollection(name: 'Nested', parentId: alphaId);

        final roots = await db.watchRootCollections().first;
        expect(roots.map((c) => c.name), ['Alpha', 'Beta']);
        expect(roots.map((c) => c.id), containsAll([alphaId, betaId]));
      },
    );

    test('watchSubCollections emits children of parent', () async {
      final parentId = await db.createCollection(name: 'Parent');
      await db.createCollection(name: 'Child B', parentId: parentId);
      await db.createCollection(name: 'Child A', parentId: parentId);

      await expectLater(
        db.watchSubCollections(parentId),
        emits(isA<List<Collection>>()),
      );

      final children = await db.watchSubCollections(parentId).first;
      expect(children.map((c) => c.name), ['Child A', 'Child B']);
    });

    test('watchAllCollections emits every collection', () async {
      await db.createCollection(name: 'Root');
      await db.createCollection(name: 'Other');

      await expectLater(
        db.watchAllCollections(),
        emits(isA<List<Collection>>()),
      );

      final all = await db.watchAllCollections().first;
      expect(all, hasLength(2));
    });

    test('createCollection and updateCollection CRUD', () async {
      final id = await db.createCollection(
        name: 'Workspace',
        description: 'Desc',
        authType: 'bearer',
        authData: '{"token":"x"}',
      );

      final created = await (db.select(
        db.collections,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(created.name, 'Workspace');
      expect(created.description, 'Desc');
      expect(created.authType, 'bearer');

      final updated = await db.updateCollection(
        id,
        'Renamed',
        'New desc',
        authType: 'api_key',
        authData: '{"key":"k"}',
      );
      expect(updated, isTrue);

      final row = await (db.select(
        db.collections,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(row.name, 'Renamed');
      expect(row.authType, 'api_key');
    });

    test('getCollectionsWithPlainAuthData filters secure refs', () async {
      await db.createCollection(name: 'Plain', authData: '{"token":"plain"}');
      await db.createCollection(
        name: 'Secure',
        authData: 'secure_auth_ref:abc',
      );
      await db.createCollection(name: 'Empty', authData: '');

      final plain = await db.getCollectionsWithPlainAuthData();
      expect(plain, hasLength(1));
      expect(plain.first.name, 'Plain');
    });

    test('updateCollectionAuthDataById updates auth payload', () async {
      final id = await db.createCollection(name: 'Auth');
      await db.updateCollectionAuthDataById(id, '{"token":"new"}');

      final row = await (db.select(
        db.collections,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(row.authData, '{"token":"new"}');
    });

    test(
      'deleteCollection recursively removes tree and soft-deletes requests',
      () async {
        final rootId = await db.createCollection(name: 'Root');
        final childId = await db.createCollection(
          name: 'Child',
          parentId: rootId,
        );
        final reqId = await db.createRequest(
          name: 'Req',
          method: 'GET',
          url: 'https://api.test',
          collectionId: childId,
        );
        await db.createEnvironment('Dev', rootId);

        await db.deleteCollection(rootId);

        expect(await db.select(db.collections).get(), isEmpty);
        expect(await db.select(db.environments).get(), isEmpty);

        final req = await (db.select(
          db.savedRequests,
        )..where((t) => t.id.equals(reqId))).getSingle();
        expect(req.isDeleted, isTrue);
        expect(req.collectionId, isNull);
      },
    );

    test('moveRequest and moveCollection relocate entities', () async {
      final sourceId = await db.createCollection(name: 'Source');
      final targetId = await db.createCollection(name: 'Target');
      final reqId = await db.createRequest(
        name: 'Move me',
        method: 'GET',
        url: 'https://api.test/move',
        collectionId: sourceId,
      );

      expect(await db.moveRequest(reqId, targetId), isTrue);
      final movedReq = await (db.select(
        db.savedRequests,
      )..where((t) => t.id.equals(reqId))).getSingle();
      expect(movedReq.collectionId, targetId);

      final folderId = await db.createCollection(
        name: 'Folder',
        parentId: sourceId,
      );
      expect(await db.moveCollection(folderId, targetId), isTrue);
      expect(await db.moveCollection(folderId, folderId), isFalse);

      final folder = await (db.select(
        db.collections,
      )..where((t) => t.id.equals(folderId))).getSingle();
      expect(folder.parentId, targetId);
    });

    test('getCollectionPath returns ancestors root-to-leaf', () async {
      final rootId = await db.createCollection(name: 'Root');
      final midId = await db.createCollection(name: 'Mid', parentId: rootId);
      final leafId = await db.createCollection(name: 'Leaf', parentId: midId);

      final path = await db.getCollectionPath(leafId);
      expect(path.map((c) => c.name), ['Root', 'Mid', 'Leaf']);
    });

    test('findCollectionByName respects parent scope', () async {
      final rootId = await db.createCollection(name: 'Shared');
      await db.createCollection(name: 'Shared', parentId: rootId);

      final rootMatch = await db.findCollectionByName('Shared', null);
      final childMatch = await db.findCollectionByName('Shared', rootId);

      expect(rootMatch?.id, rootId);
      expect(childMatch?.parentId, rootId);
    });

    test('request CRUD, soft delete, restore, and watch streams', () async {
      final collectionId = await db.createCollection(name: 'Requests');

      await expectLater(
        db.watchSavedRequests(),
        emits(isA<List<SavedRequest>>()),
      );
      await expectLater(
        db.watchRequestsInCollection(collectionId),
        emits(isA<List<SavedRequest>>()),
      );
      await expectLater(
        db.watchUnclassifiedRequests(),
        emits(isA<List<SavedRequest>>()),
      );

      final reqId = await db.createRequest(
        name: 'Ping',
        method: 'GET',
        url: 'https://api.test/ping',
        headersJson: '[{"key":"Accept","value":"json"}]',
        paramsJson: '[{"key":"q","value":"1"}]',
        body: '{}',
        collectionId: collectionId,
        schemaJson: '{"type":"object"}',
      );

      final unclassifiedId = await db.createRequest(
        name: 'Loose',
        method: 'POST',
        url: 'https://api.test/loose',
      );

      final inCollection = await db
          .watchRequestsInCollection(collectionId)
          .first;
      expect(inCollection, hasLength(1));
      expect(inCollection.first.id, reqId);

      final unclassified = await db.watchUnclassifiedRequests().first;
      expect(unclassified.map((r) => r.id), contains(unclassifiedId));

      expect(await db.softDeleteRequest(reqId), isTrue);
      final deleted = await (db.select(
        db.savedRequests,
      )..where((t) => t.id.equals(reqId))).getSingle();
      expect(deleted.isDeleted, isTrue);

      expect(await db.restoreRequest(reqId), isTrue);
      final restored = await (db.select(
        db.savedRequests,
      )..where((t) => t.id.equals(reqId))).getSingle();
      expect(restored.isDeleted, isFalse);
    });

    test(
      'findRequestInCollection and updateRequestContent merge fields',
      () async {
        final collectionId = await db.createCollection(name: 'Merge');
        final reqId = await db.createRequest(
          name: 'Old',
          method: 'POST',
          url: 'https://api.test/items',
          collectionId: collectionId,
        );

        final found = await db.findRequestInCollection(
          collectionId: collectionId,
          method: 'POST',
          url: 'https://api.test/items',
        );
        expect(found?.id, reqId);

        await db.updateRequestContent(
          id: reqId,
          name: 'Updated',
          headersJson: '[]',
          paramsJson: '[]',
          body: '{"ok":true}',
          schemaJson: '{"type":"object"}',
        );

        final updated = await (db.select(
          db.savedRequests,
        )..where((t) => t.id.equals(reqId))).getSingle();
        expect(updated.name, 'Updated');
        expect(updated.body, '{"ok":true}');
        expect(updated.schemaJson, '{"type":"object"}');
      },
    );
  });

  group('EnvironmentQueries', () {
    test(
      'watchEnvironments and createEnvironment scope by workspace',
      () async {
        final workspaceId = await db.createCollection(name: 'WS');
        await db.createEnvironment('Global', null);
        await db.createEnvironment('Scoped', workspaceId);

        await expectLater(
          db.watchEnvironments(workspaceId),
          emits(isA<List<Environment>>()),
        );
        await expectLater(
          db.watchEnvironments(null),
          emits(isA<List<Environment>>()),
        );

        final scoped = await db.watchEnvironments(workspaceId).first;
        expect(scoped, hasLength(1));
        expect(scoped.first.name, 'Scoped');

        final global = await db.watchEnvironments(null).first;
        expect(global, hasLength(1));
        expect(global.first.name, 'Global');
      },
    );

    test('setActiveEnvironment activates one env per workspace', () async {
      final workspaceId = await db.createCollection(name: 'WS');
      final envA = await db.createEnvironment('A', workspaceId);
      final envB = await db.createEnvironment('B', workspaceId);

      await expectLater(
        db.watchActiveEnvironmentId(workspaceId),
        emits(isA<int?>()),
      );

      await db.setActiveEnvironment(envA, workspaceId);
      expect(await db.watchActiveEnvironmentId(workspaceId).first, envA);

      await db.setActiveEnvironment(envB, workspaceId);
      final envs = await db.watchEnvironments(workspaceId).first;
      expect(envs.singleWhere((e) => e.id == envB).isActive, isTrue);
      expect(envs.singleWhere((e) => e.id == envA).isActive, isFalse);

      await db.setActiveEnvironment(null, workspaceId);
      expect(
        envs.every((e) => !e.isActive) ||
            (await db.watchEnvironments(workspaceId).first).every(
              (e) => !e.isActive,
            ),
        isTrue,
      );
    });

    test('deleteEnvironment removes variables', () async {
      final envId = await db.createEnvironment('Temp', null);
      await db.upsertVariable(key: 'token', value: 'abc', environmentId: envId);

      expect(await db.deleteEnvironment(envId), 1);
      expect(await db.select(db.environments).get(), isEmpty);
      expect(await db.select(db.envVariables).get(), isEmpty);
    });

    test(
      'watchResolvedVariables merges env, workspace, and global scopes',
      () async {
        final workspaceId = await db.createCollection(name: 'WS');
        final envId = await db.createEnvironment('Dev', workspaceId);
        await db.setActiveEnvironment(envId, workspaceId);

        await db.upsertVariable(
          key: 'envVar',
          value: '1',
          environmentId: envId,
        );
        await db.upsertVariable(
          key: 'wsVar',
          value: '2',
          workspaceId: workspaceId,
        );
        await db.upsertVariable(key: 'globalVar', value: '3');

        await expectLater(
          db.watchResolvedVariables(workspaceId, envId),
          emits(isA<List<EnvVariable>>()),
        );

        final resolved = await db
            .watchResolvedVariables(workspaceId, envId)
            .first;
        expect(resolved.map((v) => v.key), containsAll(['envVar', 'wsVar']));

        final globalResolved = await db
            .watchResolvedVariables(null, null)
            .first;
        expect(globalResolved.map((v) => v.key), contains('globalVar'));
      },
    );

    test('watchVariables, upsertVariable, and deleteVariable CRUD', () async {
      final workspaceId = await db.createCollection(name: 'WS');
      final envId = await db.createEnvironment('Dev', workspaceId);

      await expectLater(
        db.watchVariables(workspaceId, envId),
        emits(isA<List<EnvVariable>>()),
      );

      final insertedId = await db.upsertVariable(
        key: 'baseUrl',
        value: 'https://api.test',
        environmentId: envId,
        workspaceId: workspaceId,
      );

      await db.upsertVariable(
        id: insertedId,
        key: 'baseUrl',
        value: 'https://api.updated',
        environmentId: envId,
        workspaceId: workspaceId,
      );

      final vars = await db.watchVariables(workspaceId, envId).first;
      expect(vars.single.value, 'https://api.updated');

      expect(await db.deleteVariable(insertedId), 1);
      expect(await db.watchVariables(workspaceId, envId).first, isEmpty);
    });
  });

  group('HistoryQueries', () {
    test('insertHistory, addHistoryItem, and watchRecentHistory', () async {
      final workspaceId = await db.createCollection(name: 'WS');

      await expectLater(
        db.watchRecentHistory(workspaceId),
        emits(isA<List<HistoryEntry>>()),
      );

      final historyId = await db.insertHistory(
        method: 'GET',
        url: 'https://api.test/a',
        originalUrl: 'https://api.test/{{a}}',
        statusCode: 200,
        durationMs: 10,
        workspaceId: workspaceId,
      );

      await db.addHistoryItem(
        method: 'POST',
        url: 'https://api.test/b',
        statusCode: 201,
        durationMs: 20,
        workspaceId: workspaceId,
      );

      final history = await db.watchRecentHistory(workspaceId).first;
      expect(history, hasLength(2));
      expect(
        history.map((h) => h.url),
        containsAll(['https://api.test/a', 'https://api.test/b']),
      );

      final entry = await db.getHistoryById(historyId);
      expect(entry?.originalUrl, 'https://api.test/{{a}}');
    });

    test('clearHistory and deleteHistoryOlderThan prune entries', () async {
      final workspaceId = await db.createCollection(name: 'WS');
      final otherId = await db.createCollection(name: 'Other');

      await db.insertHistory(
        method: 'GET',
        url: 'scoped-a',
        workspaceId: workspaceId,
      );
      await db.insertHistory(
        method: 'GET',
        url: 'scoped-b',
        workspaceId: workspaceId,
      );
      await db.insertHistory(method: 'GET', url: 'global');

      expect(await db.clearHistory(workspaceId), 2);
      expect(await db.clearHistory(null), 1);
      expect(await db.select(db.historyEntries).get(), isEmpty);

      await db.insertHistory(
        method: 'GET',
        url: 'stale',
        workspaceId: workspaceId,
      );
      await db.insertHistory(method: 'GET', url: 'fresh', workspaceId: otherId);

      final pastCutoff = DateTime.now().subtract(const Duration(days: 1));
      expect(await db.deleteHistoryOlderThan(pastCutoff), 0);

      final futureCutoff = DateTime.now().add(const Duration(days: 1));
      expect(await db.deleteHistoryOlderThan(futureCutoff), 2);
      expect(await db.select(db.historyEntries).get(), isEmpty);
    });
  });

  group('SettingsQueries', () {
    test('setSetting, getSetting, and watchSetting', () async {
      await expectLater(db.watchSetting('theme'), emits(isNull));

      await db.setSetting('theme', 'dark');
      expect(await db.getSetting('theme'), 'dark');

      await expectLater(db.watchSetting('theme'), emits('dark'));

      await db.setSetting('theme', 'light');
      expect(await db.getSetting('theme'), 'light');
    });
  });
}
