import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/xolo_theme.dart';
import '../providers/environment_provider.dart';
import '../providers/form_providers.dart';
import '../providers/request_provider.dart';

class UrlInputBar extends ConsumerStatefulWidget {
  const UrlInputBar({super.key});

  @override
  ConsumerState<UrlInputBar> createState() => _UrlInputBarState();
}

class _UrlInputBarState extends ConsumerState<UrlInputBar> {
  late TextEditingController _urlController;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    final initialUrl = ref.read(urlQueryProvider);
    _urlController = TextEditingController(text: initialUrl);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    // 1. Actualizar state (USANDO NUEVO METODO SET)
    ref.read(urlQueryProvider.notifier).set(text);

    // 2. Lógica de Autocompletado
    final selection = _urlController.selection;
    if (!selection.isValid || selection.start < 2) {
      _removeOverlay();
      return;
    }

    final textBeforeCursor = text.substring(0, selection.start);
    final regex = RegExp(r'\{\{([a-zA-Z0-9_]*)$');
    final match = regex.firstMatch(textBeforeCursor);

    if (match != null) {
      final query = match.group(1) ?? '';
      _showSuggestions(query);
    } else {
      _removeOverlay();
    }
  }

  void _showSuggestions(String query) {
    final variablesMap = ref.read(resolvedVariablesProvider);

    final suggestions = variablesMap.keys
        .where((key) => key.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (suggestions.isEmpty) {
      _removeOverlay();
      return;
    }

    if (_overlayEntry != null) {
      _removeOverlay();
    }

    _overlayEntry = _createOverlayEntry(suggestions, query);
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(List<String> suggestions, String query) {
    return OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);

        return Positioned(
          width: 400,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 50),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              color: theme.colorScheme.surfaceContainer,
              shadowColor: Colors.black26,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final key = suggestions[index];
                    final value =
                        ref.read(resolvedVariablesProvider)[key] ?? '';
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: const Icon(Icons.data_object, size: 16),
                      title: Text(
                        key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () => _insertVariable(key, query),
                      hoverColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _insertVariable(String key, String query) {
    final text = _urlController.text;
    final selection = _urlController.selection;

    if (!selection.isValid) return;

    final textBeforeCursor = text.substring(0, selection.start);
    final suffix = text.substring(selection.start);

    final prefixWithoutQuery = textBeforeCursor.substring(
      0,
      textBeforeCursor.length - query.length,
    );

    final newText = '$prefixWithoutQuery$key}}$suffix';

    _urlController.text = newText;
    final newCursorPos = prefixWithoutQuery.length + key.length + 2;
    _urlController.selection = TextSelection.fromPosition(
      TextPosition(offset: newCursorPos),
    );

    // UPDATE STATE (FIXED)
    ref.read(urlQueryProvider.notifier).set(newText);
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(resolvedVariablesProvider);
    final selectedMethod = ref.watch(selectedMethodProvider);
    final requestState = ref.watch(requestProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<String>(urlQueryProvider, (previous, next) {
      if (_urlController.text != next) {
        _urlController.text = next;
        _urlController.selection = TextSelection.fromPosition(
          TextPosition(offset: next.length),
        );
      }
    });

    final resolvedVars = ref.watch(resolvedVariablesProvider);
    final baseUrl = resolvedVars['baseUrl'] ?? '';
    final hasBaseUrl = baseUrl.isNotEmpty;

    // MANDATORY Enforcement:
    // If baseUrl exists, ALWAYS show prefix and treat input as relative path.
    // Absolute URLs are only for "No Context".
    final showPrefix = hasBaseUrl;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          _buildMethodDropdown(selectedMethod, colorScheme),
          Container(width: 1, height: 28, color: colorScheme.outline),

          // SMART URL INPUT COMPONENT
          Expanded(
            child: Row(
              children: [
                if (showPrefix)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Tooltip(
                      message: 'Base URL (Enforced)',
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 200,
                        ), // Limit width
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 12,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                baseUrl, // SHOW ACTUAL VALUE
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              ' / ',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                Expanded(
                  child: CompositedTransformTarget(
                    link: _layerLink,
                    child: TextField(
                      controller: _urlController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: showPrefix
                            ? 'endpoint'
                            : 'https://api.example.com/endpoint',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      onChanged: _onTextChanged,
                      onSubmitted: (_) => _sendRequest(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: requestState.isLoading ? null : _sendRequest,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: requestState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Send',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodDropdown(String selectedMethod, ColorScheme colorScheme) {
    // Lista de métodos rápida
    final httpMethods = [
      'GET',
      'POST',
      'PUT',
      'DELETE',
      'PATCH',
      'HEAD',
      'OPTIONS',
    ];
    final methodColor = XoloTheme.getMethodColor(selectedMethod);

    return PopupMenuButton<String>(
      initialValue: selectedMethod,
      onSelected: (value) {
        ref.read(selectedMethodProvider.notifier).set(value);
      },
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: colorScheme.surfaceContainerHighest,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: methodColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              selectedMethod,
              style: TextStyle(
                color: methodColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => httpMethods.map((method) {
        final color = XoloTheme.getMethodColor(method);
        return PopupMenuItem(
          value: method,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                method,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _sendRequest() {
    final method = ref.read(selectedMethodProvider);
    var url = ref.read(urlQueryProvider);

    // SMART URL LOGIC
    // SMART URL LOGIC (ENFORCED)
    final resolvedVars = ref.read(resolvedVariablesProvider);
    // If baseUrl exists and is not empty (matching UI logic), enforce it.
    if (resolvedVars['baseUrl']?.isNotEmpty == true) {
      final isAbsolute =
          url.startsWith('http://') || url.startsWith('https://');

      if (isAbsolute) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Error: No uses rutas absolutas (http/https) aquí.',
            ),
            action: SnackBarAction(label: 'Entendido', onPressed: () {}),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior:
                SnackBarBehavior.floating, // Flotante para que se vea mejor
            duration: const Duration(seconds: 4),
          ),
        );
        // Detenemos la ejecución.
        // Opcional: Podríamos ofrecer borrar el dominio automáticamente en el SnackBarAction.
        return;
      }

      // Ensure slash handling
      if (!url.startsWith('/')) {
        url = '/$url';
      }
      url = '{{baseUrl}}$url';
    }

    final paramsList = ref.read(paramsProvider);
    final headersList = ref.read(headersProvider);
    final rawBody = ref.read(bodyContentProvider);

    final Map<String, dynamic> paramsMap = {};
    for (var item in paramsList) {
      if (item.key.isNotEmpty && item.isActive) {
        paramsMap[item.key] = item.value;
      }
    }

    final Map<String, dynamic> headersMap = {};
    for (var item in headersList) {
      if (item.key.isNotEmpty && item.isActive) {
        headersMap[item.key] = item.value;
      }
    }

    ref
        .read(requestProvider.notifier)
        .fetchData(
          method: method,
          url: url,
          queryParams: paramsMap,
          headers: headersMap,
          body: rawBody.isNotEmpty ? rawBody : null,
        );
  }
}
