import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/services/auth_secret_service.dart';
import 'package:xolo/core/services/security_service.dart';
import 'package:xolo/data/local/database.dart';

class _InMemorySecurityService extends SecurityService {
  final Map<String, String> _store = {};

  @override
  Future<void> saveSecure(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> readSecure(String key) async => _store[key];

  @override
  Future<void> deleteSecure(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _store.clear();
  }
}

void main() {
  group('AuthSecretService', () {
    late _InMemorySecurityService security;
    late AuthSecretService service;

    setUp(() {
      security = _InMemorySecurityService();
      service = AuthSecretService(security);
    });

    test('stores auth data and resolves from reference', () async {
      const raw = '{"token":"abc123"}';
      final ref = await service.storeAuthData(raw);
      final resolved = await service.resolveAuthData(ref);

      expect(ref, isNotNull);
      expect(service.isReference(ref), isTrue);
      expect(resolved, raw);
    });

    test('isReference and extractReferenceKey handle non-references', () {
      expect(service.isReference(null), isFalse);
      expect(service.isReference('plain'), isFalse);
      expect(service.extractReferenceKey('plain'), isNull);
    });

    test('storeAuthData returns null for empty input', () async {
      expect(await service.storeAuthData(null), isNull);
      expect(await service.storeAuthData(''), isNull);
    });

    test('resolveAuthData returns plain value when not a reference', () async {
      expect(await service.resolveAuthData('{"a":1}'), '{"a":1}');
      expect(await service.resolveAuthData(null), isNull);
      expect(await service.resolveAuthData(''), isNull);
    });

    test('deleteAuthData removes stored secret', () async {
      final ref = await service.storeAuthData('{"k":"v"}');
      await service.deleteAuthData(ref);
      expect(await service.resolveAuthData(ref), isNull);
    });

    test('deleteAuthData no-ops for non-reference', () async {
      await service.deleteAuthData('not-a-ref');
    });

    test(
      'migrateCollectionAuthData migrates plain auth to references',
      () async {
        final db = AppDatabase.memory();
        addTearDown(db.close);

        final collectionId = await db
            .into(db.collections)
            .insert(CollectionsCompanion.insert(name: 'Legacy'));

        await db.updateCollectionAuthDataById(collectionId, '{"legacy":true}');

        final migrated = await service.migrateCollectionAuthData(db);
        expect(migrated, 1);

        final rows = await db.getCollectionsWithPlainAuthData();
        expect(rows, isEmpty);

        final collection = await (db.select(
          db.collections,
        )..where((t) => t.id.equals(collectionId))).getSingle();
        expect(service.isReference(collection.authData), isTrue);
        expect(
          await service.resolveAuthData(collection.authData),
          '{"legacy":true}',
        );
      },
    );

    test(
      'migrate skips empty, existing references, and already secure rows',
      () async {
        final db = AppDatabase.memory();
        addTearDown(db.close);

        final emptyId = await db
            .into(db.collections)
            .insert(CollectionsCompanion.insert(name: 'Empty'));
        await db.updateCollectionAuthDataById(emptyId, null);

        final refId = await db
            .into(db.collections)
            .insert(CollectionsCompanion.insert(name: 'Ref'));
        final ref = await service.storeAuthData('{"r":1}');
        await db.updateCollectionAuthDataById(refId, ref);

        expect(await service.migrateCollectionAuthData(db), 0);
      },
    );
  });
}
