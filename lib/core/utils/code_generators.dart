import '../../presentation/providers/request_session_provider.dart';

class CodeGenerator {
  static String generateCurl(RequestSession session) {
    final buffer = StringBuffer();
    buffer.write("curl -X ${session.method} '${session.url}'");

    // Headers
    for (final h in session.headers) {
      if (h.isActive && h.key.isNotEmpty) {
        buffer.write(" \\\n  -H '${h.key}: ${h.value}'");
      }
    }

    // Auth (Basic) - Bearer usually in headers
    // If auth logic injects headers automatically at execution time,
    // the session might not have them explicitly in 'headers' list yet
    // depending on where we call this.
    // Assuming 'headers' list contains user-defined headers.
    // Ideally code gen should simulate the Auth injection or warn.
    // For now, we will just use what is in session.headers.

    // Body
    if (session.body.isNotEmpty) {
      // Escape single quotes for shell
      final escapedBody = session.body.replaceAll("'", "'\\''");
      buffer.write(" \\\n  -d '$escapedBody'");
    }

    return buffer.toString();
  }

  static String generateDartDio(RequestSession session) {
    final buffer = StringBuffer();
    buffer.writeln("import 'package:dio/dio.dart';");
    buffer.writeln("");
    buffer.writeln("final dio = Dio();");
    buffer.writeln("");
    buffer.writeln("void fetchData() async {");
    buffer.writeln("  try {");
    buffer.writeln("    final response = await dio.request(");
    buffer.writeln("      '${session.url}',");

    // Options
    buffer.writeln("      options: Options(");
    buffer.writeln("        method: '${session.method}',");

    // Headers
    final activeHeaders = session.headers.where(
      (h) => h.isActive && h.key.isNotEmpty,
    );
    if (activeHeaders.isNotEmpty) {
      buffer.writeln("        headers: {");
      for (final h in activeHeaders) {
        buffer.writeln("          '${h.key}': '${h.value}',");
      }
      buffer.writeln("        },");
    }
    buffer.writeln("      ),");

    // Body
    if (session.body.isNotEmpty) {
      buffer.writeln("      data: '''${session.body}''',");
    }

    buffer.writeln("    );");
    buffer.writeln("    print(response.data);");
    buffer.writeln("  } catch (e) {");
    buffer.writeln("    print(e);");
    buffer.writeln("  }");
    buffer.writeln("}");
    return buffer.toString();
  }

  static String generatePythonRequests(RequestSession session) {
    final buffer = StringBuffer();
    buffer.writeln("import requests");
    buffer.writeln("");
    buffer.writeln("url = '${session.url}'");
    buffer.writeln("");

    // Headers
    final activeHeaders = session.headers.where(
      (h) => h.isActive && h.key.isNotEmpty,
    );
    if (activeHeaders.isNotEmpty) {
      buffer.writeln("headers = {");
      for (final h in activeHeaders) {
        buffer.writeln("  '${h.key}': '${h.value}',");
      }
      buffer.writeln("}");
      buffer.writeln("");
    } else {
      buffer.writeln("headers = {}");
      buffer.writeln("");
    }

    // Body
    if (session.body.isNotEmpty) {
      buffer.writeln(
        "payload = '''${session.body}'''",
      ); // Triple quotes for multiline safe
      buffer.writeln("");
    } else {
      buffer.writeln("payload = {}");
      buffer.writeln("");
    }

    buffer.writeln("response = requests.request(");
    buffer.writeln("  '${session.method}',");
    buffer.writeln("  url,");
    if (activeHeaders.isNotEmpty) {
      buffer.writeln("  headers=headers,");
    }
    if (session.body.isNotEmpty) {
      // Simplification: assuming body is json or raw string.
      // If json, usually passed as json=... or data=...
      buffer.writeln("  data=payload");
    }
    buffer.writeln(")");
    buffer.writeln("");
    buffer.writeln("print(response.text)");

    return buffer.toString();
  }
}
