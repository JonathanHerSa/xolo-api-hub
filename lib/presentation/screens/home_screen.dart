import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/navigation/premium_sidebar.dart';

import '../widgets/neo_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../providers/home_tab_provider.dart';
import 'composer_screen.dart';
import 'history_screen.dart';
import 'environments_screen.dart';
import 'active_workspace_explorer.dart';
import 'settings_screen.dart';
import 'sync_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _desktopIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Breakpoint: 900px for Desktop Sidebar View
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    // Watch provider
    final mobileIndex = ref.watch(homeTabProvider);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // REUSE EXISTING SIDEBAR BUT MAP NEW SCREENS
            Expanded(
              flex: 0,
              child: PremiumSidebar(
                selectedIndex: _desktopIndex,
                onIndexChanged: (index) {
                  // Map Sidebar events
                  setState(() => _desktopIndex = index);
                },
              ),
            ),
            Expanded(child: _getDesktopContent(_desktopIndex)),
          ],
        ),
      );
    }

    // PREMIUM MOBILE LAYOUT
    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: mobileIndex,
        children: [
          ActiveWorkspaceExplorer(), // 0: Explorer (Active Project)
          HistoryScreen(), // 1
          ComposerScreen(), // 2 (Center)
          // 3: Sync
          SyncScreen(),
          SettingsScreen(), // 4
          // Container(
          //   color: Colors.red,
          //   child: Center(
          //     child: Text(
          //       "INDEX 4 REACHED",
          //       style: TextStyle(color: Colors.white, fontSize: 30),
          //     ),
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: NeoNavBar(
        currentIndex: mobileIndex,
        onTap: (index) {
          ref.read(homeTabProvider.notifier).setIndex(index);
        },
      ),
    );
  }

  Widget _getDesktopContent(int index) {
    switch (index) {
      case 0:
        return const ComposerScreen();
      case 1:
        // Desktop Sidebar "Saved" now maps to ActiveWorkspaceExplorer
        return const ActiveWorkspaceExplorer();
      // Or keep SavedRequestsScreen if CollectionsBrowser is Mobile optimized?
      // CollectionsBrowser is better structure.
      case 2:
        return const HistoryScreen();
      case 3:
        return const EnvironmentsScreen();
      case 4:
        return const SettingsScreen(); // Show as full screen
      default:
        return const ComposerScreen();
    }
  }
}
