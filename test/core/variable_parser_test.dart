import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/utils/variable_parser.dart';

void main() {
  group('VariableParser.parse', () {
    test('returns empty input unchanged', () {
      expect(VariableParser.parse('', {'a': '1'}), '');
    });

    test('returns input without markers unchanged', () {
      expect(VariableParser.parse('plain-text', {}), 'plain-text');
    });

    test('substitutes environment variables', () {
      final result = VariableParser.parse('{{baseUrl}}/users/:id', {
        'baseUrl': 'https://api.test',
        'id': '42',
      });
      expect(result, 'https://api.test/users/42');
    });

    test('substitutes {:param} path style', () {
      expect(
        VariableParser.parse('/items/{:itemId}', {'itemId': '7'}),
        '/items/7',
      );
    });

    test('supports dynamic timestamp variable', () {
      final result = VariableParser.parse(r'{{$timestamp}}', {});
      expect(int.tryParse(result), isNotNull);
    });

    test('supports dynamic guid and randomInt', () {
      final guid = VariableParser.parse(r'{{$guid}}', {});
      expect(
        guid,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          ),
        ),
      );

      final randomInt = VariableParser.parse(r'{{$randomInt}}', {});
      final n = int.tryParse(randomInt);
      expect(n, isNotNull);
      expect(n! >= 0 && n < 1000, isTrue);
    });

    test('leaves unknown placeholders intact', () {
      expect(VariableParser.parse('{{missing}}', {}), '{{missing}}');
    });

    test('recursively resolves nested placeholders up to depth limit', () {
      final result = VariableParser.parse('{{outer}}', {
        'outer': '{{inner}}',
        'inner': 'done',
      });
      expect(result, 'done');
    });

    test('stops recursion beyond max depth', () {
      final result = VariableParser.parse('{{a}}', {
        'a': '{{b}}',
        'b': '{{c}}',
        'c': '{{d}}',
        'd': '{{e}}',
        'e': 'end',
      });
      expect(result, contains('{{'));
    });
  });

  group('VariableParser.parseMap', () {
    test('returns empty map unchanged', () {
      expect(VariableParser.parseMap({}, {'x': '1'}), {});
    });

    test('parses string keys and values', () {
      final result = VariableParser.parseMap(
        {'{{host}}': '{{path}}'},
        {'host': 'api.test', 'path': '/v1'},
      );
      expect(result, {'api.test': '/v1'});
    });

    test('parses key only when value is not a string', () {
      final result = VariableParser.parseMap(
        {'{{prefix}}_flag': 42},
        {'prefix': 'dev'},
      );
      expect(result['dev_flag'], 42);
    });
  });
}
