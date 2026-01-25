import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/key_value_pair.dart';
import '../providers/request_session_provider.dart';

enum TableType { headers, params }

class KeyValueTable extends ConsumerWidget {
  final String tabId;
  final TableType type;
  final String keyPlaceholder;
  final String valuePlaceholder;

  const KeyValueTable({
    super.key,
    required this.tabId,
    required this.type,
    this.keyPlaceholder = 'Key',
    this.valuePlaceholder = 'Value',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch Async Stream
    final sessionAsync = ref.watch(requestSessionProvider(tabId));
    final session = sessionAsync.asData?.value;

    // Loading/Error fallback
    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<KeyValuePair> rows = type == TableType.headers
        ? session.headers
        : session.params;

    // Controller for updates
    final controller = ref.read(requestSessionControllerProvider(tabId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final item = rows[index];
        final isLast = index == rows.length - 1;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Toggle Active
              GestureDetector(
                onTap: () {
                  final newList = [...rows];
                  newList[index] = item.copyWith(isActive: !item.isActive);
                  _updateList(controller, newList);
                },
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: item.isActive
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: item.isActive
                          ? colorScheme.primary
                          : colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  child: item.isActive
                      ? Icon(Icons.check, size: 12, color: colorScheme.primary)
                      : null,
                ),
              ),

              // Key Input
              Expanded(
                flex: 4,
                child: _buildInput(
                  context: context,
                  initialValue: item.key,
                  placeholder: keyPlaceholder,
                  onChanged: (val) {
                    final newList = [...rows];
                    newList[index] = item.copyWith(key: val);
                    _updateList(controller, newList);
                  },
                  isKey: true,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '=',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ),

              // Value Input
              Expanded(
                flex: 5,
                child: _buildInput(
                  context: context,
                  initialValue: item.value,
                  placeholder: valuePlaceholder,
                  onChanged: (val) {
                    final newList = [...rows];
                    newList[index] = item.copyWith(value: val);
                    _updateList(controller, newList);
                  },
                  isKey: false,
                ),
              ),

              // Delete
              if (!isLast)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () {
                    if (rows.length > 1) {
                      final newList = [...rows];
                      newList.removeAt(index);
                      _updateList(controller, newList);
                    }
                  },
                )
              else
                const SizedBox(width: 32),
            ],
          ),
        );
      },
    );
  }

  void _updateList(
    RequestSessionController controller,
    List<KeyValuePair> newList,
  ) {
    if (type == TableType.headers) {
      controller.updateHeaders(newList);
    } else {
      controller.updateParams(newList);
    }
  }

  Widget _buildInput({
    required BuildContext context,
    required String initialValue,
    required String placeholder,
    required ValueChanged<String> onChanged,
    required bool isKey,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          fontSize: 13,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      style: TextStyle(
        color: isKey ? colorScheme.primary : colorScheme.onSurface,
        fontSize: 13,
        fontFamily: 'JetBrains Mono',
      ),
      onChanged: onChanged,
    );
  }
}
