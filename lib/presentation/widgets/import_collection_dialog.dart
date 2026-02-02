import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../../data/services/import_manager.dart';
import '../providers/workspace_provider.dart';
import '../providers/database_providers.dart';

class ImportCollectionDialog extends ConsumerStatefulWidget {
  final int? targetCollectionId; // Optional: specify where to import
  const ImportCollectionDialog({super.key, this.targetCollectionId});

  @override
  ConsumerState<ImportCollectionDialog> createState() =>
      _ImportCollectionDialogState();
}

class _ImportCollectionDialogState
    extends ConsumerState<ImportCollectionDialog> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  ImportFormat _selectedFormat = ImportFormat.auto;
  bool _isUrl = true; // URL vs File
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'yaml', 'yml'],
      withData: true, // Crucial for web and getting bytes
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _import() async {
    if (_isUrl && _urlController.text.trim().isEmpty) return;
    if (!_isUrl && _selectedFile == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final parentId = ref.read(activeWorkspaceIdProvider);
      final db = ref.read(databaseProvider);
      final manager = ref.read(importManagerProvider);

      if (_isUrl) {
        await manager.importFromUrl(
          _urlController.text.trim(),
          db,
          parentId: parentId,
          targetCollectionId: widget.targetCollectionId,
          format: _selectedFormat,
        );
      } else {
        if (_selectedFile?.bytes != null) {
          final content = utf8.decode(_selectedFile!.bytes!);
          await manager.importFromContent(
            content,
            db,
            parentId: parentId,
            targetCollectionId: widget.targetCollectionId,
            format: _selectedFormat,
          );
        } else {
          throw Exception('No se pudieron leer los bytes del archivo');
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('¡Importado con éxito!')));
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Importar Colección'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Source Toggle
            const Text(
              'Fuente:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('URL'),
                  icon: Icon(Icons.link),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Archivo'),
                  icon: Icon(Icons.upload_file),
                ),
              ],
              selected: {_isUrl},
              onSelectionChanged: (set) {
                setState(() => _isUrl = set.first);
              },
            ),

            const SizedBox(height: 16),

            // 2. Format Selection
            const Text(
              'Formato:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ImportFormat>(
              initialValue: _selectedFormat,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: ImportFormat.auto,
                  child: Text('Auto-detectar'),
                ),
                DropdownMenuItem(
                  value: ImportFormat.openApi,
                  child: Text('OpenAPI / Swagger'),
                ),
                DropdownMenuItem(
                  value: ImportFormat.postman,
                  child: Text('Postman Collection'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedFormat = val);
              },
            ),

            const SizedBox(height: 16),

            // 3. Input Area
            if (_isUrl)
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL del JSON/YAML',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              )
            else
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.file_open),
                label: Flexible(
                  child: Text(
                    _selectedFile?.name ?? 'Seleccionar Archivo',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            if (_isLoading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _import,
          child: const Text('Importar Ahora'),
        ),
      ],
    );
  }
}
