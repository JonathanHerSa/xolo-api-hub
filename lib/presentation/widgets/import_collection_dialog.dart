import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/data/services/import_manager.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

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

    final l10n = AppLocalizations.of(context)!;

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
          throw Exception(l10n.fileReadError);
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.importSuccess)));
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.folder_zip_rounded),
          const SizedBox(width: 8),
          Text(l10n.importApiProject),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.importDescription,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: XoloSpacing.lg),
            Text(
              l10n.importSourceLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: XoloSpacing.sm),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text(l10n.sourceUrl),
                  icon: const Icon(Icons.link),
                ),
                ButtonSegment(
                  value: false,
                  label: Text(l10n.sourceFile),
                  icon: const Icon(Icons.upload_file),
                ),
              ],
              selected: {_isUrl},
              onSelectionChanged: (set) {
                setState(() => _isUrl = set.first);
              },
            ),

            const SizedBox(height: XoloSpacing.lg),

            Text(
              l10n.importFormatLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: XoloSpacing.sm),
            DropdownButtonFormField<ImportFormat>(
              initialValue: _selectedFormat,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(
                  value: ImportFormat.auto,
                  child: Text(l10n.importAutoDetect),
                ),
                DropdownMenuItem(
                  value: ImportFormat.openApi,
                  child: Text(l10n.importOpenApi),
                ),
                DropdownMenuItem(
                  value: ImportFormat.postman,
                  child: Text(l10n.importPostman),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedFormat = val);
              },
            ),

            const SizedBox(height: XoloSpacing.lg),

            if (_isUrl)
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: l10n.importUrlLabel,
                  hintText: l10n.importUrlHint,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              )
            else
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.file_open),
                label: Flexible(
                  child: Text(
                    _selectedFile?.name ?? l10n.selectFile,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    XoloA11y.minTouchTarget,
                  ),
                ),
              ),

            if (_error != null) ...[
              const SizedBox(height: XoloSpacing.lg),
              Container(
                padding: const EdgeInsets.all(XoloSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: XoloRadius.sm,
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
              const SizedBox(height: XoloSpacing.lg),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _import,
          child: Text(l10n.importNow),
        ),
      ],
    );
  }
}
