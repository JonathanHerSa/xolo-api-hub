import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:xolo/data/local/database.dart';

void main() {
  group('AppDatabase', () {
    test('schemaVersion is 8', () {
      final db = AppDatabase.memory();
      addTearDown(db.close);

      expect(db.schemaVersion, 8);
    });

    test('onCreate creates all tables and accepts inserts', () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);

      final collectionId = await db
          .into(db.collections)
          .insert(CollectionsCompanion.insert(name: 'Workspace'));

      await db
          .into(db.environments)
          .insert(
            EnvironmentsCompanion.insert(
              name: 'Dev',
              collectionId: Value(collectionId),
            ),
          );

      await db
          .into(db.envVariables)
          .insert(
            EnvVariablesCompanion.insert(
              key: 'baseUrl',
              value: 'https://api.test',
              collectionId: Value(collectionId),
            ),
          );

      final requestId = await db
          .into(db.savedRequests)
          .insert(
            SavedRequestsCompanion.insert(
              name: 'Ping',
              method: 'GET',
              url: 'https://api.test/ping',
              collectionId: Value(collectionId),
              authType: const Value('bearer'),
              authData: const Value('{"token":"x"}'),
              schemaJson: const Value('{}'),
              preScriptsJson: const Value('[]'),
              scriptsJson: const Value('[]'),
            ),
          );

      await db
          .into(db.historyEntries)
          .insert(
            HistoryEntriesCompanion.insert(
              method: 'GET',
              url: 'https://api.test/ping',
              originalUrl: const Value('https://api.test/{{path}}'),
              savedRequestId: Value(requestId),
              workspaceId: Value(collectionId),
              statusCode: const Value(200),
              durationMs: const Value(42),
            ),
          );

      await db
          .into(db.appSettings)
          .insert(AppSettingsCompanion.insert(key: 'theme', value: 'dark'));

      final collections = await db.select(db.collections).get();
      final environments = await db.select(db.environments).get();
      final variables = await db.select(db.envVariables).get();
      final requests = await db.select(db.savedRequests).get();
      final history = await db.select(db.historyEntries).get();
      final settings = await db.select(db.appSettings).get();

      expect(collections, hasLength(1));
      expect(environments, hasLength(1));
      expect(variables, hasLength(1));
      expect(requests, hasLength(1));
      expect(history, hasLength(1));
      expect(settings, hasLength(1));
      expect(history.first.originalUrl, 'https://api.test/{{path}}');
      expect(requests.first.preScriptsJson, '[]');
    });

    test(
      'migrates from v1 and adds columns introduced in later versions',
      () async {
        final sqlite = sqlite3.openInMemory();

        sqlite.execute('''
        CREATE TABLE collections (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          parent_id INTEGER,
          created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', 'now') AS INTEGER))
        );
      ''');

        sqlite.execute('''
        CREATE TABLE saved_requests (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          method TEXT NOT NULL,
          url TEXT NOT NULL,
          headers_json TEXT,
          params_json TEXT,
          body TEXT,
          collection_id INTEGER,
          created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', 'now') AS INTEGER)),
          updated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', 'now') AS INTEGER)),
          is_deleted INTEGER NOT NULL DEFAULT 0
        );
      ''');

        sqlite.execute('''
        CREATE TABLE history_entries (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          saved_request_id INTEGER,
          workspace_id INTEGER,
          method TEXT NOT NULL,
          url TEXT NOT NULL,
          headers_json TEXT,
          params_json TEXT,
          body TEXT,
          status_code INTEGER,
          response_body TEXT,
          duration_ms INTEGER,
          executed_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', 'now') AS INTEGER))
        );
      ''');

        sqlite.execute('''
        CREATE TABLE environments (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          collection_id INTEGER,
          is_active INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', 'now') AS INTEGER))
        );
      ''');

        sqlite.execute('''
        CREATE TABLE env_variables (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          key TEXT NOT NULL,
          value TEXT NOT NULL,
          environment_id INTEGER,
          collection_id INTEGER,
          scope TEXT NOT NULL DEFAULT 'global',
          created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', 'now') AS INTEGER))
        );
      ''');

        sqlite.execute('''
        CREATE TABLE app_settings (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        );
      ''');

        sqlite.execute('PRAGMA user_version = 1');

        final executor = NativeDatabase.opened(sqlite);
        final db = AppDatabase(executor);
        addTearDown(db.close);

        expect(db.schemaVersion, 8);

        final collectionId = await db
            .into(db.collections)
            .insert(
              CollectionsCompanion.insert(
                name: 'Migrated',
                authType: const Value('api_key'),
                authData: const Value('{"key":"X-Api-Key","value":"secret"}'),
              ),
            );

        await db
            .into(db.savedRequests)
            .insert(
              SavedRequestsCompanion.insert(
                name: 'Legacy Request',
                method: 'POST',
                url: 'https://api.test/items',
                collectionId: Value(collectionId),
                authType: const Value('bearer'),
                authData: const Value('{"token":"legacy"}'),
                schemaJson: const Value('{"type":"object"}'),
                preScriptsJson: Value(
                  r'[{"key":"id","value":"{{$timestamp}}"}]',
                ),
                scriptsJson: Value(r'[{"key":"token","path":"$.token"}]'),
              ),
            );

        await db
            .into(db.historyEntries)
            .insert(
              HistoryEntriesCompanion.insert(
                method: 'POST',
                url: 'https://api.test/items',
                originalUrl: const Value('https://api.test/{{resource}}'),
                workspaceId: Value(collectionId),
                authType: const Value('bearer'),
                authData: const Value('{"token":"legacy"}'),
                statusCode: const Value(201),
              ),
            );

        final collection = await (db.select(
          db.collections,
        )..where((t) => t.id.equals(collectionId))).getSingle();
        final request = await db.select(db.savedRequests).getSingle();
        final history = await db.select(db.historyEntries).getSingle();

        expect(collection.authType, 'api_key');
        expect(request.schemaJson, '{"type":"object"}');
        expect(request.preScriptsJson, contains('timestamp'));
        expect(request.scriptsJson, contains(r'$.token'));
        expect(history.originalUrl, 'https://api.test/{{resource}}');
        expect(history.authType, 'bearer');
      },
    );
  });
}
