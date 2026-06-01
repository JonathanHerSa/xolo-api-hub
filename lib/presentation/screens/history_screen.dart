import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:xolo/core/theme/premium_theme.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/domain/entities/history_entry_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/history_provider.dart';
import 'package:xolo/presentation/providers/home_tab_provider.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/providers/tabs_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(recentHistoryStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: l10n.clearHistoryTooltip,
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
                    Icons.history_rounded,
                    size: 56,
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: XoloSpacing.lg),
                  Text(
                    l10n.noRecentHistory,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: XoloSpacing.sm),
                  Text(
                    l10n.requestsWillAppearHere,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.85,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: XoloSpacing.lg,
                  vertical: XoloSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.26,
                  ),
                  borderRadius: XoloRadius.lg,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timeline_rounded, color: colorScheme.primary),
                    const SizedBox(width: XoloSpacing.md),
                    Expanded(
                      child: Text(
                        l10n.historyEventsCount(history.length),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                        child: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                      ),
                      onDismissed: (direction) {
                        HapticFeedback.mediumImpact();
                        // Optimistic UI updates automatically via Stream, but we must delete from DB
                        final repo = ref.read(xoloRepositoryProvider);
                        repo.deleteHistoryEntry(entry);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.entryDeleted),
                            action: SnackBarAction(
                              label: l10n.undo,
                              onPressed: () {
                                repo.restoreHistoryEntry(entry);
                              },
                            ),
                          ),
                        );
                      },
                      child: _HistoryItem(entry: entry),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.errorMessage('$err'))),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearHistoryDialogTitle),
        content: Text(l10n.clearHistoryDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Limpiar solo historial del workspace activo
              final workspaceId = ref.read(activeWorkspaceIdProvider);
              await ref.read(xoloRepositoryProvider).clearHistory(workspaceId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends ConsumerWidget {
  final HistoryEntryEntity entry;

  const _HistoryItem({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final methodColor = XoloPremiumTheme.getMethodColor(entry.method);

    // Status color logic (2xx success, else error)
    final isSuccess =
        entry.statusCode != null &&
        entry.statusCode! >= 200 &&
        entry.statusCode! < 300;
    final statusColor = isSuccess ? Colors.green : colorScheme.error;

    return InkWell(
      onTap: () => _loadHistoryItem(context, ref),
      borderRadius: XoloRadius.md,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
          borderRadius: XoloRadius.md,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
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
    sessionController.setUrl(entry.originalUrl ?? entry.url);
    // Note: History currently doesn't store body or headers in a structured way to restore perfectly,
    // but we restore what we have. Future improvement: Store full request snapshot.

    // 3. Set Active
    ref.read(tabsProvider.notifier).setActiveTab(newTabId);

    // 4. Restore Response (Optional, for "Replay" feel) => Maybe not needed if we want user to click "Send"
    // If we want to show the PAST response, we'd need to populate requestProvider(newTabId).restoreResponse(...)

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.requestLoadedInNewTab),
      ),
    );
    // Switch to Composer Tab (Index 2)
    ref.read(homeTabProvider.notifier).setIndex(2);
  }
}
