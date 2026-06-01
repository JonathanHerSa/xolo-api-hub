part of 'database.dart';

extension RunQueries on AppDatabase {
  Future<List<SavedRequest>> fetchRequestsInCollection(int collectionId) {
    return (select(savedRequests)
          ..where(
            (t) =>
                t.collectionId.equals(collectionId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Future<List<Collection>> fetchSubCollections(int parentId) {
    return (select(collections)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Future<int> createCollectionRun({
    required int collectionId,
    int? workspaceId,
    int? environmentId,
    required int totalSteps,
    bool stopOnFailure = true,
    String? runOptionsJson,
  }) {
    return into(collectionRuns).insert(
      CollectionRunsCompanion.insert(
        collectionId: collectionId,
        workspaceId: Value(workspaceId),
        environmentId: Value(environmentId),
        status: 'running',
        totalSteps: Value(totalSteps),
        stopOnFailure: Value(stopOnFailure),
        runOptionsJson: Value(runOptionsJson),
      ),
    );
  }

  Future<void> finishCollectionRun({
    required int runId,
    required String status,
    required int passedSteps,
    required int failedSteps,
    required int skippedSteps,
    String? variablesSnapshotJson,
  }) async {
    await (update(collectionRuns)..where((t) => t.id.equals(runId))).write(
      CollectionRunsCompanion(
        status: Value(status),
        passedSteps: Value(passedSteps),
        failedSteps: Value(failedSteps),
        skippedSteps: Value(skippedSteps),
        variablesSnapshotJson: Value(variablesSnapshotJson),
        finishedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> insertRunStepResultRow({
    required int runId,
    required int stepIndex,
    int? savedRequestId,
    required String name,
    required String method,
    required String url,
    required String stepStatus,
    int? statusCode,
    int? durationMs,
    required bool passed,
    String? assertionResultsJson,
    String? errorMessage,
    String? responseBodySnippet,
  }) {
    return into(runStepResults).insert(
      RunStepResultsCompanion.insert(
        runId: runId,
        stepIndex: stepIndex,
        savedRequestId: Value(savedRequestId),
        name: name,
        method: method,
        url: url,
        stepStatus: stepStatus,
        statusCode: Value(statusCode),
        durationMs: Value(durationMs),
        passed: Value(passed),
        assertionResultsJson: Value(assertionResultsJson),
        errorMessage: Value(errorMessage),
        responseBodySnippet: Value(responseBodySnippet),
      ),
    );
  }

  Stream<List<CollectionRun>> watchCollectionRuns({int? workspaceId}) {
    final query = select(collectionRuns)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    if (workspaceId != null) {
      query.where((t) => t.workspaceId.equals(workspaceId));
    }
    return query.watch();
  }

  Future<CollectionRun?> getCollectionRunById(int id) {
    return (select(collectionRuns)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<RunStepResult>> getRunStepResults(int runId) {
    return (select(runStepResults)
          ..where((t) => t.runId.equals(runId))
          ..orderBy([(t) => OrderingTerm(expression: t.stepIndex)]))
        .get();
  }

  Future<bool> updateRequestAssertions(int requestId, String? assertionsJson) {
    return (update(savedRequests)..where((t) => t.id.equals(requestId)))
        .write(
          SavedRequestsCompanion(
            assertionsJson: Value(assertionsJson),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .then((rows) => rows > 0);
  }
}
