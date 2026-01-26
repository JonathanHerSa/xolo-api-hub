import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../providers/database_providers.dart';
import '../providers/collections_provider.dart';
import '../providers/workspace_provider.dart';
import '../widgets/create_collection_dialog.dart';
import 'collection_detail_screen.dart';
import 'environments_screen.dart';
import 'package:xolo/presentation/providers/tabs_provider.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'composer_screen.dart';

class ActiveWorkspaceExplorer extends ConsumerWidget {
  const ActiveWorkspaceExplorer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get Active Workspace ID (null = Global / No Project Selected)
    final activeId = ref.watch(activeWorkspaceIdProvider);

    // 2. Fetch All Projects (Root Collections) for Selector
    final projectsAsync = ref.watch(rootCollectionsProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: projectsAsync.when(
          data: (projects) {
            String currentName = 'Select Project';
            if (activeId != null) {
              final found = projects.where((c) => c.id == activeId).firstOrNull;
              if (found != null) currentName = found.name;
            } else {
              currentName = 'All Projects';
            }

            return PopupMenuButton<int?>(
              initialValue: activeId,
              tooltip: 'Select Project',
              position: PopupMenuPosition.under,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
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
                const PopupMenuItem(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.dashboard_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('All Projects'),
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
                        SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Text("Loading..."),
          error: (_, __) => const Text("Active Workspace"),
        ),
        centerTitle: true,
        actions: [
          if (activeId != null)
            IconButton(
              icon: const Icon(Icons.layers_outlined),
              tooltip: 'Environments',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EnvironmentsScreen()),
                );
              },
            ),

          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Item',
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
    AsyncValue<List<Collection>> asyncProjects,
  ) {
    return asyncProjects.when(
      data: (projects) {
        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("No Projects Yet"),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () =>
                      showCreateCollectionDialog(context, ref, null),
                  child: const Text("Create First Project"),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (ctx, i) {
            final p = projects[i];
            return Card(
              elevation: 0,
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.folder)),
                title: Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('ID: ${p.id}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  // View: Contents of Active Project (Recursive Tree)
  Widget _buildWorkspaceContent(
    BuildContext context,
    WidgetRef ref,
    int workspaceId,
  ) {
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
                    const Text("Empty Project"),
                    TextButton.icon(
                      onPressed: () =>
                          showCreateCollectionDialog(context, ref, workspaceId),
                      icon: const Icon(Icons.create_new_folder),
                      label: const Text("Create Folder"),
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
          error: (e, s) => Text("Error loading requests: $e"),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }
}

// -----------------------------------------------------------------------------
// RECURSIVE FOLDER TILE
// -----------------------------------------------------------------------------
class ExplorableFolderTile extends ConsumerWidget {
  final Collection collection;

  const ExplorableFolderTile({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch children
    final foldersAsync = ref.watch(subCollectionsProvider(collection.id));
    final requestsAsync = ref.watch(collectionRequestsProvider(collection.id));

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(Icons.folder, color: Colors.amber, size: 20),
        title: Text(collection.name, style: const TextStyle(fontSize: 14)),
        minTileHeight: 40,
        childrenPadding: const EdgeInsets.only(left: 16), // Indent
        children: [_buildChildren(foldersAsync, requestsAsync)],
      ),
    );
  }

  Widget _buildChildren(
    AsyncValue<List<Collection>> foldersAsync,
    AsyncValue<List<SavedRequest>> requestsAsync,
  ) {
    if (foldersAsync.isLoading || requestsAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final folders = foldersAsync.asData?.value ?? [];
    final requests = requestsAsync.asData?.value ?? [];

    if (folders.isEmpty && requests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Empty Folder",
          style: TextStyle(
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
  final SavedRequest request;

  const RequestTile({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.only(left: 8, right: 16),
      leading: _buildMethodBadge(context, request.method),
      title: Text(
        request.name,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        // OPEN REQUEST IN COMPOSER
        final tabs = ref.read(tabsProvider);
        final activeTab = tabs.activeTabId;

        ref
            .read(requestSessionControllerProvider(activeTab))
            .loadRequest(request);

        // Todo: Switch Tab
      },
    );
  }

  Widget _buildMethodBadge(BuildContext context, String method) {
    Color color = Colors.grey;
    if (method == 'GET') {
      color = Colors.green;
    } else if (method == 'POST')
      color = Colors.orange;
    else if (method == 'PUT')
      color = Colors.blue;
    else if (method == 'DELETE')
      color = Colors.red;

    return Container(
      width: 36,
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
