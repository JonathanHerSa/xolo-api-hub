import 'dart:convert';

import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/mappers/entity_mappers.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/collection_run_entity.dart';
import 'package:xolo/domain/entities/env_variable_entity.dart';
import 'package:xolo/domain/entities/environment_entity.dart';
import 'package:xolo/domain/entities/history_entry_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/domain/repositories/xolo_repository.dart';

class DriftXoloRepository implements XoloRepository {
  DriftXoloRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> setSetting(String key, String value) =>
      _db.setSetting(key, value);

  @override
  Future<String?> getSetting(String key) => _db.getSetting(key);

  @override
  Stream<String?> watchSetting(String key) => _db.watchSetting(key);

  @override
  Stream<List<CollectionEntity>> watchRootCollections() =>
      _db.watchRootCollections().map(mapCollections);

  @override
  Stream<List<CollectionEntity>> watchSubCollections(int parentId) =>
      _db.watchSubCollections(parentId).map(mapCollections);

  @override
  Stream<List<CollectionEntity>> watchAllCollections() =>
      _db.watchAllCollections().map(mapCollections);

  @override
  Stream<List<SavedRequestEntity>> watchRequestsInCollection(
    int collectionId,
  ) => _db.watchRequestsInCollection(collectionId).map(mapSavedRequests);

  @override
  Stream<List<SavedRequestEntity>> watchUnclassifiedRequests() =>
      _db.watchUnclassifiedRequests().map(mapSavedRequests);

  @override
  Stream<List<SavedRequestEntity>> watchSavedRequests() =>
      _db.watchSavedRequests().map(mapSavedRequests);

  @override
  Future<int> createCollection({
    required String name,
    String? description,
    int? parentId,
    String? authType,
    String? authData,
  }) => _db.createCollection(
    name: name,
    description: description,
    parentId: parentId,
    authType: authType,
    authData: authData,
  );

  @override
  Future<bool> updateCollection(
    int id,
    String name,
    String? description, {
    String? authType,
    String? authData,
  }) => _db.updateCollection(
    id,
    name,
    description,
    authType: authType,
    authData: authData,
  );

  @override
  Future<List<CollectionEntity>> getCollectionsWithPlainAuthData() async =>
      mapCollections(await _db.getCollectionsWithPlainAuthData());

  @override
  Future<void> updateCollectionAuthDataById(int id, String? authData) =>
      _db.updateCollectionAuthDataById(id, authData);

  @override
  Future<void> deleteCollection(int id) => _db.deleteCollection(id);

  @override
  Future<bool> moveRequest(int requestId, int? collectionId) =>
      _db.moveRequest(requestId, collectionId);

  @override
  Future<bool> moveCollection(int collectionId, int? newParentId) =>
      _db.moveCollection(collectionId, newParentId);

  @override
  Future<List<CollectionEntity>> getCollectionPath(int collectionId) async =>
      mapCollections(await _db.getCollectionPath(collectionId));

  @override
  Future<CollectionEntity?> findCollectionByName(
    String name,
    int? parentId,
  ) async {
    final row = await _db.findCollectionByName(name, parentId);
    return row?.toEntity();
  }

  @override
  Stream<List<HistoryEntryEntity>> watchRecentHistory(int? workspaceId) =>
      _db.watchRecentHistory(workspaceId).map(mapHistoryEntries);

  @override
  Future<int> addHistoryItem({
    required String method,
    required String url,
    String? originalUrl,
    int? statusCode,
    int? durationMs,
    int? responseSize,
    int? workspaceId,
  }) => _db.addHistoryItem(
    method: method,
    url: url,
    originalUrl: originalUrl,
    statusCode: statusCode,
    durationMs: durationMs,
    responseSize: responseSize,
    workspaceId: workspaceId,
  );

  @override
  Future<HistoryEntryEntity?> getHistoryById(int id) async {
    final row = await _db.getHistoryById(id);
    return row?.toEntity();
  }

  @override
  Future<int> clearHistory(int? workspaceId) => _db.clearHistory(workspaceId);

  @override
  Future<void> clearAllHistory() async {
    await _db.delete(_db.historyEntries).go();
  }

  @override
  Future<void> deleteHistoryEntry(HistoryEntryEntity entry) async {
    await (_db.delete(
      _db.historyEntries,
    )..where((t) => t.id.equals(entry.id))).go();
  }

  @override
  Future<int> restoreHistoryEntry(HistoryEntryEntity entry) {
    return _db.into(_db.historyEntries).insert(toHistoryRow(entry));
  }

  @override
  Future<int> createRequest({
    required String name,
    required String method,
    required String url,
    String? headersJson,
    String? paramsJson,
    String? body,
    int? collectionId,
    String? schemaJson,
  }) => _db.createRequest(
    name: name,
    method: method,
    url: url,
    headersJson: headersJson,
    paramsJson: paramsJson,
    body: body,
    collectionId: collectionId,
    schemaJson: schemaJson,
  );

  @override
  Future<bool> softDeleteRequest(int id) => _db.softDeleteRequest(id);

  @override
  Future<bool> restoreRequest(int id) => _db.restoreRequest(id);

  @override
  Future<SavedRequestEntity?> findRequestInCollection({
    required int collectionId,
    required String method,
    required String url,
  }) async {
    final row = await _db.findRequestInCollection(
      collectionId: collectionId,
      method: method,
      url: url,
    );
    return row?.toEntity();
  }

