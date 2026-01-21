import 'package:flutter/material.dart';

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
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildNode(widget.data, '', 0, null),
      ),
    );
  }

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

  static const _darkColors = _JsonColors(
    key: Color(0xFFF87171), // Coral (carmesí claro)
    string: Color(0xFF34D399), // Verde
    number: Color(0xFFFBBF24), // Amarillo
    boolean: Color(0xFF60A5FA), // Azul
    nullValue: Color(0xFF6B7280),
    punctuation: Color(0xFF6B7280),
    collapsed: Color(0xFF9CA3AF),
  );

  static const _lightColors = _JsonColors(
    key: Color(0xFFB91C1C), // Carmesí
    string: Color(0xFF059669), // Verde
    number: Color(0xFFD97706), // Naranja
    boolean: Color(0xFF2563EB), // Azul
    nullValue: Color(0xFF6B7280),
    punctuation: Color(0xFF6B7280),
    collapsed: Color(0xFF9CA3AF),
  );
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
