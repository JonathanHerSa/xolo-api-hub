import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/request_provider.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';

class ScriptRule {
  String variableName;
  String jsonPath;
  String value;

  ScriptRule({this.variableName = '', this.jsonPath = '', this.value = ''});

  Map<String, dynamic> toJson() {
    return {'key': variableName, 'path': jsonPath, 'value': value};
  }

  factory ScriptRule.fromJson(Map<String, dynamic> json) {
    return ScriptRule(
      variableName: json['key'] ?? '',
      jsonPath: json['path'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

class ScriptsTab extends ConsumerStatefulWidget {
  final String tabId;
  const ScriptsTab({super.key, required this.tabId});

  @override
  ConsumerState<ScriptsTab> createState() => _ScriptsTabState();
}

class _ScriptsTabState extends ConsumerState<ScriptsTab>
    with TickerProviderStateMixin {
  List<ScriptRule> _preRules = [];
  List<ScriptRule> _postRules = [];
  Map<String, String> _testResults = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRules() {
    final session = ref
        .read(requestSessionProvider(widget.tabId))
        .asData
        ?.value;

    // Load Post-Request (Extractions)
    final postJson = session?.scriptsJson;
    if (postJson != null && postJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(postJson);
        _postRules = list.map((e) => ScriptRule.fromJson(e)).toList();
      } catch (_) {
        _postRules = [];
      }
    } else {
      _postRules = [];
    }
    if (_postRules.isEmpty || _postRules.last.variableName.isNotEmpty) {
      _postRules.add(ScriptRule());
    }

    // Load Pre-Request
    final preJson = session?.preScriptsJson;
    if (preJson != null && preJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(preJson);
        _preRules = list.map((e) => ScriptRule.fromJson(e)).toList();
      } catch (_) {
        _preRules = [];
      }
    } else {
      _preRules = [];
    }
    if (_preRules.isEmpty || _preRules.last.variableName.isNotEmpty) {
      _preRules.add(ScriptRule());
    }

    setState(() {});
  }

  void _saveRules() {
    // Save Post
    final filteredPost = _postRules
        .where((r) => r.variableName.isNotEmpty)
        .map((r) => r.toJson())
        .toList();
    final postJson = filteredPost.isEmpty ? null : jsonEncode(filteredPost);
    ref
        .read(requestSessionControllerProvider(widget.tabId))
        .setScriptsJson(postJson);

    // Save Pre
    final filteredPre = _preRules
        .where((r) => r.variableName.isNotEmpty)
        .map((r) => r.toJson())
        .toList();
    final preJson = filteredPre.isEmpty ? null : jsonEncode(filteredPre);
    ref
        .read(requestSessionControllerProvider(widget.tabId))
        .setPreScriptsJson(preJson);
  }

  void _addRule(bool isPre) {
    setState(() {
      if (isPre) {
        _preRules.add(ScriptRule());
      } else {
        _postRules.add(ScriptRule());
      }
    });
  }

  void _removeRule(int index, bool isPre) {
    setState(() {
      if (isPre) {
        _preRules.removeAt(index);
        if (_preRules.isEmpty) _preRules.add(ScriptRule());
      } else {
        _postRules.removeAt(index);
        if (_postRules.isEmpty) _postRules.add(ScriptRule());
      }
      _saveRules();
    });
  }

  void _runTest() {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.read(requestProvider(widget.tabId)).asData?.value;
    final responseData = state?.data;

    if (responseData == null) {
      _showError(l10n.noResponseToTest);
      return;
    }

    final filtered = _postRules
        .where((r) => r.variableName.isNotEmpty)
        .map((r) => r.toJson())
        .toList();
    final scriptsJson = jsonEncode(filtered);

    final results = ref
        .read(requestControllerProvider(widget.tabId))
        .testScripts(responseData, scriptsJson);

    setState(() {
      _testResults = results;
    });
    _showSuccess(l10n.testCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: l10n.preRequestTab),
            Tab(text: l10n.postRequestTab),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRulesList(isPre: true, l10n: l10n),
              _buildRulesList(isPre: false, l10n: l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulesList({
    required bool isPre,
    required AppLocalizations l10n,
  }) {
    final rules = isPre ? _preRules : _postRules;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                isPre ? Icons.bolt : Icons.auto_fix_high,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isPre
                    ? l10n.preRequestDescription
                    : l10n.postRequestDescription,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (!isPre) ...[
                TextButton.icon(
                  onPressed: _runTest,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: Text(l10n.test),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
                const SizedBox(width: 8),
              ],
              TextButton.icon(
                onPressed: () => _addRule(isPre),
                icon: const Icon(Icons.add, size: 16),
                label: Text(l10n.add),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index];
              final testValue = isPre ? null : _testResults[rule.variableName];

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller:
                                TextEditingController(text: rule.variableName)
                                  ..selection = TextSelection.fromPosition(
                                    TextPosition(
                                      offset: rule.variableName.length,
                                    ),
                                  ),
                            decoration: InputDecoration(
                              hintText: l10n.variableNameHint,
                              border: InputBorder.none,
                              hintStyle: const TextStyle(fontSize: 13),
                            ),
                            style: const TextStyle(fontSize: 13),
                            onChanged: (val) {
                              rule.variableName = val;
                              _saveRules();
                            },
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller:
                                TextEditingController(
                                    text: isPre ? rule.value : rule.jsonPath,
                                  )
                                  ..selection = TextSelection.fromPosition(
                                    TextPosition(
                                      offset: isPre
                                          ? rule.value.length
                                          : rule.jsonPath.length,
                                    ),
                                  ),
                            decoration: InputDecoration(
                              hintText: isPre
                                  ? l10n.valueHint
                                  : l10n.jsonPathHint,
                              border: InputBorder.none,
                              hintStyle: const TextStyle(fontSize: 13),
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                            onChanged: (val) {
                              if (isPre) {
                                rule.value = val;
                              } else {
                                rule.jsonPath = val;
                              }
                              _saveRules();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => _removeRule(index, isPre),
                        ),
                      ],
                    ),
                  ),
                  if (!isPre && testValue != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: testValue.startsWith('[Error')
                            ? Colors.red.withValues(alpha: 0.05)
                            : Colors.orange.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Resultado: $testValue',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: testValue.startsWith('[Error')
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                    ),
                  const Divider(height: 1),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Text(
            isPre
                ? 'Las variables definidas aquí se evaluarán justo antes de enviar la petición.'
                : 'Las variables se guardarán automáticamente en el entorno activo después de ejecutar la petición.',
            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }
}
