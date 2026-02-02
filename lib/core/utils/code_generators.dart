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

  static String generateRustReqwest(RequestSession session) {
    final buffer = StringBuffer();
    buffer.writeln("use reqwest::Client;");
    buffer.writeln("use reqwest::header::{HeaderMap, HeaderValue};");
    buffer.writeln("");
    buffer.writeln("#[tokio::main]");
    buffer.writeln(
      "async fn main() -> Result<(), Box<dyn std::error::Error>> {",
    );
    buffer.writeln("    let client = Client::new();");
    buffer.writeln("    let mut headers = HeaderMap::new();");

    final activeHeaders = session.headers.where(
      (h) => h.isActive && h.key.isNotEmpty,
    );
    for (final h in activeHeaders) {
      buffer.writeln(
        "    headers.insert(\"${h.key}\", HeaderValue::from_static(\"${h.value}\"));",
      );
    }

    buffer.writeln("");
    if (session.body.isNotEmpty) {
      buffer.writeln("    let body = r#\"${session.body}\"#;");
    }

    buffer.writeln("    let res = client");
    buffer.writeln(
      "        .${session.method.toLowerCase()}(\"${session.url}\")",
    );
    if (activeHeaders.isNotEmpty) {
      buffer.writeln("        .headers(headers)");
    }
    if (session.body.isNotEmpty) {
      buffer.writeln("        .body(body)");
    }
    buffer.writeln("        .send()");
    buffer.writeln("        .await?;");
    buffer.writeln("");
    buffer.writeln("    println!(\"Status: {}\", res.status());");
    buffer.writeln("    let body = res.text().await?;");
    buffer.writeln("    println!(\"Body:\\n\\n{}\", body);");
    buffer.writeln("    Ok(())");
    buffer.writeln("}");

    return buffer.toString();
  }

  static String generateGoNative(RequestSession session) {
    final buffer = StringBuffer();
    buffer.writeln("package main");
    buffer.writeln("");
    buffer.writeln("import (");
    buffer.writeln("    \"fmt\"");
    buffer.writeln("    \"io\"");
    buffer.writeln("    \"net/http\"");
    buffer.writeln("    \"strings\"");
    buffer.writeln(")");
    buffer.writeln("");
    buffer.writeln("func main() {");
    buffer.writeln("    url := \"${session.url}\"");
    buffer.writeln("    method := \"${session.method}\"");

    if (session.body.isNotEmpty) {
      buffer.writeln("    payload := strings.NewReader(`\n${session.body}`)");
    } else {
      buffer.writeln("    payload := nil");
    }

    buffer.writeln("");
    buffer.writeln("    client := &http.Client{}");
    buffer.writeln("    req, err := http.NewRequest(method, url, payload)");
    buffer.writeln("    if err != nil {");
    buffer.writeln("        fmt.Println(err)");
    buffer.writeln("        return");
    buffer.writeln("    }");

    final activeHeaders = session.headers.where(
      (h) => h.isActive && h.key.isNotEmpty,
    );
    for (final h in activeHeaders) {
      buffer.writeln("    req.Header.Add(\"${h.key}\", \"${h.value}\")");
    }

    buffer.writeln("");
    buffer.writeln("    res, err := client.Do(req)");
    buffer.writeln("    if err != nil {");
    buffer.writeln("        fmt.Println(err)");
    buffer.writeln("        return");
    buffer.writeln("    }");
    buffer.writeln("    defer res.Body.Close()");
    buffer.writeln("");
    buffer.writeln("    body, err := io.ReadAll(res.Body)");
    buffer.writeln("    if err != nil {");
    buffer.writeln("        fmt.Println(err)");
    buffer.writeln("        return");
    buffer.writeln("    }");
    buffer.writeln("    fmt.Println(string(body))");
    buffer.writeln("}");

    return buffer.toString();
  }

  static String generatePythonHttpx(RequestSession session) {
    final buffer = StringBuffer();
    buffer.writeln("import httpx");
    buffer.writeln("import asyncio");
    buffer.writeln("");
    buffer.writeln("async def main():");
    buffer.writeln("    url = \"${session.url}\"");

    final activeHeaders = session.headers.where(
      (h) => h.isActive && h.key.isNotEmpty,
    );
    if (activeHeaders.isNotEmpty) {
      buffer.writeln("    headers = {");
      for (final h in activeHeaders) {
        buffer.writeln("        \"${h.key}\": \"${h.value}\",");
      }
      buffer.writeln("    }");
    } else {
      buffer.writeln("    headers = {}");
    }

    if (session.body.isNotEmpty) {
      buffer.writeln("    content = \"\"\"${session.body}\"\"\"");
    } else {
      buffer.writeln("    content = None");
    }

    buffer.writeln("");
    buffer.writeln("    async with httpx.AsyncClient() as client:");
    buffer.writeln("        response = await client.request(");
    buffer.writeln("            \"${session.method}\",");
    buffer.writeln("            url,");
    buffer.writeln("            headers=headers,");
    if (session.body.isNotEmpty) {
      buffer.writeln("            content=content");
    }
    buffer.writeln("        )");
    buffer.writeln("        print(f\"Status: {response.status_code}\")");
    buffer.writeln("        print(response.text)");
    buffer.writeln("");
    buffer.writeln("if __name__ == \"__main__\":");
    buffer.writeln("    asyncio.run(main())");

    return buffer.toString();
  }
}
