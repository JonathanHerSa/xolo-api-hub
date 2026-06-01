import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collections_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';
import 'package:xolo/presentation/screens/collection_detail_screen.dart';
import 'package:xolo/presentation/screens/environments_screen.dart';
import 'package:xolo/presentation/screens/history_screen.dart';
import 'package:xolo/presentation/widgets/create_collection_dialog.dart';
import 'package:xolo/presentation/widgets/import_collection_dialog.dart';
import 'package:xolo/presentation/widgets/xolo_brand_mark.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final collectionsAsync = ref.watch(flattenedCollectionsStreamProvider);
    final activeId = ref.watch(activeWorkspaceIdProvider);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.16),
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: XoloBrandMark(subtitle: l10n.appTitle),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                /*
                ListTile(
                  leading: const Icon(Icons.folder_special),
                  title: Text(l10n.allRequests),
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
                  title: Text(l10n.history),
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
                  title: Text(l10n.environmentsAndVariables),
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
                  title: Text(l10n.importCollection),
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
                    l10n.projectsSection,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                collectionsAsync.when(
                  data: (flattened) {
                    if (flattened.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(l10n.noProjectsFound),
                      );
                    }
                    return Column(
                      children: flattened.map((item) {
                        final col = item.collection;
                        final depth = item.depth;
                        final isActive = activeId == col.id;

                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CollectionDetailScreen(collection: col),
                              ),
                            );

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
                                    _confirmDeleteCollection(
                                      context,
                                      ref,
                                      col,
                                      l10n,
                                    );
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: const Icon(Icons.edit, size: 18),
                                      title: Text(l10n.edit),
                                      dense: true,
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'import',
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.input,
                                        size: 18,
                                      ),
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
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
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
                      l10n.errorMessage(err.toString()),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),
        ],
      ),
    );
  }

  void _confirmDeleteCollection(
    BuildContext context,
    WidgetRef ref,
    CollectionEntity col,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteNamedTitle(col.name)),
        content: Text(l10n.deleteCollectionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref
                  .read(collectionsControllerProvider.notifier)
                  .deleteCollection(col.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
