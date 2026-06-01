import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';

class NeoNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NeoNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final items = [
      (icon: Icons.grid_view_rounded, label: l10n.projects),
      (icon: Icons.history_rounded, label: l10n.history),
      (icon: Icons.bolt_rounded, label: l10n.compose),
      (icon: Icons.backup_rounded, label: l10n.backup),
      (icon: Icons.tune_rounded, label: l10n.settings),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: XoloRadius.xl,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.55),
            ),
            boxShadow: XoloSurfaces.floatingShadow(opacity: 0.22),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: List.generate(items.length, (index) {
                final isActive = index == currentIndex;
                final item = items[index];
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: isActive,
                    label: item.label,
                    child: InkWell(
                      borderRadius: XoloRadius.lg,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(index);
                      },
                      child: AnimatedContainer(
                        duration: XoloMotion.normal,
                        curve: XoloMotion.standard,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: XoloRadius.lg,
                          color: isActive
                              ? colorScheme.primary.withValues(alpha: 0.14)
                              : Colors.transparent,
                          border: Border.all(
                            color: isActive
                                ? colorScheme.primary.withValues(alpha: 0.28)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: 21,
                              color: isActive
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 10,
                                    color: isActive
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
