part of 'database.dart';

extension HistoryQueries on AppDatabase {
  // ---------------------------------------------------------------------------
  // HISTORY QUERIES (Scoped)
  // ---------------------------------------------------------------------------

  /// Historial filtrado por Workspace
  Stream<List<HistoryEntry>> watchRecentHistory(
    int? workspaceId, {
    int limit = 50,
  }) {
    return (select(historyEntries)
          ..where((t) {
            if (workspaceId == null) return t.workspaceId.isNull();
            return t.workspaceId.equals(workspaceId);
          })
          ..orderBy([(t) => OrderingTerm.desc(t.executedAt)])
          ..limit(limit))
        .watch();
  }

  Future<int> insertHistory({
    required String method,
    required String url,
    String? originalUrl,
    String? headersJson,
    String? paramsJson,
    String? body,
    int? statusCode,
    String? responseBody,
    int? durationMs,
    int? savedRequestId,
    int? workspaceId, // Add
  }) {
    return into(historyEntries).insert(
      HistoryEntriesCompanion.insert(
        method: method,
        url: url,
        originalUrl: Value(originalUrl),
        headersJson: Value(headersJson),
        paramsJson: Value(paramsJson),
        body: Value(body),
        statusCode: Value(statusCode),
        responseBody: Value(responseBody),
        durationMs: Value(durationMs),
        savedRequestId: Value(savedRequestId),
        workspaceId: Value(workspaceId),
      ),
    );
  }

  // Alias for better readability / consistency with provider usage
  Future<int> addHistoryItem({
    required String method,
    required String url,
    String? originalUrl,
    int? statusCode,
    int? durationMs,
    int? responseSize, // Not stored in DB currently, ignored or mapped?
    int? workspaceId,
  }) {
    return insertHistory(
      method: method,
      url: url,
      originalUrl: originalUrl,
      statusCode: statusCode,
      durationMs: durationMs,
      workspaceId: workspaceId,
    );
  }

  Future<HistoryEntry?> getHistoryById(int id) {
    return (select(
      historyEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> deleteHistoryOlderThan(DateTime date) {
    return (delete(
      historyEntries,
    )..where((t) => t.executedAt.isSmallerThanValue(date))).go();
  }

  Future<int> clearHistory(int? workspaceId) {
    return (delete(historyEntries)..where((t) {
          if (workspaceId == null) return t.workspaceId.isNull();
          return t.workspaceId.equals(workspaceId);
        }))
        .go();
  }
}
