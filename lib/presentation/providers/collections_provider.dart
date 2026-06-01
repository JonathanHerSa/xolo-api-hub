import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/domain/repositories/xolo_repository.dart';
import 'package:xolo/presentation/providers/database_providers.dart';

class FlattenedCollection {
  final CollectionEntity collection;
  final int depth;
  FlattenedCollection(this.collection, this.depth);
}

final rootCollectionsProvider = StreamProvider<List<CollectionEntity>>((ref) {
  final repo = ref.watch(xoloRepositoryProvider);
  return repo.watchRootCollections();
});

final subCollectionsProvider =
    StreamProvider.family<List<CollectionEntity>, int>((ref, parentId) {
      final repo = ref.watch(xoloRepositoryProvider);
      return repo.watchSubCollections(parentId);
    });

final flattenedCollectionsStreamProvider =
    StreamProvider<List<FlattenedCollection>>((ref) {
      final repo = ref.watch(xoloRepositoryProvider);

      return repo.watchAllCollections().map((all) {
        all.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

        final childrenMap = <int, List<CollectionEntity>>{};
        for (final c in all) {
          if (c.parentId != null) {
            childrenMap.putIfAbsent(c.parentId!, () => []).add(c);
          }
        }

        final flattened = <FlattenedCollection>[];

        void traverse(CollectionEntity c, int depth) {
          flattened.add(FlattenedCollection(c, depth));
          final children = childrenMap[c.id] ?? [];
          for (final child in children) {
            traverse(child, depth + 1);
          }
        }

        final roots = all.where((c) => c.parentId == null);
        for (final r in roots) {
          traverse(r, 0);
        }

        return flattened;
      });
    });

final collectionRequestsProvider =
    StreamProvider.family<List<SavedRequestEntity>, int>((ref, collectionId) {
      final repo = ref.watch(xoloRepositoryProvider);
      return repo.watchRequestsInCollection(collectionId);
    });

final unclassifiedRequestsProvider = StreamProvider<List<SavedRequestEntity>>((
  ref,
) {
  final repo = ref.watch(xoloRepositoryProvider);
  return repo.watchUnclassifiedRequests();
});

final collectionBreadcrumbsProvider =
    FutureProvider.family<List<CollectionEntity>, int>((ref, collectionId) {
      final repo = ref.watch(xoloRepositoryProvider);
      return repo.getCollectionPath(collectionId);
    });

class CollectionsController extends Notifier<void> {
  XoloRepository get _repo => ref.read(xoloRepositoryProvider);

  @override
  void build() {}

  Future<void> createCollection({
    required String name,
    String? description,
    int? parentId,
  }) async {
    if (name.trim().isEmpty) return;

    final newId = await _repo.createCollection(
      name: name.trim(),
      description: description,
      parentId: parentId,
    );

    if (parentId == null) {
      await _createDefaultEnvironments(newId);
    }
  }

  Future<void> _createDefaultEnvironments(int workspaceId) async {
    final envs = ['Development', 'Staging', 'Production'];
    for (final envName in envs) {
      final envId = await _repo.createEnvironment(envName, workspaceId);
      await _repo.upsertVariable(
        key: 'baseUrl',
        value: 'https://${envName.toLowerCase()}.api.example.com',
        environmentId: envId,
        workspaceId: workspaceId,
      );

      if (envName == 'Development') {
        await _repo.setActiveEnvironment(envId, workspaceId);
      }
    }
  }

  Future<void> renameCollection(
    int id,
    String name,
    String? description,
  ) async {
    if (name.trim().isEmpty) return;
    await _repo.updateCollection(id, name.trim(), description);
  }

  Future<void> deleteCollection(int id) async {
    await _repo.deleteCollection(id);
  }

  Future<void> moveRequestToCollection(int requestId, int? collectionId) async {
    await _repo.moveRequest(requestId, collectionId);
  }
}

final collectionsControllerProvider =
    NotifierProvider<CollectionsController, void>(CollectionsController.new);
