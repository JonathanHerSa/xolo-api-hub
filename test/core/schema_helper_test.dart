import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/utils/schema_helper.dart';

void main() {
  group('SchemaHelper.generateSample', () {
    test('returns example before default and nullable', () {
      expect(
        SchemaHelper.generateSample({
          'example': 'from-example',
          'default': 'from-default',
          'nullable': true,
        }),
        'from-example',
      );
    });

    test('returns default when no example', () {
      expect(
        SchemaHelper.generateSample({'default': 42, 'nullable': true}),
        42,
      );
    });

    test('returns null when nullable without example or default', () {
      expect(SchemaHelper.generateSample({'nullable': true}), isNull);
    });

    test('merges allOf object parts', () {
      final result = SchemaHelper.generateSample({
        'allOf': [
          {
            'type': 'object',
            'properties': {
              'a': {'type': 'string'},
            },
          },
          {
            'type': 'object',
            'properties': {
              'b': {'type': 'integer'},
            },
          },
        ],
      });
      expect(result, isA<Map<String, dynamic>>());
      expect(result['a'], 'string');
      expect(result['b'], 0);
    });

    test('returns empty map for allOf with no mergeable parts', () {
      expect(
        SchemaHelper.generateSample({
          'allOf': [
            {'type': 'string'},
            {'type': 'integer'},
          ],
        }),
        {},
      );
    });

    test('uses first branch of oneOf and anyOf', () {
      final oneOf = SchemaHelper.generateSample({
        'oneOf': [
          {'type': 'boolean'},
          {'type': 'string'},
        ],
      });
      expect(oneOf, true);

      final anyOf = SchemaHelper.generateSample({
        'anyOf': [
          {
            'enum': ['x', 'y'],
          },
          {'type': 'number'},
        ],
      });
      expect(anyOf, 'x');
    });

    test('returns first enum value', () {
      expect(
        SchemaHelper.generateSample({
          'enum': ['alpha', 'beta'],
        }),
        'alpha',
      );
    });

    test('builds object from properties', () {
      final obj = SchemaHelper.generateSample({
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'count': {'type': 'integer'},
          'active': {'type': 'boolean', 'nullable': true},
        },
      });
      expect(obj, {'name': 'string', 'count': 0, 'active': null});
    });

    test('returns empty object without properties', () {
      expect(SchemaHelper.generateSample({'type': 'object'}), {});
    });

    test('builds array with one sample item', () {
      expect(
        SchemaHelper.generateSample({
          'type': 'array',
          'items': {'type': 'string'},
        }),
        ['string'],
      );
    });

    test('returns empty array without items or nullable items', () {
      expect(SchemaHelper.generateSample({'type': 'array'}), []);
      expect(
        SchemaHelper.generateSample({
          'type': 'array',
          'items': {'nullable': true},
        }),
        [],
      );
    });

    test('handles string formats and primitives', () {
      final dateTime = SchemaHelper.generateSample({
        'type': 'string',
        'format': 'date-time',
      });
      expect(DateTime.tryParse(dateTime as String), isNotNull);

      expect(
        SchemaHelper.generateSample({'type': 'string', 'format': 'date'}),
        '2025-01-01',
      );
      expect(SchemaHelper.generateSample({'type': 'string'}), 'string');
      expect(SchemaHelper.generateSample({'type': 'integer'}), 0);
      expect(SchemaHelper.generateSample({'type': 'number'}), 0);
      expect(SchemaHelper.generateSample({'type': 'boolean'}), true);
    });

    test('uses example on primitives when provided', () {
      expect(
        SchemaHelper.generateSample({'type': 'string', 'example': 'custom'}),
        'custom',
      );
      expect(
        SchemaHelper.generateSample({'type': 'integer', 'example': 99}),
        99,
      );
    });

    test('falls back to schema example for unknown type', () {
      expect(SchemaHelper.generateSample({'example': 'fallback'}), 'fallback');
    });

    test('object via properties key without explicit type', () {
      final obj = SchemaHelper.generateSample({
        'properties': {
          'id': {'type': 'integer'},
        },
      });
      expect(obj, {'id': 0});
    });
  });

  group('SchemaHelper.resolveSchema', () {
    final root = {
      'components': {
        'schemas': {
          'User': {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
            },
          },
          'Pet': {
            'type': 'object',
            'properties': {
              'owner': {r'$ref': '#/components/schemas/User'},
            },
          },
          'CycleA': {r'$ref': '#/components/schemas/CycleB'},
          'CycleB': {r'$ref': '#/components/schemas/CycleA'},
        },
      },
    };

    test('resolves ref into nested schema', () {
      final resolved = SchemaHelper.resolveSchema({
        r'$ref': '#/components/schemas/Pet',
      }, root);
      expect(resolved['type'], 'object');
      final owner = resolved['properties']['owner'] as Map<String, dynamic>;
      expect(owner['type'], 'object');
      expect(owner['properties']['name']['type'], 'string');
    });

    test('breaks cyclic ref with empty map', () {
      final resolved = SchemaHelper.resolveSchema({
        r'$ref': '#/components/schemas/CycleA',
      }, root);
      expect(resolved, {});
    });

    test('keeps schema when ref is unresolvable', () {
      const schema = {r'$ref': '#/missing/path'};
      expect(SchemaHelper.resolveSchema(schema, root), schema);
    });

    test('returns null for external ref paths', () {
      const schema = {r'$ref': 'https://example.com/schema.json'};
      expect(SchemaHelper.resolveSchema(schema, root), schema);
    });

    test('recurses properties, items, and composition keywords', () {
      final input = {
        'type': 'object',
        'properties': {
          'list': {
            'type': 'array',
            'items': {r'$ref': '#/components/schemas/User'},
          },
        },
        'allOf': [
          {r'$ref': '#/components/schemas/User'},
        ],
        'oneOf': [
          {r'$ref': '#/components/schemas/User'},
        ],
        'anyOf': [
          {r'$ref': '#/components/schemas/User'},
        ],
      };

      final resolved = SchemaHelper.resolveSchema(input, root);
      final listItems =
          (resolved['properties']['list'] as Map)['items']
              as Map<String, dynamic>;
      expect(listItems['properties']['name']['type'], 'string');
      expect((resolved['allOf'] as List).first['type'], 'object');
      expect((resolved['oneOf'] as List).first['type'], 'object');
      expect((resolved['anyOf'] as List).first['type'], 'object');
    });
  });
}
