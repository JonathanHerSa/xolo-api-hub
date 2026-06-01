import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/mappers/entity_mappers.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/domain/entities/env_variable_entity.dart';
import 'package:xolo/domain/entities/environment_entity.dart';
import 'package:xolo/domain/entities/history_entry_entity.dart';
import 'package:xolo/domain/entities/saved_request_entity.dart';

void main() {
  final fixedDate = DateTime(2024, 6, 15, 10, 30);

  group('CollectionEntityMapper', () {
    test('toEntity preserves all fields', () {
      final row = Collection(
        id: 1,
        name: 'API Hub',
        description: 'Root workspace',
        parentId: null,
        createdAt: fixedDate,
        authType: 'bearer',
        authData: '{"token":"abc"}',
      );

      final entity = row.toEntity();

      expect(entity, isA<CollectionEntity>());
      expect(entity.id, 1);
      expect(entity.name, 'API Hub');
      expect(entity.description, 'Root workspace');
      expect(entity.parentId, isNull);
      expect(entity.authType, 'bearer');
      expect(entity.authData, '{"token":"abc"}');
      expect(entity.createdAt, fixedDate);
      expect(entity.isRoot, isTrue);
    });
  });

  group('SavedRequestEntityMapper', () {
    test('toEntity preserves all fields', () {
      final row = SavedRequest(
        id: 10,
        name: 'Get Users',
        method: 'GET',
        url: 'https://api.test/users',
        headersJson: '{"Accept":"application/json"}',
        paramsJson: '{"page":"1"}',
        body: null,
        authType: 'basic',
        authData: '{"username":"u","password":"p"}',
        schemaJson: '{"type":"object"}',
        preScriptsJson: '[{"key":"orderId","value":"ord_{{id}}"}]',
        scriptsJson: r'[{"key":"token","path":"$.access_token"}]',
        collectionId: 1,
        createdAt: fixedDate,
        updatedAt: fixedDate,
        isDeleted: false,
      );

      final entity = row.toEntity();

      expect(entity, isA<SavedRequestEntity>());
      expect(entity.id, 10);
      expect(entity.name, 'Get Users');
      expect(entity.method, 'GET');
      expect(entity.url, 'https://api.test/users');
      expect(entity.headersJson, '{"Accept":"application/json"}');
      expect(entity.paramsJson, '{"page":"1"}');
      expect(entity.body, isNull);
      expect(entity.authType, 'basic');
      expect(entity.authData, '{"username":"u","password":"p"}');
      expect(entity.schemaJson, '{"type":"object"}');
      expect(entity.preScriptsJson, '[{"key":"orderId","value":"ord_{{id}}"}]');
      expect(entity.scriptsJson, r'[{"key":"token","path":"$.access_token"}]');
      expect(entity.collectionId, 1);
      expect(entity.createdAt, fixedDate);
      expect(entity.updatedAt, fixedDate);
      expect(entity.isDeleted, isFalse);
    });
  });

  group('HistoryEntryEntityMapper', () {
    test('toHistoryRow and toEntity roundtrip all fields', () {
      final entity = HistoryEntryEntity(
        id: 5,
        savedRequestId: 10,
        workspaceId: 1,
        method: 'POST',
        url: 'https://api.test/users/42',
        originalUrl: 'https://api.test/users/{{userId}}',
        headersJson: '{}',
        paramsJson: null,
        body: '{"name":"Ada"}',
        authType: 'bearer',
        authData: '{"token":"t"}',
        statusCode: 201,
        responseBody: '{"ok":true}',
        durationMs: 150,
        executedAt: fixedDate,
      );

      final row = toHistoryRow(entity);
      final roundtripped = row.toEntity();

      expect(roundtripped.id, entity.id);
      expect(roundtripped.savedRequestId, entity.savedRequestId);
      expect(roundtripped.workspaceId, entity.workspaceId);
      expect(roundtripped.method, entity.method);
      expect(roundtripped.url, entity.url);
      expect(roundtripped.originalUrl, entity.originalUrl);
      expect(roundtripped.headersJson, entity.headersJson);
      expect(roundtripped.paramsJson, entity.paramsJson);
      expect(roundtripped.body, entity.body);
      expect(roundtripped.authType, entity.authType);
      expect(roundtripped.authData, entity.authData);
      expect(roundtripped.statusCode, entity.statusCode);
      expect(roundtripped.responseBody, entity.responseBody);
      expect(roundtripped.durationMs, entity.durationMs);
      expect(roundtripped.executedAt, entity.executedAt);
    });
  });

  group('EnvironmentEntityMapper', () {
    test('toEntity preserves all fields', () {
      final row = Environment(
        id: 3,
        name: 'Production',
        collectionId: 1,
        isActive: true,
        createdAt: fixedDate,
      );

      final entity = row.toEntity();

      expect(entity, isA<EnvironmentEntity>());
      expect(entity.id, 3);
      expect(entity.name, 'Production');
      expect(entity.collectionId, 1);
      expect(entity.isActive, isTrue);
      expect(entity.createdAt, fixedDate);
    });
  });

  group('EnvVariableEntityMapper', () {
    test('toEntity preserves all fields', () {
      final row = EnvVariable(
        id: 7,
        key: 'baseUrl',
        value: 'https://api.test',
        environmentId: 3,
        collectionId: 1,
        scope: 'env',
        createdAt: fixedDate,
      );

      final entity = row.toEntity();

      expect(entity, isA<EnvVariableEntity>());
      expect(entity.id, 7);
      expect(entity.key, 'baseUrl');
      expect(entity.value, 'https://api.test');
      expect(entity.environmentId, 3);
      expect(entity.collectionId, 1);
      expect(entity.scope, 'env');
      expect(entity.createdAt, fixedDate);
    });
  });

  group('list mappers', () {
    test('mapCollections maps every row', () {
      final rows = [
        Collection(
          id: 1,
          name: 'A',
          description: null,
          parentId: null,
          createdAt: fixedDate,
          authType: null,
          authData: null,
        ),
        Collection(
          id: 2,
          name: 'B',
          description: 'nested',
          parentId: 1,
          createdAt: fixedDate,
          authType: 'inherit',
          authData: null,
        ),
      ];

      final entities = mapCollections(rows);

      expect(entities, hasLength(2));
      expect(entities[0].id, 1);
      expect(entities[1].parentId, 1);
    });

    test('mapSavedRequests maps every row', () {
      final rows = [
        SavedRequest(
          id: 1,
          name: 'Req',
          method: 'GET',
          url: '/',
          headersJson: null,
          paramsJson: null,
          body: null,
          authType: null,
          authData: null,
          schemaJson: null,
          preScriptsJson: null,
          scriptsJson: null,
          collectionId: null,
          createdAt: fixedDate,
          updatedAt: fixedDate,
          isDeleted: false,
        ),
      ];

      expect(mapSavedRequests(rows), hasLength(1));
    });

    test('mapHistoryEntries maps every row', () {
      final rows = [
        HistoryEntry(
          id: 1,
          savedRequestId: null,
          workspaceId: null,
          method: 'GET',
          url: '/',
          originalUrl: '/{{path}}',
          headersJson: null,
          paramsJson: null,
          body: null,
          authType: null,
          authData: null,
          statusCode: 200,
          responseBody: null,
          durationMs: 10,
          executedAt: fixedDate,
        ),
      ];

      expect(mapHistoryEntries(rows), hasLength(1));
    });

    test('mapEnvironments maps every row', () {
      final rows = [
        Environment(
          id: 1,
          name: 'Dev',
          collectionId: null,
          isActive: false,
          createdAt: fixedDate,
        ),
      ];

      expect(mapEnvironments(rows), hasLength(1));
    });

    test('mapEnvVariables maps every row', () {
      final rows = [
        EnvVariable(
          id: 1,
          key: 'k',
          value: 'v',
          environmentId: null,
          collectionId: null,
          scope: 'global',
          createdAt: fixedDate,
        ),
      ];

      expect(mapEnvVariables(rows), hasLength(1));
    });
  });
}
