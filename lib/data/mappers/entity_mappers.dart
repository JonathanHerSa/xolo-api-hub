import 'dart:convert';

import 'package:xolo/data/local/database.dart';
import 'package:xolo/domain/entities/collection_run_entity.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/env_variable_entity.dart';
import 'package:xolo/domain/entities/environment_entity.dart';
import 'package:xolo/domain/entities/history_entry_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';

extension CollectionEntityMapper on Collection {
  CollectionEntity toEntity() => CollectionEntity(
    id: id,
    name: name,
    description: description,
    parentId: parentId,
    authType: authType,
    authData: authData,
    createdAt: createdAt,
  );
}

extension SavedRequestEntityMapper on SavedRequest {
  SavedRequestEntity toEntity() => SavedRequestEntity(
    id: id,
    name: name,
    method: method,
    url: url,
    headersJson: headersJson,
    paramsJson: paramsJson,
    body: body,
    authType: authType,
    authData: authData,
    schemaJson: schemaJson,
    preScriptsJson: preScriptsJson,
    scriptsJson: scriptsJson,
    assertionsJson: assertionsJson,
    collectionId: collectionId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isDeleted: isDeleted,
  );
}

extension HistoryEntryEntityMapper on HistoryEntry {
  HistoryEntryEntity toEntity() => HistoryEntryEntity(
    id: id,
    savedRequestId: savedRequestId,
    workspaceId: workspaceId,
    method: method,
    url: url,
    originalUrl: originalUrl,
    headersJson: headersJson,
    paramsJson: paramsJson,
    body: body,
    authType: authType,
    authData: authData,
    statusCode: statusCode,
    responseBody: responseBody,
    durationMs: durationMs,
    executedAt: executedAt,
  );
}

extension EnvironmentEntityMapper on Environment {
  EnvironmentEntity toEntity() => EnvironmentEntity(
    id: id,
    name: name,
    collectionId: collectionId,
    isActive: isActive,
    createdAt: createdAt,
  );
}

extension EnvVariableEntityMapper on EnvVariable {
  EnvVariableEntity toEntity() => EnvVariableEntity(
    id: id,
    key: key,
    value: value,
    environmentId: environmentId,
    collectionId: collectionId,
    scope: scope,
    createdAt: createdAt,
  );
}

List<CollectionEntity> mapCollections(List<Collection> rows) =>
    rows.map((row) => row.toEntity()).toList(growable: false);

List<SavedRequestEntity> mapSavedRequests(List<SavedRequest> rows) =>
    rows.map((row) => row.toEntity()).toList(growable: false);

List<HistoryEntryEntity> mapHistoryEntries(List<HistoryEntry> rows) =>
    rows.map((row) => row.toEntity()).toList(growable: false);

List<EnvironmentEntity> mapEnvironments(List<Environment> rows) =>
    rows.map((row) => row.toEntity()).toList(growable: false);

List<EnvVariableEntity> mapEnvVariables(List<EnvVariable> rows) =>
    rows.map((row) => row.toEntity()).toList(growable: false);

extension CollectionRunEntityMapper on CollectionRun {
  CollectionRunEntity toEntity() => CollectionRunEntity(
    id: id,
    collectionId: collectionId,
    workspaceId: workspaceId,
    environmentId: environmentId,
    status: RunStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => RunStatus.completed,
    ),
    totalSteps: totalSteps,
    passedSteps: passedSteps,
    failedSteps: failedSteps,
    skippedSteps: skippedSteps,
    startedAt: startedAt,
    finishedAt: finishedAt,
    stopOnFailure: stopOnFailure,
    variablesSnapshotJson: variablesSnapshotJson,
  );
}

extension RunStepResultEntityMapper on RunStepResult {
  RunStepResultEntity toEntity() {
    final assertions = <AssertionResultEntity>[];
    if (assertionResultsJson != null && assertionResultsJson!.isNotEmpty) {
      try {
        final list = jsonDecode(assertionResultsJson!) as List<dynamic>;
        for (final item in list) {
          assertions.add(
            AssertionResultEntity.fromJson(item as Map<String, dynamic>),
          );
        }
      } catch (_) {}
    }
    return RunStepResultEntity(
      stepIndex: stepIndex,
      savedRequestId: savedRequestId,
      name: name,
      method: method,
      url: url,
      status: RunStepStatus.values.firstWhere(
        (s) => s.name == stepStatus,
        orElse: () => RunStepStatus.error,
      ),
      statusCode: statusCode,
      durationMs: durationMs,
      passed: passed,
      assertionResults: assertions,
      errorMessage: errorMessage,
      responseBodySnippet: responseBodySnippet,
    );
  }
}

List<CollectionRunEntity> mapCollectionRuns(List<CollectionRun> rows) =>
    rows.map((row) => row.toEntity()).toList(growable: false);

List<RunStepResultEntity> mapRunStepResults(List<RunStepResult> rows) =>
    rows.map((row) => row.toEntity()).toList(growable: false);

HistoryEntry toHistoryRow(HistoryEntryEntity entity) => HistoryEntry(
  id: entity.id,
  savedRequestId: entity.savedRequestId,
  workspaceId: entity.workspaceId,
  method: entity.method,
  url: entity.url,
  originalUrl: entity.originalUrl,
  headersJson: entity.headersJson,
  paramsJson: entity.paramsJson,
  body: entity.body,
  authType: entity.authType,
  authData: entity.authData,
  statusCode: entity.statusCode,
  responseBody: entity.responseBody,
  durationMs: entity.durationMs,
  executedAt: entity.executedAt,
);
