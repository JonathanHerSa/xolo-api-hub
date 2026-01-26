import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/xolo_theme.dart';
import '../../data/local/database.dart';
import '../providers/database_providers.dart';
import '../providers/history_provider.dart';
import '../providers/workspace_provider.dart';
import '../providers/tabs_provider.dart';
import '../providers/request_session_provider.dart';
import '../providers/home_tab_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos el nuevo provider específico de historial
    final historyAsync = ref.watch(recentHistoryStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpiar historial (Contexto actual)',
            onPressed: () => _confirmClearHistory(context, ref),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay historial reciente',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return Dismissible(
                key: Key('history_${entry.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: colorScheme.errorContainer,
                  child: Icon(Icons.delete_outline, color: colorScheme.error),
                ),
                onDismissed: (direction) {
                  HapticFeedback.mediumImpact();
                  // Optimistic UI updates automatically via Stream, but we must delete from DB
                  final db = ref.read(databaseProvider);
                  db.delete(db.historyEntries).delete(entry);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Entry deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          // Undo logic: re-insert.
                          // Requires converting Entry to Companion or Insertable.
                          // For now, simple delete.
                          db.into(db.historyEntries).insert(entry);
                        },
                      ),
                    ),
                  );
                },
                child: _HistoryItem(entry: entry),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar Historial?'),
        content: const Text('Se eliminarán las entradas de este Workspace.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Limpiar solo historial del workspace activo
              final workspaceId = ref.read(activeWorkspaceIdProvider);
              await ref.read(databaseProvider).clearHistory(workspaceId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends ConsumerWidget {
  final HistoryEntry entry;

  const _HistoryItem({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final methodColor = XoloTheme.getMethodColor(entry.method);

    // Status color logic (2xx success, else error)
    final isSuccess =
        entry.statusCode != null &&
        entry.statusCode! >= 200 &&
        entry.statusCode! < 300;
    final statusColor = isSuccess ? XoloTheme.statusSuccess : colorScheme.error;

    return InkWell(
      onTap: () => _loadHistoryItem(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            // Status Code Badge
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.statusCode?.toString() ?? 'ERR',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),

            // Method Badge
            Text(
              entry.method,
              style: TextStyle(
                color: methodColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),

            // URL & Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.url,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        _formatTime(entry.executedAt),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      if (entry.durationMs != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '•',
                            style: TextStyle(color: colorScheme.outline),
                          ),
                        ),
                        Text(
                          '${entry.durationMs}ms',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    // Si es hoy, mostrar hora. Si no, fecha.
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0 && now.day == dt.day) {
      return DateFormat.Hm().format(dt);
    }
    return DateFormat.MMMd().format(dt);
  }

  void _loadHistoryItem(BuildContext context, WidgetRef ref) {
    // 1. Create new tab
    final newTabId = ref.read(tabsProvider.notifier).addTab();

    // 2. Populate Session State
    final sessionController = ref.read(
      requestSessionControllerProvider(newTabId),
    );
    sessionController.setMethod(entry.method);
    sessionController.setUrl(entry.url);
    // Note: History currently doesn't store body or headers in a structured way to restore perfectly,
    // but we restore what we have. Future improvement: Store full request snapshot.

    // 3. Set Active
    ref.read(tabsProvider.notifier).setActiveTab(newTabId);

    // 4. Restore Response (Optional, for "Replay" feel) => Maybe not needed if we want user to click "Send"
    // If we want to show the PAST response, we'd need to populate requestProvider(newTabId).restoreResponse(...)

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request cargado en nueva pestaña')),
    );
    // Switch to Composer Tab (Index 2)
    ref.read(homeTabProvider.notifier).setIndex(2);
  }
}
