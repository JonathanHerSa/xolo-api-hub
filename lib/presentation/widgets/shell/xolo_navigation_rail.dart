import 'package:flutter/material.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';

class XoloNavigationRail extends StatelessWidget {
  const XoloNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final items = [
      (icon: Icons.bolt_rounded, label: l10n.composer),
      (icon: Icons.folder_open_rounded, label: l10n.collections),
      (icon: Icons.history_rounded, label: l10n.history),
      (icon: Icons.tune_rounded, label: l10n.environments),
      (icon: Icons.settings_rounded, label: l10n.settings),
    ];

    return Container(
      width: XoloLayout.railWidth,
      color: colorScheme.surfaceContainerLowest,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: XoloRadius.sm,
              ),
              child: Text(
                'X',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == selectedIndex;
              return _RailItem(
                icon: item.icon,
                label: item.label,
                selected: selected,
                onTap: () => onIndexChanged(index),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: XoloLayout.railWidth,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: selected
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
