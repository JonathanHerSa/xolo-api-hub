import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/services/auth_secret_service.dart';
import 'package:xolo/domain/entities/collection_entity.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/database_providers.dart';

void showCreateCollectionDialog(
  BuildContext context,
  WidgetRef ref,
  int? parentId, {
  bool isWorkspace = false,
  CollectionEntity? collectionToEdit,
}) {
  showDialog(
    context: context,
    builder: (context) => _CreateCollectionDialog(
      parentId: parentId,
      isWorkspace: isWorkspace,
      collectionToEdit: collectionToEdit,
    ),
  );
}

class _CreateCollectionDialog extends ConsumerStatefulWidget {
  final int? parentId;
  final bool isWorkspace;
  final CollectionEntity? collectionToEdit;

  const _CreateCollectionDialog({
    this.parentId,
    this.isWorkspace = false,
    this.collectionToEdit,
  });

  @override
  ConsumerState<_CreateCollectionDialog> createState() =>
      _CreateCollectionDialogState();
}

class _CreateCollectionDialogState
    extends ConsumerState<_CreateCollectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  String _authType = 'inherit';
  Map<String, dynamic> _authData = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.collectionToEdit?.name ?? '',
    );
    _descController = TextEditingController(
      text: widget.collectionToEdit?.description ?? '',
    );

    _initAuthState();
  }

  Future<void> _initAuthState() async {
    if (widget.collectionToEdit != null) {
      _authType = widget.collectionToEdit!.authType ?? 'inherit';
      final secretService = ref.read(authSecretServiceProvider);
      final resolvedAuth = await secretService.resolveAuthData(
        widget.collectionToEdit!.authData,
      );
      if (resolvedAuth != null) {
        try {
          _authData = jsonDecode(resolvedAuth) as Map<String, dynamic>;
        } catch (_) {}
      }
    } else {
      if (widget.isWorkspace) {
        _authType = 'none';
      } else {
        _authType = 'inherit';
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authTypes = {
      'inherit': l10n.authInheritFromParent,
      'none': l10n.authNone,
      'bearer': l10n.authBearerToken,
      'basic': l10n.authBasicAuth,
      'api_key': l10n.authApiKey,
      'oauth2': l10n.authOAuth2,
      'aws': l10n.authAwsSignature,
    };

    final isEdit = widget.collectionToEdit != null;
    final title = isEdit
        ? (widget.isWorkspace ? l10n.renameProject : l10n.renameFolder)
        : (widget.isWorkspace ? l10n.newProject : l10n.newFolder);

    final availableAuthTypes = Map.of(authTypes);
    if (widget.isWorkspace) {
      availableAuthTypes.remove('inherit');
    }

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.name,
                        hintText: l10n.projectNameHint,
                        border: const OutlineInputBorder(),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.nameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: l10n.descriptionOptional,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.authorization,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: availableAuthTypes.containsKey(_authType)
                    ? _authType
                    : (widget.isWorkspace ? 'none' : 'inherit'),
                decoration: InputDecoration(
                  labelText: l10n.authType,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: availableAuthTypes.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _authType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildAuthForm(l10n),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEdit ? l10n.save : l10n.create),
        ),
      ],
    );
  }

  Widget _buildAuthForm(AppLocalizations l10n) {
    switch (_authType) {
      case 'inherit':
        return Text(
          l10n.inheritAuthDescription,
          style: const TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        );
      case 'none':
        return Text(
          l10n.noAuthDescription,
          style: const TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        );
      case 'bearer':
        return TextFormField(
          initialValue: _authData['token'],
          decoration: InputDecoration(
            labelText: l10n.authBearerToken,
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => _authData['token'] = v,
        );
      case 'basic':
        return Column(
          children: [
            TextFormField(
              initialValue: _authData['username'],
              decoration: InputDecoration(
                labelText: l10n.username,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => _authData['username'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _authData['password'],
              decoration: InputDecoration(
                labelText: l10n.password,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
              onChanged: (v) => _authData['password'] = v,
            ),
          ],
        );
      case 'api_key':
        return Column(
          children: [
            TextFormField(
              initialValue: _authData['key'],
              decoration: InputDecoration(
                labelText: l10n.keyLabel,
                border: const OutlineInputBorder(),
                hintText: l10n.apiKeyHint,
              ),
              onChanged: (v) => _authData['key'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _authData['value'],
              decoration: InputDecoration(
                labelText: l10n.valueLabel,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => _authData['value'] = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _authData['in'] ?? 'header',
              decoration: InputDecoration(
                labelText: l10n.addToLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'header', child: Text(l10n.header)),
                DropdownMenuItem(value: 'query', child: Text(l10n.queryParams)),
              ],
              onChanged: (v) => _authData['in'] = v,
            ),
          ],
        );
      default:
        return Text(l10n.configNotAvailable);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(xoloRepositoryProvider);
    final name = _nameController.text.trim();
    final desc = _descController.text.trim().isEmpty
        ? null
        : _descController.text.trim();

    String? authDataJson;
    if (_authData.isNotEmpty && _authType != 'none' && _authType != 'inherit') {
      authDataJson = jsonEncode(_authData);
    }

    try {
      final secretService = ref.read(authSecretServiceProvider);
      final authSecretRef = await secretService.storeAuthData(authDataJson);

      if (widget.collectionToEdit != null) {
        await secretService.deleteAuthData(widget.collectionToEdit!.authData);
        await db.updateCollection(
          widget.collectionToEdit!.id,
          name,
          desc,
          authType: _authType,
          authData: authSecretRef,
        );
      } else {
        await db.createCollection(
          name: name,
          description: desc,
          parentId: widget.parentId,
          authType: _authType,
          authData: authSecretRef,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isWorkspace ? l10n.projectSaved : l10n.folderSaved,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
