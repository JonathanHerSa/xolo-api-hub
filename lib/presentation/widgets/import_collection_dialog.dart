import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/openapi_service.dart';
import '../providers/workspace_provider.dart';
import '../providers/database_providers.dart';

class ImportCollectionDialog extends ConsumerStatefulWidget {
  const ImportCollectionDialog({super.key});

  @override
  ConsumerState<ImportCollectionDialog> createState() =>
      _ImportCollectionDialogState();
}

class _ImportCollectionDialogState
    extends ConsumerState<ImportCollectionDialog> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use activeWorkspaceIdProvider instead of undefined currentWorkspaceProvider
      final workspaceId = ref.read(activeWorkspaceIdProvider)?.toString();

      if (workspaceId == null) {
        throw Exception('No workspace selected');
      }

      final db = ref.read(databaseProvider);

      await ref
          .read(openApiServiceProvider)
          .importFromUrl(url, workspaceId, db);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collection imported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import OpenAPI Collection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'OpenAPI Specification URL',
              hintText: 'https://petstore.swagger.io/v2/swagger.json',
              border: OutlineInputBorder(),
            ),
            enabled: !_isLoading,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _import,
          child: const Text('Import'),
        ),
      ],
    );
  }
}
