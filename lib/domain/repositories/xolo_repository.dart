import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/env_variable_entity.dart';
import 'package:xolo/domain/entities/environment_entity.dart';
import 'package:xolo/domain/entities/history_entry_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/domain/entities/collection_run_entity.dart';

/// Data-access contract for presentation and core services.
abstract class XoloRepository {
  Future<void> setSetting(String key, String value);
  Future<String?> getSetting(String key);
  Stream<String?> watchSetting(String key);

  Stream<List<CollectionEntity>> watchRootCollections();
  Stream<List<CollectionEntity>> watchSubCollections(int parentId);
  Stream<List<CollectionEntity>> watchAllCollections();
  Stream<List<SavedRequestEntity>> watchRequestsInCollection(int collectionId);
  Stream<List<SavedRequestEntity>> watchUnclassifiedRequests();
  Stream<List<SavedRequestEntity>> watchSavedRequests();

  Future<int> createCollection({
    required String name,
    String? description,
    int? parentId,
    String? authType,
    String? authData,
  });
  Future<bool> updateCollection(
    int id,
    String name,
    String? description, {
    String? authType,
    String? authData,
  });
  Future<List<CollectionEntity>> getCollectionsWithPlainAuthData();
  Future<void> updateCollectionAuthDataById(int id, String? authData);
  Future<void> deleteCollection(int id);
  Future<bool> moveRequest(int requestId, int? collectionId);
  Future<bool> moveCollection(int collectionId, int? newParentId);
  Future<List<CollectionEntity>> getCollectionPath(int collectionId);
  Future<CollectionEntity?> findCollectionByName(String name, int? parentId);

  Stream<List<HistoryEntryEntity>> watchRecentHistory(int? workspaceId);
  Future<int> addHistoryItem({
    required String method,
    required String url,
    String? originalUrl,
    int? statusCode,
    int? durationMs,
    int? responseSize,
    int? workspaceId,
  });
  Future<HistoryEntryEntity?> getHistoryById(int id);
  Future<int> clearHistory(int? workspaceId);
  Future<void> clearAllHistory();
  Future<void> deleteHistoryEntry(HistoryEntryEntity entry);
  Future<int> restoreHistoryEntry(HistoryEntryEntity entry);

  Future<int> createRequest({
    required String name,
    required String method,
    required String url,
    String? headersJson,
    String? paramsJson,
    String? body,
    int? collectionId,
    String? schemaJson,
  });
  Future<bool> softDeleteRequest(int id);
  Future<bool> restoreRequest(int id);
  Future<SavedRequestEntity?> findRequestInCollection({
    required int collectionId,
    required String method,
    required String url,
  });
  Future<int> updateRequestContent({
    required int id,
    required String name,
    String? headersJson,
    String? paramsJson,
    String? body,
    String? schemaJson,
  });

  Stream<List<EnvironmentEntity>> watchEnvironments(int? workspaceId);
  Stream<int?> watchActiveEnvironmentId(int? workspaceId);
  Future<int> createEnvironment(String name, int? workspaceId);
  Future<void> setActiveEnvironment(int? envId, int? workspaceId);
  Future<int> deleteEnvironment(int id);

  Stream<List<EnvVariableEntity>> watchResolvedVariables(
    int? workspaceId,
    int? environmentId,
  );
  Stream<List<EnvVariableEntity>> watchVariables(
    int? workspaceId,
    int? environmentId,
  );
  Future<int> upsertVariable({
    int? id,
    required String key,
    required String value,
    int? environmentId,
    int? workspaceId,
  });
  Future<int> deleteVariable(int id);

  Future<void> wipeAllLocalData();

  // Collection runs
  Future<List<SavedRequestEntity>> fetchRequestsInCollection(int collectionId);
  Future<List<CollectionEntity>> fetchSubCollections(int parentId);
  Future<CollectionEntity?> getCollectionById(int id);

  Future<int> createCollectionRun({
    required int collectionId,
    int? workspaceId,
    int? environmentId,
    required int totalSteps,
    bool stopOnFailure,
    String? runOptionsJson,
  });

  Future<void> finishCollectionRun({
    required int runId,
    required RunStatus status,
    required int passedSteps,
    required int failedSteps,
    required int skippedSteps,
    String? variablesSnapshotJson,
  });

  Future<void> insertRunStepResult({
    required int runId,
    required RunStepResultEntity step,
  });

  Stream<List<CollectionRunEntity>> watchCollectionRuns({int? workspaceId});
  Future<CollectionRunEntity?> getCollectionRunById(int id);
  Future<List<RunStepResultEntity>> getRunStepResults(int runId);

  Future<bool> updateRequestAssertions(int requestId, String? assertionsJson);
}
