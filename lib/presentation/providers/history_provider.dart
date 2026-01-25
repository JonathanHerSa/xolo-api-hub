import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import 'database_providers.dart';
import 'workspace_provider.dart';

/// Historial reciente filtrado por el Workspace activo
final recentHistoryStreamProvider =
    StreamProvider.autoDispose<List<HistoryEntry>>((ref) {
      final db = ref.watch(databaseProvider);
      final workspaceId = ref.watch(activeWorkspaceIdProvider);

      return db.watchRecentHistory(workspaceId);
    });

// Podríamos agregar actions aquí si fuera un Notifier
