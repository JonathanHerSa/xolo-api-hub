import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/utils/script_executor.dart';

void main() {
  group('ScriptExecutor.executePreScripts', () {
    test('returns empty map for null or empty json', () {
      expect(ScriptExecutor.executePreScripts(null, {}), isEmpty);
      expect(ScriptExecutor.executePreScripts('', {}), isEmpty);
    });

    test('evaluates templates using base variables', () {
      const json = '[{"key":"orderId","value":"order_{{prefix}}_{{suffix}}"}]';

      final result = ScriptExecutor.executePreScripts(json, {
        'prefix': 'A',
        'suffix': '99',
      });

      expect(result, {'orderId': 'order_A_99'});
    });

    test('skips rules with null or empty value template', () {
      const json = '[{"key":"ok","value":""}]';

      expect(ScriptExecutor.executePreScripts(json, {}), isEmpty);
    });

    test('returns empty map for invalid json', () {
      expect(ScriptExecutor.executePreScripts('not-json', {}), isEmpty);
    });
  });

  group('ScriptExecutor.testPostScripts', () {
    test('returns empty map for empty json', () {
      expect(ScriptExecutor.testPostScripts({'a': 1}, ''), isEmpty);
    });

    test('extracts values via json path', () {
      const json = r'[{"key":"token","path":"$.access_token"}]';
      final response = {'access_token': 'abc123', 'expires_in': 3600};

      final result = ScriptExecutor.testPostScripts(response, json);

      expect(result, {'token': 'abc123'});
    });

    test('returns no match marker when path misses', () {
      const json = r'[{"key":"missing","path":"$.unknown"}]';

      final result = ScriptExecutor.testPostScripts({'ok': true}, json);

      expect(result, {'missing': '[No Match]'});
    });

    test('returns error marker for invalid json path', () {
      const json = r'[{"key":"bad","path":"$[invalid"}]';

      final result = ScriptExecutor.testPostScripts({'ok': true}, json);

      expect(result['bad'], startsWith('[Error:'));
    });

    test('skips rules with empty path', () {
      const json = r'[{"key":"x","path":""}]';

      expect(ScriptExecutor.testPostScripts({'a': 1}, json), isEmpty);
    });
  });
}
