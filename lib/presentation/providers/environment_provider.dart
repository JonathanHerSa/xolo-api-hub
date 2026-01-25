import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import 'database_providers.dart';
import 'workspace_provider.dart';

// =============================================================================
// PROVIDERS DE LECTURA (Scoped by Workspace)
// =============================================================================

/// Lista de entornos filtrada por Workspace activo
final environmentsListProvider = StreamProvider<List<Environment>>((ref) {
  final db = ref.watch(databaseProvider);
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  // Si workspaceId es null (Global/Unclassified), trae entornos globales (collectionId is null)
  return db.watchEnvironments(workspaceId);
});

/// ID del entorno activo (dentro del workspace actual)
final activeEnvironmentIdProvider = StreamProvider<int?>((ref) {
  final db = ref.watch(databaseProvider);
  // El active environment se guarda con un flag isActive en la tabla.
  // La query watchActiveEnvironmentId ya filtra por isActive=true AND workspace context
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  return db.watchActiveEnvironmentId(workspaceId);
});

/// Variables CRUD (listado para editar en EnvironmentsScreen)
/// Si activeEnvId es null, muestra variables globales del workspace actual.
final rawVariablesProvider = StreamProvider<List<EnvVariable>>((ref) {
  final db = ref.watch(databaseProvider);
  final activeEnvId = ref.watch(activeEnvironmentIdProvider).value;
  final workspaceId = ref.watch(activeWorkspaceIdProvider);

  // db.watchVariables logic:
  // if activeEnvId != null -> Env vars
  // if activeEnvId == null -> Global workspace vars
  return db.watchVariables(workspaceId, activeEnvId);
});

// =============================================================================
// PROVIDER DE RESOLUCIÓN (Para Interpolación)
// =============================================================================

// Helper para family provider (porque necesitamos pasar 2 args)
class _ResolvedVarsArgs {
  final int? workspaceId;
  final int? envId;
  _ResolvedVarsArgs(this.workspaceId, this.envId);

  @override
  bool operator ==(Object other) =>
      other is _ResolvedVarsArgs &&
      other.workspaceId == workspaceId &&
      other.envId == envId;
  @override
  int get hashCode => Object.hash(workspaceId, envId);
}

final _resolvedVarsStreamProvider =
    StreamProvider.family<List<EnvVariable>, _ResolvedVarsArgs>((ref, args) {
      return ref
          .watch(databaseProvider)
          .watchResolvedVariables(args.workspaceId, args.envId);
    });

/// Variables resueltas consolidadas (Global + Env)
final resolvedVariablesProvider = Provider<Map<String, String>>((ref) {
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  final activeEnvId = ref.watch(activeEnvironmentIdProvider).value;

  final variablesAsync = ref.watch(
    _resolvedVarsStreamProvider(_ResolvedVarsArgs(workspaceId, activeEnvId)),
  );

  return variablesAsync.when(
    data: (vars) {
      final globalVars = <String, String>{};
      final envVars = <String, String>{};

      for (final v in vars) {
        // Distinguir por scope
        if (v.environmentId == null) {
          globalVars[v.key] = v.value;
        } else {
          envVars[v.key] = v.value;
        }
      }

      // Merge: Environment sobrescribe Global
      return {...globalVars, ...envVars};
    },
    loading: () => const {},
    error: (_, __) => const {},
  );
});
