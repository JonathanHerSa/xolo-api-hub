import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final savedRequestsStreamProvider =
    StreamProvider.autoDispose<List<SavedRequest>>((ref) {
      final db = ref.watch(databaseProvider);
      return db.watchSavedRequests();
    });
