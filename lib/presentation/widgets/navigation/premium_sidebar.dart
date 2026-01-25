import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/workspace_provider.dart';
import '../import_collection_dialog.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeWorkspace = ref.watch(activeWorkspaceProvider).value;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: colorScheme.outline, width: 1)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.tertiary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'XOLO',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                        ),
                        if (activeWorkspace != null)
                          Text(
                            activeWorkspace.name,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // NAVIGATION ITEMS
            _SidebarItem(
              icon: Icons.send_rounded,
              label: 'Composer',
              isSelected: selectedIndex == 0,
              onTap: () => onIndexChanged(0),
            ),

            _SidebarItem(
              icon: Icons.folder_open_rounded,
              label: 'Collections',
              isSelected: selectedIndex == 1,
              onTap: () => onIndexChanged(1),
            ),

            _SidebarItem(
              icon: Icons.history_rounded,
              label: 'History',
              isSelected: selectedIndex == 2,
              onTap: () => onIndexChanged(2),
            ),

            _SidebarItem(
              icon: Icons.layers_outlined,
              label: 'Environments',
              isSelected: selectedIndex == 3,
              onTap: () => onIndexChanged(3),
            ),

            _SidebarItem(
              icon: Icons.cloud_download_outlined,
              label: 'Import',
              isSelected: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const ImportCollectionDialog(),
                );
              },
            ),

            const Spacer(),

            const Divider(thickness: 1, height: 1),
            _SidebarItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              isSelected: selectedIndex == 4,
              onTap: () => onIndexChanged(4), // Placeholder
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: colorScheme.primary.withValues(alpha: 0.2))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
