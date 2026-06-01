import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/domain/entities/assertion_rule_entity.dart';
import 'package:xolo/domain/services/assertion_evaluator.dart';

void main() {
  group('AssertionEvaluator', () {
    test('status_code equals passes', () {
      final results = AssertionEvaluator.evaluate(
        rules: const [
          AssertionRuleEntity(
            type: AssertionType.statusCode,
            expected: '200',
          ),
        ],
        statusCode: 200,
        durationMs: 100,
        responseData: {'ok': true},
      );
      expect(results.single.passed, isTrue);
    });

    test('status_code equals fails', () {
      final results = AssertionEvaluator.evaluate(
        rules: const [
          AssertionRuleEntity(
            type: AssertionType.statusCode,
            expected: '200',
          ),
        ],
        statusCode: 500,
        durationMs: 100,
        responseData: null,
      );
      expect(results.single.passed, isFalse);
    });

    test('json_path_exists', () {
      final results = AssertionEvaluator.evaluate(
        rules: const [
          AssertionRuleEntity(
            type: AssertionType.jsonPathExists,
            target: r'$.token',
            expected: '',
          ),
        ],
        statusCode: 200,
        durationMs: 50,
        responseData: {'token': 'abc'},
      );
      expect(results.single.passed, isTrue);
    });

    test('body_contains', () {
      final results = AssertionEvaluator.evaluate(
        rules: const [
          AssertionRuleEntity(
            type: AssertionType.bodyContains,
            expected: 'success',
          ),
        ],
        statusCode: 200,
        durationMs: 50,
        responseData: '{"status":"success"}',
      );
      expect(results.single.passed, isTrue);
    });

    test('response_time lessThan', () {
      final results = AssertionEvaluator.evaluate(
        rules: const [
          AssertionRuleEntity(
            type: AssertionType.responseTimeMs,
            expected: '3000',
            operator: 'lessThan',
          ),
        ],
        statusCode: 200,
        durationMs: 120,
        responseData: null,
      );
      expect(results.single.passed, isTrue);
    });
  });
}
