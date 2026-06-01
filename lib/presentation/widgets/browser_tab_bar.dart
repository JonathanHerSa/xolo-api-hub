import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/premium_theme.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/core/theme/xolo_theme_extension.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';
import 'package:xolo/presentation/providers/tabs_provider.dart';

class BrowserTabBar extends ConsumerWidget {
  const BrowserTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(tabsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.45),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 8, top: 6, bottom: 0),
        itemCount: tabs.openTabIds.length + 1,
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
    final colorScheme = Theme.of(context).colorScheme;
    final mono = XoloThemeExtension.of(context)?.monoSmall;

    if (session == null) {
      return Container(
        width: 120,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final methodColor = XoloPremiumTheme.getMethodColor(session.method);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(tabsProvider.notifier).setActiveTab(tabId);
          },
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          child: AnimatedContainer(
            duration: XoloMotion.normal,
            width: 168,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surface.withValues(alpha: 0.45),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              border: Border(
                top: BorderSide(
                  color: isActive ? methodColor : Colors.transparent,
                  width: 2,
                ),
                left: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.35),
                ),
                right: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: methodColor.withValues(alpha: 0.14),
                    borderRadius: XoloRadius.sm,
                  ),
                  child: Text(
                    session.method,
                    style: (mono ?? const TextStyle(fontSize: 10)).copyWith(
                      color: methodColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.name.isNotEmpty ? session.name : 'Untitled',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ref.read(tabsProvider.notifier).closeTab(tabId);
                  },
                  borderRadius: BorderRadius.circular(99),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
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

class _AddTabButton extends ConsumerWidget {
  final ColorScheme colorScheme;

  const _AddTabButton({required this.colorScheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 8, top: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(tabsProvider.notifier).addTab(),
          borderRadius: XoloRadius.md,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: XoloRadius.md,
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.45),
              ),
            ),
            child: Icon(
              Icons.add,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
