import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collections_provider.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/environment_provider.dart';
import 'package:xolo/presentation/providers/tabs_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';
import 'package:xolo/presentation/screens/saved_requests_screen.dart'; // For dialog access
import 'package:xolo/presentation/widgets/browser_tab_bar.dart';
import 'package:xolo/presentation/widgets/command_palette.dart';
import 'package:xolo/presentation/widgets/import_collection_dialog.dart';
import 'package:xolo/presentation/widgets/import_curl_dialog.dart';
import 'package:xolo/presentation/widgets/request_tabs.dart';
import 'package:xolo/presentation/widgets/url_input_bar.dart';

class ComposerScreen extends ConsumerWidget {
  final Widget? drawer;
  const ComposerScreen({super.key, this.drawer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tabs = ref.watch(tabsProvider);

    return Scaffold(
      drawer: drawer,
      backgroundColor: colorScheme.surfaceContainerLowest,
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
            tooltip: l10n.saveRequestTooltip,
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
              } else if (value == 'collection') {
                showDialog(
                  context: context,
                  builder: (_) => const ImportCollectionDialog(),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'collection',
                child: Row(
                  children: [
                    const Icon(Icons.folder_zip_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.importApiProject),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'curl',
                child: Row(
                  children: [
                    const Icon(Icons.terminal, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.importCurl),
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
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: XoloSpacing.lg,
                    vertical: XoloSpacing.md,
                  ),
                  decoration: XoloSurfaces.accentPanel(colorScheme),
                  child: Row(
                    children: [
                      Icon(Icons.terminal_rounded, color: colorScheme.primary),
                      const SizedBox(width: XoloSpacing.md),
                      Expanded(
                        child: Text(
                          l10n.dailyDriverMode,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showCommandPalette(context),
                        icon: const Icon(Icons.keyboard_command_key, size: 15),
                        label: Text(l10n.cmdKShortcut),
                      ),
                    ],
                  ),
                ),

                // BROWSER TABS
                const BrowserTabBar(),

                // ACTIVE TAB CONTENT
                if (tabs.openTabIds.isEmpty)
                  Expanded(child: Center(child: Text(l10n.noActiveTabs)))
                else
                  Expanded(
                    key: ValueKey(
                      tabs.activeTabId,
                    ), // Force rebuild on tab switch
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                      decoration: XoloSurfaces.panel(
                        colorScheme,
                        borderRadius: XoloRadius.lg,
                        color: colorScheme.surface.withValues(alpha: 0.72),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 6,
                              right: 6,
                            ),
                            child: UrlInputBar(tabId: tabs.activeTabId),
                          ),
                          Expanded(child: RequestTabs(tabId: tabs.activeTabId)),
                        ],
                      ),
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
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const CommandPalette(),
    );
  }
}

class _WorkspaceTitle extends ConsumerWidget {
  const _WorkspaceTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.projectLabel,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                activeWorkspaceAsync.when(
                  data: (ws) => Text(
                    ws?.name ?? l10n.globalContext,
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
                  error: (_, _) => Text(
                    l10n.errorGeneric,
                    style: const TextStyle(fontSize: 10, color: Colors.red),
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
          final l10n = AppLocalizations.of(ctx)!;
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.switchWorkspace,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.public),
                  title: Text(l10n.globalContext),
                  subtitle: Text(l10n.globalContextSubtitle),
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.noProjectsFound),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final activeId = ref.watch(activeEnvironmentIdProvider).value;
    final envsAsync = ref.watch(environmentsListProvider);

    return envsAsync.when(
      data: (envs) {
        final activeEnv = envs.where((e) => e.id == activeId).firstOrNull;
        if (activeEnv == null) {
          return const SizedBox.shrink(); // Hide if no active env found
        }

        return PopupMenuButton<int>(
          tooltip: l10n.switchEnvironmentTooltip,
          offset: const Offset(0, 40),
          onSelected: (id) {
            final db = ref.read(xoloRepositoryProvider);
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
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
