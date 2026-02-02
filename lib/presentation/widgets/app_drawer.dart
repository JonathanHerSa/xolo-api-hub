import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../providers/collections_provider.dart';
import '../providers/workspace_provider.dart';
import '../screens/history_screen.dart';
import '../screens/environments_screen.dart';
import '../screens/collection_detail_screen.dart';
import 'import_collection_dialog.dart';
import 'create_collection_dialog.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final collectionsAsync = ref.watch(flattenedCollectionsStreamProvider);
    final activeId = ref.watch(activeWorkspaceIdProvider);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hub, size: 48, color: colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Xolo API Hub', style: theme.textTheme.titleLarge),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Standard Menu Items
                /* 
                ListTile(
                  leading: const Icon(Icons.folder_special),
                  title: const Text('All Requests'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SavedRequestsScreen()),
                    );
                  },
                ),
                */
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Historial'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.layers),
                  title: const Text('Entornos y Variables'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EnvironmentsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text('Importar Colección'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => const ImportCollectionDialog(),
                    );
                  },
                ),

                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'PROYECTOS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Collection Tree
                collectionsAsync.when(
                  data: (flattened) {
                    if (flattened.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No hay proyectos.'),
                      );
                    }
                    return Column(
                      children: flattened.map((item) {
                        final col = item.collection;
                        final depth = item.depth;
                        final isActive = activeId == col.id;

                        return InkWell(
                          onTap: () {
                            // Close drawer and navigate/set active
                            Navigator.pop(context);
                            // Set active workspace logic if it's a root?
                            // Or navigate to Detail Screen?
                            // Let's navigate to detail screen for drill down
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CollectionDetailScreen(collection: col),
                              ),
                            );

                            // Optional: Set as active workspace if root
                            if (col.parentId == null) {
                              ref
                                  .read(activeWorkspaceIdProvider.notifier)
                                  .setWorkspace(col.id);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 16.0 + (depth * 16.0),
                            ),
                            child: ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              selected: isActive,
                              leading: Icon(
                                depth == 0 ? Icons.folder : Icons.folder_open,
                                size: 20,
                                color: isActive ? colorScheme.primary : null,
                              ),
                              title: Text(
                                col.name,
                                style: TextStyle(
                                  fontWeight: depth == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isActive ? colorScheme.primary : null,
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 18),
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    showCreateCollectionDialog(
                                      context,
                                      ref,
                                      col.parentId,
                                      isWorkspace: col.parentId == null,
                                      collectionToEdit: col,
                                    );
                                  } else if (val == 'import') {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => ImportCollectionDialog(
                                        targetCollectionId: col.id,
                                      ),
                                    );
                                  } else if (val == 'delete') {
                                    _confirmDeleteCollection(context, ref, col);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit, size: 18),
                                      title: Text('Editar'),
                                      dense: true,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'import',
                                    child: ListTile(
                                      leading: Icon(Icons.input, size: 18),
                                      title: Text('Importar'),
                                      dense: true,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      title: Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      dense: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),
          // ... (Configuración)
        ],
      ),
    );
  }

  void _confirmDeleteCollection(
    BuildContext context,
    WidgetRef ref,
    Collection col,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar "${col.name}"?'),
        content: const Text('Se eliminarán todos los requests contenidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              ref
                  .read(collectionsControllerProvider.notifier)
                  .deleteCollection(col.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
