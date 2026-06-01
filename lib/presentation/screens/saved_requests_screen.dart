import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collections_provider.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/form_providers.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/providers/tabs_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';
import 'package:xolo/presentation/screens/collection_detail_screen.dart';
import 'package:xolo/presentation/widgets/draggable_tiles.dart'; // IMPORT SHARED TILES

class SavedRequestsScreen extends ConsumerStatefulWidget {
  const SavedRequestsScreen({super.key});

  @override
  ConsumerState<SavedRequestsScreen> createState() =>
      _SavedRequestsScreenState();
}

class _SavedRequestsScreenState extends ConsumerState<SavedRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final rootCollectionsAsync = ref.watch(rootCollectionsProvider);
    final unclassifiedAsync = ref.watch(unclassifiedRequestsProvider);
    final activeWorkspaceId = ref.watch(activeWorkspaceIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProjectsAndRequests),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: l10n.newProjectTooltip,
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
                l10n.projectsWorkspacesSection,
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
                  return _buildEmptyState(colorScheme, l10n);
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
              error: (e, s) => Text(l10n.errorMessage(e.toString())),
            ),

            const Divider(height: 32),

            // --- UNCLASSIFIED REQUESTS ---
            DragTarget<SavedRequestEntity>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) {
                final req = details.data;
                ref.read(xoloRepositoryProvider).moveRequest(req.id, null);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.requestMovedToRoot(req.name))),
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
                              l10n.unclassifiedRoot,
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
                                  l10n.dragRequestsHere,
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
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1, indent: 16),
                            itemBuilder: (ctx, index) {
                              final req = requests[index];
                              return DraggableRequestTile(
                                req: req,
                                onTap: () => _loadRequest(req),
                                onDelete: () {
                                  ref
                                      .read(xoloRepositoryProvider)
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
                        error: (e, s) => Text(l10n.errorMessage(e.toString())),
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

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
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
              Expanded(child: Text(l10n.createProjectHint)),
            ],
          ),
        ),
      ),
    );
  }

  void _loadRequest(SavedRequestEntity req) {
    final l10n = AppLocalizations.of(context)!;
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
    ).showSnackBar(SnackBar(content: Text(l10n.loadedRequest(req.name))));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _showCreateCollectionDialog(int? parentId) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newProjectFolder),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.name),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCollection(CollectionEntity col) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteNamedTitle(col.name)),
        content: Text(l10n.deleteCollectionWithEnvironments),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final activeId = ref.read(activeWorkspaceIdProvider);
              if (activeId == col.id) {
                await ref
                    .read(activeWorkspaceIdProvider.notifier)
                    .setWorkspace(null);
              }
              await ref.read(xoloRepositoryProvider).deleteCollection(col.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.deleteAll),
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
    final l10n = AppLocalizations.of(context)!;
    final collectionsAsync = widget.ref.watch(
      flattenedCollectionsStreamProvider,
    );

    return AlertDialog(
      title: Text(l10n.saveRequest),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.requestNameLabel,
                hintText: l10n.requestNameHint,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              decoration: InputDecoration(labelText: l10n.folderProjectLabel),
              initialValue: _selectedCollectionId,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.unclassifiedRootOption),
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
                  error: (_, _) => [],
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
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          label: Text(l10n.save),
          icon: const Icon(Icons.save),
          onPressed: () async {
            if (_nameCtrl.text.isEmpty) return;

            final name = _nameCtrl.text;
            final collectionId = _selectedCollectionId;

            final method = widget.ref.read(selectedMethodProvider);
            final url = widget.ref.read(urlQueryProvider);
            final body = widget.ref.read(bodyContentProvider);

            await widget.ref
                .read(xoloRepositoryProvider)
                .createRequest(
                  name: name,
                  method: method,
                  url: url,
                  body: body,
                  collectionId: collectionId,
                );

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.requestSavedSuccess)));
            }
          },
        ),
      ],
    );
  }
}
