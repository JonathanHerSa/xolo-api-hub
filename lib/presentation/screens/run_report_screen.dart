import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:xolo/core/router/app_router.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/domain/entities/collection_run_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collection_run_provider.dart';
import 'package:xolo/presentation/providers/database_providers.dart';

class RunReportScreen extends ConsumerWidget {
  const RunReportScreen({super.key, required this.runId});

  final int runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(runDetailProvider(runId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(l10n.runReport),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorMessage(e.toString()))),
        data: (data) {
          final (run, steps) = data;
          if (run == null) {
            return Center(child: Text(l10n.runNotFound));
          }
          return _RunReportBody(run: run, steps: steps);
        },
      ),
    );
  }
}

class _RunReportBody extends ConsumerWidget {
  const _RunReportBody({required this.run, required this.steps});

  final CollectionRunEntity run;
  final List<RunStepResultEntity> steps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat.yMMMd().add_Hm();

    RunStepResultEntity? firstFailure;
    for (final step in steps) {
      if (!step.passed && step.status != RunStepStatus.skipped) {
        firstFailure = step;
        break;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(XoloSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(XoloSpacing.lg),
          decoration: XoloSurfaces.panel(colorScheme, borderRadius: XoloRadius.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.stepsPassed(run.passedSteps, run.totalSteps),
                style: XoloTypography.cardTitle(colorScheme).copyWith(fontSize: 22),
              ),
              const SizedBox(height: XoloSpacing.sm),
              Text(
                '${l10n.runFailed}: ${run.failedSteps} • ${l10n.runSkipped}: ${run.skippedSteps}',
                style: XoloTypography.cardSubtitle(colorScheme),
              ),
              const SizedBox(height: XoloSpacing.xs),
              Text(dateFmt.format(run.startedAt), style: XoloTypography.meta(colorScheme)),
            ],
          ),
        ),
        const SizedBox(height: XoloSpacing.xl),
        ...steps.map((step) => _StepDetailCard(step: step)),
        if (firstFailure != null) ...[
          const SizedBox(height: XoloSpacing.lg),
          FilledButton.icon(
            onPressed: () async {
              final collection = await ref
                  .read(xoloRepositoryProvider)
                  .getCollectionById(run.collectionId);
              await ref.read(collectionRunProvider.notifier).resumeRun(
                collectionId: run.collectionId,
                collectionName: collection?.name ?? 'Collection',
                fromStepIndex: firstFailure!.stepIndex,
              );
              if (context.mounted) context.go(AppRoutes.runActive);
            },
            icon: const Icon(Icons.replay_rounded),
            label: Text(l10n.reRunFromFailure),
          ),
        ],
      ],
    );
  }
}

class _StepDetailCard extends StatelessWidget {
  const _StepDetailCard({required this.step});

  final RunStepResultEntity step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final passed = step.passed;

    return Card(
      margin: const EdgeInsets.only(bottom: XoloSpacing.md),
      child: ExpansionTile(
        leading: Icon(
          passed ? Icons.check_circle_outline : Icons.highlight_off_outlined,
          color: passed ? XoloPalette.accent : colorScheme.error,
        ),
        title: Text(step.name),
        subtitle: Text('${step.method} ${step.statusCode ?? ''}'),
        children: [
          if (step.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(XoloSpacing.md),
              child: Text(step.errorMessage!, style: TextStyle(color: colorScheme.error)),
            ),
          ...step.assertionResults.map(
            (a) => ListTile(
              dense: true,
              leading: Icon(
                a.passed ? Icons.check : Icons.close,
                size: 18,
                color: a.passed ? XoloPalette.accent : colorScheme.error,
              ),
              title: Text(a.message, style: const TextStyle(fontSize: 13)),
            ),
          ),
          if (step.responseBodySnippet != null)
            Padding(
              padding: const EdgeInsets.all(XoloSpacing.md),
              child: Text(
                step.responseBodySnippet!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
