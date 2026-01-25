import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// =============================================================================
// TABLAS
// =============================================================================

/// Configuración de la App (Persistencia simple)
class AppSettings extends Table {
  TextColumn get key => text().withLength(min: 1, max: 50)();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Requests guardados/reutilizables
class SavedRequests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get method => text().withLength(min: 1, max: 10)();
  TextColumn get url => text()();
  TextColumn get headersJson => text().nullable()();
  TextColumn get paramsJson => text().nullable()();
  TextColumn get body => text().nullable()();

  // Auth Columns (Phase 6)
  TextColumn get authType => text().nullable()(); // 'bearer', 'basic', etc.
  TextColumn get authData =>
      text().nullable()(); // JSON string with token, user/pass, etc.

  // Body Schema (Phase Maintenance)
  // Stores the RESOLVED (dereferenced) OpenAPI schema for the body,
  // allowing smart re-generation later.
  TextColumn get schemaJson => text().nullable()();

  IntColumn get collectionId =>
      integer().nullable().references(Collections, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

/// Historial automático de ejecuciones (Ahora con Workspace Context)
class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get savedRequestId =>
      integer().nullable().references(SavedRequests, #id)();
  // NUEVO: Contexto de Workspace
  IntColumn get workspaceId =>
      integer().nullable().references(Collections, #id)();

  TextColumn get method => text()();
  TextColumn get url => text()();
  TextColumn get headersJson => text().nullable()();
  TextColumn get paramsJson => text().nullable()();
  TextColumn get body => text().nullable()();

  // Auth Snapshot (Optional, for history reproducibility)
  TextColumn get authType => text().nullable()();
  TextColumn get authData => text().nullable()();

  IntColumn get statusCode => integer().nullable()();
  TextColumn get responseBody => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get executedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Colecciones (Proyectos y Carpetas)
class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get parentId => integer().nullable().references(Collections, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Entornos (Dev, Stage, Prod)
/// Ahora pertenecen a una Colección/Workspace específico.
class Environments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();

  // NUEVO: Pertenencia a Workspace
  // Si null, es "Global del Usuario" (disponible en todos o en ninguno? Definamos "Sin Workspace" como su propio contexto)
  IntColumn get collectionId =>
      integer().nullable().references(Collections, #id)();

  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Variables (Global del Workspace o Específica del Entorno del Workspace)
class EnvVariables extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().withLength(min: 1, max: 100)();
  TextColumn get value => text()();
  // Scope Env Específico
  IntColumn get environmentId =>
      integer().nullable().references(Environments, #id)();
  // Scope Global de Workspace
  IntColumn get collectionId =>
      integer().nullable().references(Collections, #id)();

  TextColumn get scope => text().withDefault(const Constant('global'))();
  // scope 'env' = environmentId != null
  // scope 'global' = collectionId != null && environmentId == null
  // scope 'user_global' = both null (si lo soportamos)

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// =============================================================================
// DATABASE
// =============================================================================

@DriftDatabase(
  tables: [
    SavedRequests,
    HistoryEntries,
    Collections,
    Environments,
    EnvVariables,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // Bump version for schemaJson

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add Auth columns (v2)
          await m.addColumn(savedRequests, savedRequests.authType);
          await m.addColumn(savedRequests, savedRequests.authData);
          await m.addColumn(historyEntries, historyEntries.authType);
          await m.addColumn(historyEntries, historyEntries.authData);
        }
        if (from < 3) {
          // Add schemaJson (v3)
          await m.addColumn(savedRequests, savedRequests.schemaJson);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // APP SETTINGS (KV STORE)
  // ---------------------------------------------------------------------------

  Future<void> setSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<String?> getSetting(String key) async {
    final result = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  Stream<String?> watchSetting(String key) {
    return (select(appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((r) => r?.value);
  }

  // ---------------------------------------------------------------------------
  // COLLECTIONS (WORKSPACES)
  // ---------------------------------------------------------------------------

  /// Obtener colecciones raíz (Proyectos/Workspaces)
  Stream<List<Collection>> watchRootCollections() {
    return (select(collections)
          ..where((t) => t.parentId.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Stream<List<Collection>> watchSubCollections(int parentId) {
    return (select(collections)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Trae TODAS las colecciones para armar árbol en memoria
  Stream<List<Collection>> watchAllCollections() {
    return (select(
      collections,
    )..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  Stream<List<SavedRequest>> watchRequestsInCollection(int collectionId) {
    return (select(savedRequests)
          ..where(
            (t) =>
                t.collectionId.equals(collectionId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Stream<List<SavedRequest>> watchUnclassifiedRequests() {
    return (select(savedRequests)
          ..where((t) => t.collectionId.isNull() & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<int> createCollection({
    required String name,
    String? description,
    int? parentId,
  }) {
    return into(collections).insert(
      CollectionsCompanion.insert(
        name: name,
        description: Value(description),
        parentId: Value(parentId),
      ),
    );
  }

  Future<bool> updateCollection(int id, String name, String? description) {
    return (update(collections)..where((t) => t.id.equals(id)))
        .write(
          CollectionsCompanion(
            name: Value(name),
            description: Value(description),
          ),
        )
        .then((rows) => rows > 0);
  }

  Future<void> deleteCollection(int id) async {
    await transaction(() async {
      final children = await (select(
        collections,
      )..where((t) => t.parentId.equals(id))).get();

      for (final child in children) {
        await deleteCollection(child.id);
      }

      await (update(
        savedRequests,
      )..where((t) => t.collectionId.equals(id))).write(
        const SavedRequestsCompanion(
          isDeleted: Value(true),
          collectionId: Value(null),
        ),
      );

      // Eliminar Entornos asociados al Workspace (si es root)
      await (delete(
        environments,
      )..where((t) => t.collectionId.equals(id))).go();

      await (delete(collections)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<bool> moveRequest(int requestId, int? collectionId) async {
    final count =
        await (update(savedRequests)..where((t) => t.id.equals(requestId)))
            .write(SavedRequestsCompanion(collectionId: Value(collectionId)));
    return count > 0;
  }

  Future<bool> moveCollection(int collectionId, int? newParentId) async {
    if (collectionId == newParentId) return false;
    final count =
        await (update(collections)..where((t) => t.id.equals(collectionId)))
            .write(CollectionsCompanion(parentId: Value(newParentId)));
    return count > 0;
  }

  Future<List<Collection>> getCollectionPath(int collectionId) async {
    final path = <Collection>[];
    int? currentId = collectionId;

    while (currentId != null) {
      final collection = await (select(
        collections,
      )..where((t) => t.id.equals(currentId!))).getSingleOrNull();

      if (collection != null) {
        path.insert(0, collection);
        currentId = collection.parentId;
      } else {
        break;
      }
    }
    return path;
  }

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
    int? statusCode,
    int? durationMs,
    int? responseSize, // Not stored in DB currently, ignored or mapped?
    // DB has 'responseBody', provider passes 'responseSize'.
    // Provider passed 'responseSize' but it wasn't in DB Schema?
    // Let's check provider usage.
    int? workspaceId,
  }) {
    // Provider calls: addHistoryItem(method, url, statusCode, durationMs, responseSize, workspaceId)
    // We update params to match what we have.
    return insertHistory(
      method: method,
      url: url,
      statusCode: statusCode,
      durationMs: durationMs,
      workspaceId: workspaceId,
      // We don't store responseSize explicitly in DB yet, doing nothing with it.
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

  // ---------------------------------------------------------------------------
  // SAVED REQUESTS QUERIES
  // ---------------------------------------------------------------------------

  Stream<List<SavedRequest>> watchSavedRequests() {
    return (select(savedRequests)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  // RENAMED: createRequest matches UI
  Future<int> createRequest({
    required String name,
    required String method,
    required String url,
    String? headersJson,
    String? paramsJson,
    String? body,
    int? collectionId,
    String? schemaJson,
  }) {
    return into(savedRequests).insert(
      SavedRequestsCompanion.insert(
        name: name,
        method: method,
        url: url,
        headersJson: Value(headersJson),
        paramsJson: Value(paramsJson),
        body: Value(body),
        collectionId: Value(collectionId),
        schemaJson: Value(schemaJson),
      ),
    );
  }

  Future<bool> softDeleteRequest(int id) async {
    final count = await (update(savedRequests)..where((t) => t.id.equals(id)))
        .write(
          SavedRequestsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return count > 0;
  }

  Future<bool> restoreRequest(int id) async {
    final count = await (update(savedRequests)..where((t) => t.id.equals(id)))
        .write(
          SavedRequestsCompanion(
            isDeleted: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return count > 0;
  }

  // ---------------------------------------------------------------------------
  // IMPORT HELPERS (Merge Logic)
  // ---------------------------------------------------------------------------

  Future<Collection?> findCollectionByName(String name, int? parentId) {
    return (select(collections)..where(
          (t) =>
              t.name.equals(name) &
              (parentId == null
                  ? t.parentId.isNull()
                  : t.parentId.equals(parentId)),
        ))
        .getSingleOrNull();
  }

  Future<SavedRequest?> findRequestInCollection({
    required int collectionId,
    required String method,
    required String url,
  }) {
    return (select(savedRequests)..where(
          (t) =>
              t.collectionId.equals(collectionId) &
              t.method.equals(method) &
              t.url.equals(url) &
              t.isDeleted.equals(false),
        ))
        .getSingleOrNull();
  }

  Future<int> updateRequestContent({
    required int id,
    required String name,
    String? headersJson,
    String? paramsJson,
    String? body,
    String? schemaJson,
  }) {
    return (update(savedRequests)..where((t) => t.id.equals(id))).write(
      SavedRequestsCompanion(
        name: Value(name),
        headersJson: Value(headersJson),
        paramsJson: Value(paramsJson),
        body: Value(body),
        schemaJson: Value(schemaJson),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ENVIRONMENTS & VARIABLES QUERIES (Scoped)
  // ---------------------------------------------------------------------------

  /// Obtener entornos de un workspace dado
  Stream<List<Environment>> watchEnvironments(int? workspaceId) {
    return (select(environments)
          ..where((t) {
            if (workspaceId == null) return t.collectionId.isNull();
            return t.collectionId.equals(workspaceId);
          })
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Stream<int?> watchActiveEnvironmentId(int? workspaceId) {
    return (select(environments)..where(
          (t) =>
              t.isActive.equals(true) &
              (workspaceId == null
                  ? t.collectionId.isNull()
                  : t.collectionId.equals(workspaceId)),
        ))
        .watchSingleOrNull()
        .map((env) => env?.id);
  }

  Future<int> createEnvironment(String name, int? workspaceId) {
    return into(environments).insert(
      EnvironmentsCompanion.insert(
        name: name,
        collectionId: Value(workspaceId),
      ),
    );
  }

  Future<void> setActiveEnvironment(int? envId, int? workspaceId) async {
    // Desactivar todos en ESTE workspace
    await (update(environments)..where(
          (t) => workspaceId == null
              ? t.collectionId.isNull()
              : t.collectionId.equals(workspaceId),
        ))
        .write(const EnvironmentsCompanion(isActive: Value(false)));

    if (envId != null) {
      await (update(environments)..where((t) => t.id.equals(envId))).write(
        const EnvironmentsCompanion(isActive: Value(true)),
      );
    }
  }

  Future<int> deleteEnvironment(int id) async {
    return await transaction(() async {
      await (delete(
        envVariables,
      )..where((t) => t.environmentId.equals(id))).go();
      return await (delete(environments)..where((t) => t.id.equals(id))).go();
    });
  }

  // ---------------------------------------------------------------------------
  // VARIABLES QUERIES (Updated & Consolidated)
  // ---------------------------------------------------------------------------

  /// Obtiene las variables resueltas para un contexto dado.
  /// Trae:
  /// 1. Variables del entorno activo (si activeEnvId != null)
  /// 2. Variables globales del workspace (si workspaceId != null)
  /// 3. Variables globales de usuario (ambos null)
  Stream<List<EnvVariable>> watchResolvedVariables(
    int? workspaceId,
    int? activeEnvId,
  ) {
    return (select(envVariables)..where((t) {
          // Logic:
          // (environmentId == activeId) OR (collectionId == workspaceId AND environmentId IS NULL)

          Expression<bool> predicate = const Constant(false);

          if (activeEnvId != null) {
            predicate = predicate | t.environmentId.equals(activeEnvId);
          }

          if (workspaceId != null) {
            predicate =
                predicate |
                (t.collectionId.equals(workspaceId) & t.environmentId.isNull());
          } else {
            // "Sin Clasificar" / Global: traemos las que no tienen ni env ni collection
            predicate =
                predicate |
                (t.collectionId.isNull() & t.environmentId.isNull());
          }

          return predicate;
        }))
        .watch();
  }

  /// Watch crud variables list (para la pantalla de edición)
  /// Si envId != null, mostramos variables de ese env.
  /// Si envId == null, mostramos variables globales del workspace.
  Stream<List<EnvVariable>> watchVariables(
    int? workspaceId,
    int? environmentId,
  ) {
    return (select(envVariables)..where((t) {
          if (environmentId != null) {
            return t.environmentId.equals(environmentId);
          }
          // Globales del workspace
          if (workspaceId != null) {
            return t.collectionId.equals(workspaceId) &
                t.environmentId.isNull();
          }
          // Globales de usuario (Sin workspace)
          return t.collectionId.isNull() & t.environmentId.isNull();
        }))
        .watch();
  }

  Future<int> upsertVariable({
    int? id,
    required String key,
    required String value,
    int? environmentId,
    int? workspaceId,
  }) {
    if (id != null) {
      return (update(envVariables)..where((t) => t.id.equals(id))).write(
        EnvVariablesCompanion(key: Value(key), value: Value(value)),
      );
    } else {
      return into(envVariables).insert(
        EnvVariablesCompanion.insert(
          key: key,
          value: value,
          environmentId: Value(environmentId),
          collectionId: Value(workspaceId),
          scope: Value(environmentId != null ? 'env' : 'global'),
        ),
      );
    }
  }

  /// Eliminar variable
  Future<int> deleteVariable(int id) {
    return (delete(envVariables)..where((t) => t.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'xolo_v3.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
