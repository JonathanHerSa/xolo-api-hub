import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/xolo_theme.dart';
import '../providers/form_providers.dart';
import '../providers/request_provider.dart';

class UrlInputBar extends ConsumerStatefulWidget {
  const UrlInputBar({super.key});

  @override
  ConsumerState<UrlInputBar> createState() => _UrlInputBarState();
}

class _UrlInputBarState extends ConsumerState<UrlInputBar> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    // Inicializar con el valor actual del provider
    final initialUrl = ref.read(urlQueryProvider);
    _urlController = TextEditingController(text: initialUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMethod = ref.watch(selectedMethodProvider);
    final requestState = ref.watch(requestProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Escuchar cambios externos del provider (ej: al cargar del historial)
    ref.listen<String>(urlQueryProvider, (previous, next) {
      if (_urlController.text != next) {
        _urlController.text = next;
        // Mover cursor al final
        _urlController.selection = TextSelection.fromPosition(
          TextPosition(offset: next.length),
        );
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          // Method Selector
          _buildMethodDropdown(selectedMethod, colorScheme),

          // Divider
          Container(width: 1, height: 28, color: colorScheme.outline),

          // URL Input
          Expanded(
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'https://api.example.com/endpoint',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
              onChanged: (value) {
                ref.read(urlQueryProvider.notifier).state = value;
              },
              onSubmitted: (_) => _sendRequest(),
            ),
          ),

          // Send Button
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
    final methodColor = XoloTheme.getMethodColor(selectedMethod);

    return PopupMenuButton<String>(
      initialValue: selectedMethod,
      onSelected: (value) {
        ref.read(selectedMethodProvider.notifier).state = value;
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
    final url = ref.read(urlQueryProvider);
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
