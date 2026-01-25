import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../providers/database_providers.dart';
import '../providers/form_providers.dart';
import '../providers/collections_provider.dart';
import '../providers/workspace_provider.dart';
import '../providers/tabs_provider.dart';
import '../providers/request_session_provider.dart';
import 'collection_detail_screen.dart';
import '../widgets/draggable_tiles.dart'; // IMPORT SHARED TILES

class SavedRequestsScreen extends ConsumerStatefulWidget {
  const SavedRequestsScreen({super.key});

  @override
  ConsumerState<SavedRequestsScreen> createState() =>
      _SavedRequestsScreenState();
}

class _SavedRequestsScreenState extends ConsumerState<SavedRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final rootCollectionsAsync = ref.watch(rootCollectionsProvider);
    final unclassifiedAsync = ref.watch(unclassifiedRequestsProvider);
    final activeWorkspaceId = ref.watch(activeWorkspaceIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Proyectos y Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'Nuevo Proyecto',
            onPressed: () => _showCreateCollectionDialog(null),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- WORKSPACES / COLLECTIONS ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'PROYECTOS / WORKSPACES',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontSize: 12,
                ),
              ),
            ),

            rootCollectionsAsync.when(
              data: (collections) {
                if (collections.isEmpty) {
                  return _buildEmptyState(colorScheme);
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final col = collections[index];
                    return DraggableCollectionTile(
                      collection: col,
                      activeWorkspaceId: activeWorkspaceId,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CollectionDetailScreen(collection: col),
                          ),
                        );
                      },
                      onActivate: () {
                        ref
                            .read(activeWorkspaceIdProvider.notifier)
                            .setWorkspace(col.id);
                      },
                      onDelete: () => _confirmDeleteCollection(col),
                    );
                  },
                );
              },
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),

            const Divider(height: 32),

            // --- UNCLASSIFIED REQUESTS ---
            DragTarget<SavedRequest>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) {
                final req = details.data;
                ref.read(databaseProvider).moveRequest(req.id, null);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Request "${req.name}" movido a raíz'),
                  ),
                );
              },
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;

                return Container(
                  color: isHovering
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'SIN CLASIFICAR (RAÍZ)',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.bug_report_outlined,
                              size: 16,
                              color: colorScheme.outline,
                            ),
                          ],
                        ),
                      ),

                      unclassifiedAsync.when(
                        data: (requests) {
                          if (requests.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  'Arrastra requests aquí para sacarlos de carpetas',
                                  style: TextStyle(
                                    color: colorScheme.outline,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: requests.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, indent: 16),
                            itemBuilder: (ctx, index) {
                              final req = requests[index];
                              return DraggableRequestTile(
                                req: req,
                                onTap: () => _loadRequest(req),
                                onDelete: () {
                                  ref
                                      .read(databaseProvider)
                                      .softDeleteRequest(req.id);
                                },
                              );
                            },
                          );
                        },
                        loading: () => const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, s) => Text('Error: $e'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: colorScheme.tertiary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Crea un proyecto para aislar tus entornos y variables.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadRequest(SavedRequest req) {
    // 1. Create new tab
    final newTabId = ref.read(tabsProvider.notifier).addTab();

    // 2. Populate Session State
    final sessionController = ref.read(
      requestSessionControllerProvider(newTabId),
    );
    sessionController.setMethod(req.method);
    sessionController.setUrl(req.url);
    sessionController.setName(req.name);

    if (req.body != null) {
      sessionController.setBody(req.body!);
    }
    // 3. Set Active
    ref.read(tabsProvider.notifier).setActiveTab(newTabId);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Cargado: ${req.name}')));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _showCreateCollectionDialog(int? parentId) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Proyecto / Carpeta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref
                    .read(collectionsControllerProvider.notifier)
                    .createCollection(
                      name: controller.text,
                      parentId: parentId,
                    );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCollection(Collection col) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar "${col.name}"?'),
        content: const Text(
          'Se eliminarán todos los requests y entornos contenidos. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final activeId = ref.read(activeWorkspaceIdProvider);
              if (activeId == col.id) {
                ref.read(activeWorkspaceIdProvider.notifier).setWorkspace(null);
              }
              await ref.read(databaseProvider).deleteCollection(col.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );
  }
}

// FUNCION GLOBAL PARA LLAMAR DESDE HOME
Future<void> showSaveRequestDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  await showDialog(
    context: context,
    builder: (context) => _SaveRequestDialog(ref: ref),
  );
}

class _SaveRequestDialog extends StatefulWidget {
  final WidgetRef ref;
  const _SaveRequestDialog({required this.ref});

  @override
  State<_SaveRequestDialog> createState() => _SaveRequestDialogState();
}

class _SaveRequestDialogState extends State<_SaveRequestDialog> {
  final _nameCtrl = TextEditingController();
  int? _selectedCollectionId; // Null = Unclassified

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = widget.ref.watch(
      flattenedCollectionsStreamProvider,
    );

    return AlertDialog(
      title: const Text('Guardar Request'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del Request',
                hintText: 'Ej: Get Users',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              decoration: const InputDecoration(
                labelText: 'Carpeta / Proyecto',
              ),
              initialValue: _selectedCollectionId,
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Sin Clasificar (Raíz)'),
                ),
                ...collectionsAsync.when(
                  data: (cols) => cols.map(
                    (c) => DropdownMenuItem(
                      value: c.collection.id,
                      child: Text(
                        '${'  ' * c.depth}${c.depth > 0 ? '└ ' : ''}${c.collection.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  loading: () => [],
                  error: (_, __) => [],
                ),
              ],
              onChanged: (val) => setState(() => _selectedCollectionId = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          label: const Text('Guardar'),
          icon: const Icon(Icons.save),
          onPressed: () async {
            if (_nameCtrl.text.isEmpty) return;

            final name = _nameCtrl.text;
            final collectionId = _selectedCollectionId;

            final method = widget.ref.read(selectedMethodProvider);
            final url = widget.ref.read(urlQueryProvider);
            final body = widget.ref.read(bodyContentProvider);

            await widget.ref
                .read(databaseProvider)
                .createRequest(
                  name: name,
                  method: method,
                  url: url,
                  body: body,
                  collectionId: collectionId,
                );

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request guardado exitosamente')),
              );
            }
          },
        ),
      ],
    );
  }
}
