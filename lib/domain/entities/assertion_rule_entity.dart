import 'dart:convert';

/// Declarative assertion rule for collection run validation.
enum AssertionType {
  statusCode,
  responseTimeMs,
  jsonPathExists,
  jsonPathEquals,
  bodyContains,
}

class AssertionRuleEntity {
  const AssertionRuleEntity({
    required this.type,
    this.target,
    required this.expected,
    this.operator = 'equals',
  });

  final AssertionType type;
  final String? target;
  final String expected;
  final String operator;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'target': target,
    'expected': expected,
    'operator': operator,
  };

  factory AssertionRuleEntity.fromJson(Map<String, dynamic> json) {
    return AssertionRuleEntity(
      type: AssertionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AssertionType.statusCode,
      ),
      target: json['target'] as String?,
      expected: json['expected']?.toString() ?? '',
      operator: json['operator'] as String? ?? 'equals',
    );
  }

  static List<AssertionRuleEntity> listFromJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return const [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => AssertionRuleEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
