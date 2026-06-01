import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:xolo/core/router/app_router.dart';
import 'package:xolo/domain/entities/run_plan_item.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/collection_run_provider.dart';

Future<void> showRunCollectionSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int collectionId,
  required String collectionName,
}) {
  var stopOnFailure = true;
  var delayMs = 0;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context)!;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.runCollection, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(collectionName),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.stopOnFailure),
                  value: stopOnFailure,
                  onChanged: (v) => setState(() => stopOnFailure = v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.delayBetweenSteps),
                  subtitle: Slider(
                    value: delayMs.toDouble(),
                    min: 0,
                    max: 2000,
                    divisions: 4,
                    label: '${delayMs}ms',
                    onChanged: (v) => setState(() => delayMs = v.round()),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ref.read(collectionRunProvider.notifier).startRun(
                      collectionId: collectionId,
                      collectionName: collectionName,
                      options: RunOptions(
                        stopOnFailure: stopOnFailure,
                        delayBetweenStepsMs: delayMs,
                      ),
                    );
                    if (context.mounted) context.go(AppRoutes.runActive);
                  },
                  child: Text(l10n.runCollection),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
