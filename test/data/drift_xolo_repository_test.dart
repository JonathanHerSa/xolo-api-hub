import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/repositories/drift_xolo_repository.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/env_variable_entity.dart';
import 'package:xolo/domain/entities/environment_entity.dart';
import 'package:xolo/domain/entities/history_entry_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';

void main() {
  late AppDatabase db;
  late DriftXoloRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = DriftXoloRepository(db);
  });

  tearDown(() {
    db.close();
  });

  group('DriftXoloRepository settings', () {
    test('setSetting, getSetting, watchSetting delegate to db', () async {
      await expectLater(repo.watchSetting('locale'), emits(isNull));

      await repo.setSetting('locale', 'es');
      expect(await repo.getSetting('locale'), 'es');

      await expectLater(repo.watchSetting('locale'), emits('es'));
    });
  });

  group('DriftXoloRepository collections', () {
    test('watch and CRUD methods map CollectionEntity', () async {
      await expectLater(
        repo.watchRootCollections(),
        emits(isA<List<CollectionEntity>>()),
      );

      final id = await repo.createCollection(
        name: 'Workspace',
        description: 'Root',
        authType: 'bearer',
        authData: '{"token":"x"}',
      );

      final roots = await repo.watchRootCollections().first;
      expect(roots.single.name, 'Workspace');
      expect(roots.single, isA<CollectionEntity>());

      final plain = await repo.getCollectionsWithPlainAuthData();
      expect(plain, hasLength(1));
      expect(plain.first.authData, '{"token":"x"}');

      expect(
        await repo.updateCollection(
          id,
          'Updated',
          'Desc',
          authType: 'inherit',
          authData: '{"token":"x"}',
        ),
        isTrue,
      );

      await repo.updateCollectionAuthDataById(id, '{"token":"y"}');
      final found = await repo.findCollectionByName('Updated', null);
      expect(found?.authData, '{"token":"y"}');

      final childId = await repo.createCollection(name: 'Child', parentId: id);
      final path = await repo.getCollectionPath(childId);
      expect(path.map((c) => c.name), ['Updated', 'Child']);

      expect(await repo.moveCollection(childId, null), isTrue);
      final moved = await repo.findCollectionByName('Child', null);
      expect(moved?.parentId, isNull);

      await repo.deleteCollection(id);
      final remaining = await repo.watchAllCollections().first;
      expect(remaining, hasLength(1));
      expect(remaining.single.name, 'Child');

      await repo.deleteCollection(childId);
      expect(await repo.watchAllCollections().first, isEmpty);
    });
  });

  group('DriftXoloRepository requests', () {
    test('request streams and mutations map SavedRequestEntity', () async {
      final collectionId = await repo.createCollection(name: 'Reqs');

      await expectLater(
        repo.watchSavedRequests(),
        emits(isA<List<SavedRequestEntity>>()),
      );
      await expectLater(
        repo.watchRequestsInCollection(collectionId),
        emits(isA<List<SavedRequestEntity>>()),
      );
      await expectLater(
        repo.watchUnclassifiedRequests(),
        emits(isA<List<SavedRequestEntity>>()),
      );

      final reqId = await repo.createRequest(
        name: 'Ping',
        method: 'GET',
        url: 'https://api.test/ping',
        collectionId: collectionId,
      );

      final found = await repo.findRequestInCollection(
        collectionId: collectionId,
        method: 'GET',
        url: 'https://api.test/ping',
      );
      expect(found?.id, reqId);
      expect(found, isA<SavedRequestEntity>());

      await repo.updateRequestContent(
        id: reqId,
        name: 'Ping updated',
        body: '{}',
      );

      expect(await repo.moveRequest(reqId, null), isTrue);
      expect(await repo.softDeleteRequest(reqId), isTrue);
      expect(await repo.restoreRequest(reqId), isTrue);
    });
  });

  group('DriftXoloRepository history', () {
    test('history methods map HistoryEntryEntity', () async {
      final workspaceId = await repo.createCollection(name: 'WS');

      await expectLater(
        repo.watchRecentHistory(workspaceId),
        emits(isA<List<HistoryEntryEntity>>()),
      );

      final id = await repo.addHistoryItem(
        method: 'GET',
        url: 'https://api.test/h',
        originalUrl: 'https://api.test/{{h}}',
        statusCode: 200,
        durationMs: 15,
        workspaceId: workspaceId,
      );

      final entry = await repo.getHistoryById(id);
      expect(entry, isA<HistoryEntryEntity>());
      expect(entry?.originalUrl, 'https://api.test/{{h}}');

      await repo.deleteHistoryEntry(entry!);
      expect(await repo.getHistoryById(id), isNull);

      final restoredId = await repo.restoreHistoryEntry(entry);
      expect(restoredId, greaterThan(0));
      expect(await repo.getHistoryById(restoredId), isNotNull);

      expect(await repo.clearHistory(workspaceId), 1);

      await repo.addHistoryItem(
        method: 'POST',
        url: 'https://api.test/x',
        workspaceId: workspaceId,
      );
      await repo.clearAllHistory();
      expect(await repo.watchRecentHistory(workspaceId).first, isEmpty);
    });
  });

  group('DriftXoloRepository environments', () {
    test('environment and variable streams map entities', () async {
      final workspaceId = await repo.createCollection(name: 'WS');
      final envId = await repo.createEnvironment('Dev', workspaceId);

      await expectLater(
        repo.watchEnvironments(workspaceId),
        emits(isA<List<EnvironmentEntity>>()),
      );
      await expectLater(
        repo.watchActiveEnvironmentId(workspaceId),
        emits(isA<int?>()),
      );
      await expectLater(
        repo.watchResolvedVariables(workspaceId, envId),
        emits(isA<List<EnvVariableEntity>>()),
      );
      await expectLater(
        repo.watchVariables(workspaceId, envId),
        emits(isA<List<EnvVariableEntity>>()),
      );

      await repo.setActiveEnvironment(envId, workspaceId);
      expect(await repo.watchActiveEnvironmentId(workspaceId).first, envId);

      final varId = await repo.upsertVariable(
        key: 'token',
        value: 'abc',
        environmentId: envId,
        workspaceId: workspaceId,
      );
      expect(varId, greaterThan(0));

      final vars = await repo.watchVariables(workspaceId, envId).first;
      expect(vars.single, isA<EnvVariableEntity>());

      expect(await repo.deleteEnvironment(envId), 1);
      expect(await repo.deleteVariable(varId), 0);
    });
  });

  group('DriftXoloRepository wipeAllLocalData', () {
    test('removes all tables', () async {
      final collectionId = await repo.createCollection(name: 'WS');
      await repo.createRequest(
        name: 'Req',
        method: 'GET',
        url: 'https://api.test',
        collectionId: collectionId,
      );
      await repo.createEnvironment('Dev', collectionId);
      await repo.upsertVariable(
        key: 'k',
        value: 'v',
        workspaceId: collectionId,
      );
      await repo.addHistoryItem(
        method: 'GET',
        url: 'https://api.test',
        workspaceId: collectionId,
      );
      await repo.setSetting('theme', 'dark');

      await repo.wipeAllLocalData();

      expect(await repo.watchAllCollections().first, isEmpty);
      expect(await repo.watchSavedRequests().first, isEmpty);
      expect(await repo.watchEnvironments(collectionId).first, isEmpty);
      expect(await repo.watchRecentHistory(collectionId).first, isEmpty);
      expect(await repo.getSetting('theme'), isNull);
    });
  });
}
