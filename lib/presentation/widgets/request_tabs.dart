import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/utils/schema_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/request_provider.dart';
import '../providers/request_session_provider.dart';

import 'key_value_table.dart';
import 'json_viewer.dart';
import 'auth_tab.dart';

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
    _tabController = TabController(length: 5, vsync: this);
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
        _tabController.animateTo(4); // Index 4 = Response
      }
    });

    return Column(
      children: [
        if (isLoading) const LinearProgressIndicator(),

        if (error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.red.withValues(alpha: 0.1),
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),

        TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          labelPadding: EdgeInsets.zero, // Compact tabs
          tabs: [
            const Tab(text: 'Params'),
            const Tab(text: 'Auth'),
            const Tab(text: 'Headers'),
            const Tab(text: 'Body'),
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

              // 3. BODY
              _BodyTab(tabId: widget.tabId),

              // 4. RESPONSE
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
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialBody =
        ref.read(requestSessionProvider(widget.tabId)).asData?.value.body ?? '';
    _controller = TextEditingController(text: initialBody);
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
