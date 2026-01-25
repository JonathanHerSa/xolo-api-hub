import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../providers/database_providers.dart';
import '../providers/collections_provider.dart';
import '../providers/workspace_provider.dart';
import '../providers/tabs_provider.dart';
import '../providers/request_session_provider.dart';
import '../widgets/draggable_tiles.dart';

class CollectionDetailScreen extends ConsumerStatefulWidget {
  final Collection collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  ConsumerState<CollectionDetailScreen> createState() =>
      _CollectionDetailScreenState();
}

class _CollectionDetailScreenState
    extends ConsumerState<CollectionDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeWorkspaceId = ref.watch(activeWorkspaceIdProvider);

    // Observamos sub-colecciones y requests
    final subCollectionsAsync = ref.watch(
      subCollectionsProvider(widget.collection.id), // Use widget.collection
    );
    final requestsAsync = ref.watch(
      collectionRequestsProvider(widget.collection.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar en ${widget.collection.name}...',
                prefixIcon: const Icon(Icons.search, size: 20),
                prefixIconConstraints: const BoxConstraints(minWidth: 36),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            tooltip: 'Nuevo Request',
            onPressed: () => _showCreateRequestDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'Nueva Subcarpeta',
            onPressed: () => _showCreateSubCollectionDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              _showEditCollectionDialog(context, ref);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCIÓN: SUBCARPETAS
            subCollectionsAsync.when(
              data: (subs) {
                // Filter
                final filtered = subs
                    .where((s) => s.name.toLowerCase().contains(_searchQuery))
                    .toList();
                if (filtered.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'CARPETAS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                    ...filtered.map(
                      (sub) => DraggableCollectionTile(
                        collection: sub,
                        activeWorkspaceId: activeWorkspaceId,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CollectionDetailScreen(collection: sub),
                            ),
                          );
                        },
                        onActivate: () {
                          ref
                              .read(activeWorkspaceIdProvider.notifier)
                              .setWorkspace(sub.id);
                        },
                        onDelete: () =>
                            _confirmDeleteCollection(context, ref, sub),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // SECCIÓN: REQUESTS
            requestsAsync.when(
              data: (requests) {
                // Filter
                final filtered = requests
                    .where((r) => r.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filtered.isEmpty) {
                  if (_searchQuery.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No se encontraron requests',
                          style: TextStyle(color: colorScheme.outline),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_drive_file_outlined,
                            size: 48,
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay requests aquí',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'REQUESTS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final req = filtered[index];
                        return DraggableRequestTile(
                          req: req,
                          onTap: () => _loadRequest(context, ref, req),
                          onDelete: () async {
                            final db = ref.read(databaseProvider);
                            await db.softDeleteRequest(req.id);
                          },
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Padding(
                padding: EdgeInsets.all(16),
                child: Text('Error: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadRequest(BuildContext context, WidgetRef ref, SavedRequest req) {
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

  Future<void> _showCreateSubCollectionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Subcarpeta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref
                    .read(collectionsControllerProvider.notifier)
                    .createCollection(
                      name: controller.text,
                      parentId: widget.collection.id, // Current collection ID
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Crear Folder'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateRequestDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameCtrl = TextEditingController();
    String selectedMethod = 'GET';

    final methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nuevo Request'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod,
                  decoration: const InputDecoration(labelText: 'Método'),
                  items: methods
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => selectedMethod = val ?? 'GET'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty) {
                    final db = ref.read(databaseProvider);
                    await db.createRequest(
                      name: nameCtrl.text,
                      method: selectedMethod,
                      url: '',
                      collectionId: widget.collection.id,
                    );

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request creado')),
                      );
                    }
                  }
                },
                child: const Text('Crear Request'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditCollectionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController(text: widget.collection.name);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renombrar Carpeta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nuevo Nombre'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref
                    .read(collectionsControllerProvider.notifier)
                    .renameCollection(
                      widget.collection.id,
                      controller.text,
                      widget.collection.description,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context); // Force refresh by going back
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCollection(
    BuildContext context,
    WidgetRef ref,
    Collection col,
  ) {
    // Show confirmation logic
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar "${col.name}"?'),
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
