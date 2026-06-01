import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/theme/premium_theme.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/core/theme/xolo_theme_extension.dart';
import 'package:xolo/core/utils/variable_text_controller.dart';
import 'package:xolo/domain/entities/key_value_pair.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/providers/environment_provider.dart';
import 'package:xolo/presentation/providers/request_provider.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';

class UrlInputBar extends ConsumerStatefulWidget {
  final String tabId;
  const UrlInputBar({super.key, required this.tabId});

  @override
  ConsumerState<UrlInputBar> createState() => _UrlInputBarState();
}

class _UrlInputBarState extends ConsumerState<UrlInputBar> {
  late VariableTextController _urlController;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isBaseUrlExpanded = false;

  @override
  void initState() {
    super.initState();
    // Use .asData?.value instead of valueOrNull
    final initialUrl =
        ref.read(requestSessionProvider(widget.tabId)).asData?.value.url ?? '';
    _urlController = VariableTextController(text: initialUrl);

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
    final controller = ref.read(requestSessionControllerProvider(widget.tabId));
    controller.setUrl(text);

    // Path Param Extraction logic {:paramName}
    final pathParamRegex = RegExp(r'\{:([a-zA-Z0-9_]+)\}');
    final matches = pathParamRegex.allMatches(text);

    if (matches.isNotEmpty) {
      final newParams = matches.map((m) => m.group(1)!).toSet();
      final currentParams = controller.state.params;
      final existingKeys = currentParams.map((e) => e.key).toSet();
      final paramsToAdd = newParams.difference(existingKeys);

      if (paramsToAdd.isNotEmpty) {
        // We need to import KeyValuePair but it's not exported from anywhere visible here?
        // It is imported at top: import '../../domain/entities/key_value_pair.dart'; if we didn't remove it.
        // Wait, see original file content.
        // It imports: import '../providers/request_session_provider.dart';
        // RequestSessionProvider imports 'key_value_pair.dart'. Does it export it?
        // Let's check imports in UrlInputBar.

        final updatedParams = List<KeyValuePair>.from(currentParams);
        // Remove empty rows to clean up before adding
        updatedParams.removeWhere((e) => e.key.isEmpty && e.value.isEmpty);

        for (final key in paramsToAdd) {
          updatedParams.add(KeyValuePair(key: key, value: '', isActive: true));
        }
        controller.updateParams(updatedParams);
      }
    }

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

    ref.read(requestSessionControllerProvider(widget.tabId)).setUrl(newText);
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(resolvedVariablesProvider);

    final sessionAsync = ref.watch(requestSessionProvider(widget.tabId));
    final requestAsync = ref.watch(requestProvider(widget.tabId));

    final session = sessionAsync.asData?.value;
    if (session == null) return const SizedBox.shrink();

    final selectedMethod = session.method;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<
      AsyncValue<RequestSession>
    >(requestSessionProvider(widget.tabId), (previous, next) {
      final nextUrl = next.asData?.value.url;
      // Solo actualizar si el texto es diferente y el foco no está activo (opcional)
      // O si es la carga inicial (previous es loading/null)
      final prevUrl = previous?.asData?.value.url;

      if (nextUrl != null && _urlController.text != nextUrl) {
        // Si el usuario está escribiendo y el cambio viene de su escritura (loopback), no movemos el cursor.
        // Pero aquí estamos cargando desde fuera (Navigation).
        // Para evitar problemas de cursor saltando, verificamos si el cambio es sustancial.

        // Si anterior era null/vacio y ahora tiene valor, es una carga de request. Force update.
        if ((prevUrl == null || prevUrl.isEmpty) && nextUrl.isNotEmpty) {
          _urlController.text = nextUrl;
          _urlController.selection = TextSelection.fromPosition(
            TextPosition(offset: nextUrl.length),
          );
        }
        // Si el cambio viene de otro lado (no local), podríamos querer actualizar,
        // pero si tiene foco y estamos escribiendo, el provider ya tiene lo que escribimos.
        // El problema es recibir updates externos mientras escribimos.
        // Dado que RequestSession es local por tab, solo "nosotros" escribimos o "cargamos".
      }
    });

    // Manual sync for initial load (simulating fireImmediately)
    final currentUrl = session.url;
    if (_urlController.text.isEmpty && currentUrl.isNotEmpty) {
      _urlController.text = currentUrl;
      _urlController.selection = TextSelection.fromPosition(
        TextPosition(offset: currentUrl.length),
      );
    }

    final resolvedVars = ref.watch(resolvedVariablesProvider);
    final baseUrl = resolvedVars['baseUrl'] ?? '';
    final hasBaseUrl = baseUrl.isNotEmpty;

    final showPrefix = hasBaseUrl;

    return Container(
      decoration: XoloSurfaces.panel(colorScheme, borderRadius: XoloRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          _buildMethodDropdown(selectedMethod, colorScheme),
          Container(width: 1, height: 28, color: colorScheme.outline),

          // SMART URL INPUT COMPONENT
          Expanded(
            child: Row(
              children: [
                if (showPrefix)
                  Flexible(
                    flex: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Tooltip(
                        message: 'Base URL (Tap to expand/collapse)',
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isBaseUrlExpanded = !_isBaseUrlExpanded;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            constraints: BoxConstraints(
                              maxWidth: _isBaseUrlExpanded
                                  ? 200
                                  : 70, // Reduced sizes
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
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
                                    maxLines: 1,
                                  ),
                                ),
                                if (_isBaseUrlExpanded) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_left,
                                    size: 12,
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
                      style:
                          (XoloThemeExtension.of(context)?.mono ??
                                  const TextStyle())
                              .copyWith(
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
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient:
                    XoloThemeExtension.of(context)?.accentGradient ??
                    XoloSurfaces.accentGradient(colorScheme.primary),
                borderRadius: XoloRadius.md,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: requestAsync.isLoading ? null : _sendRequest,
                  borderRadius: XoloRadius.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    child: requestAsync.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Send',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
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
    final httpMethods = [
      'GET',
      'POST',
      'PUT',
      'DELETE',
      'PATCH',
      'HEAD',
      'OPTIONS',
    ];
    final methodColor = XoloPremiumTheme.getMethodColor(selectedMethod);

    return PopupMenuButton<String>(
      initialValue: selectedMethod,
      onSelected: (value) {
        ref
            .read(requestSessionControllerProvider(widget.tabId))
            .setMethod(value);
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
              style:
                  (XoloThemeExtension.of(context)?.monoSmall ??
                          const TextStyle())
                      .copyWith(
                        color: methodColor,
                        fontWeight: FontWeight.w700,
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
        final color = XoloPremiumTheme.getMethodColor(method);
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
    final session = ref
        .read(requestSessionProvider(widget.tabId))
        .asData
        ?.value;
    if (session == null) return;

    final method = session.method;
    var url = session.url;

    final resolvedVars = ref.read(resolvedVariablesProvider);
    if (resolvedVars['baseUrl']?.isNotEmpty == true) {
      final isAbsolute =
          url.startsWith('http://') || url.startsWith('https://');

      if (isAbsolute) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.absoluteUrlError),
            action: SnackBarAction(label: l10n.understood, onPressed: () {}),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      if (!url.startsWith('/')) {
        url = '/$url';
      }
      url = '{{baseUrl}}$url';
    }

    final Map<String, dynamic> paramsMap = {};
    for (var item in session.params) {
      if (item.key.isNotEmpty && item.isActive) {
        paramsMap[item.key] = item.value;
      }
    }

    final Map<String, dynamic> headersMap = {};
    for (var item in session.headers) {
      if (item.key.isNotEmpty && item.isActive) {
        headersMap[item.key] = item.value;
      }
    }

    final rawBody = session.body;

    ref
        .read(requestControllerProvider(widget.tabId))
        .fetchData(
          method: method,
          url: url,
          queryParams: paramsMap,
          headers: headersMap,
          body: rawBody.isNotEmpty ? rawBody : null,
          authType: session.authType,
          authData: session.authData,
          collectionId: session.collectionId,
        );
  }
}
