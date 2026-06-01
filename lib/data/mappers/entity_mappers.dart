import 'package:xolo/data/local/database.dart';
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
