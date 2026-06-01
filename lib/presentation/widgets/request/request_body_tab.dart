import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/utils/schema_helper.dart';
import 'package:xolo/core/utils/variable_text_controller.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';

class RequestBodyTab extends ConsumerStatefulWidget {
  final String tabId;
  const RequestBodyTab({super.key, required this.tabId});

  @override
  ConsumerState<RequestBodyTab> createState() => _RequestBodyTabState();
}

class _RequestBodyTabState extends ConsumerState<RequestBodyTab> {
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
    final l10n = AppLocalizations.of(context)!;
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
                label: Text(l10n.beautify),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _minify,
                icon: const Icon(Icons.compress, size: 16),
                label: Text(l10n.minify),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Spacer(),
              // Replace Menu with Smart Button
              IconButton(
                icon: const Icon(Icons.auto_awesome, size: 18),
                tooltip: l10n.generateFromSchema,
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
              decoration: InputDecoration(
                hintText: l10n.bodyJsonHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(8),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _beautify() {
    final l10n = AppLocalizations.of(context)!;
    final text = _controller.text;
    if (text.isEmpty) return;
    try {
      final json = jsonDecode(text);
      final pretty = const JsonEncoder.withIndent('  ').convert(json);
      _updateBody(pretty);
    } catch (e) {
      _showError(l10n.invalidJson);
    }
  }

  void _minify() {
    final l10n = AppLocalizations.of(context)!;
    final text = _controller.text;
    if (text.isEmpty) return;
    try {
      final json = jsonDecode(text);
      final minified = jsonEncode(json);
      _updateBody(minified);
    } catch (e) {
      _showError(l10n.invalidJson);
    }
  }

  void _generateFromSchema() {
    final l10n = AppLocalizations.of(context)!;
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
          _showSuccess(l10n.schemaGenerated);
        } else {
          _updateBody('{}');
          _showError(l10n.schemaEmptyResult);
        }
      } catch (e) {
        _updateBody('{}');
        _showError(l10n.schemaParseFailed);
      }
    } else {
      _updateBody('{}');
      _showError(l10n.noSchemaAvailable);
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
