import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import 'database_providers.dart';

// Helper Class for UI
class FlattenedCollection {
  final Collection collection;
  final int depth;
  FlattenedCollection(this.collection, this.depth);
}

// -----------------------------------------------------------------------------
// STREAMS (LECTURA)
// -----------------------------------------------------------------------------

/// Obtiene los proyectos (Colecciones Raíz)
final rootCollectionsProvider = StreamProvider<List<Collection>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRootCollections();
});

/// Obtiene subcarpetas dado un parentId
final subCollectionsProvider = StreamProvider.family<List<Collection>, int>((
  ref,
  parentId,
) {
  final db = ref.watch(databaseProvider);
  return db.watchSubCollections(parentId);
});

/// Obtiene TODAS las colecciones aplanadas con nivel de profundidad (para Dropdowns)
final flattenedCollectionsStreamProvider =
    StreamProvider<List<FlattenedCollection>>((ref) {
      final db = ref.watch(databaseProvider);

      return db.watchAllCollections().map((all) {
        // A pesar del order by SQL, asegurar orden por nombre para consistencia visual
        all.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

        // Construir mapa de hijos
        final childrenMap = <int, List<Collection>>{};
        for (final c in all) {
          if (c.parentId != null) {
            childrenMap.putIfAbsent(c.parentId!, () => []).add(c);
          }
        }

        final flattened = <FlattenedCollection>[];

        // Función recursiva
        void traverse(Collection c, int depth) {
          flattened.add(FlattenedCollection(c, depth));
          final children = childrenMap[c.id] ?? [];
          for (final child in children) {
            traverse(child, depth + 1);
          }
        }

        // Empezar por las raíces
        final roots = all.where((c) => c.parentId == null);
        for (final r in roots) {
          traverse(r, 0);
        }

        return flattened;
      });
    });

/// Obtiene requests de una colección específica
final collectionRequestsProvider =
    StreamProvider.family<List<SavedRequest>, int>((ref, collectionId) {
      final db = ref.watch(databaseProvider);
      return db.watchRequestsInCollection(collectionId);
    });

/// Obtiene requests sin clasificar (para la pantalla principal)
final unclassifiedRequestsProvider = StreamProvider<List<SavedRequest>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchUnclassifiedRequests();
});

/// Obtiene el path (breadcrumbs) de una colección
final collectionBreadcrumbsProvider =
    FutureProvider.family<List<Collection>, int>((ref, collectionId) {
      final db = ref.watch(databaseProvider);
      return db.getCollectionPath(collectionId);
    });

// -----------------------------------------------------------------------------
// NOTIFIER (LOGICA / ESCRITURA)
// -----------------------------------------------------------------------------

class CollectionsController extends Notifier<void> {
  // Acceso lazy a DB
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  void build() {}

  /// Crear un Proyecto (Raíz) o Carpeta
  Future<void> createCollection({
    required String name,
    String? description,
    int? parentId,
  }) async {
    if (name.trim().isEmpty) return;

    // 1. Crear la colección
    final newId = await _db.createCollection(
      name: name.trim(),
      description: description,
      parentId: parentId,
    );

    // 2. Si es Raíz (Workspace), crear entornos default
    if (parentId == null) {
      await _createDefaultEnvironments(newId);
    }
  }

  Future<void> _createDefaultEnvironments(int workspaceId) async {
    final envs = ['Development', 'Staging', 'Production'];
    for (final envName in envs) {
      final envId = await _db.createEnvironment(envName, workspaceId);
      // 3. Crear variable baseUrl obligatoria
      await _db.upsertVariable(
        key: 'baseUrl',
        value: 'https://${envName.toLowerCase()}.api.example.com',
        environmentId: envId,
        workspaceId:
            workspaceId, // redundante si envId está set, pero consistente
      );

      // 4. Activar "Development" por defecto
      if (envName == 'Development') {
        await _db.setActiveEnvironment(envId, workspaceId);
      }
    }
  }

  /// Renombrar Colección
  Future<void> renameCollection(
    int id,
    String name,
    String? description,
  ) async {
    if (name.trim().isEmpty) return;
    await _db.updateCollection(id, name.trim(), description);
  }

  /// Eliminar Colección (y todo su contenido recursivamente)
  Future<void> deleteCollection(int id) async {
    await _db.deleteCollection(id);
  }

  /// Mover un request a una colección
  Future<void> moveRequestToCollection(int requestId, int? collectionId) async {
    await _db.moveRequest(requestId, collectionId);
  }
}

final collectionsControllerProvider =
    NotifierProvider<CollectionsController, void>(CollectionsController.new);
