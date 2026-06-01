import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/repositories/drift_xolo_repository.dart';
import 'package:xolo/domain/services/run_plan_builder.dart';

void main() {
  test('RunPlanBuilder orders depth-first', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = DriftXoloRepository(db);

    final rootId = await repo.createCollection(name: 'Root');
    final folderId = await repo.createCollection(name: 'Folder', parentId: rootId);
    await repo.createRequest(
      name: 'RootReq',
      method: 'GET',
      url: 'https://a.test/1',
      collectionId: rootId,
    );
    await repo.createRequest(
      name: 'FolderReq',
      method: 'GET',
      url: 'https://a.test/2',
      collectionId: folderId,
    );

    final plan = await RunPlanBuilder(repo).build(rootId);
    expect(plan.length, 2);
    expect(plan.first.request.name, 'RootReq');
    expect(plan.last.request.name, 'FolderReq');
  });
}
