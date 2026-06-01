part of 'database.dart';

extension EnvironmentQueries on AppDatabase {
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
