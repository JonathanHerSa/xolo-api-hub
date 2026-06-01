import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';
import 'package:xolo/presentation/widgets/import_collection_dialog.dart';
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
      width: 264,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(color: colorScheme.outline.withValues(alpha: 0.55)),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            Color.alphaBlend(
              colorScheme.primary.withValues(alpha: 0.04),
              colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: XoloBrandMark(
                subtitle: activeWorkspace?.name,
                compact: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.projectsSection.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
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
            _SidebarItem(
              icon: Icons.cloud_download_outlined,
              label: l10n.import,
              isSelected: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const ImportCollectionDialog(),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
            _SidebarItem(
              icon: Icons.settings_rounded,
              label: l10n.settings,
              isSelected: selectedIndex == 4,
              onTap: () => onIndexChanged(4),
            ),
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: XoloRadius.md,
          child: AnimatedContainer(
            duration: XoloMotion.normal,
            curve: XoloMotion.standard,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: XoloRadius.md,
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.28)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: XoloMotion.normal,
                  width: 3,
                  height: isSelected ? 18 : 0,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(
                                alpha: 0.45,
                              ),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
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
