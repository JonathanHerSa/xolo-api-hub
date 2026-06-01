import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';
import 'package:xolo/presentation/widgets/xolo_brand_mark.dart';

class PremiumSidebar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const PremiumSidebar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final activeWorkspace = ref.watch(activeWorkspaceProvider).value;

    return Container(
      width: 240,
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: XoloBrandMark(subtitle: activeWorkspace?.name),
            ),
            _SidebarItem(
              icon: Icons.send_rounded,
              label: l10n.composer,
              isSelected: selectedIndex == 0,
              onTap: () => onIndexChanged(0),
            ),
            _SidebarItem(
              icon: Icons.folder_open_rounded,
              label: l10n.collections,
              isSelected: selectedIndex == 1,
              onTap: () => onIndexChanged(1),
            ),
            _SidebarItem(
              icon: Icons.history_rounded,
              label: l10n.history,
              isSelected: selectedIndex == 2,
              onTap: () => onIndexChanged(2),
            ),
            _SidebarItem(
              icon: Icons.layers_outlined,
              label: l10n.environments,
              isSelected: selectedIndex == 3,
              onTap: () => onIndexChanged(3),
            ),
            const Spacer(),
            const Divider(height: 1),
            _SidebarItem(
              icon: Icons.settings_rounded,
              label: l10n.settings,
              isSelected: selectedIndex == 4,
              onTap: () => onIndexChanged(4),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Material(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: XoloRadius.md,
        child: InkWell(
          onTap: onTap,
          borderRadius: XoloRadius.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
