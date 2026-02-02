import 'package:uuid/uuid.dart';
import 'dart:math';

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
      r'(\{\{([a-zA-Z0-9_\$]+)\}\})|(:([a-zA-Z0-9_]+))|(\{:[a-zA-Z0-9_]+\})',
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

      if (key == null) return match.group(0)!;

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
