import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collections_provider.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/providers/tabs_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';
import 'package:xolo/presentation/screens/environments_screen.dart';
import 'package:xolo/presentation/widgets/create_collection_dialog.dart';
import 'package:xolo/presentation/widgets/import_collection_dialog.dart';

class ActiveWorkspaceExplorer extends ConsumerWidget {
  const ActiveWorkspaceExplorer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // 1. Get Active Workspace ID (null = Global / No Project Selected)
    final activeId = ref.watch(activeWorkspaceIdProvider);

    // 2. Fetch All Projects (Root Collections) for Selector
    final projectsAsync = ref.watch(rootCollectionsProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: projectsAsync.when(
          data: (projects) {
            String currentName = l10n.selectProject;
            if (activeId != null) {
              final found = projects.where((c) => c.id == activeId).firstOrNull;
              if (found != null) currentName = found.name;
            } else {
              currentName = l10n.allProjects;
            }

            return PopupMenuButton<int?>(
              initialValue: activeId,
              tooltip: l10n.selectProject,
              position: PopupMenuPosition.under,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: XoloSpacing.md,
                  vertical: XoloSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: XoloRadius.xl,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
              onSelected: (newId) {
                ref
                    .read(activeWorkspaceIdProvider.notifier)
                    .setWorkspace(newId);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: null,
                  child: Row(
                    children: [
                      const Icon(Icons.dashboard_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.allProjects),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                ...projects.map(
                  (c) => PopupMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        const Icon(Icons.folder_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => Text(l10n.loading),
          error: (_, _) => Text(l10n.activeWorkspace),
        ),
        centerTitle: true,
        actions: [
          if (activeId != null) ...[
            projectsAsync.when(
              data: (projects) {
                final activeProj = projects
                    .where((p) => p.id == activeId)
                    .firstOrNull;
                if (activeProj == null) return const SizedBox();
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.editProjectSettings,
                  onPressed: () => showCreateCollectionDialog(
                    context,
                    ref,
                    null,
                    isWorkspace: true,
                    collectionToEdit: activeProj,
                  ),
                );
              },
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),
            IconButton(
              icon: const Icon(Icons.layers_outlined),
              tooltip: l10n.environments,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EnvironmentsScreen()),
                );
              },
            ),
          ],

          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.newItem,
            onPressed: () {
              if (activeId == null) {
                showCreateCollectionDialog(context, ref, null);
              } else {
                showCreateCollectionDialog(context, ref, activeId);
              }
            },
          ),
        ],
      ),
      body: activeId == null
          ? _buildProjectsList(context, ref, projectsAsync)
          : _buildWorkspaceContent(context, ref, activeId),
    );
  }

