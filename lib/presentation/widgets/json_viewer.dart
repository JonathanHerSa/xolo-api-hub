import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// JSON Viewer optimizado con nodos colapsables
/// INICIA COLAPSADO para evitar renderizar todo de golpe
class JsonViewer extends StatefulWidget {
  final dynamic data;

  const JsonViewer({super.key, required this.data});

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  // Track de qué nodos están EXPANDIDOS (por defecto todo colapsado)
  final Set<String> _expandedPaths = {''}; // Solo raíz expandido

  @override
  void didUpdateWidget(JsonViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      // Resetear cuando cambia el data
      _expandedPaths.clear();
      _expandedPaths.add('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SelectionArea(
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildNode(widget.data, '', 0, null),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.copy, size: 16),
            tooltip: 'Copiar JSON',
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
              padding: const EdgeInsets.all(8),
            ),
            onPressed: () {
              final text = const JsonEncoder.withIndent(
                '  ',
              ).convert(widget.data);
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON copiado al portapapeles')),
              );
            },
          ),
        ),
      ],
    );
  }

  // ... (rest of build methods)

  // --- REFINED COLORS (Dracula/Monokai inspired but cleaner) ---

  static const _darkColors = _JsonColors(
    key: Color(0xFFFF7B72), // Soft Red (GitHub Dark key)
    string: Color(0xFFA5D6FF), // Soft Blue/Cyan
    number: Color(0xFF79C0FF), // Blue
    boolean: Color(0xFF56D364), // Green
    nullValue: Color(0xFF6E7681), // Grey
    punctuation: Color(0xFFC9D1D9), // White/Grey
    collapsed: Color(0xFF8B949E),
  );

  static const _lightColors = _JsonColors(
    key: Color(0xFFD32F2F), // Crimson
    string: Color(0xFF0984E3), // Vibrant Blue
    number: Color(0xFF0097E6), // Bright Blue
    boolean: Color(0xFF27AE60), // Green
    nullValue: Color(0xFF7F8C8D),
    punctuation: Color(0xFF2D3436),
    collapsed: Color(0xFFAAAAAA),
  );

  Widget _buildNode(dynamic value, String path, int indent, String? keyName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? _darkColors : _lightColors;

    if (value is Map) {
      return _buildMapNode(value, path, indent, keyName, colors);
    } else if (value is List) {
      return _buildListNode(value, path, indent, keyName, colors);
    } else {
      return _buildValueNode(value, keyName, colors);
    }
  }

  Widget _buildMapNode(
    Map map,
    String path,
    int indent,
    String? keyName,
    _JsonColors colors,
  ) {
    final isExpanded = _expandedPaths.contains(path);
    final isEmpty = map.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        InkWell(
          onTap: isEmpty ? null : () => _toggleExpand(path),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEmpty)
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: colors.punctuation,
                )
              else
                const SizedBox(width: 16),
              if (keyName != null) ...[
                Text('"$keyName"', style: _keyStyle(colors)),
                Text(': ', style: _punctStyle(colors)),
              ],
              Text('{', style: _punctStyle(colors)),
              if (!isExpanded || isEmpty) ...[
                Text(
                  isEmpty ? '' : ' ${map.length} ',
                  style: TextStyle(
                    color: colors.collapsed,
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                  ),
                ),
                Text('}', style: _punctStyle(colors)),
              ],
            ],
          ),
        ),

        // Contenido (solo si está expandido)
        if (isExpanded && !isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < map.entries.length; i++)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: _buildNode(
                          map.entries.elementAt(i).value,
                          '$path.${map.entries.elementAt(i).key}',
                          indent + 1,
                          map.entries.elementAt(i).key.toString(),
                        ),
                      ),
                      if (i < map.entries.length - 1)
                        Text(',', style: _punctStyle(colors)),
                    ],
                  ),
              ],
            ),
          ),

        if (isExpanded && !isEmpty) Text('}', style: _punctStyle(colors)),
      ],
    );
  }

  Widget _buildListNode(
    List list,
    String path,
    int indent,
    String? keyName,
    _JsonColors colors,
  ) {
    final isExpanded = _expandedPaths.contains(path);
    final isEmpty = list.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        InkWell(
          onTap: isEmpty ? null : () => _toggleExpand(path),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEmpty)
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: colors.punctuation,
                )
              else
                const SizedBox(width: 16),
              if (keyName != null) ...[
                Text('"$keyName"', style: _keyStyle(colors)),
                Text(': ', style: _punctStyle(colors)),
              ],
              Text('[', style: _punctStyle(colors)),
              if (!isExpanded || isEmpty) ...[
                Text(
                  isEmpty ? '' : ' ${list.length} ',
                  style: TextStyle(
                    color: colors.collapsed,
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                  ),
                ),
                Text(']', style: _punctStyle(colors)),
              ],
            ],
          ),
        ),

        // Contenido (solo si está expandido)
        if (isExpanded && !isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < list.length; i++)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: _buildNode(
                          list[i],
                          '$path[$i]',
                          indent + 1,
                          null,
                        ),
                      ),
                      if (i < list.length - 1)
                        Text(',', style: _punctStyle(colors)),
                    ],
                  ),
              ],
            ),
          ),

        if (isExpanded && !isEmpty) Text(']', style: _punctStyle(colors)),
      ],
    );
  }

  Widget _buildValueNode(dynamic value, String? keyName, _JsonColors colors) {
    Color valueColor;
    String displayValue;

    if (value == null) {
      valueColor = colors.nullValue;
      displayValue = 'null';
    } else if (value is bool) {
      valueColor = colors.boolean;
      displayValue = value.toString();
    } else if (value is num) {
      valueColor = colors.number;
      displayValue = value.toString();
    } else {
      valueColor = colors.string;
      String str = value.toString();
      if (str.length > 200) str = '${str.substring(0, 200)}...';
      displayValue = '"${str.replaceAll('\n', '\\n')}"';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 16),
        if (keyName != null) ...[
          Text('"$keyName"', style: _keyStyle(colors)),
          Text(': ', style: _punctStyle(colors)),
        ],
        Flexible(
          child: Text(
            displayValue,
            style: TextStyle(
              color: valueColor,
              fontFamily: 'JetBrains Mono',
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _keyStyle(_JsonColors c) =>
      TextStyle(color: c.key, fontFamily: 'JetBrains Mono', fontSize: 13);
  TextStyle _punctStyle(_JsonColors c) => TextStyle(
    color: c.punctuation,
    fontFamily: 'JetBrains Mono',
    fontSize: 13,
  );

  void _toggleExpand(String path) {
    setState(() {
      if (_expandedPaths.contains(path)) {
        _expandedPaths.remove(path);
      } else {
        _expandedPaths.add(path);
      }
    });
  }
}

class _JsonColors {
  final Color key;
  final Color string;
  final Color number;
  final Color boolean;
  final Color nullValue;
  final Color punctuation;
  final Color collapsed;

  const _JsonColors({
    required this.key,
    required this.string,
    required this.number,
    required this.boolean,
    required this.nullValue,
    required this.punctuation,
    required this.collapsed,
  });
}
