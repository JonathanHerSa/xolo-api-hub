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
import 'package:xolo/presentation/screens/saved_requests_screen.dart';
import 'package:xolo/presentation/widgets/browser_tab_bar.dart';
import 'package:xolo/presentation/widgets/command_palette.dart';
import 'package:xolo/presentation/widgets/import_curl_dialog.dart';
import 'package:xolo/presentation/widgets/request_tabs.dart';
import 'package:xolo/presentation/widgets/url_input_bar.dart';

class ComposerScreen extends ConsumerWidget {
  const ComposerScreen({super.key, this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = ref.watch(tabsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: drawer,
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
              _openPalette(context),
          const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
              _openPalette(context),
        },
        child: Focus(
          autofocus: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ComposerToolbar(
                onPalette: () => _openPalette(context),
                onSave: () => showSaveRequestDialog(context: context, ref: ref),
                onImportCurl: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        ImportCurlDialog(activeTabId: tabs.activeTabId),
                  );
                },
              ),
              const Divider(height: 1),
              const BrowserTabBar(),
              const Divider(height: 1),
              if (tabs.openTabIds.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.noActiveTabs,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  key: ValueKey(tabs.activeTabId),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: UrlInputBar(tabId: tabs.activeTabId),
                      ),
                      const SizedBox(height: 8),
                      Expanded(child: RequestTabs(tabId: tabs.activeTabId)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPalette(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const CommandPalette(),
    );
  }
}

class _ComposerToolbar extends ConsumerWidget {
  const _ComposerToolbar({
    required this.onPalette,
    required this.onSave,
    required this.onImportCurl,
  });

  final VoidCallback onPalette;
  final VoidCallback onSave;
  final VoidCallback onImportCurl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final workspace = ref.watch(activeWorkspaceProvider).value;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Builder(
              builder: (ctx) {
                if (!(Scaffold.maybeOf(ctx)?.hasDrawer ?? false)) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                );
              },
            ),
            InkWell(
              onTap: () => _pickWorkspace(context, ref),
              borderRadius: XoloRadius.sm,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      workspace?.name ?? l10n.globalContext,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const _EnvChip(),
            IconButton(
              tooltip: l10n.saveRequestTooltip,
              icon: const Icon(Icons.bookmark_border_rounded),
              onPressed: onSave,
            ),
            IconButton(
              tooltip: l10n.importCurl,
              icon: const Icon(Icons.terminal_rounded),
              onPressed: onImportCurl,
            ),
            IconButton(
              tooltip: l10n.cmdKShortcut,
              icon: const Icon(Icons.search_rounded),
              onPressed: onPalette,
            ),
          ],
        ),
      ),
    );
  }

  void _pickWorkspace(BuildContext context, WidgetRef ref) {
    final activeId = ref.read(activeWorkspaceIdProvider);
    ref.read(rootCollectionsProvider).whenData((collections) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        builder: (ctx) {
          final l10n = AppLocalizations.of(ctx)!;
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(l10n.globalContext),
                  trailing: activeId == null ? const Icon(Icons.check) : null,
                  onTap: () {
                    ref
                        .read(activeWorkspaceIdProvider.notifier)
                        .setWorkspace(null);
                    Navigator.pop(ctx);
                  },
                ),
                ...collections.map(
                  (c) => ListTile(
                    title: Text(c.name),
                    trailing: activeId == c.id ? const Icon(Icons.check) : null,
                    onTap: () {
                      ref
                          .read(activeWorkspaceIdProvider.notifier)
                          .setWorkspace(c.id);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _EnvChip extends ConsumerWidget {
  const _EnvChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeId = ref.watch(activeEnvironmentIdProvider).value;
    final envs = ref.watch(environmentsListProvider).asData?.value ?? const [];

    if (envs.isEmpty) return const SizedBox.shrink();
    final active =
        envs.where((e) => e.id == activeId).firstOrNull ?? envs.first;

    return PopupMenuButton<int>(
      tooltip: l10n.switchEnvironmentTooltip,
      offset: const Offset(0, 36),
      onSelected: (id) {
        final db = ref.read(xoloRepositoryProvider);
        db.setActiveEnvironment(id, ref.read(activeWorkspaceIdProvider));
      },
      itemBuilder: (ctx) => envs
          .map(
            (e) => PopupMenuItem(
              value: e.id,
              child: Text(
                e.name,
                style: TextStyle(
                  fontWeight: e.id == active.id ? FontWeight.w600 : null,
                ),
              ),
            ),
          )
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 8,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              active.name,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Icon(Icons.expand_more, size: 16),
          ],
        ),
      ),
    );
  }
}
