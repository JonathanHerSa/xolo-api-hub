import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/repositories/drift_xolo_repository.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';
import 'package:xolo/domain/repositories/xolo_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final xoloRepositoryProvider = Provider<XoloRepository>((ref) {
  return DriftXoloRepository(ref.watch(databaseProvider));
});

final savedRequestsStreamProvider =
    StreamProvider.autoDispose<List<SavedRequestEntity>>((ref) {
      final repo = ref.watch(xoloRepositoryProvider);
      return repo.watchSavedRequests();
    });
