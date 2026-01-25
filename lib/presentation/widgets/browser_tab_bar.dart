import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tabs_provider.dart';
import '../providers/request_session_provider.dart';
import '../../core/theme/xolo_theme.dart';

class BrowserTabBar extends ConsumerWidget {
  const BrowserTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(tabsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.openTabIds.length + 1, // Tabs + Add Button
        itemBuilder: (context, index) {
          if (index == tabs.openTabIds.length) {
            return _AddTabButton(colorScheme: colorScheme);
          }

          final tabId = tabs.openTabIds[index];
          final isActive = tabId == tabs.activeTabId;

          return _TabItem(tabId: tabId, isActive: isActive);
        },
      ),
    );
  }
}

class _TabItem extends ConsumerWidget {
  final String tabId;
  final bool isActive;

  const _TabItem({required this.tabId, required this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(requestSessionProvider(tabId));
    final session = sessionAsync.asData?.value;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (session == null) {
      return Container(
        width: 100,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final methodColor = XoloTheme.getMethodColor(session.method);

    return InkWell(
      onTap: () {
        ref.read(tabsProvider.notifier).setActiveTab(tabId);
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.surfaceContainerHighest : null,
          border: isActive
              ? Border(
                  top: BorderSide(color: colorScheme.primary, width: 2),
                  right: BorderSide(color: colorScheme.outlineVariant),
                )
              : Border(right: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Text(
              session.method,
              style: TextStyle(
                color: methodColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                session.name.isNotEmpty
                    ? session.name
                    : (session.url.isEmpty ? 'Untitled' : session.url),
                style: TextStyle(
                  color: isActive
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            _CloseButton(
              onPressed: () {
                ref.read(tabsProvider.notifier).closeTab(tabId);
              },
              isActive: isActive,
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;

  const _CloseButton({required this.onPressed, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          Icons.close,
          size: 14,
          color: isActive
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AddTabButton extends ConsumerWidget {
  final ColorScheme colorScheme;

  const _AddTabButton({required this.colorScheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(tabsProvider.notifier).addTab();
      },
      child: Container(
        width: 40,
        alignment: Alignment.center,
        child: Icon(Icons.add, color: colorScheme.onSurfaceVariant, size: 20),
      ),
    );
  }
}
