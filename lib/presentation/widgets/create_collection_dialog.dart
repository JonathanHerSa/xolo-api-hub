import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.collectionToEdit?.name ?? '',
    );
    _descController = TextEditingController(
      text: widget.collectionToEdit?.description ?? '',
    );
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

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: Text(isEdit ? 'Save' : 'Create')),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(databaseProvider);
    final name = _nameController.text.trim();
    final desc = _descController.text.trim().isEmpty
        ? null
        : _descController.text.trim();

    try {
      if (widget.collectionToEdit != null) {
        // Edit
        await db.updateCollection(widget.collectionToEdit!.id, name, desc);
      } else {
        // Create
        await db.createCollection(
          name: name,
          description: desc,
          parentId: widget.parentId,
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
