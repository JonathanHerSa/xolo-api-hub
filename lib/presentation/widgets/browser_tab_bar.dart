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

    return SizedBox(
      height: XoloLayout.requestTabHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tabs.openTabIds.length + 1,
        itemBuilder: (context, index) {
          if (index == tabs.openTabIds.length) {
            return _AddTab(colorScheme: colorScheme);
          }
          return _RequestTab(
            tabId: tabs.openTabIds[index],
            isActive: tabs.openTabIds[index] == tabs.activeTabId,
          );
        },
      ),
    );
  }
}

class _RequestTab extends ConsumerWidget {
  const _RequestTab({required this.tabId, required this.isActive});

  final String tabId;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(requestSessionProvider(tabId)).asData?.value;
    final colorScheme = Theme.of(context).colorScheme;
    final mono = XoloThemeExtension.of(context)?.monoSmall;

    if (session == null) {
      return const SizedBox(
        width: 100,
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final methodColor = XoloPremiumTheme.getMethodColor(session.method);
    final name = session.name.isNotEmpty ? session.name : 'Untitled';

    return Padding(
      padding: const EdgeInsets.only(right: 4, top: 6),
      child: Material(
        color: isActive
            ? colorScheme.surfaceContainerHighest
            : Colors.transparent,
        borderRadius: XoloRadius.sm,
        child: InkWell(
          onTap: () => ref.read(tabsProvider.notifier).setActiveTab(tabId),
          borderRadius: XoloRadius.sm,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200, minWidth: 120),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Text(
                  session.method,
                  style: (mono ?? const TextStyle(fontSize: 11)).copyWith(
                    color: methodColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(tabsProvider.notifier).closeTab(tabId),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
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

class _AddTab extends ConsumerWidget {
  const _AddTab({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 6),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        icon: Icon(Icons.add, size: 18, color: colorScheme.onSurfaceVariant),
        onPressed: () => ref.read(tabsProvider.notifier).addTab(),
      ),
    );
  }
}
