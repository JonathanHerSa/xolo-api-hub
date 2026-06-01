import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/utils/curl_parser.dart';
import 'package:xolo/domain/entities/key_value_pair.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final text = _controller.text;
    if (text.isEmpty) return;

    final parsed = CurlParser.parse(text);
    if (parsed == null) {
      setState(() {
        _error = l10n.invalidCurlCommand;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.curlImportedSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.importCurl,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: l10n.pasteCurlHint,
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
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _import, child: Text(l10n.import)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
