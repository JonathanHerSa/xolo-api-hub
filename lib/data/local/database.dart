import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'tables.dart';
part 'settings_queries.dart';
part 'collection_queries.dart';
part 'history_queries.dart';
part 'environment_queries.dart';
part 'database.g.dart';

// =============================================================================
// DATABASE
// =============================================================================

@DriftDatabase(
  tables: [
    SavedRequests,
    HistoryEntries,
    Collections,
    Environments,
    EnvVariables,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @visibleForTesting
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 7; // Bump version for History originalUrl

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add Auth columns (v2)
          await m.addColumn(savedRequests, savedRequests.authType);
          await m.addColumn(savedRequests, savedRequests.authData);
          await m.addColumn(historyEntries, historyEntries.authType);
          await m.addColumn(historyEntries, historyEntries.authData);
        }
        if (from < 3) {
          // Add schemaJson (v3)
          await m.addColumn(savedRequests, savedRequests.schemaJson);
        }
        if (from < 4) {
          // Add Auth columns to Collections (v4)
          await m.addColumn(collections, collections.authType);
          await m.addColumn(collections, collections.authData);
        }
        if (from < 5) {
          // Add scriptsJson (v5)
          await m.addColumn(savedRequests, savedRequests.scriptsJson);
        }
        if (from < 6) {
          // Add preScriptsJson (v6)
          await m.addColumn(savedRequests, savedRequests.preScriptsJson);
        }
        if (from < 7) {
          // Add originalUrl to history (v7)
          await m.addColumn(historyEntries, historyEntries.originalUrl);
        }
      },
    );
  }
}

// coverage:ignore-start
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'xolo_v3.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// coverage:ignore-end
