import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/domain/entities/assertion_rule_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';

class AssertionsTab extends ConsumerStatefulWidget {
  const AssertionsTab({super.key, required this.tabId});

  final String tabId;

  @override
  ConsumerState<AssertionsTab> createState() => _AssertionsTabState();
}

class _AssertionsTabState extends ConsumerState<AssertionsTab> {
  List<AssertionRuleEntity> _rules = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final session = ref.read(requestSessionProvider(widget.tabId)).asData?.value;
    _rules = AssertionRuleEntity.listFromJson(session?.assertionsJson);
    if (_rules.isEmpty) {
      _rules = [
        const AssertionRuleEntity(
          type: AssertionType.statusCode,
          expected: '200',
        ),
      ];
    }
  }

  void _persist() {
    final json = jsonEncode(_rules.map((r) => r.toJson()).toList());
    ref
        .read(requestSessionControllerProvider(widget.tabId))
        .setAssertionsJson(json);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...List.generate(_rules.length, (index) {
          final rule = _rules[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<AssertionType>(
                    initialValue: rule.type,
                    decoration: InputDecoration(labelText: l10n.assertionType),
                    items: AssertionType.values
                        .map(
                          (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _rules[index] = AssertionRuleEntity(
                          type: v,
                          target: rule.target,
                          expected: rule.expected,
                          operator: rule.operator,
                        );
                        _persist();
                      });
                    },
                  ),
                  if (rule.type == AssertionType.jsonPathExists ||
                      rule.type == AssertionType.jsonPathEquals)
                    TextFormField(
                      initialValue: rule.target,
                      decoration: InputDecoration(labelText: l10n.assertionTarget),
                      onChanged: (v) {
                        _rules[index] = AssertionRuleEntity(
                          type: rule.type,
                          target: v,
                          expected: rule.expected,
                          operator: rule.operator,
                        );
                        _persist();
                      },
                    ),
                  TextFormField(
                    initialValue: rule.expected,
                    decoration: InputDecoration(labelText: l10n.assertionExpected),
                    onChanged: (v) {
                      _rules[index] = AssertionRuleEntity(
                        type: rule.type,
                        target: rule.target,
                        expected: v,
                        operator: rule.operator,
                      );
                      _persist();
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _rules.add(
                const AssertionRuleEntity(
                  type: AssertionType.statusCode,
                  expected: '200',
                ),
              );
              _persist();
            });
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.addAssertion),
        ),
      ],
    );
  }
}
