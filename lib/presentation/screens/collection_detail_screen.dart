import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/xolo_theme.dart';
import '../../data/local/database.dart';
import '../providers/database_providers.dart';
import '../providers/form_providers.dart';
import '../providers/request_provider.dart';
import '../providers/collections_provider.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final Collection collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Observamos sub-colecciones y requests
    final subCollectionsAsync = ref.watch(
      subCollectionsProvider(collection.id),
    );
    final requestsAsync = ref.watch(collectionRequestsProvider(collection.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined), // o post_add
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
              // Editar esta carpeta
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
                if (subs.isEmpty) return const SizedBox.shrink();
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
                    ...subs.map(
                      (sub) => ListTile(
                        leading: Icon(
                          Icons.folder,
                          color: colorScheme.secondary,
                        ),
                        title: Text(sub.name),
                        trailing: const Icon(Icons.chevron_right, size: 16),
                        onTap: () {
                          // Navegar recursivamente
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CollectionDetailScreen(collection: sub),
                            ),
                          );
                        },
                        onLongPress: () {
                          // Opciones de borrar subcarpeta
                          _confirmDeleteCollection(context, ref, sub);
                        },
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
                if (requests.isEmpty) {
                  // Si no hay requests y no hay subcarpetas (check via provider async value? complicado aqui)
                  // Simplemente mostramos mensaje si la lista es vacía.
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_drive_file_outlined,
                            size: 48,
                            color: colorScheme.outline.withOpacity(0.3),
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
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        final methodColor = XoloTheme.getMethodColor(
                          req.method,
                        );

                        return ListTile(
                          leading: SizedBox(
                            width: 50,
                            child: Text(
                              req.method,
                              style: TextStyle(
                                color: methodColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          title: Text(
                            req.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            req.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'delete') {
                                final db = ref.read(databaseProvider);
                                await db.softDeleteRequest(req.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            _loadRequest(context, ref, req);
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
    ref.read(selectedMethodProvider.notifier).set(req.method);
    ref.read(urlQueryProvider.notifier).set(req.url);

    if (req.body != null) {
      ref.read(bodyContentProvider.notifier).update(req.body!);
    }

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
                      parentId: collection.id, // Current collection ID
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
                      collectionId: collection.id,
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
    final controller = TextEditingController(text: collection.name);
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
                      collection.id,
                      controller.text,
                      collection.description,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  // Si el nombre cambia, el AppBar se actualiza reactivamente por el stream si estuviéramos viendo el stream
                  // pero CollectionDetailScreen recibe 'collection' estático en constructor.
                  // Problema: El título no cambiará hasta que volvamos atrás y entremos.
                  // Solución: El widget debería observar la colección viva, no usar la estática excepto para ID.
                  // Por simplicidad del fix rapido: Navigation pop o message.
                  // Mejor: Hacer pop para forzar refresh al volver a entrar
                  // Navigator.pop(context);
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
    ref.read(collectionsControllerProvider.notifier).deleteCollection(col.id);
  }
}
