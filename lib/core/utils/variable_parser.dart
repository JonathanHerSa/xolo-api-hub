import 'dart:math';

import 'package:uuid/uuid.dart';

/// Clase encargada de parsear y sustituir variables en strings
/// Soporta formato {{variable}}
class VariableParser {
  /// Parsea un string reemplazando las variables por sus valores
  /// [input]: String a parsear (ej: "{{host}}/api/v1")
  /// [variables]: Mapa de variables disponibles (key: nombre, value: valor)
  /// Retorna el string con las variables sustituidas
  static String parse(
    String input,
    Map<String, String> variables, {
    int depth = 0,
  }) {
    if (input.isEmpty) return input;
    // Check for potential variable markers before doing regex
    if (!input.contains('{{') &&
        !input.contains(':') &&
        !input.contains('{:')) {
      return input;
    }
    if (depth > 3) return input; // Max recursion depth

    // Regex para {{variable}}, :path_param y {:path_param}
    // Añadido \$ para soportar variables dinámicas como {{$timestamp}}
    final regex = RegExp(
      r'(\{\{([a-zA-Z0-9_\$:\-]+)\}\})|(:([a-zA-Z0-9_]+))|(\{:[a-zA-Z0-9_]+\})',
    );

    final result = input.replaceAllMapped(regex, (match) {
      String? key;
      if (match.group(2) != null) {
        key = match.group(2); // {{key}}
      } else if (match.group(4) != null) {
        key = match.group(4); // :key
      } else if (match.group(5) != null) {
        // {:key} -> strip {: and }
        final g5 = match.group(5)!;
        key = g5.substring(2, g5.length - 1);
      }

      if (key == null) return match.group(0)!; // coverage:ignore-line

      // --- Dynamic Variables ---
      if (key == r'$timestamp') {
        return DateTime.now().millisecondsSinceEpoch.toString();
      }
      if (key == r'$guid') {
        return const Uuid().v4();
      }
      if (key == r'$randomInt') {
        return Random().nextInt(1000).toString();
      }
      if (key == r'$isoDate') {
        return DateTime.now().toIso8601String().split('T').first;
      }
      if (key == r'$isoDateTime') {
        return DateTime.now().toIso8601String();
      }
      if (key == r'$randomEmail') {
        return 'user${Random().nextInt(99999)}@xolo.test';
      }
      if (key.startsWith(r'$randomString')) {
        final len = _randomStringLength(key);
        return _randomAlphanumeric(len);
      }
      if (key.startsWith(r'$randomIntRange')) {
        final range = _randomIntRange(key);
        if (range != null) {
          return (range.$1 + Random().nextInt(range.$2 - range.$1 + 1)).toString();
        }
      }

      // Buscar variable en el mapa (case sensitive para mantener consistencia)
      final value = variables[key];

      // Si existe, devolver valor. Si no, devolver el placeholder original
      return value ?? match.group(0)!;
    });

    // Recursively parse if the result still contains braces and we haven't hit limit
    if (result != input && result.contains('{{')) {
      return parse(result, variables, depth: depth + 1);
    }
    return result;
  }

  static int _randomStringLength(String key) {
    // {{$randomString:8}} encoded as key $randomString:8 in regex group
    if (key.contains(':')) {
      return int.tryParse(key.split(':').last) ?? 8;
    }
    return 8;
  }

  static (int, int)? _randomIntRange(String key) {
    // {{$randomIntRange:1:100}} -> key $randomIntRange:1:100
    final parts = key.split(':');
    if (parts.length >= 3) {
      final min = int.tryParse(parts[1]);
      final max = int.tryParse(parts[2]);
      if (min != null && max != null && min <= max) return (min, max);
    }
    return null;
  }

  static String _randomAlphanumeric(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
      length.clamp(1, 64),
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Parsea un mapa de headers o params
  static Map<String, dynamic> parseMap(
    Map<String, dynamic> input,
    Map<String, String> variables,
  ) {
    if (input.isEmpty) return input;

    final result = <String, dynamic>{};

    input.forEach((key, value) {
      if (value is String) {
        // Parsear tanto la key como el value
        final parsedKey = parse(key, variables);
        final parsedValue = parse(value, variables);
        result[parsedKey] = parsedValue;
      } else {
        // Si no es string, dejar como está
        result[parse(key, variables)] = value;
      }
    });

    return result;
  }
}
