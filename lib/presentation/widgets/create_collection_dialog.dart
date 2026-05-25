import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../core/services/auth_secret_service.dart';
import '../providers/database_providers.dart';

void showCreateCollectionDialog(
  BuildContext context,
  WidgetRef ref,
  int? parentId, {
  bool isWorkspace = false,
  Collection? collectionToEdit,
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
  final Collection? collectionToEdit;

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
  late TextEditingController _descController; // Optional description

  // Auth State
  String _authType = 'inherit';
  Map<String, dynamic> _authData = {};

  final Map<String, String> _authTypes = {
    'inherit': 'Inherit from Parent',
    'none': 'No Auth',
    'bearer': 'Bearer Token',
    'basic': 'Basic Auth',
    'api_key': 'API Key',
    'oauth2': 'OAuth 2.0',
    'aws': 'AWS Signature',
  };

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
      // Defaults
      if (widget.isWorkspace) {
        _authType = 'none'; // Workspaces can't inherit
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
    final isEdit = widget.collectionToEdit != null;
    final title = isEdit
        ? 'Rename ${widget.isWorkspace ? "Project" : "Folder"}'
        : 'New ${widget.isWorkspace ? "Project" : "Folder"}';

    // Remove 'inherit' option if it's a Workspace (Root)
    final availableAuthTypes = Map.of(_authTypes);
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
              // 1. Basic Info
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'My API Project',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // 2. Auth Configuration
              Text(
                'Authorization',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: availableAuthTypes.containsKey(_authType)
                    ? _authType
                    : (widget.isWorkspace ? 'none' : 'inherit'),
                decoration: const InputDecoration(
                  labelText: 'Auth Type',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
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
                      // Don't clear data immediately to allow undo
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildAuthForm(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: Text(isEdit ? 'Save' : 'Create')),
      ],
    );
  }

  Widget _buildAuthForm() {
    switch (_authType) {
      case 'inherit':
        return const Text(
          'This folder will use the authentication configured in its parent folder or project.',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        );
      case 'none':
        return const Text(
          'No authentication will be used.',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        );
      case 'bearer':
        return TextFormField(
          initialValue: _authData['token'],
          decoration: const InputDecoration(
            labelText: 'Bearer Token',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => _authData['token'] = v,
        );
      case 'basic':
        return Column(
          children: [
            TextFormField(
              initialValue: _authData['username'],
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _authData['username'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _authData['password'],
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Key',
                border: OutlineInputBorder(),
                hintText: 'X-API-Key',
              ),
              onChanged: (v) => _authData['key'] = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _authData['value'],
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _authData['value'] = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _authData['in'] ?? 'header',
              decoration: const InputDecoration(
                labelText: 'Add to',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'header', child: Text('Header')),
                DropdownMenuItem(value: 'query', child: Text('Query Params')),
              ],
              onChanged: (v) => _authData['in'] = v,
            ),
          ],
        );
      default:
        return const Text('Configuration not available for this type yet.');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(databaseProvider);
    final name = _nameController.text.trim();
    final desc = _descController.text.trim().isEmpty
        ? null
        : _descController.text.trim();

    // Encode Auth Data
    String? authDataJson;
    if (_authData.isNotEmpty && _authType != 'none' && _authType != 'inherit') {
      authDataJson = jsonEncode(_authData);
    }

    try {
      final secretService = ref.read(authSecretServiceProvider);
      final authSecretRef = await secretService.storeAuthData(authDataJson);

      if (widget.collectionToEdit != null) {
        await secretService.deleteAuthData(widget.collectionToEdit!.authData);
        // Edit
        await db.updateCollection(
          widget.collectionToEdit!.id,
          name,
          desc,
          authType: _authType,
          authData: authSecretRef,
        );
      } else {
        // Create
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
            content: Text('${widget.isWorkspace ? "Project" : "Folder"} saved'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
