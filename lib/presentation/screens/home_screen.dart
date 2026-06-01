import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xolo/core/router/app_router.dart';
import 'package:xolo/presentation/providers/home_tab_provider.dart';
import 'package:xolo/presentation/widgets/app_drawer.dart';
import 'package:xolo/presentation/widgets/neo_nav_bar.dart';
import 'package:xolo/presentation/widgets/shell/xolo_navigation_rail.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;
    final location = GoRouterState.of(context).uri.toString();
    final mobileIndex = tabIndexForRoute(location);
    final railIndex = railIndexForRoute(location);
    final backgroundColor =
        Theme.of(context).colorScheme.surfaceContainerLowest;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Row(
          children: [
            XoloNavigationRail(
              selectedIndex: railIndex,
              onIndexChanged: (index) {
                final route = routeForRailIndex(index);
                ref.read(homeTabProvider.notifier).setIndex(
                      tabIndexForRoute(route),
                    );
                context.go(route);
              },
            ),
            VerticalDivider(
              width: 1,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: backgroundColor,
      body: child,
      bottomNavigationBar: NeoNavBar(
        currentIndex: mobileIndex,
        onTap: (index) {
          ref.read(homeTabProvider.notifier).setIndex(index);
          context.go(routeForTabIndex(index));
        },
      ),
    );
  }
}
