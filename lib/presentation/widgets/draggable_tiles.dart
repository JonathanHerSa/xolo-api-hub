import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/xolo_theme.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/services/sync_service.dart';
import '../../data/local/database.dart';
import '../providers/collections_provider.dart';
import '../providers/request_session_provider.dart';
import '../providers/tabs_provider.dart';
import '../providers/database_providers.dart';
import '../providers/workspace_provider.dart';

class DraggableCollectionTile extends ConsumerWidget {
  final Collection collection;
  final int? activeWorkspaceId;
  final VoidCallback onTap;
  final VoidCallback onActivate;
  final VoidCallback onDelete;

  const DraggableCollectionTile({
    super.key,
    required this.collection,
    required this.activeWorkspaceId,
    required this.onTap,
    required this.onActivate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = activeWorkspaceId == collection.id;

    // Fetch Children
    final subCollectionsAsync = ref.watch(
      subCollectionsProvider(collection.id),
    );
    final requestsAsync = ref.watch(collectionRequestsProvider(collection.id));

    return LongPressDraggable<Collection>(
      data: collection,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceContainer,
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 250,
          child: Row(
            children: [
              const Icon(Icons.folder, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(collection.name, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTile(context, ref, isActive, false, [], []),
      ),
      child: DragTarget<Object>(
        onWillAcceptWithDetails: (details) {
          final data = details.data;
          if (data is SavedRequest) return true;
          if (data is Collection && data.id != collection.id) return true;
          return false;
        },
        onAcceptWithDetails: (details) async {
          final data = details.data;
          final db = ref.read(databaseProvider);
          if (data is SavedRequest) {
            await db.moveRequest(data.id, collection.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Request "${data.name}" movido a "${collection.name}"',
                  ),
                ),
              );
            }
          } else if (data is Collection) {
            await db.moveCollection(data.id, collection.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Proyecto "${data.name}" movido dentro de "${collection.name}"',
                  ),
                ),
              );
            }
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;

          return subCollectionsAsync.when(
            data: (subs) => requestsAsync.when(
              data: (reqs) =>
                  _buildTile(context, ref, isActive, isHovering, subs, reqs),
              loading: () =>
                  _buildTile(context, ref, isActive, isHovering, subs, []),
              error: (_, __) =>
                  _buildTile(context, ref, isActive, isHovering, subs, []),
            ),
            loading: () =>
                _buildTile(context, ref, isActive, isHovering, [], []),
            error: (_, __) =>
                _buildTile(context, ref, isActive, isHovering, [], []),
          );
        },
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    WidgetRef ref,
    bool isActive,
    bool isHovering,
    List<Collection> subCollections,
    List<SavedRequest> requests,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasChildren = subCollections.isNotEmpty || requests.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isHovering ? colorScheme.primary.withValues(alpha: 0.1) : null,
        border: isHovering ? Border.all(color: colorScheme.primary) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        key: PageStorageKey(
          'collection-${collection.id}',
        ), // Keep expansion state
        leading: Icon(
          isActive ? Icons.folder_special : Icons.folder,
          color: isActive ? colorScheme.primary : colorScheme.secondary,
        ),
        title: Text(
          collection.name,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? colorScheme.primary : null,
          ),
        ),
        subtitle: collection.description != null
            ? Text(collection.description!)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPopupMenu(context, ref, isActive),
            if (hasChildren)
              Icon(
                Icons.keyboard_arrow_down,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 16),
        shape: const Border(), // Remove borders when expanded
        collapsedShape: const Border(),
        children: [
          // 1. Sub-Collections (Recursive)
          ...subCollections.map(
            (sub) => DraggableCollectionTile(
              collection: sub,
              activeWorkspaceId: activeWorkspaceId,
              onTap: () {}, // No-op, expansion handles it
              onActivate: () {
                ref
                    .read(activeWorkspaceIdProvider.notifier)
                    .setWorkspace(sub.id);
              },
              onDelete: () async {
                final db = ref.read(databaseProvider);
                await db.deleteCollection(sub.id);
              },
            ),
          ),

          // 2. Requests
          ...requests.map(
            (req) => DraggableRequestTile(
              req: req,
              onTap: () => _loadRequest(context, ref, req),
              onDelete: () async {
                final db = ref.read(databaseProvider);
                await db.softDeleteRequest(req.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _loadRequest(BuildContext context, WidgetRef ref, SavedRequest req) {
    // Shared Logic: Open Tab
    final newTabId = ref.read(tabsProvider.notifier).addTab();

    final sessionController = ref.read(
      requestSessionControllerProvider(newTabId),
    );
    sessionController.setMethod(req.method);
    sessionController.setUrl(req.url);
    sessionController.setName(req.name);

    if (req.body != null) {
      sessionController.setBody(req.body!);
    }

    ref.read(tabsProvider.notifier).setActiveTab(newTabId);

    // If we are in a Dialog or Drawer, close it?
    // Usually tree view is on main screen, so no pop needed unless mobile drawer.
    // But since this is recursive, we might be deep.
    // For now, simple Snackbar feedback.
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cargado: ${req.name}'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref, bool isActive) {
    return PopupMenuButton<String>(
      onSelected: (val) async {
        if (val == 'delete') onDelete();
        if (val == 'activate') onActivate();
        if (val == 'export') {
          final dir = await FilePicker.platform.getDirectoryPath();
          if (dir != null) {
            try {
              final db = ref.read(databaseProvider);
              await ref
                  .read(syncServiceProvider)
                  .exportCollection(
                    collection: collection,
                    directoryPath: dir,
                    db: db,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Colección exportada correctamente'),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error exportando: $e')));
              }
            }
          }
        }
      },
      itemBuilder: (ctx) => [
        if (!isActive)
          const PopupMenuItem(
            value: 'activate',
            child: Text('Activar Workspace'),
          ),
        const PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.upload_file, size: 18, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text('Sync / Export'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class DraggableRequestTile extends StatelessWidget {
  final SavedRequest req;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DraggableRequestTile({
    super.key,
    required this.req,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<SavedRequest>(
      data: req,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 300,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Row(
            children: [
              Icon(Icons.http, color: XoloTheme.getMethodColor(req.method)),
              const SizedBox(width: 8),
              Expanded(child: Text(req.name, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildTile(context)),
      child: _buildTile(context),
    );
  }

  Widget _buildTile(BuildContext context) {
    final methodColor = XoloTheme.getMethodColor(req.method);
    return ListTile(
      dense: true,
      leading: Text(
        req.method,
        style: TextStyle(color: methodColor, fontWeight: FontWeight.bold),
      ),
      title: Text(req.name),
      subtitle: Text(req.url, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: onDelete,
      ),
    );
  }
}
