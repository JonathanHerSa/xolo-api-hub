import 'package:go_router/go_router.dart';

import 'package:xolo/presentation/screens/active_workspace_explorer.dart';
import 'package:xolo/presentation/screens/composer_screen.dart';
import 'package:xolo/presentation/screens/environments_screen.dart';
import 'package:xolo/presentation/screens/history_screen.dart';
import 'package:xolo/presentation/screens/home_screen.dart';
import 'package:xolo/presentation/screens/collection_run_screen.dart';
import 'package:xolo/presentation/screens/run_history_screen.dart';
import 'package:xolo/presentation/screens/run_report_screen.dart';
import 'package:xolo/presentation/screens/settings_screen.dart';
import 'package:xolo/presentation/screens/sync_screen.dart';

abstract final class AppRoutes {
  static const explorer = '/';
  static const history = '/history';
  static const composer = '/composer';
  static const sync = '/sync';
  static const environments = '/environments';
  static const settings = '/settings';
  static const runActive = '/runs/active';
  static const runHistory = '/runs';
  static const runReport = '/runs/report';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.explorer,
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.explorer,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ActiveWorkspaceExplorer()),
        ),
        GoRoute(
          path: AppRoutes.history,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HistoryScreen()),
        ),
        GoRoute(
          path: AppRoutes.composer,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ComposerScreen()),
        ),
        GoRoute(
          path: AppRoutes.sync,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SyncScreen()),
        ),
        GoRoute(
          path: AppRoutes.environments,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: EnvironmentsScreen()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
        GoRoute(
          path: AppRoutes.runActive,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CollectionRunScreen()),
        ),
        GoRoute(
          path: AppRoutes.runHistory,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: RunHistoryScreen()),
        ),
        GoRoute(
          path: '${AppRoutes.runReport}/:runId',
          pageBuilder: (context, state) {
            final runId = int.parse(state.pathParameters['runId']!);
            return NoTransitionPage(child: RunReportScreen(runId: runId));
          },
        ),
      ],
    ),
  ],
);

/// Maps bottom-nav index to route path.
String routeForTabIndex(int index) {
  return switch (index) {
    0 => AppRoutes.explorer,
    1 => AppRoutes.history,
    2 => AppRoutes.composer,
    3 => AppRoutes.sync,
    4 => AppRoutes.settings,
    _ => AppRoutes.explorer,
  };
}

int tabIndexForRoute(String location) {
  if (location.startsWith(AppRoutes.history)) return 1;
  if (location.startsWith(AppRoutes.composer)) return 2;
  if (location.startsWith(AppRoutes.sync)) return 3;
  if (location.startsWith(AppRoutes.settings)) return 4;
  return 0;
}

/// Desktop rail order: composer, collections, history, environments, settings.
int railIndexForRoute(String location) {
  if (location.startsWith(AppRoutes.composer)) return 0;
  if (location.startsWith(AppRoutes.history)) return 2;
  if (location.startsWith(AppRoutes.environments)) return 3;
  if (location.startsWith(AppRoutes.settings)) return 4;
  return 1;
}

String routeForRailIndex(int index) {
  return switch (index) {
    0 => AppRoutes.composer,
    1 => AppRoutes.explorer,
    2 => AppRoutes.history,
    3 => AppRoutes.environments,
    4 => AppRoutes.settings,
    _ => AppRoutes.explorer,
  };
}
