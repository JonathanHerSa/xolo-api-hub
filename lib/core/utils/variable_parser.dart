/// Clase encargada de parsear y sustituir variables en strings
/// Soporta formato {{variable}}
class VariableParser {
  /// Parsea un string reemplazando las variables por sus valores
  /// [input]: String a parsear (ej: "{{host}}/api/v1")
  /// [variables]: Mapa de variables disponibles (key: nombre, value: valor)
  /// Retorna el string con las variables sustituidas
  static String parse(String input, Map<String, String> variables) {
    if (input.isEmpty) return input;
    if (!input.contains('{{')) return input;

    // Regex para encontrar {{variable}}
    final regex = RegExp(r'\{\{([a-zA-Z0-9_]+)\}\}');

    return input.replaceAllMapped(regex, (match) {
      final key = match.group(1);
      if (key == null) return match.group(0)!;

      // Buscar variable en el mapa (case sensitive para mantener consistencia)
      final value = variables[key];

      // Si existe, devolver valor. Si no, devolver el placeholder original
      return value ?? match.group(0)!;
    });
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
