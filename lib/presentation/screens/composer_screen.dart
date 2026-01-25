import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tabs_provider.dart';
import '../providers/workspace_provider.dart';
import '../providers/collections_provider.dart';
import '../providers/database_providers.dart';
import '../providers/environment_provider.dart';
import '../widgets/url_input_bar.dart';
import '../widgets/request_tabs.dart';
import '../widgets/browser_tab_bar.dart';
import '../widgets/import_curl_dialog.dart';
import '../widgets/command_palette.dart';
import 'package:flutter/services.dart';
import 'saved_requests_screen.dart'; // For dialog access

class ComposerScreen extends ConsumerWidget {
  final Widget? drawer;
  const ComposerScreen({super.key, this.drawer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tabs = ref.watch(tabsProvider);

    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        title: const _WorkspaceTitle(),
        centerTitle: true,
        backgroundColor:
            theme.colorScheme.surface, // Blend with body in Premium
        elevation: 0,
        actions: [
          const _EnvironmentSwitcher(),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Guardar Request',
            onPressed: () => showSaveRequestDialog(context: context, ref: ref),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'curl') {
                showDialog(
                  context: context,
                  builder: (_) =>
                      ImportCurlDialog(activeTabId: tabs.activeTabId),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'curl',
                child: Row(
                  children: [
                    Icon(Icons.terminal, size: 18),
                    SizedBox(width: 8),
                    Text('Import cURL'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
              _showCommandPalette(context),
          const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
              _showCommandPalette(context),
        },
        child: Focus(
          autofocus: true,
          child: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              children: [
                // BROWSER TABS
                const BrowserTabBar(),

                // ACTIVE TAB CONTENT
                if (tabs.openTabIds.isEmpty)
                  const Expanded(child: Center(child: Text('No active tabs')))
                else
                  Expanded(
                    key: ValueKey(
                      tabs.activeTabId,
                    ), // Force rebuild on tab switch
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 0),
                          child: UrlInputBar(tabId: tabs.activeTabId),
                        ),
                        Expanded(child: RequestTabs(tabId: tabs.activeTabId)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCommandPalette(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const CommandPalette(),
    );
  }
}

class _WorkspaceTitle extends ConsumerWidget {
  const _WorkspaceTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorkspaceAsync = ref.watch(activeWorkspaceProvider);
    final allCollectionsAsync = ref.watch(rootCollectionsProvider);
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        _showWorkspaceSelector(context, ref, allCollectionsAsync);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Text(
                  'PROJECT',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                activeWorkspaceAsync.when(
                  data: (ws) => Text(
                    ws?.name ?? 'Global Context',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text(
                    'Error',
                    style: TextStyle(fontSize: 10, color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.unfold_more,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkspaceSelector(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<dynamic>> collectionsAsync,
  ) {
    final activeId = ref.read(activeWorkspaceIdProvider);

    collectionsAsync.whenData((collections) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Switch Workspace',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.public),
                  title: const Text('Global Context'),
                  subtitle: const Text('Shared variables & history'),
                  selected: activeId == null,
                  trailing: activeId == null ? const Icon(Icons.check) : null,
                  onTap: () {
                    ref
                        .read(activeWorkspaceIdProvider.notifier)
                        .setWorkspace(null);
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(),
                if (collections.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No projects found.'),
                  ),
                ...collections.map(
                  (col) => ListTile(
                    leading: const Icon(Icons.folder_special),
                    title: Text(col.name),
                    selected: activeId == col.id,
                    trailing: activeId == col.id
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      ref
                          .read(activeWorkspaceIdProvider.notifier)
                          .setWorkspace(col.id);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    });
  }
}

class _EnvironmentSwitcher extends ConsumerWidget {
  const _EnvironmentSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeId = ref.watch(activeEnvironmentIdProvider).value;
    final envsAsync = ref.watch(environmentsListProvider);

    return envsAsync.when(
      data: (envs) {
        final activeEnv = envs.where((e) => e.id == activeId).firstOrNull;
        if (activeEnv == null)
          return const SizedBox.shrink(); // Hide if no active env found

        return PopupMenuButton<int>(
          tooltip: 'Cambiar Entorno',
          offset: const Offset(0, 40),
          onSelected: (id) {
            final db = ref.read(databaseProvider);
            final workspaceId = ref.read(activeWorkspaceIdProvider);
            db.setActiveEnvironment(id, workspaceId);
          },
          itemBuilder: (context) {
            return envs.map((e) {
              return PopupMenuItem(
                value: e.id,
                child: Row(
                  children: [
                    Icon(
                      Icons.layers,
                      size: 16,
                      color: e.id == activeId
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      e.name,
                      style: TextStyle(
                        fontWeight: e.id == activeId
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: e.id == activeId
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                    if (e.id == activeId) ...[
                      const Spacer(),
                      Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activeEnv.name.length > 3
                      ? activeEnv.name.substring(0, 3).toUpperCase()
                      : activeEnv.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
