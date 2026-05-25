import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/utils/schema_helper.dart';
import 'code_snippet_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';
import '../providers/request_session_provider.dart';

import 'key_value_table.dart';
import 'json_viewer.dart';
import 'auth_tab.dart';
import '../../core/theme/xolo_design_tokens.dart';
import '../../core/utils/variable_text_controller.dart';

class RequestTabs extends ConsumerStatefulWidget {
  final String tabId;
  const RequestTabs({super.key, required this.tabId});

  @override
  ConsumerState<RequestTabs> createState() => _RequestTabsState();
}

class _RequestTabsState extends ConsumerState<RequestTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch Request State (Execution)
    final requestAsync = ref.watch(requestProvider(widget.tabId));
    final requestState = requestAsync.asData?.value;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Combined Loading State
    final isLoading =
        requestAsync.isLoading || (requestState?.isLoading ?? false);
    final error = requestAsync.error?.toString() ?? requestState?.error;
    final statusCode = requestState?.statusCode;
    final data = requestState?.data;

    // Auto-switch to response tab on success
    ref.listen(requestProvider(widget.tabId), (previous, next) {
      final prevLoading =
          previous?.isLoading == true ||
          (previous?.asData?.value.isLoading ?? false);
      final nextLoading =
          next.isLoading || (next.asData?.value.isLoading ?? false);

      final nextData = next.asData?.value.data;
      final nextError = next.error ?? next.asData?.value.error;

      if (prevLoading &&
          !nextLoading &&
          (nextData != null || nextError != null)) {
        _tabController.animateTo(5); // Index 5 = Response
      }
    });

    return Column(
      children: [
        if (isLoading) const LinearProgressIndicator(),

        if (error != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            padding: const EdgeInsets.all(XoloSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: XoloRadius.sm,
            ),
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),

        Container(
          margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
            borderRadius: XoloRadius.md,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 2.5,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: [
                    const Tab(text: 'Params'),
                    const Tab(text: 'Auth'),
                    const Tab(text: 'Headers'),
                    const Tab(text: 'Body'),
                    const Tab(text: 'Scripts'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Response'),
                          if (statusCode != null) ...[
                            const SizedBox(width: 4),
                            _StatusBadge(statusCode: statusCode),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.code),
                tooltip: 'Show Code',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CodeSnippetDialog(tabId: widget.tabId),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. PARAMS
              KeyValueTable(
                tabId: widget.tabId,
                type: TableType.params,
                keyPlaceholder: 'Query Param',
              ),

              // 2. AUTH
              AuthTab(tabId: widget.tabId),

              // 3. HEADERS
              KeyValueTable(
                tabId: widget.tabId,
                type: TableType.headers,
                keyPlaceholder: 'Header',
              ),

              // 4. BODY
              _BodyTab(tabId: widget.tabId),

              // 5. SCRIPTS
              _ScriptsTab(tabId: widget.tabId),

              // 6. RESPONSE
              _ResponseTab(isLoading: isLoading, data: data, error: error),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int statusCode;
  const _StatusBadge({required this.statusCode});

  @override
  Widget build(BuildContext context) {
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final color = isSuccess ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        statusCode.toString(),
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BodyTab extends ConsumerStatefulWidget {
  final String tabId;
  const _BodyTab({required this.tabId});

  @override
  ConsumerState<_BodyTab> createState() => _BodyTabState();
}

class _BodyTabState extends ConsumerState<_BodyTab> {
  late VariableTextController _controller;

  @override
  void initState() {
    super.initState();
    final initialBody =
        ref.read(requestSessionProvider(widget.tabId)).asData?.value.body ?? '';
    _controller = VariableTextController(text: initialBody);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<
      AsyncValue<RequestSession>
    >(requestSessionProvider(widget.tabId), (previous, next) {
      final nextBody = next.asData?.value.body;
      final prevBody = previous?.asData?.value.body;

      if (nextBody != null && _controller.text != nextBody) {
        // Sync if it's an external load (previous empty/null)
        if ((prevBody == null || prevBody.isEmpty) && nextBody.isNotEmpty) {
          _controller.text = nextBody;
        }
        // For now, we avoid overwriting user typing if they differ slightly
        // but if they are drastically different (external reset), we should sync.
        // Relying on previous being empty is a heuristic for "Load Request".
      }
    });

    // Manual sync for initial load
    final sessionSync = ref
        .watch(requestSessionProvider(widget.tabId))
        .asData
        ?.value;
    if (sessionSync != null) {
      final currentBody = sessionSync.body;
      if (_controller.text.isEmpty && currentBody.isNotEmpty) {
        _controller.text = currentBody;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Toolbar
          Row(
            children: [
              TextButton.icon(
                onPressed: _beautify,
                icon: const Icon(Icons.format_align_left, size: 16),
                label: const Text('Beautify'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _minify,
                icon: const Icon(Icons.compress, size: 16),
                label: const Text('Minify'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Spacer(),
              // Replace Menu with Smart Button
              IconButton(
                icon: const Icon(Icons.auto_awesome, size: 18),
                tooltip: 'Generate from Schema',
                onPressed: _generateFromSchema,
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (val) => ref
                  .read(requestSessionControllerProvider(widget.tabId))
                  .setBody(val),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: '{\n  "key": "value"\n}',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(8),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _beautify() {
    final text = _controller.text;
    if (text.isEmpty) return;
    try {
      final json = jsonDecode(text);
      final pretty = const JsonEncoder.withIndent('  ').convert(json);
      _updateBody(pretty);
    } catch (e) {
      _showError('Invalid JSON');
    }
  }

  void _minify() {
    final text = _controller.text;
    if (text.isEmpty) return;
    try {
      final json = jsonDecode(text);
      final minified = jsonEncode(json);
      _updateBody(minified);
    } catch (e) {
      _showError('Invalid JSON');
    }
  }

  void _generateFromSchema() {
    final session = ref
        .read(requestSessionProvider(widget.tabId))
        .asData
        ?.value;
    final schemaJson = session?.schemaJson;

    if (schemaJson != null && schemaJson.isNotEmpty) {
      try {
        final schema = jsonDecode(schemaJson) as Map<String, dynamic>;
        // Use our helper method
        final sample = SchemaHelper.generateSample(schema);
        if (sample != null) {
          final pretty = const JsonEncoder.withIndent('  ').convert(sample);
          _updateBody(pretty);
          _showSuccess('Data generated from Schema');
        } else {
          _updateBody('{}');
          _showError('Schema produced valid null/empty result.');
        }
      } catch (e) {
        _updateBody('{}');
        _showError('Failed to parse Schema');
      }
    } else {
      // No schema available
      _updateBody('{}');
      _showError('No Schema available for this request');
    }
  }

  void _updateBody(String text) {
    _controller.text = text;
    ref.read(requestSessionControllerProvider(widget.tabId)).setBody(text);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _ResponseTab extends StatelessWidget {
  final bool isLoading;
  final dynamic data;
  final String? error;

  const _ResponseTab({required this.isLoading, this.data, this.error});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            // Copy paste enabled
            'Error:\n$error',
            style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
          ),
        ),
      );
    }

    if (data == null) {
      return Center(
        child: Text(
          'Sin respuesta',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    // JSON Viewer correcto
    return JsonViewer(data: data);
  }
}

class _ScriptsTab extends ConsumerStatefulWidget {
  final String tabId;
  const _ScriptsTab({super.key, required this.tabId});

  @override
  ConsumerState<_ScriptsTab> createState() => _ScriptsTabState();
}

class _ScriptsTabState extends ConsumerState<_ScriptsTab>
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
    final state = ref.read(requestProvider(widget.tabId)).asData?.value;
    final responseData = state?.data;

    if (responseData == null) {
      _showError('No hay respuesta disponible para probar.');
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
    _showSuccess('Prueba completada');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Pre-request'),
            Tab(text: 'Post-request (Extraer)'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRulesList(isPre: true),
              _buildRulesList(isPre: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulesList({required bool isPre}) {
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
                    ? 'Generar/Sustituir variables antes de la petición'
                    : 'Extraer variables de la respuesta',
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
                  label: const Text('Probar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
                const SizedBox(width: 8),
              ],
              TextButton.icon(
                onPressed: () => _addRule(isPre),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Añadir'),
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
                            decoration: const InputDecoration(
                              hintText: 'Nombre Variable',
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 13),
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
                                  ? 'Valor (ej: order_{{\$timestamp}})'
                                  : r'JSON Path (ej: $.token)',
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
                            ? Colors.red.withOpacity(0.05)
                            : Colors.orange.withOpacity(0.05),
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
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