  @override
  Future<int> updateRequestContent({
    required int id,
    required String name,
    String? headersJson,
    String? paramsJson,
    String? body,
    String? schemaJson,
  }) => _db.updateRequestContent(
    id: id,
    name: name,
    headersJson: headersJson,
    paramsJson: paramsJson,
    body: body,
    schemaJson: schemaJson,
  );

  @override
  Stream<List<EnvironmentEntity>> watchEnvironments(int? workspaceId) =>
      _db.watchEnvironments(workspaceId).map(mapEnvironments);

  @override
  Stream<int?> watchActiveEnvironmentId(int? workspaceId) =>
      _db.watchActiveEnvironmentId(workspaceId);

  @override
  Future<int> createEnvironment(String name, int? workspaceId) =>
      _db.createEnvironment(name, workspaceId);

  @override
  Future<void> setActiveEnvironment(int? envId, int? workspaceId) =>
      _db.setActiveEnvironment(envId, workspaceId);

  @override
  Future<int> deleteEnvironment(int id) => _db.deleteEnvironment(id);

  @override
  Stream<List<EnvVariableEntity>> watchResolvedVariables(
    int? workspaceId,
    int? environmentId,
  ) => _db
      .watchResolvedVariables(workspaceId, environmentId)
      .map(mapEnvVariables);

  @override
  Stream<List<EnvVariableEntity>> watchVariables(
    int? workspaceId,
    int? environmentId,
  ) => _db.watchVariables(workspaceId, environmentId).map(mapEnvVariables);

  @override
  Future<int> upsertVariable({
    int? id,
    required String key,
    required String value,
    int? environmentId,
    int? workspaceId,
  }) => _db.upsertVariable(
    id: id,
    key: key,
    value: value,
    environmentId: environmentId,
    workspaceId: workspaceId,
  );

  @override
  Future<int> deleteVariable(int id) => _db.deleteVariable(id);

  @override
  Future<void> wipeAllLocalData() async {
    await _db.delete(_db.runStepResults).go();
    await _db.delete(_db.collectionRuns).go();
    await _db.delete(_db.historyEntries).go();
    await _db.delete(_db.savedRequests).go();
    await _db.delete(_db.envVariables).go();
    await _db.delete(_db.environments).go();
    await _db.delete(_db.collections).go();
    await _db.delete(_db.appSettings).go();
  }

  @override
  Future<List<SavedRequestEntity>> fetchRequestsInCollection(
    int collectionId,
  ) async => mapSavedRequests(await _db.fetchRequestsInCollection(collectionId));

  @override
  Future<List<CollectionEntity>> fetchSubCollections(int parentId) async =>
      mapCollections(await _db.fetchSubCollections(parentId));

  @override
  Future<CollectionEntity?> getCollectionById(int id) async {
    final row = await (_db.select(
      _db.collections,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.toEntity();
  }

  @override
  Future<int> createCollectionRun({
    required int collectionId,
    int? workspaceId,
    int? environmentId,
    required int totalSteps,
    bool stopOnFailure = true,
    String? runOptionsJson,
  }) => _db.createCollectionRun(
    collectionId: collectionId,
    workspaceId: workspaceId,
    environmentId: environmentId,
    totalSteps: totalSteps,
    stopOnFailure: stopOnFailure,
    runOptionsJson: runOptionsJson,
  );

  @override
  Future<void> finishCollectionRun({
    required int runId,
    required RunStatus status,
    required int passedSteps,
    required int failedSteps,
    required int skippedSteps,
    String? variablesSnapshotJson,
  }) => _db.finishCollectionRun(
    runId: runId,
    status: status.name,
    passedSteps: passedSteps,
    failedSteps: failedSteps,
    skippedSteps: skippedSteps,
    variablesSnapshotJson: variablesSnapshotJson,
  );

  @override
  Future<void> insertRunStepResult({
    required int runId,
    required RunStepResultEntity step,
  }) async {
    final assertionsJson = step.assertionResults.isEmpty
        ? null
        : jsonEncode(step.assertionResults.map((a) => a.toJson()).toList());
    await _db.insertRunStepResultRow(
      runId: runId,
      stepIndex: step.stepIndex,
      savedRequestId: step.savedRequestId,
      name: step.name,
      method: step.method,
      url: step.url,
      stepStatus: step.status.name,
      statusCode: step.statusCode,
      durationMs: step.durationMs,
      passed: step.passed,
      assertionResultsJson: assertionsJson,
      errorMessage: step.errorMessage,
      responseBodySnippet: step.responseBodySnippet,
    );
  }

  @override
  Stream<List<CollectionRunEntity>> watchCollectionRuns({int? workspaceId}) =>
      _db.watchCollectionRuns(workspaceId: workspaceId).map(mapCollectionRuns);

  @override
  Future<CollectionRunEntity?> getCollectionRunById(int id) async {
    final row = await _db.getCollectionRunById(id);
    return row?.toEntity();
  }

  @override
  Future<List<RunStepResultEntity>> getRunStepResults(int runId) async =>
      mapRunStepResults(await _db.getRunStepResults(runId));

  @override
  Future<bool> updateRequestAssertions(
    int requestId,
    String? assertionsJson,
  ) => _db.updateRequestAssertions(requestId, assertionsJson);
}
