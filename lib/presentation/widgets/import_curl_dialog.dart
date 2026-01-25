import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/curl_parser.dart';
import '../../presentation/providers/request_session_provider.dart';
import '../../domain/entities/key_value_pair.dart';

class ImportCurlDialog extends ConsumerStatefulWidget {
  final String activeTabId;
  const ImportCurlDialog({super.key, required this.activeTabId});

  @override
  ConsumerState<ImportCurlDialog> createState() => _ImportCurlDialogState();
}

class _ImportCurlDialogState extends ConsumerState<ImportCurlDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _import() {
    final text = _controller.text;
    if (text.isEmpty) return;

    final parsed = CurlParser.parse(text);
    if (parsed == null) {
      setState(() {
        _error = 'Invalid cURL command or format not supported';
      });
      return;
    }

    // Apply to current tab
    final controller = ref.read(
      requestSessionControllerProvider(widget.activeTabId),
    );

    // Method
    controller.setMethod(parsed.method);

    // URL
    controller.setUrl(parsed.url);

    // Headers
    final newHeaders = parsed.headers.entries
        .map((e) => KeyValuePair(key: e.key, value: e.value, isActive: true))
        .toList();
    if (newHeaders.isNotEmpty) {
      controller.updateHeaders(newHeaders);
    }

    // Body
    if (parsed.body != null) {
      controller.setBody(parsed.body!);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('cURL imported successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import cURL',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Paste your cURL command here...',
                border: const OutlineInputBorder(),
                errorText: _error,
                filled: true,
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _import, child: const Text('Import')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
