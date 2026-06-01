import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:xolo/core/router/app_router.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collection_run_provider.dart';

class RunHistoryScreen extends ConsumerWidget {
  const RunHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final runsAsync = ref.watch(collectionRunsHistoryProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat.yMMMd().add_Hm();

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: Text(l10n.runHistory)),
      body: runsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorMessage(e.toString()))),
        data: (runs) {
          if (runs.isEmpty) {
            return Center(
              child: Text(
                l10n.noRunHistory,
                style: XoloTypography.cardSubtitle(colorScheme),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(XoloSpacing.lg),
            itemCount: runs.length,
            separatorBuilder: (_, __) => const SizedBox(height: XoloSpacing.sm),
            itemBuilder: (context, index) {
              final run = runs[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: XoloRadius.md,
                  side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                ),
                title: Text(l10n.stepsPassed(run.passedSteps, run.totalSteps)),
                subtitle: Text(dateFmt.format(run.startedAt)),
                trailing: Icon(
                  run.failedSteps == 0 ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: run.failedSteps == 0 ? XoloPalette.accent : colorScheme.error,
                ),
                onTap: () => context.go('${AppRoutes.runReport}/${run.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