  Widget _buildProjectsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CollectionEntity>> asyncProjects,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return asyncProjects.when(
      data: (projects) {
        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                ),
                const SizedBox(height: 16),
                Text(l10n.noProjectsYet),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () =>
                      showCreateCollectionDialog(context, ref, null),
                  child: Text(l10n.createFirstProject),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(XoloSpacing.lg),
          itemCount: projects.length,
          itemBuilder: (ctx, i) {
            final p = projects[i];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: XoloSpacing.md),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: XoloSpacing.lg,
                  vertical: XoloSpacing.sm,
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.14),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.folder_rounded),
                ),
                title: Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(l10n.projectNumber(p.id)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18),
                      onSelected: (val) {
                        if (val == 'edit') {
                          showCreateCollectionDialog(
                            context,
                            ref,
                            null,
                            isWorkspace: true,
                            collectionToEdit: p,
                          );
                        } else if (val == 'import') {
                          showDialog(
                            context: context,
                            builder: (ctx) => ImportCollectionDialog(
                              targetCollectionId: p.id,
                            ),
                          );
                        } else if (val == 'delete') {
                          _confirmDeleteProject(context, ref, p);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: const Icon(Icons.edit, size: 18),
                            title: Text(l10n.editProject),
                            dense: true,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'import',
                          child: ListTile(
                            leading: const Icon(Icons.input, size: 18),
                            title: Text(l10n.import),
                            dense: true,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            title: Text(
                              l10n.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
                onTap: () {
                  ref
                      .read(activeWorkspaceIdProvider.notifier)
                      .setWorkspace(p.id);
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(l10n.errorMessage(e.toString()))),
    );
  }

  // View: Contents of Active Project (Recursive Tree)
  Widget _buildWorkspaceContent(
    BuildContext context,
    WidgetRef ref,
    int workspaceId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final foldersAsync = ref.watch(subCollectionsProvider(workspaceId));
    final requestsAsync = ref.watch(collectionRequestsProvider(workspaceId));

    return foldersAsync.when(
      data: (folders) {
        return requestsAsync.when(
          data: (requests) {
            if (folders.isEmpty && requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Opacity(
                      opacity: 0.5,
                      child: Icon(Icons.folder_open, size: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.emptyProject),
                    TextButton.icon(
                      onPressed: () =>
                          showCreateCollectionDialog(context, ref, workspaceId),
                      icon: const Icon(Icons.create_new_folder),
                      label: Text(l10n.createFolder),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ...folders.map((f) => ExplorableFolderTile(collection: f)),
                ...requests.map((r) => RequestTile(request: r)),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, s) => Text(l10n.errorLoadingRequests(e.toString())),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(l10n.errorMessage(e.toString()))),
    );
  }
}

// -----------------------------------------------------------------------------
// RECURSIVE FOLDER TILE
// -----------------------------------------------------------------------------
class ExplorableFolderTile extends ConsumerWidget {
  final CollectionEntity collection;

  const ExplorableFolderTile({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Watch children
    final foldersAsync = ref.watch(subCollectionsProvider(collection.id));
    final requestsAsync = ref.watch(collectionRequestsProvider(collection.id));

    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        collapsedBackgroundColor: colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.18),
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.24,
        ),
        shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
        collapsedShape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
        leading: Icon(
          Icons.folder_rounded,
          color: colorScheme.primary,
          size: 20,
        ),
        title: Text(
          collection.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: XoloSpacing.md),
        childrenPadding: const EdgeInsets.fromLTRB(12, 4, 6, 10),
        minTileHeight: 46,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18),
          onSelected: (val) {
            if (val == 'edit') {
              showCreateCollectionDialog(
                context,
                ref,
                collection.parentId,
                isWorkspace: collection.parentId == null,
                collectionToEdit: collection,
              );
            } else if (val == 'import') {
              showDialog(
                context: context,
                builder: (ctx) =>
                    ImportCollectionDialog(targetCollectionId: collection.id),
              );
            } else if (val == 'delete') {
              _confirmDeleteFolder(context, ref, collection);
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: const Icon(Icons.edit, size: 18),
                title: Text(l10n.editFolder),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'import',
              child: ListTile(
                leading: const Icon(Icons.input, size: 18),
                title: Text(l10n.import),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: const Icon(Icons.delete, size: 18, color: Colors.red),
                title: Text(
                  l10n.delete,
                  style: const TextStyle(color: Colors.red),
                ),
                dense: true,
              ),
            ),
          ],
        ),
        children: [_buildChildren(context, foldersAsync, requestsAsync)],
      ),
    );
  }

  Widget _buildChildren(
    BuildContext context,
    AsyncValue<List<CollectionEntity>> foldersAsync,
    AsyncValue<List<SavedRequestEntity>> requestsAsync,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (foldersAsync.isLoading || requestsAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final folders = foldersAsync.asData?.value ?? [];
    final requests = requestsAsync.asData?.value ?? [];

    if (folders.isEmpty && requests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          l10n.emptyFolder,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      children: [
        ...folders.map((f) => ExplorableFolderTile(collection: f)),
        ...requests.map((r) => RequestTile(request: r)),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// REQUEST TILE
// -----------------------------------------------------------------------------
class RequestTile extends ConsumerWidget {
  final SavedRequestEntity request;

  const RequestTile({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: XoloRadius.md,
      onTap: () {
        final tabs = ref.read(tabsProvider);
        final activeTab = tabs.activeTabId;

        ref
            .read(requestSessionControllerProvider(activeTab))
            .loadRequest(request);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(4, 0, 4, 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: XoloRadius.md,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.16),
        ),
        child: Row(
          children: [
            _buildMethodBadge(context, request.method),
            const SizedBox(width: XoloSpacing.md),
            Expanded(
              child: Text(
                request.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodBadge(BuildContext context, String method) {
    Color color = Colors.grey;
    if (method == 'GET') {
      color = Colors.green;
    } else if (method == 'POST') {
      color = Colors.orange;
    } else if (method == 'PUT') {
      color = Colors.blue;
    } else if (method == 'DELETE') {
      color = Colors.red;
    }

    return Container(
      width: 40,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: XoloRadius.sm,
      ),
      alignment: Alignment.center,
      child: Text(
        method.substring(0, method.length > 3 ? 3 : method.length),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------

void _confirmDeleteProject(
  BuildContext context,
  WidgetRef ref,
  CollectionEntity p,
) {
  final l10n = AppLocalizations.of(context)!;
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteNamedTitle(p.name)),
      content: Text(l10n.deleteProjectMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            ref
                .read(collectionsControllerProvider.notifier)
                .deleteCollection(p.id);
            Navigator.pop(ctx);
          },
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
}

void _confirmDeleteFolder(
  BuildContext context,
  WidgetRef ref,
  CollectionEntity f,
) {
  final l10n = AppLocalizations.of(context)!;
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteNamedTitle(f.name)),
      content: Text(l10n.deleteFolderMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            ref
                .read(collectionsControllerProvider.notifier)
                .deleteCollection(f.id);
            Navigator.pop(ctx);
          },
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
}
