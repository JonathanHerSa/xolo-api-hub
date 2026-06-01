import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/premium_theme.dart';
import 'package:xolo/data/services/sync_service.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collections_provider.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/providers/tabs_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

class DraggableCollectionTile extends ConsumerWidget {
  final CollectionEntity collection;
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

    final subCollectionsAsync = ref.watch(
      subCollectionsProvider(collection.id),
    );
    final requestsAsync = ref.watch(collectionRequestsProvider(collection.id));

    return LongPressDraggable<CollectionEntity>(
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
          if (data is SavedRequestEntity) return true;
          if (data is CollectionEntity && data.id != collection.id) return true;
          return false;
        },
        onAcceptWithDetails: (details) async {
          final data = details.data;
          final l10n = AppLocalizations.of(context)!;
          final db = ref.read(xoloRepositoryProvider);
          if (data is SavedRequestEntity) {
            await db.moveRequest(data.id, collection.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.requestMovedToCollection(data.name, collection.name),
                  ),
                ),
              );
            }
          } else if (data is CollectionEntity) {
            await db.moveCollection(data.id, collection.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.projectMovedToCollection(data.name, collection.name),
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
              error: (_, _) =>
                  _buildTile(context, ref, isActive, isHovering, subs, []),
            ),
            loading: () =>
                _buildTile(context, ref, isActive, isHovering, [], []),
            error: (_, _) =>
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
    List<CollectionEntity> subCollections,
    List<SavedRequestEntity> requests,
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
        key: PageStorageKey('collection-${collection.id}'),
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
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          ...subCollections.map(
            (sub) => DraggableCollectionTile(
              collection: sub,
              activeWorkspaceId: activeWorkspaceId,
              onTap: () {},
              onActivate: () {
                ref
                    .read(activeWorkspaceIdProvider.notifier)
                    .setWorkspace(sub.id);
              },
              onDelete: () async {
                final db = ref.read(xoloRepositoryProvider);
                await db.deleteCollection(sub.id);
              },
            ),
          ),
          ...requests.map(
            (req) => DraggableRequestTile(
              req: req,
              onTap: () => _loadRequest(context, ref, req),
              onDelete: () async {
                final db = ref.read(xoloRepositoryProvider);
                await db.softDeleteRequest(req.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _loadRequest(
    BuildContext context,
    WidgetRef ref,
    SavedRequestEntity req,
  ) {
    final l10n = AppLocalizations.of(context)!;
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

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.loadedRequest(req.name)),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref, bool isActive) {
    final l10n = AppLocalizations.of(context)!;

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
                  SnackBar(content: Text(l10n.collectionExported)),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.exportError(e.toString()))),
                );
              }
            }
          }
        }
      },
      itemBuilder: (ctx) => [
        if (!isActive)
          PopupMenuItem(value: 'activate', child: Text(l10n.activateWorkspace)),
        PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.upload_file, size: 18, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text(l10n.syncExport),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class DraggableRequestTile extends StatelessWidget {
  final SavedRequestEntity req;
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
    return LongPressDraggable<SavedRequestEntity>(
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
              Icon(
                Icons.http,
                color: XoloPremiumTheme.getMethodColor(req.method),
              ),
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
    final methodColor = XoloPremiumTheme.getMethodColor(req.method);
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
