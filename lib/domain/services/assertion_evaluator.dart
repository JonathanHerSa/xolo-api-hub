import 'dart:convert';

import 'package:json_path/json_path.dart';

import 'package:xolo/domain/entities/assertion_rule_entity.dart';
import 'package:xolo/domain/entities/collection_run_entity.dart';

/// Pure evaluator for declarative assertion rules.
class AssertionEvaluator {
  AssertionEvaluator._();

  static List<AssertionResultEntity> evaluate({
    required List<AssertionRuleEntity> rules,
    required int? statusCode,
    required int durationMs,
    required dynamic responseData,
    String? errorMessage,
  }) {
    if (rules.isEmpty) {
      return const [
        AssertionResultEntity(
          ruleType: 'implicit',
          passed: true,
          message: 'No assertions defined',
        ),
      ];
    }

    return rules
        .map(
          (rule) => _evaluateRule(
            rule: rule,
            statusCode: statusCode,
            durationMs: durationMs,
            responseData: responseData,
            errorMessage: errorMessage,
          ),
        )
        .toList();
  }

  static AssertionResultEntity _evaluateRule({
    required AssertionRuleEntity rule,
    required int? statusCode,
    required int durationMs,
    required dynamic responseData,
    String? errorMessage,
  }) {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return AssertionResultEntity(
        ruleType: rule.type.name,
        passed: false,
        message: 'Request error: $errorMessage',
      );
    }

    switch (rule.type) {
      case AssertionType.statusCode:
        return _evalStatusCode(rule, statusCode);
      case AssertionType.responseTimeMs:
        return _evalResponseTime(rule, durationMs);
      case AssertionType.jsonPathExists:
        return _evalJsonPathExists(rule, responseData);
      case AssertionType.jsonPathEquals:
        return _evalJsonPathEquals(rule, responseData);
      case AssertionType.bodyContains:
        return _evalBodyContains(rule, responseData);
    }
  }

  static AssertionResultEntity _evalStatusCode(
    AssertionRuleEntity rule,
    int? statusCode,
  ) {
    final code = statusCode ?? -1;
    if (rule.operator == 'in') {
      final allowed = rule.expected
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList();
      final passed = allowed.contains(code);
      return AssertionResultEntity(
        ruleType: rule.type.name,
        passed: passed,
        message: passed
            ? 'Status $code is in [${allowed.join(', ')}]'
            : 'Expected status in [${allowed.join(', ')}], got $code',
      );
    }

    final expected = int.tryParse(rule.expected) ?? 0;
    final passed = code == expected;
    return AssertionResultEntity(
      ruleType: rule.type.name,
      passed: passed,
      message: passed
          ? 'Status code is $expected'
          : 'Expected status $expected, got $code',
    );
  }

  static AssertionResultEntity _evalResponseTime(
    AssertionRuleEntity rule,
    int durationMs,
  ) {
    final limit = int.tryParse(rule.expected) ?? 0;
    final passed = rule.operator == 'lessThan'
        ? durationMs < limit
        : durationMs <= limit;
    return AssertionResultEntity(
      ruleType: rule.type.name,
      passed: passed,
      message: passed
          ? 'Response time ${durationMs}ms within limit'
          : 'Response time ${durationMs}ms exceeds ${limit}ms',
    );
  }

  static AssertionResultEntity _evalJsonPathExists(
    AssertionRuleEntity rule,
    dynamic responseData,
  ) {
    final path = rule.target ?? rule.expected;
    try {
      final matches = JsonPath(path).read(responseData);
      final passed = matches.isNotEmpty && matches.first.value != null;
      return AssertionResultEntity(
        ruleType: rule.type.name,
        passed: passed,
        message: passed
            ? 'JSONPath $path exists'
            : 'JSONPath $path not found',
      );
    } catch (e) {
      return AssertionResultEntity(
        ruleType: rule.type.name,
        passed: false,
        message: 'Invalid JSONPath $path',
      );
    }
  }

  static AssertionResultEntity _evalJsonPathEquals(
    AssertionRuleEntity rule,
    dynamic responseData,
  ) {
    final path = rule.target ?? '';
    try {
      final matches = JsonPath(path).read(responseData);
      if (matches.isEmpty) {
        return AssertionResultEntity(
          ruleType: rule.type.name,
          passed: false,
          message: 'JSONPath $path not found',
        );
      }
      final actual = matches.first.value?.toString() ?? '';
      final expected = _stripQuotes(rule.expected);
      final passed = actual == expected;
      return AssertionResultEntity(
        ruleType: rule.type.name,
        passed: passed,
        message: passed
            ? '$path equals "$expected"'
            : 'Expected "$expected" at $path, got "$actual"',
      );
    } catch (e) {
      return AssertionResultEntity(
        ruleType: rule.type.name,
        passed: false,
        message: 'Invalid JSONPath $path',
      );
    }
  }

  static AssertionResultEntity _evalBodyContains(
    AssertionRuleEntity rule,
    dynamic responseData,
  ) {
    final bodyStr = _responseToString(responseData);
    final passed = bodyStr.contains(rule.expected);
    return AssertionResultEntity(
      ruleType: rule.type.name,
      passed: passed,
      message: passed
          ? 'Body contains "${rule.expected}"'
          : 'Body does not contain "${rule.expected}"',
    );
  }

  static String _responseToString(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  static String _stripQuotes(String value) {
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  static bool allPassed(List<AssertionResultEntity> results) {
    return results.every((r) => r.passed);
  }
}
