import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import 'database_providers.dart';
import 'collections_provider.dart';

/// ID del Workspace (Colección Raíz) activo.
/// null = Global / Sin Clasificar.
final activeWorkspaceIdProvider = NotifierProvider<WorkspaceNotifier, int?>(
  WorkspaceNotifier.new,
);

class WorkspaceNotifier extends Notifier<int?> {
  // Key para persistencia
  static const _kActiveWorkspaceKey = 'active_workspace_id';

  @override
  int? build() {
    // Intentar cargar asíncronamente al inicio
    _loadSavedWorkspace();
    return null; // Estado inicial mientras carga
  }

  Future<void> _loadSavedWorkspace() async {
    try {
      final db = ref.read(databaseProvider);
      final savedIdStr = await db.getSetting(_kActiveWorkspaceKey);

      if (savedIdStr != null && savedIdStr.isNotEmpty) {
        final id = int.tryParse(savedIdStr);
        if (id != null) {
          // Verificar si el workspace aún existe
          // (Opcional, pero bueno para evitar estados fantasma)
          // Por simplicidad, asumimos que existe o fallback.
          state = id;
        }
      }
    } catch (_) {
      // Ignorar errores de carga inicial
    }
  }

  Future<void> setWorkspace(int? id) async {
    state = id;
    final db = ref.read(databaseProvider);
    await db.setSetting(_kActiveWorkspaceKey, id?.toString() ?? '');

    // Al cambiar de workspace, deberíamos resetear el entorno activo?
    // Depende de la UX. Si los entornos son aislados, sí.
    // El activeEnvironmentIdProvider observa la DB filtered por active=true AND workspaceId.
    // Si cambio workspaceId, la query de activeEnvironment cambia...
    // Pero en DB podría haber un entorno activo del workspace ANTERIOR que se queda activo?
    // Mi implementación de `setActiveEnvironment` desactiva otros del MISMO workspace.
    // Así que puede haber múltiples entornos "activos" en la tabla (uno por workspace).
    // Esto es genial: al volver al workspace A, recordará su entorno activo.
    // No necesito hacer nada extra aquí.
  }
}

/// Provider helper para obtener el objeto Collection del workspace activo (nombre, etc)
final activeWorkspaceProvider = FutureProvider<Collection?>((ref) async {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return null;

  final db = ref.watch(databaseProvider);
  // No tengo getCollectionById, uso query simple o agrego DAO.
  // Usaré una query directa aquí si es posible o agrego metodo a DB.
  // Agregaré un método getCollectionById a DB si hace falta,
  // O filtro de la lista rootCollections (cacheada).

  final allRoots = await ref.watch(rootCollectionsProvider.future);
  try {
    return allRoots.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});
