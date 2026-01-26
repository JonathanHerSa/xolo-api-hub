import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../providers/database_providers.dart';
import '../providers/collections_provider.dart';
import '../providers/workspace_provider.dart';
import '../widgets/create_collection_dialog.dart';
import 'collection_detail_screen.dart';

class CollectionsBrowserScreen extends ConsumerWidget {
  const CollectionsBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(rootCollectionsProvider);
    final activeId = ref.watch(activeWorkspaceIdProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Project',
            onPressed: () {
              showCreateCollectionDialog(
                context,
                ref,
                null, // No parent, root collection
                isWorkspace: true,
              );
            },
          ),
        ],
      ),
      body: collectionsAsync.when(
        data: (collections) {
          if (collections.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  const Text('No projects yet'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () {
                      showCreateCollectionDialog(
                        context,
                        ref,
                        null, // No parent, root collection
                        isWorkspace: true,
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Project'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Special "Global" Item? Maybe. Or just list Workspaces.
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: activeId == null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: activeId == null
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  child: const Icon(Icons.public),
                ),
                title: const Text('Global Context'),
                subtitle: const Text('Shared space'),
                trailing: activeId == null
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () {
                  ref
                      .read(activeWorkspaceIdProvider.notifier)
                      .setWorkspace(null);
                  // Navigation? If we are in a TabView, usually we stay here or go to Composer.
                  // User probably wants to go to Composer to work.
                  // But let's leave navigation to the TabBar logic (user taps Composer tab).
                  // Or toast "Switched to Global".
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Switched to Global Context'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const Divider(),
              ...collections.map((col) {
                final isActive = activeId == col.id;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: isActive
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    child: Text(col.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(
                    col.name,
                    style: TextStyle(
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: col.description != null
                      ? Text(col.description!, maxLines: 1)
                      : null,
                  trailing: isActive
                      ? const Icon(Icons.check_circle)
                      : const Icon(Icons.chevron_right),
                  onTap: () {
                    // 1. Set Workspace Active
                    ref
                        .read(activeWorkspaceIdProvider.notifier)
                        .setWorkspace(col.id);

                    // 2. Navigate to Details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CollectionDetailScreen(collection: col),
                      ),
                    );
                  },
                  onLongPress: () {
                    HapticFeedback.lightImpact();
                    _showCollectionOptions(context, ref, col);
                  },
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showCollectionOptions(
    BuildContext context,
    WidgetRef ref,
    Collection collection,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                showCreateCollectionDialog(
                  context,
                  ref,
                  null,
                  isWorkspace: true,
                  collectionToEdit: collection,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref, collection);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Collection collection,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${collection.name}"?'),
        content: const Text(
          'This will permanently delete the project and ALL its contents (folders, requests).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(databaseProvider).deleteCollection(collection.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
