import 'package:xolo/domain/entities/run_plan_item.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/domain/repositories/xolo_repository.dart';

/// Builds an ordered execution plan from a collection tree (depth-first).
class RunPlanBuilder {
  RunPlanBuilder(this._repo);

  final XoloRepository _repo;

  Future<List<RunPlanItem>> build(int collectionId) async {
    final items = <RunPlanItem>[];
    var index = 0;
    await _walk(collectionId, (request) {
      items.add(
        RunPlanItem(
          stepIndex: index++,
          request: request,
          collectionId: request.collectionId,
        ),
      );
    });
    return items;
  }

  Future<void> _walk(
    int collectionId,
    void Function(SavedRequestEntity) onRequest,
  ) async {
    final requests = await _repo.fetchRequestsInCollection(collectionId);
    for (final request in requests) {
      onRequest(request);
    }

    final subCollections = await _repo.fetchSubCollections(collectionId);
    for (final sub in subCollections) {
      await _walk(sub.id, onRequest);
    }
  }
}
