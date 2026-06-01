import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/repositories/drift_xolo_repository.dart';
import 'package:xolo/presentation/providers/collections_provider.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/environment_provider.dart';
import 'package:xolo/presentation/providers/incognito_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

import '../helpers/test_providers.dart';

class _PinnedWorkspaceNotifier extends WorkspaceNotifier {
  _PinnedWorkspaceNotifier(this.workspaceId);

  final int workspaceId;

  @override
  int? build() => workspaceId;
}

void main() {
  group('CollectionsController', () {
    late TestHarness harness;

    setUp(() {
      harness = TestHarness.create();
    });

    tearDown(() {
      harness.dispose();
    });

    test('createCollection with root creates default environments', () async {
      final controller = harness.container.read(
        collectionsControllerProvider.notifier,
      );

      await controller.createCollection(name: '  My Workspace  ');

      final roots = await harness.repo.watchRootCollections().first;
      expect(roots, hasLength(1));
      expect(roots.first.name, 'My Workspace');

      final envs = await harness.repo.watchEnvironments(roots.first.id).first;
      expect(
        envs.map((e) => e.name),
        containsAll(['Development', 'Staging', 'Production']),
      );

      final activeId = await harness.repo
          .watchActiveEnvironmentId(roots.first.id)
          .first;
      expect(activeId, isNotNull);

      final vars = await harness.repo
          .watchResolvedVariables(roots.first.id, activeId)
          .first;
      expect(vars.any((v) => v.key == 'baseUrl'), isTrue);
    });

    test('createCollection ignores blank name', () async {
      final controller = harness.container.read(
        collectionsControllerProvider.notifier,
      );
      await controller.createCollection(name: '   ');
      final roots = await harness.repo.watchRootCollections().first;
      expect(roots, isEmpty);
    });

    test('renameCollection updates name and skips blank', () async {
      final id = await harness.repo.createCollection(name: 'Old');
      final controller = harness.container.read(
        collectionsControllerProvider.notifier,
      );

      await controller.renameCollection(id, '  New Name  ', 'desc');
      final updated = (await harness.repo.watchRootCollections().first).first;
      expect(updated.name, 'New Name');
      expect(updated.description, 'desc');

      await controller.renameCollection(id, '  ', null);
      expect(
        (await harness.repo.watchRootCollections().first).first.name,
        'New Name',
      );
    });

    test('deleteCollection removes collection', () async {
      final id = await harness.repo.createCollection(name: 'ToDelete');
      final controller = harness.container.read(
        collectionsControllerProvider.notifier,
      );

      await controller.deleteCollection(id);
      expect(await harness.repo.watchRootCollections().first, isEmpty);
    });

    test('moveRequestToCollection updates request collection', () async {
      final collectionId = await harness.repo.createCollection(name: 'Target');
      final requestId = await harness.repo.createRequest(
        name: 'Req',
        method: 'GET',
        url: 'https://api.test',
      );

      final controller = harness.container.read(
        collectionsControllerProvider.notifier,
      );
      await controller.moveRequestToCollection(requestId, collectionId);

      final inCollection = await harness.repo
          .watchRequestsInCollection(collectionId)
          .first;
      expect(inCollection.single.id, requestId);
    });
  });

  group('resolvedVariablesProvider', () {
    test('returns empty map while environment stream is loading', () {
      final harness = TestHarness.create();
      addTearDown(harness.dispose);

      expect(harness.container.read(resolvedVariablesProvider), isEmpty);
    });

    test('merges global and environment-specific variables', () async {
      final db = AppDatabase.memory();
      final repo = DriftXoloRepository(db);
      final workspaceId = await repo.createCollection(name: 'WS');
      final envId = await repo.createEnvironment('Dev', workspaceId);
      await repo.setActiveEnvironment(envId, workspaceId);

      await repo.upsertVariable(
        key: 'globalVar',
        value: 'global-value',
        workspaceId: workspaceId,
      );
      await repo.upsertVariable(
        key: 'envVar',
        value: 'env-value',
        environmentId: envId,
        workspaceId: workspaceId,
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          xoloRepositoryProvider.overrideWithValue(repo),
          activeWorkspaceIdProvider.overrideWith(
            () => _PinnedWorkspaceNotifier(workspaceId),
          ),
        ],
      );
      addTearDown(() {
        container.dispose();
        db.close();
      });

      final envSub = container.listen(activeEnvironmentIdProvider, (_, _) {});
      final varsSub = container.listen(resolvedVariablesProvider, (_, _) {});
      addTearDown(envSub.close);
      addTearDown(varsSub.close);

      expect(
        await repo.watchResolvedVariables(workspaceId, envId).first,
        hasLength(2),
      );

      Map<String, String> vars = {};
      for (var i = 0; i < 100; i++) {
        vars = container.read(resolvedVariablesProvider);
        if (vars.containsKey('globalVar')) break;
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      expect(vars['globalVar'], 'global-value');
      expect(vars['envVar'], 'env-value');
    });
  });

  group('WorkspaceNotifier', () {
    test('setWorkspace persists active workspace id', () async {
      final harness = TestHarness.create();
      addTearDown(harness.dispose);

      final workspaceId = await harness.repo.createCollection(
        name: 'Persisted',
      );

      await harness.container
          .read(activeWorkspaceIdProvider.notifier)
          .setWorkspace(workspaceId);

      expect(harness.container.read(activeWorkspaceIdProvider), workspaceId);

      final saved = await harness.repo.getSetting('active_workspace_id');
      expect(saved, workspaceId.toString());

      await harness.container
          .read(activeWorkspaceIdProvider.notifier)
          .setWorkspace(null);
      expect(harness.container.read(activeWorkspaceIdProvider), isNull);
    });

    test('loads saved workspace id on startup', () async {
      final db = AppDatabase.memory();
      final repo = DriftXoloRepository(db);
      final workspaceId = await repo.createCollection(name: 'Saved');
      await repo.setSetting('active_workspace_id', workspaceId.toString());

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          xoloRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(() {
        container.dispose();
        db.close();
      });

      container.listen(activeWorkspaceIdProvider, (_, _) {});

      for (var i = 0; i < 50; i++) {
        if (container.read(activeWorkspaceIdProvider) == workspaceId) break;
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      expect(container.read(activeWorkspaceIdProvider), workspaceId);
    });

    test('activeWorkspaceProvider resolves active collection', () async {
      final harness = TestHarness.create();
      addTearDown(harness.dispose);

      final workspaceId = await harness.repo.createCollection(name: 'Active');
      await harness.container
          .read(activeWorkspaceIdProvider.notifier)
          .setWorkspace(workspaceId);

      harness.container.listen(activeWorkspaceProvider, (_, _) {});

      final active = await harness.container.read(
        activeWorkspaceProvider.future,
      );
      expect(active?.name, 'Active');
    });
  });

  group('environment stream providers', () {
    test(
      'environmentsListProvider and rawVariablesProvider emit data',
      () async {
        final db = AppDatabase.memory();
        final repo = DriftXoloRepository(db);
        final workspaceId = await repo.createCollection(name: 'WS');
        final envId = await repo.createEnvironment('Dev', workspaceId);
        await repo.setActiveEnvironment(envId, workspaceId);
        await repo.upsertVariable(
          key: 'token',
          value: 'abc',
          environmentId: envId,
          workspaceId: workspaceId,
        );

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            xoloRepositoryProvider.overrideWithValue(repo),
            activeWorkspaceIdProvider.overrideWith(
              () => _PinnedWorkspaceNotifier(workspaceId),
            ),
          ],
        );
        addTearDown(() {
          container.dispose();
          db.close();
        });

        container.listen(environmentsListProvider, (_, _) {});
        container.listen(activeEnvironmentIdProvider, (_, _) {});
        container.listen(rawVariablesProvider, (_, _) {});

        final envs = await container.read(environmentsListProvider.future);
        expect(envs.single.name, 'Dev');

        final activeId = await container.read(
          activeEnvironmentIdProvider.future,
        );
        expect(activeId, envId);

        final vars = await container.read(rawVariablesProvider.future);
        expect(vars.single.key, 'token');
      },
    );
  });

  group('database_providers', () {
    test('smoke read with memory database override', () {
      final harness = TestHarness.create();
      addTearDown(harness.dispose);

      expect(harness.container.read(databaseProvider), isNotNull);
      expect(harness.container.read(xoloRepositoryProvider), harness.repo);
      expect(harness.container.read(savedRequestsStreamProvider), isNotNull);
    });
  });

  group('isIncognitoProvider', () {
    test('toggle switches incognito flag', () {
      final harness = fullProviderContainer(AppDatabase.memory());
      addTearDown(harness.dispose);

      expect(harness.read(isIncognitoProvider), isFalse);

      harness.read(isIncognitoProvider.notifier).toggle();
      expect(harness.read(isIncognitoProvider), isTrue);

      harness.read(isIncognitoProvider.notifier).set(false);
      expect(harness.read(isIncognitoProvider), isFalse);
    });
  });
}
