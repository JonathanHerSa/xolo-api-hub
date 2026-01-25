import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/xolo_theme.dart';
import '../providers/request_provider.dart';
import '../providers/environment_provider.dart';
import '../providers/workspace_provider.dart';
import '../providers/collections_provider.dart';
import '../widgets/url_input_bar.dart';
import '../widgets/request_tabs.dart';
import 'saved_requests_screen.dart'; // For dialog access

class ComposerScreen extends ConsumerWidget {
  final Widget? drawer;
  const ComposerScreen({super.key, this.drawer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeEnvIdAsync = ref.watch(activeEnvironmentIdProvider);

    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        title: const _WorkspaceTitle(),
        centerTitle: true,
        backgroundColor:
            theme.colorScheme.surface, // Blend with body in Premium
        elevation: 0,
        actions: [
          if (activeEnvIdAsync.value != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'ENV: ACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Guardar Request',
            onPressed: () => showSaveRequestDialog(context: context, ref: ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: const Column(
          children: [
            UrlInputBar(),
            Expanded(child: RequestTabs()),
          ],
        ),
      ),
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
