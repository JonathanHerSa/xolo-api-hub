import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:xolo/core/router/app_router.dart';
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
import 'package:xolo/presentation/widgets/ui/xolo_empty_state.dart';
import 'package:xolo/presentation/widgets/ui/xolo_interactive_card.dart';
import 'package:xolo/presentation/widgets/ui/xolo_section_header.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(recentHistoryStreamProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
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
            return XoloEmptyState(
              icon: Icons.history_rounded,
              title: l10n.noRecentHistory,
              subtitle: l10n.requestsWillAppearHere,
              actions: [
                FilledButton.icon(
                  onPressed: () {
                    ref.read(homeTabProvider.notifier).setIndex(2);
                    context.go(AppRoutes.composer);
                  },
                  icon: const Icon(Icons.bolt_rounded),
                  label: Text(l10n.compose),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              XoloSpacing.lg,
              XoloSpacing.sm,
              XoloSpacing.lg,
              XoloSpacing.lg,
            ),
            children: [
              XoloSectionHeader(
                title: l10n.historyEventsCount(history.length),
                icon: Icons.timeline_rounded,
                padding: const EdgeInsets.only(bottom: XoloSpacing.md),
              ),
              ...history.map(
                (entry) => Dismissible(
                  key: Key('history_${entry.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: XoloSpacing.md),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: XoloRadius.lg,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                    ),
                  ),
                  onDismissed: (direction) {
                    HapticFeedback.mediumImpact();
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
    final colorScheme = Theme.of(context).colorScheme;
    final methodColor = XoloPremiumTheme.getMethodColor(entry.method);

    final isSuccess =
        entry.statusCode != null &&
        entry.statusCode! >= 200 &&
        entry.statusCode! < 300;
    final statusColor = isSuccess ? XoloPalette.accent : colorScheme.error;

    return XoloInteractiveCard(
      onTap: () => _loadHistoryItem(context, ref),
      child: Row(
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: XoloRadius.sm,
              border: Border.all(color: statusColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              entry.statusCode?.toString() ?? 'ERR',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: XoloSpacing.md),
          Container(
            width: 44,
            alignment: Alignment.center,
            child: Text(
              entry.method,
              style: TextStyle(
                color: methodColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: XoloSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.url,
                  style: XoloTypography.cardTitle(colorScheme).copyWith(
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
                      style: XoloTypography.meta(colorScheme),
                    ),
                    if (entry.durationMs != null) ...[
                      Text(
                        ' · ',
                        style: XoloTypography.meta(colorScheme),
                      ),
                      Text(
                        '${entry.durationMs}ms',
                        style: XoloTypography.meta(colorScheme),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0 && now.day == dt.day) {
      return DateFormat.Hm().format(dt);
    }
    return DateFormat.MMMd().format(dt);
  }

  void _loadHistoryItem(BuildContext context, WidgetRef ref) {
    final newTabId = ref.read(tabsProvider.notifier).addTab();

    final sessionController = ref.read(
      requestSessionControllerProvider(newTabId),
    );
    sessionController.setMethod(entry.method);
    sessionController.setUrl(entry.originalUrl ?? entry.url);

    ref.read(tabsProvider.notifier).setActiveTab(newTabId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.requestLoadedInNewTab),
      ),
    );
    ref.read(homeTabProvider.notifier).setIndex(2);
    context.go(AppRoutes.composer);
  }
}
