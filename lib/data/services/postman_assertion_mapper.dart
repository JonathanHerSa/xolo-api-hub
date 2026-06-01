import 'dart:convert';

import 'package:xolo/domain/entities/assertion_rule_entity.dart';

/// Maps a subset of Postman test scripts to Xolo declarative assertions.
class PostmanAssertionMapper {
  PostmanAssertionMapper._();

  static List<AssertionRuleEntity> fromPostmanEvents(
    List<dynamic>? events,
  ) {
    if (events == null) return const [];
    final rules = <AssertionRuleEntity>[];

    for (final event in events) {
      if (event is! Map<String, dynamic>) continue;
      if (event['listen'] != 'test') continue;
      final scriptBlock = event['script'];
      final script = scriptBlock is Map ? scriptBlock['exec'] : event['exec'];
      final lines = script is List
          ? script.map((e) => e.toString()).toList()
          : [script.toString()];

      for (final line in lines) {
        rules.addAll(_parseLine(line));
      }
    }
    return rules;
  }

  static List<AssertionRuleEntity> _parseLine(String line) {
    final statusMatch = RegExp(
      r'pm\.response\.to\.have\.status\((\d+)\)',
    ).firstMatch(line);
    if (statusMatch != null) {
      return [
        AssertionRuleEntity(
          type: AssertionType.statusCode,
          expected: statusMatch.group(1)!,
        ),
      ];
    }

    final existsMatch = RegExp(
      r'pm\.expect\([^.]+\.(\w+)\)\.to\.exist',
    ).firstMatch(line);
    if (existsMatch != null) {
      return [
        AssertionRuleEntity(
          type: AssertionType.jsonPathExists,
          target: r'$.' '${existsMatch.group(1)}',
          expected: '',
        ),
      ];
    }

    final jsonPathExists = RegExp(
      r'pm\.expect\(json\.([^\)]+)\)\.to\.exist',
    ).firstMatch(line);
    if (jsonPathExists != null) {
      return [
        AssertionRuleEntity(
          type: AssertionType.jsonPathExists,
          target: r'$.' '${jsonPathExists.group(1)!}',
          expected: '',
        ),
      ];
    }

    return const [];
  }

  static String? encodeRules(List<AssertionRuleEntity> rules) {
    if (rules.isEmpty) return null;
    return jsonEncode(rules.map((r) => r.toJson()).toList());
  }
}
