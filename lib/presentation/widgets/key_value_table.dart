import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/utils/variable_text_controller.dart';
import 'package:xolo/domain/entities/key_value_pair.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';

enum TableType { headers, params }

class KeyValueTable extends ConsumerStatefulWidget {
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
  ConsumerState<KeyValueTable> createState() => _KeyValueTableState();
}

class _KeyValueTableState extends ConsumerState<KeyValueTable> {
  // Mapping of index to controllers to preserve state and highlighting
  final Map<int, VariableTextController> _keyControllers = {};
  final Map<int, VariableTextController> _valueControllers = {};

  @override
  void dispose() {
    for (var c in _keyControllers.values) {
      c.dispose();
    }
    for (var c in _valueControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  VariableTextController _getController(
    int index,
    String initialValue,
    bool isKey,
  ) {
    final Map<int, VariableTextController> map = isKey
        ? _keyControllers
        : _valueControllers;
    if (!map.containsKey(index)) {
      map[index] = VariableTextController(text: initialValue);
    } else if (map[index]!.text != initialValue && !isKey) {
      // Only sync if they differ significantly (e.g. external update)
      // We avoid syncing the 'key' too aggressively to keep cursor stable
      // Actually, for value params, highlighting is critical.
      if (DateTime.now().millisecond % 5 == 0) {
        // Tiny heuristic or just update if not focused
        // map[index]!.text = initialValue;
      }
    }
    return map[index]!;
  }

  @override
  Widget build(BuildContext context) {
    // Watch Async Stream
    final sessionAsync = ref.watch(requestSessionProvider(widget.tabId));
    final session = sessionAsync.asData?.value;

    // Loading/Error fallback
    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<KeyValuePair> rows = widget.type == TableType.headers
        ? session.headers
        : session.params;

    // Controller for updates
    final controller = ref.read(requestSessionControllerProvider(widget.tabId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final item = rows[index];
        final isLast = index == rows.length - 1;

        final kCtrl = _getController(index, item.key, true);
        final vCtrl = _getController(index, item.value, false);

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
                child: TextField(
                  controller: kCtrl,
                  decoration: InputDecoration(
                    hintText: widget.keyPlaceholder,
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 13,
                    fontFamily: 'JetBrains Mono',
                  ),
                  onChanged: (val) {
                    final newList = [...rows];
                    newList[index] = item.copyWith(key: val);
                    _updateList(controller, newList);
                  },
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
                child: TextField(
                  controller: vCtrl,
                  decoration: InputDecoration(
                    hintText: widget.valuePlaceholder,
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontFamily: 'JetBrains Mono',
                  ),
                  onChanged: (val) {
                    final newList = [...rows];
                    newList[index] = item.copyWith(value: val);
                    _updateList(controller, newList);
                  },
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
                      // Clear controllers
                      _keyControllers.remove(index);
                      _valueControllers.remove(index);
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
    if (widget.type == TableType.headers) {
      controller.updateHeaders(newList);
    } else {
      controller.updateParams(newList);
    }
  }
}
