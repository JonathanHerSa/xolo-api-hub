import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/navigation/premium_sidebar.dart';
import '../widgets/settings_dialog.dart';
import 'composer_screen.dart';
import 'saved_requests_screen.dart';
import 'history_screen.dart';
import 'environments_screen.dart';

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

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            PremiumSidebar(
              selectedIndex: _desktopIndex,
              onIndexChanged: (index) => _handleDesktopNav(context, index),
            ),
            Expanded(child: _getIndexContent(_desktopIndex)),
          ],
        ),
      );
    } else {
      // Mobile: Entry point is Composer with Drawer
      return ComposerScreen(
        drawer: Drawer(
          child: PremiumSidebar(
            selectedIndex: 0, // Always 0 in home context mobile
            onIndexChanged: (index) => _handleMobileNav(context, index),
          ),
        ),
      );
    }
  }

  Widget _getIndexContent(int index) {
    switch (index) {
      case 0:
        return const ComposerScreen(); // No drawer param needed in desktop
      case 1:
        return const SavedRequestsScreen();
      case 2:
        return const HistoryScreen();
      case 3:
        return const EnvironmentsScreen();
      default:
        // Index 4 (Settings) returns a dummy view if reached via state,
        // but it should be intercepted by onIndexChanged.
        // We return Composer just in case.
        return const ComposerScreen();
    }
  }

  void _handleDesktopNav(BuildContext context, int index) {
    if (index == 4) {
      // Open Settings
      showDialog(context: context, builder: (_) => const SettingsDialog());
      return;
    }
    setState(() => _desktopIndex = index);
  }

  void _handleMobileNav(BuildContext context, int index) {
    Navigator.pop(context); // Close drawer

    if (index == 0) return; // Already on Home (Composer)

    if (index == 4) {
      showDialog(context: context, builder: (_) => const SettingsDialog());
      return;
    }

    Widget? page;
    if (index == 1) page = const SavedRequestsScreen();
    if (index == 2) page = const HistoryScreen();
    if (index == 3) page = const EnvironmentsScreen();

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }
}
