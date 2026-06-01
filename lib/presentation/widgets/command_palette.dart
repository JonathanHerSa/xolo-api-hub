import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/domain/entities/environment_entity.dart';
import 'package:xolo/domain/entities/history_entry_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collections_provider.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/environment_provider.dart';
import 'package:xolo/presentation/providers/history_provider.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/providers/tabs_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';
import 'package:xolo/presentation/widgets/import_curl_dialog.dart';

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
        _selectedIndex = 0;
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
    final l10n = AppLocalizations.of(context)!;
    final collectionsAsync = ref.watch(flattenedCollectionsStreamProvider);
    final envsAsync = ref.watch(environmentsListProvider);
    final savedRequestsAsync = ref.watch(savedRequestsStreamProvider);
    final historyAsync = ref.watch(recentHistoryStreamProvider);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.only(top: 100),
      alignment: Alignment.topCenter,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: XoloRadius.lg,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.65),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      decoration: InputDecoration.collapsed(
                        hintText: l10n.typeToSearch,
                      ),
                      style: const TextStyle(fontSize: 18),
                      onSubmitted: (_) => _executeSelection(
                        _getResults(
                          l10n,
                          collectionsAsync,
                          envsAsync,
                          savedRequestsAsync,
                          historyAsync,
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
            Expanded(
              child: _buildResultsList(
                l10n,
                collectionsAsync,
                envsAsync,
                savedRequestsAsync,
                historyAsync,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PaletteItem> _getResults(
    AppLocalizations l10n,
    AsyncValue<List<FlattenedCollection>> cols,
    AsyncValue<List<EnvironmentEntity>> envs,
    AsyncValue<List<SavedRequestEntity>> savedRequests,
    AsyncValue<List<HistoryEntryEntity>> history,
  ) {
    final results = <PaletteItem>[];

    final actions = [
      PaletteItem(
        title: l10n.importCurl,
        subtitle: l10n.paletteAction,
        icon: Icons.terminal,
        action: () => _openCurlImport(),
      ),
      PaletteItem(
        title: l10n.switchWorkspaceAction,
        subtitle: l10n.paletteAction,
        icon: Icons.public,
        action: () {},
      ),
    ];

    if (_query.isEmpty) {
      return actions;
    }

    final q = _query.toLowerCase();

    for (final a in actions) {
      if (a.title.toLowerCase().contains(q)) results.add(a);
    }

    cols.whenData((list) {
      for (final item in list) {
        if (item.collection.name.toLowerCase().contains(q)) {
          results.add(
            PaletteItem(
              title: item.collection.name,
              subtitle: item.collection.parentId == null
                  ? l10n.paletteProject
                  : l10n.paletteFolder,
              icon: item.collection.parentId == null
                  ? Icons.folder_special
                  : Icons.folder,
              action: () {
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

    envs.whenData((list) {
      for (final env in list) {
        if (env.name.toLowerCase().contains(q)) {
          results.add(
            PaletteItem(
              title: env.name,
              subtitle: l10n.paletteEnvironment,
              icon: Icons.layers,
              action: () {
                final db = ref.read(xoloRepositoryProvider);
                final workspaceId = ref.read(activeWorkspaceIdProvider);
                db.setActiveEnvironment(env.id, workspaceId);
              },
            ),
          );
        }
      }
    });

    savedRequests.whenData((list) {
      for (final req in list) {
        if (req.name.toLowerCase().contains(q) ||
            req.url.toLowerCase().contains(q)) {
          results.add(
            PaletteItem(
              title: req.name,
              subtitle: '${l10n.paletteRequest} • ${req.method} ${req.url}',
              icon: Icons.http,
              action: () {
                final tabsState = ref.read(tabsProvider);
                final activeTabId = tabsState.activeTabId;
                ref
                    .read(requestSessionControllerProvider(activeTabId))
                    .loadRequest(req);
                ref.read(tabsProvider.notifier).setActiveTab(activeTabId);
              },
            ),
          );
        }
      }
    });

    history.whenData((list) {
      for (final item in list) {
        final line = '${item.method} ${item.url}';
        if (line.toLowerCase().contains(q)) {
          results.add(
            PaletteItem(
              title: line,
              subtitle:
                  '${l10n.paletteHistory} • ${item.statusCode ?? '-'} • ${item.durationMs ?? 0}ms',
              icon: Icons.history,
              action: () {
                final tabsState = ref.read(tabsProvider);
                final activeTabId = tabsState.activeTabId;
                final session = ref.read(
                  requestSessionControllerProvider(activeTabId),
                );
                session.setMethod(item.method);
                session.setUrl(item.originalUrl ?? item.url);
                if (item.body != null) {
                  session.setBody(item.body!);
                }
              },
            ),
          );
        }
      }
    });

    return results;
  }

  Widget _buildResultsList(
    AppLocalizations l10n,
    AsyncValue<List<FlattenedCollection>> cols,
    AsyncValue<List<EnvironmentEntity>> envs,
    AsyncValue<List<SavedRequestEntity>> savedRequests,
    AsyncValue<List<HistoryEntryEntity>> history,
  ) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          setState(() {
            final count = _getResults(
              l10n,
              cols,
              envs,
              savedRequests,
              history,
            ).length;
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
            final results = _getResults(
              l10n,
              cols,
              envs,
              savedRequests,
              history,
            );
            if (results.isEmpty) {
              return Center(child: Text(l10n.noResultsFound));
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
    Navigator.pop(context);
    item.action();
  }

  void _openCurlImport() {
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
