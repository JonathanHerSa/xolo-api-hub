import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xolo/core/router/app_router.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/presentation/providers/home_tab_provider.dart';
import 'package:xolo/presentation/screens/active_workspace_explorer.dart';
import 'package:xolo/presentation/screens/composer_screen.dart';
import 'package:xolo/presentation/screens/environments_screen.dart';
import 'package:xolo/presentation/screens/history_screen.dart';
import 'package:xolo/presentation/screens/settings_screen.dart';
import 'package:xolo/presentation/widgets/app_drawer.dart';
import 'package:xolo/presentation/widgets/navigation/premium_sidebar.dart';
import 'package:xolo/presentation/widgets/neo_nav_bar.dart';

/// Shell layout for mobile bottom nav and desktop sidebar.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final location = GoRouterState.of(context).uri.toString();
    final mobileIndex = tabIndexForRoute(location);

    if (isDesktop) {
      return _DesktopShell(location: location);
    }

    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
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

class _DesktopShell extends StatefulWidget {
  const _DesktopShell({required this.location});

  final String location;

  @override
  State<_DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<_DesktopShell> {
  int _desktopIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: XoloSurfaces.appBackground(Theme.of(context).colorScheme),
        ),
        child: Row(
          children: [
            PremiumSidebar(
              selectedIndex: _desktopIndex,
              onIndexChanged: (index) {
                setState(() => _desktopIndex = index);
              },
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest
                        .withValues(alpha: 0.35),
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  child: _getDesktopContent(_desktopIndex),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDesktopContent(int index) {
    return switch (index) {
      0 => const ComposerScreen(),
      1 => const ActiveWorkspaceExplorer(),
      2 => const HistoryScreen(),
      3 => const EnvironmentsScreen(),
      4 => const SettingsScreen(),
      _ => const ComposerScreen(),
    };
  }
}

/// Legacy entry point kept for tests and deep links without shell.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeShell(child: ActiveWorkspaceExplorer());
  }
}
