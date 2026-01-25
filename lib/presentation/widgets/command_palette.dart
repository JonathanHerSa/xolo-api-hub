import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/collections_provider.dart';
import '../providers/environment_provider.dart';
import '../providers/database_providers.dart';
import '../providers/tabs_provider.dart';
import '../providers/workspace_provider.dart';
import '../../data/local/database.dart'; // For types
import 'import_curl_dialog.dart';

class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _query = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _query = _controller.text;
        _selectedIndex = 0; // Reset selection on new query
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Fetch Data
    final collectionsAsync = ref.watch(flattenedCollectionsStreamProvider);
    final envsAsync = ref.watch(environmentsListProvider);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.only(top: 100),
      alignment: Alignment.topCenter,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Type to search...',
                      ),
                      style: const TextStyle(fontSize: 18),
                      onSubmitted: (_) => _executeSelection(
                        _getResults(
                          collectionsAsync,
                          envsAsync,
                        )[_selectedIndex],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ESC',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Results List
            Expanded(child: _buildResultsList(collectionsAsync, envsAsync)),
          ],
        ),
      ),
    );
  }

  List<PaletteItem> _getResults(
    AsyncValue<List<FlattenedCollection>> cols,
    AsyncValue<List<Environment>> envs,
  ) {
    final results = <PaletteItem>[];

    // 1. Actions (Static)
    final actions = [
      PaletteItem(
        title: 'Import cURL',
        subtitle: 'Action',
        icon: Icons.terminal,
        action: () => _openCurlImport(),
      ),
      PaletteItem(
        title: 'Switch Workspace',
        subtitle: 'Action',
        icon: Icons.public, // Or folder special
        action: () {
          // This is tricky to invoke directly as it needs context/ref properly
          // We can perhaps just close and show the selector?
          // For now, let's skip complex UI interactions that depend on parent widgets
          // unless we refactor.
          // Actually we are in a Dialog, we can close and perform action.
        },
      ),
    ];

    if (_query.isEmpty) {
      return actions; // Show actions by default
    }

    final q = _query.toLowerCase();

    // Filter Actions
    for (final a in actions) {
      if (a.title.toLowerCase().contains(q)) results.add(a);
    }

    // 2. Collections (Projects/Folders)
    cols.whenData((list) {
      for (final item in list) {
        if (item.collection.name.toLowerCase().contains(q)) {
          results.add(
            PaletteItem(
              title: item.collection.name,
              subtitle: item.collection.parentId == null ? 'Project' : 'Folder',
              icon: item.collection.parentId == null
                  ? Icons.folder_special
                  : Icons.folder,
              action: () {
                // Select the Workspace (if root) or Expand?
                // Switching workspace is the main use case
                if (item.collection.parentId == null) {
                  ref
                      .read(activeWorkspaceIdProvider.notifier)
                      .setWorkspace(item.collection.id);
                }
              },
            ),
          );
        }
      }
    });

    // 3. Environments
    envs.whenData((list) {
      for (final env in list) {
        if (env.name.toLowerCase().contains(q)) {
          results.add(
            PaletteItem(
              title: env.name,
              subtitle: 'Environment',
              icon: Icons.layers,
              action: () {
                final db = ref.read(databaseProvider);
                final workspaceId = ref.read(activeWorkspaceIdProvider);
                db.setActiveEnvironment(env.id, workspaceId);
              },
            ),
          );
        }
      }
    });

    return results;
  }

  Widget _buildResultsList(
    AsyncValue<List<FlattenedCollection>> cols,
    AsyncValue<List<Environment>> envs,
  ) {
    // Handling shortcut navigation
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          setState(() {
            final count = _getResults(cols, envs).length;
            if (_selectedIndex < count - 1) _selectedIndex++;
          });
        },
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          setState(() {
            if (_selectedIndex > 0) _selectedIndex--;
          });
        },
      },
      child: Focus(
        autofocus: true,
        child: Builder(
          builder: (context) {
            final results = _getResults(cols, envs);
            if (results.isEmpty) {
              return const Center(child: Text('No results found'));
            }

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                final isSelected = index == _selectedIndex;

                return InkWell(
                  onTap: () => _executeSelection(item),
                  onHover: (hovering) {
                    if (hovering) {
                      setState(() => _selectedIndex = index);
                    }
                  },
                  child: Container(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.subdirectory_arrow_left, size: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _executeSelection(PaletteItem item) {
    Navigator.pop(context); // Close palette
    item.action();
  }

  void _openCurlImport() {
    // Retrieve active tab ID for the dialog...
    // This is a bit tricky from global palette.
    // We can just rely on the fact that when dialog opens, it can check active tab?
    // Or we assume the palette is invoked while on Composer.
    final tabs = ref.read(tabsProvider);
    showDialog(
      context: context,
      builder: (_) => ImportCurlDialog(activeTabId: tabs.activeTabId),
    );
  }
}

class PaletteItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback action;

  PaletteItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.action,
  });
}
