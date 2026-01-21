import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/xolo_theme.dart';
import '../../data/local/database.dart';
import '../providers/database_providers.dart';
import '../providers/form_providers.dart';

class SavedRequestsScreen extends ConsumerWidget {
  const SavedRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedRequestsStreamProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Requests')),
      body: savedAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text('Error: $err', style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin requests guardados',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Guarda requests con el botón ★',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _SavedRequestTile(request: requests[index]);
            },
          );
        },
      ),
    );
  }
}

class _SavedRequestTile extends ConsumerWidget {
  final SavedRequest request;

  const _SavedRequestTile({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final methodColor = XoloTheme.getMethodColor(request.method);

    return Dismissible(
      key: Key('saved_${request.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: colorScheme.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('¿Eliminar request?'),
                content: Text('Se eliminará "${request.name}"'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      'Eliminar',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) async {
        final db = ref.read(databaseProvider);
        await db.softDeleteRequest(request.id);
      },
      child: InkWell(
        onTap: () => _loadRequest(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              // Method badge
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: methodColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.method,
                  style: TextStyle(
                    color: methodColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 14),

              // Name and URL
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _truncateUrl(request.url),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  void _loadRequest(BuildContext context, WidgetRef ref) {
    ref.read(selectedMethodProvider.notifier).state = request.method;
    ref.read(urlQueryProvider.notifier).state = request.url;
    if (request.body != null) {
      ref.read(bodyContentProvider.notifier).state = request.body!;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cargado: ${request.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
    Navigator.pop(context);
  }

  String _truncateUrl(String url) {
    return url.replaceFirst('https://', '').replaceFirst('http://', '');
  }
}

// ============================================================================
// DIALOG PARA GUARDAR REQUEST
// ============================================================================

Future<void> showSaveRequestDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final nameController = TextEditingController();
  final colorScheme = Theme.of(context).colorScheme;

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Guardar Request'),
      content: TextField(
        controller: nameController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Nombre del request',
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(ctx, name);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );

  if (result != null && result.isNotEmpty) {
    await _saveCurrentRequest(ref, result);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guardado: $result'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

Future<void> _saveCurrentRequest(WidgetRef ref, String name) async {
  final db = ref.read(databaseProvider);
  final method = ref.read(selectedMethodProvider);
  final url = ref.read(urlQueryProvider);
  final body = ref.read(bodyContentProvider);
  final headersList = ref.read(headersProvider);
  final paramsList = ref.read(paramsProvider);

  final Map<String, String> headersMap = {};
  for (var item in headersList) {
    if (item.key.isNotEmpty && item.isActive) {
      headersMap[item.key] = item.value;
    }
  }

  final Map<String, String> paramsMap = {};
  for (var item in paramsList) {
    if (item.key.isNotEmpty && item.isActive) {
      paramsMap[item.key] = item.value;
    }
  }

  await db.saveRequest(
    name: name,
    method: method,
    url: url,
    body: body.isNotEmpty ? body : null,
    headersJson: headersMap.isNotEmpty ? jsonEncode(headersMap) : null,
    paramsJson: paramsMap.isNotEmpty ? jsonEncode(paramsMap) : null,
  );
}
