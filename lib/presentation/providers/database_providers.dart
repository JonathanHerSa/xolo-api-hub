import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';

// =============================================================================
// DATABASE PROVIDER
// =============================================================================

/// Provider singleton de la base de datos
/// Se usa en toda la app para acceder a la BD
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Cerrar la BD cuando se destruya el provider
  ref.onDispose(() => db.close());
  return db;
});

// =============================================================================
// HISTORY PROVIDERS
// =============================================================================

/// Stream reactivo del historial reciente
/// Se actualiza automáticamente cuando hay nuevas entradas
final historyStreamProvider = StreamProvider<List<HistoryEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecentHistory(limit: 100);
});

/// Provider para obtener un item específico del historial
final historyItemProvider = FutureProvider.family<HistoryEntry?, int>((
  ref,
  id,
) {
  final db = ref.watch(databaseProvider);
  return db.getHistoryById(id);
});

// =============================================================================
// SAVED REQUESTS PROVIDERS
// =============================================================================

/// Stream reactivo de requests guardados
final savedRequestsStreamProvider = StreamProvider<List<SavedRequest>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSavedRequests();
});
