import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collections_provider.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/providers/tabs_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';
import 'package:xolo/presentation/widgets/create_collection_dialog.dart';
import 'package:xolo/presentation/widgets/draggable_tiles.dart';

class CollectionDetailScreen extends ConsumerStatefulWidget {
  final CollectionEntity collection;

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
    final l10n = AppLocalizations.of(context)!;
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
                hintText: l10n.searchInCollection(widget.collection.name),
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
            tooltip: l10n.newRequestTooltip,
            onPressed: () => _showCreateRequestDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: l10n.newSubfolderTooltip,
            onPressed: () => showCreateCollectionDialog(
              context,
              ref,
              widget.collection.id,
              isWorkspace: false,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showCreateCollectionDialog(
              context,
              ref,
              widget.collection.parentId,
              isWorkspace: widget.collection.parentId == null,
              collectionToEdit: widget.collection,
            ),
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
                        l10n.foldersSection,
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
              error: (_, _) => const SizedBox.shrink(),
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
                          l10n.noRequestsFound,
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
                            l10n.noRequestsHere,
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
                        l10n.requestsSection,
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
                            final db = ref.read(xoloRepositoryProvider);
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
                padding: const EdgeInsets.all(16),
                child: Text(l10n.errorMessage(err.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadRequest(
    BuildContext context,
    WidgetRef ref,
    SavedRequestEntity req,
  ) {
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

  Future<void> _showCreateRequestDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    String selectedMethod = 'GET';

    final methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.newRequest),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l10n.name),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod,
                  decoration: InputDecoration(labelText: l10n.method),
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
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty) {
                    final db = ref.read(xoloRepositoryProvider);
                    await db.createRequest(
                      name: nameCtrl.text,
                      method: selectedMethod,
                      url: '',
                      collectionId: widget.collection.id,
                    );

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.requestCreated)),
                      );
                    }
                  }
                },
                child: Text(l10n.createRequest),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteCollection(
    BuildContext context,
    WidgetRef ref,
    CollectionEntity col,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Show confirmation logic
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
