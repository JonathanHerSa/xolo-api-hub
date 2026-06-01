import 'dart:convert';

import 'package:json_path/json_path.dart';
import 'package:xolo/core/services/app_logger.dart';
import 'package:xolo/core/utils/variable_parser.dart';

/// Pure functions for evaluating pre/post request scripts.
class ScriptExecutor {
  ScriptExecutor._(); // coverage:ignore-line

  /// Evaluates pre-request script rules against [baseVars].
  static Map<String, String> executePreScripts(
    String? preScriptsJson,
    Map<String, String> baseVars,
  ) {
    if (preScriptsJson == null || preScriptsJson.isEmpty) return {};
    final results = <String, String>{};

    try {
      final List<dynamic> rules = jsonDecode(preScriptsJson);
      for (final rule in rules) {
        final varName = rule['key'];
        final template = rule['value'];
        if (varName == null || template == null || template.isEmpty) continue;

        try {
          final evaluated = VariableParser.parse(template, baseVars);
          results[varName] = evaluated;
        } catch (e) {
          // coverage:ignore-start
          AppLogger.warn('Error evaluating pre-script rule');
          // coverage:ignore-end
        }
      }
    } catch (e) {
      AppLogger.warn('Error parsing pre-scripts JSON');
    }
    return results;
  }

  /// Tests post-response script rules without persisting variables.
  static Map<String, String> testPostScripts(
    dynamic responseData,
    String scriptsJson,
  ) {
    if (scriptsJson.isEmpty) return {};
    final results = <String, String>{};

    try {
      final List<dynamic> rules = jsonDecode(scriptsJson);
      for (final rule in rules) {
        final varName = rule['key'];
        final pathStr = rule['path'];
        if (varName == null || pathStr == null || pathStr.isEmpty) continue;

        try {
          final jsonPath = JsonPath(pathStr);
          final matches = jsonPath.read(responseData);

          if (matches.isNotEmpty) {
            final firstValue = matches.first.value;
            results[varName] = firstValue?.toString() ?? 'null';
          } else {
            results[varName] = '[No Match]';
          }
        } catch (e) {
          results[varName] = '[Error: $e]';
        }
      }
    } catch (e) {
      AppLogger.warn('Error testing scripts');
    }
    return results;
  }
}
