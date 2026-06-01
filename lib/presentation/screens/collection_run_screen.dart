import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:xolo/core/router/app_router.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/domain/entities/collection_run_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collection_run_provider.dart';

class CollectionRunScreen extends ConsumerWidget {
  const CollectionRunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final runState = ref.watch(collectionRunProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(collectionRunProvider, (prev, next) {
      if (prev?.uiState == CollectionRunUiState.running &&
          (next.uiState == CollectionRunUiState.completed ||
              next.uiState == CollectionRunUiState.cancelled) &&
          next.runId != null) {
        context.go('${AppRoutes.runReport}/${next.runId}');
      }
    });

    final progress = runState.totalSteps == 0
        ? 0.0
        : runState.currentStepIndex / runState.totalSteps;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(l10n.runningCollection),
        actions: [
          if (runState.uiState == CollectionRunUiState.running)
            TextButton(
              onPressed: () => ref.read(collectionRunProvider.notifier).cancelRun(),
              child: Text(l10n.cancel),
            ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress.clamp(0, 1)),
          Padding(
            padding: const EdgeInsets.all(XoloSpacing.lg),
            child: Text(
              l10n.runningStep(
                runState.currentStepIndex,
                runState.totalSteps,
              ),
              style: XoloTypography.cardSubtitle(colorScheme),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: XoloSpacing.lg),
              itemCount: runState.steps.length,
              itemBuilder: (context, index) {
                final step = runState.steps[index];
                return _RunStepTile(step: step);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RunStepTile extends StatelessWidget {
  const _RunStepTile({required this.step});

  final RunStepResultEntity step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (step.status) {
      RunStepStatus.passed => (Icons.check_circle_rounded, XoloPalette.accent),
      RunStepStatus.failed => (Icons.cancel_rounded, colorScheme.error),
      RunStepStatus.skipped => (Icons.skip_next_rounded, colorScheme.outline),
      RunStepStatus.error => (Icons.error_outline_rounded, colorScheme.error),
    };

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(step.name),
      subtitle: Text('${step.method} • ${step.statusCode ?? '—'} • ${step.durationMs ?? 0}ms'),
    );
  }
}
