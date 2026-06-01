import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xolo/core/router/app_router.dart';
import 'package:xolo/core/theme/premium_theme.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collections_provider.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/providers/tabs_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';
import 'package:xolo/presentation/widgets/create_collection_dialog.dart';
import 'package:xolo/presentation/widgets/import_collection_dialog.dart';
import 'package:xolo/presentation/widgets/ui/xolo_empty_state.dart';
import 'package:xolo/presentation/widgets/ui/xolo_interactive_card.dart';
import 'package:xolo/presentation/widgets/ui/xolo_section_header.dart';

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
        centerTitle: false,
        titleSpacing: 16,
        title: _ProjectSelector(
          activeId: activeId,
          projectsAsync: projectsAsync,
          l10n: l10n,
        ),
        actions: [
          IconButton(
            tooltip: l10n.import,
            icon: const Icon(Icons.upload_file_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) =>
                    ImportCollectionDialog(targetCollectionId: activeId),
              );
            },
          ),
          if (activeId != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.editProjectSettings,
              onPressed: projectsAsync.hasValue
                  ? () {
                      final activeProj = projectsAsync.asData!.value
                          .where((p) => p.id == activeId)
                          .firstOrNull;
                      if (activeProj == null) return;
                      showCreateCollectionDialog(
                        context,
                        ref,
                        null,
                        isWorkspace: true,
                        collectionToEdit: activeProj,
                      );
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.layers_outlined),
              tooltip: l10n.environments,
              onPressed: () => context.go(AppRoutes.environments),
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
          return XoloEmptyState(
            icon: Icons.folder_open_rounded,
            title: l10n.noProjectsYet,
            subtitle: l10n.createProjectHint,
            actions: [
              FilledButton.tonalIcon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const ImportCollectionDialog(),
                  );
                },
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(l10n.importApiProject),
              ),
              FilledButton.icon(
                onPressed: () =>
                    showCreateCollectionDialog(context, ref, null),
                icon: const Icon(Icons.add),
                label: Text(l10n.createFirstProject),
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            XoloSpacing.lg,
            0,
            XoloSpacing.lg,
            XoloSpacing.lg,
          ),
          children: [
            XoloSectionHeader(
              title: l10n.projects.toUpperCase(),
              subtitle: l10n.createProjectHint,
              icon: Icons.folder_copy_outlined,
              padding: const EdgeInsets.only(bottom: XoloSpacing.md),
            ),
            ...projects.map((p) => _ProjectCard(project: p)),
          ],
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
              return XoloEmptyState(
                icon: Icons.create_new_folder_outlined,
                title: l10n.emptyProject,
                subtitle: l10n.createFolder,
                actions: [
                  FilledButton.icon(
                    onPressed: () =>
                        showCreateCollectionDialog(context, ref, workspaceId),
                    icon: const Icon(Icons.create_new_folder_outlined),
                    label: Text(l10n.createFolder),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                XoloSpacing.lg,
                XoloSpacing.sm,
                XoloSpacing.lg,
                XoloSpacing.lg,
              ),
              children: [
                XoloSectionHeader(
                  title: l10n.collections.toUpperCase(),
                  icon: Icons.account_tree_outlined,
                  padding: const EdgeInsets.only(bottom: XoloSpacing.sm),
                ),
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

class _ProjectCard extends ConsumerWidget {
  const _ProjectCard({required this.project});

  final CollectionEntity project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return XoloInteractiveCard(
      onTap: () {
        ref.read(activeWorkspaceIdProvider.notifier).setWorkspace(project.id);
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: XoloRadius.md,
            ),
            child: Icon(
              Icons.folder_rounded,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: XoloSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: XoloTypography.cardTitle(colorScheme),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.projectNumber(project.id),
                  style: XoloTypography.meta(colorScheme),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18),
            onSelected: (val) {
              if (val == 'edit') {
                showCreateCollectionDialog(
                  context,
                  ref,
                  null,
                  isWorkspace: true,
                  collectionToEdit: project,
                );
              } else if (val == 'import') {
                showDialog(
                  context: context,
                  builder: (ctx) => ImportCollectionDialog(
                    targetCollectionId: project.id,
                  ),
                );
              } else if (val == 'delete') {
                _confirmDeleteProject(context, ref, project);
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
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _ProjectSelector extends ConsumerWidget {
  const _ProjectSelector({
    required this.activeId,
    required this.projectsAsync,
    required this.l10n,
  });

  final int? activeId;
  final AsyncValue<List<CollectionEntity>> projectsAsync;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final reservedActions = activeId != null ? 220.0 : 140.0;
    final maxWidth = (screenWidth - reservedActions - 48).clamp(120.0, 360.0);
    final projects = projectsAsync.asData?.value ?? const <CollectionEntity>[];
    final isLoading = projectsAsync.isLoading && projects.isEmpty;

    var currentName = l10n.selectProject;
    if (isLoading) {
      currentName = l10n.loading;
    } else if (activeId != null) {
      final found = projects.where((c) => c.id == activeId).firstOrNull;
      if (found != null) currentName = found.name;
    } else {
      currentName = l10n.allProjects;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: PopupMenuButton<int?>(
        enabled: !isLoading,
        initialValue: activeId,
        tooltip: l10n.selectProject,
        position: PopupMenuPosition.under,
        onSelected: (newId) {
          ref.read(activeWorkspaceIdProvider.notifier).setWorkspace(newId);
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: null,
            child: Row(
              children: [
                const Icon(Icons.dashboard_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.allProjects,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                  Expanded(
                    child: Text(
                      c.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: XoloSpacing.md,
            vertical: XoloSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: XoloRadius.lg,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  currentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
      ),
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
    final methodColor = XoloPremiumTheme.getMethodColor(request.method);
    final methodLabel = request.method.length > 3
        ? request.method.substring(0, 3)
        : request.method;

    return XoloInteractiveCard(
      margin: const EdgeInsets.fromLTRB(4, 0, 4, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: XoloRadius.md,
      onTap: () {
        final tabs = ref.read(tabsProvider);
        final activeTab = tabs.activeTabId;

        ref
            .read(requestSessionControllerProvider(activeTab))
            .loadRequest(request);
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: methodColor.withValues(alpha: 0.14),
              borderRadius: XoloRadius.sm,
              border: Border.all(color: methodColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              methodLabel,
              style: TextStyle(
                color: methodColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: XoloSpacing.md),
          Expanded(
            child: Text(
              request.name,
              style: XoloTypography.cardTitle(colorScheme).copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
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
