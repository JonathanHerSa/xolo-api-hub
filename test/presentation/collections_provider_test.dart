import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/presentation/providers/collections_provider.dart';

import '../helpers/test_providers.dart';

void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
  });

  tearDown(() {
    harness.dispose();
  });

  test('rootCollectionsProvider emits root collections', () async {
    await harness.repo.createCollection(name: 'Alpha');
    harness.container.listen(rootCollectionsProvider, (_, _) {});

    final roots = await harness.container.read(rootCollectionsProvider.future);
    expect(roots, hasLength(1));
    expect(roots.first.name, 'Alpha');
  });

  test('subCollectionsProvider emits children', () async {
    final parentId = await harness.repo.createCollection(name: 'Parent');
    await harness.repo.createCollection(name: 'Child', parentId: parentId);
    harness.container.listen(subCollectionsProvider(parentId), (_, _) {});

    final subs = await harness.container.read(
      subCollectionsProvider(parentId).future,
    );
    expect(subs.single.name, 'Child');
  });

  test('flattenedCollectionsStreamProvider sorts and nests by depth', () async {
    final rootId = await harness.repo.createCollection(name: 'Zeta');
    final root2Id = await harness.repo.createCollection(name: 'Alpha');
    final childId = await harness.repo.createCollection(
      name: 'Nested',
      parentId: root2Id,
    );
    harness.container.listen(flattenedCollectionsStreamProvider, (_, _) {});

    final flat = await harness.container.read(
      flattenedCollectionsStreamProvider.future,
    );

    expect(
      flat.map((e) => e.collection.id),
      containsAll([rootId, root2Id, childId]),
    );
    final nested = flat.firstWhere((e) => e.collection.id == childId);
    expect(nested.depth, 1);
    expect(flat.first.collection.name, 'Alpha');
  });

  test('collectionRequestsProvider and unclassifiedRequestsProvider', () async {
    final collectionId = await harness.repo.createCollection(name: 'C');
    await harness.repo.createRequest(
      name: 'In',
      method: 'GET',
      url: 'https://in.test',
      collectionId: collectionId,
    );
    await harness.repo.createRequest(
      name: 'Out',
      method: 'GET',
      url: 'https://out.test',
    );

    harness.container.listen(
      collectionRequestsProvider(collectionId),
      (_, _) {},
    );
    harness.container.listen(unclassifiedRequestsProvider, (_, _) {});

    final inCollection = await harness.container.read(
      collectionRequestsProvider(collectionId).future,
    );
    final unclassified = await harness.container.read(
      unclassifiedRequestsProvider.future,
    );

    expect(inCollection.single.name, 'In');
    expect(unclassified.single.name, 'Out');
  });

  test('collectionBreadcrumbsProvider returns path', () async {
    final rootId = await harness.repo.createCollection(name: 'Root');
    final childId = await harness.repo.createCollection(
      name: 'Child',
      parentId: rootId,
    );

    final path = await harness.container.read(
      collectionBreadcrumbsProvider(childId).future,
    );
    expect(path.map((c) => c.name), ['Root', 'Child']);
  });
}
