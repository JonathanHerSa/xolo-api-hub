import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// =============================================================================
// TABLAS
// =============================================================================

/// Requests guardados/reutilizables
class SavedRequests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get method => text().withLength(min: 1, max: 10)();
  TextColumn get url => text()();
  TextColumn get headersJson => text().nullable()();
  TextColumn get paramsJson => text().nullable()();
  TextColumn get body => text().nullable()();
  IntColumn get collectionId =>
      integer().nullable().references(Collections, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

/// Historial automático de ejecuciones
class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get savedRequestId =>
      integer().nullable().references(SavedRequests, #id)();
  TextColumn get method => text()();
  TextColumn get url => text()();
  TextColumn get headersJson => text().nullable()();
  TextColumn get paramsJson => text().nullable()();
  TextColumn get body => text().nullable()();
  IntColumn get statusCode => integer().nullable()();
  TextColumn get responseBody => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get executedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Colecciones para organizar requests
class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get parentId => integer().nullable().references(Collections, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Entornos (Dev, Stage, Prod) - Preparado para Fase 2
class Environments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Variables por scope - Preparado para Fase 2
/// Renombrada a EnvVariables para evitar conflicto con Variable de Drift
class EnvVariables extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().withLength(min: 1, max: 100)();
  TextColumn get value => text()();
  IntColumn get environmentId =>
      integer().nullable().references(Environments, #id)();
  TextColumn get scope => text().withDefault(const Constant('global'))();
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ---------------------------------------------------------------------------
  // HISTORY QUERIES
  // ---------------------------------------------------------------------------

  /// Obtener historial reciente (stream reactivo)
  Stream<List<HistoryEntry>> watchRecentHistory({int limit = 50}) {
    return (select(historyEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.executedAt)])
          ..limit(limit))
        .watch();
  }

  /// Insertar una entrada en el historial
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
      ),
    );
  }

  /// Obtener entrada de historial por ID
  Future<HistoryEntry?> getHistoryById(int id) {
    return (select(
      historyEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Limpiar historial antiguo
  Future<int> deleteHistoryOlderThan(DateTime date) {
    return (delete(
      historyEntries,
    )..where((t) => t.executedAt.isSmallerThanValue(date))).go();
  }

  /// Limpiar todo el historial
  Future<int> clearHistory() {
    return delete(historyEntries).go();
  }

  // ---------------------------------------------------------------------------
  // SAVED REQUESTS QUERIES
  // ---------------------------------------------------------------------------

  /// Obtener todos los requests guardados (sin soft delete)
  Stream<List<SavedRequest>> watchSavedRequests() {
    return (select(savedRequests)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Guardar un request
  Future<int> saveRequest({
    required String name,
    required String method,
    required String url,
    String? headersJson,
    String? paramsJson,
    String? body,
    int? collectionId,
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
      ),
    );
  }

  /// Soft delete de un request
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

  /// Restaurar un request eliminado
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
}

// =============================================================================
// CONNECTION HELPER
// =============================================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'xolo.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
