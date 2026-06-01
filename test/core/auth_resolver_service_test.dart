import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/services/auth_resolver_service.dart';
import 'package:xolo/core/services/auth_secret_service.dart';
import 'package:xolo/core/services/security_service.dart';

import '../helpers/test_providers.dart';

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
  group('AuthResolverService', () {
    late TestHarness harness;
    late AuthResolverService resolver;
    late AuthSecretService authSecrets;

    setUp(() {
      harness = TestHarness.create();
      authSecrets = AuthSecretService(_InMemorySecurityService());
      resolver = AuthResolverService(harness.repo, authSecrets);
    });

    tearDown(() {
      harness.dispose();
    });

    test('returns direct request auth with resolved secret ref', () async {
      const raw = '{"token":"direct"}';
      final ref = await authSecrets.storeAuthData(raw);

      final result = await resolver.resolveAuth(
        requestAuthType: 'bearer',
        requestAuthData: ref,
        collectionId: 1,
      );

      expect(result.source, 'request');
      expect(result.type, 'bearer');
      expect(result.data, raw);
    });

    test('returns none when request auth is explicitly none', () async {
      final result = await resolver.resolveAuth(
        requestAuthType: 'none',
        requestAuthData: '{"ignored":true}',
        collectionId: 1,
      );

      expect(result.source, 'none');
      expect(result.type, isNull);
      expect(result.data, isNull);
    });

    test('returns none when inheriting without collection', () async {
      final result = await resolver.resolveAuth(
        requestAuthType: 'inherit',
        collectionId: null,
      );

      expect(result.source, 'none');
    });

    test('inherits project auth from root collection', () async {
      final projectId = await harness.repo.createCollection(name: 'Project');
      await harness.repo.updateCollection(
        projectId,
        'Project',
        null,
        authType: 'apikey',
        authData: '{"apiKey":"project-key"}',
      );

      final result = await resolver.resolveAuth(
        requestAuthType: 'inherit',
        collectionId: projectId,
      );

      expect(result.source, 'project');
      expect(result.type, 'apikey');
      expect(result.data, '{"apiKey":"project-key"}');
    });

    test('inherits folder auth from nearest parent', () async {
      final projectId = await harness.repo.createCollection(name: 'Project');
      final folderId = await harness.repo.createCollection(
        name: 'Folder',
        parentId: projectId,
      );
      await harness.repo.updateCollection(
        folderId,
        'Folder',
        null,
        authType: 'basic',
        authData: '{"user":"folder"}',
      );

      final result = await resolver.resolveAuth(
        requestAuthType: 'inherit',
        collectionId: folderId,
      );

      expect(result.source, 'folder');
      expect(result.type, 'basic');
      expect(result.data, '{"user":"folder"}');
    });

    test('collection none stops inheritance', () async {
      final projectId = await harness.repo.createCollection(name: 'Project');
      await harness.repo.updateCollection(
        projectId,
        'Project',
        null,
        authType: 'bearer',
        authData: '{"token":"root"}',
      );
      final childId = await harness.repo.createCollection(
        name: 'Blocked',
        parentId: projectId,
      );
      await harness.repo.updateCollection(
        childId,
        'Blocked',
        null,
        authType: 'none',
      );

      final result = await resolver.resolveAuth(
        requestAuthType: 'inherit',
        collectionId: childId,
      );

      expect(result.source, 'none');
    });

    test('returns none when path has only inherit auth', () async {
      final projectId = await harness.repo.createCollection(name: 'Empty');
      await harness.repo.updateCollection(
        projectId,
        'Empty',
        null,
        authType: 'inherit',
      );

      final result = await resolver.resolveAuth(
        requestAuthType: 'inherit',
        collectionId: projectId,
      );

      expect(result.source, 'none');
    });

    test('resolves collection auth stored as secret reference', () async {
      const raw = '{"token":"stored"}';
      final ref = await authSecrets.storeAuthData(raw);
      final projectId = await harness.repo.createCollection(name: 'Secure');
      await harness.repo.updateCollection(
        projectId,
        'Secure',
        null,
        authType: 'bearer',
        authData: ref,
      );

      final result = await resolver.resolveAuth(
        requestAuthType: 'inherit',
        collectionId: projectId,
      );

      expect(result.data, raw);
      expect(result.source, 'project');
    });

    test('passes through plain auth data on request', () async {
      final result = await resolver.resolveAuth(
        requestAuthType: 'bearer',
        requestAuthData: '{"token":"plain"}',
        collectionId: null,
      );

      expect(result.data, '{"token":"plain"}');
      expect(result.source, 'request');
    });
  });
}
