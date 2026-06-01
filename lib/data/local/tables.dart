part of 'database.dart';

// Drift table definitions are declarative schema; covered via query/migration tests.
// coverage:ignore-file

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

  // Pre-Request Scripts
  TextColumn get preScriptsJson => text().nullable()();

  // Post-Request Scripts (Request Chaining)
  TextColumn get scriptsJson => text().nullable()();

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
  TextColumn get url => text()(); // Resolved URL (absolute)
  TextColumn get originalUrl =>
      text().nullable()(); // Template URL (with variables)
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

  // Auth Inheritance (v4)
  TextColumn get authType =>
      text().nullable()(); // 'bearer', 'basic', 'inherit', etc.
  TextColumn get authData =>
      text().nullable()(); // JSON string with token, etc.
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
