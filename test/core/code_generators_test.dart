import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/utils/code_generators.dart';
import 'package:xolo/domain/entities/key_value_pair.dart';
import 'package:xolo/presentation/providers/request_session_provider.dart';

RequestSession _sessionWithHeadersAndBody() {
  return RequestSession(
    id: 'tab-1',
    method: 'POST',
    url: 'https://api.example.com/users',
    headers: [
      KeyValuePair(key: 'Content-Type', value: 'application/json'),
      KeyValuePair(key: 'X-Disabled', value: 'off', isActive: false),
      KeyValuePair(key: 'Authorization', value: 'Bearer token'),
    ],
    params: [],
    body: '{"name":"Ada"}',
  );
}

void main() {
  group('CodeGenerator.generateCurl', () {
    test('builds curl with method, url, active headers and escaped body', () {
      final session = RequestSession(
        id: 'tab-1',
        method: 'POST',
        url: 'https://api.example.com/users',
        headers: [
          KeyValuePair(key: 'Content-Type', value: 'application/json'),
          KeyValuePair(key: 'X-Disabled', value: 'off', isActive: false),
          KeyValuePair(key: 'Authorization', value: 'Bearer token'),
        ],
        params: [],
        body: "{\n  \"name\": \"O'Brien\"\n}",
      );

      final curl = CodeGenerator.generateCurl(session);

      expect(curl, startsWith("curl -X POST 'https://api.example.com/users'"));
      expect(curl, contains("-H 'Content-Type: application/json'"));
      expect(curl, contains("-H 'Authorization: Bearer token'"));
      expect(curl, isNot(contains('X-Disabled')));
      expect(curl, contains("-d '{"));
      expect(curl, contains("O'\\''Brien"));
    });

    test('omits body flag when body is empty', () {
      final session = RequestSession(
        id: 'tab-2',
        method: 'GET',
        url: 'https://api.example.com/health',
        headers: const [],
        params: const [],
      );

      final curl = CodeGenerator.generateCurl(session);

      expect(curl, "curl -X GET 'https://api.example.com/health'");
      expect(curl, isNot(contains('-d ')));
    });
  });

  group('CodeGenerator language generators', () {
    final session = _sessionWithHeadersAndBody();

    test('generateDartDio includes headers and body', () {
      final code = CodeGenerator.generateDartDio(session);
      expect(code, contains("import 'package:dio/dio.dart';"));
      expect(code, contains("'Content-Type': 'application/json'"));
      expect(code, isNot(contains('X-Disabled')));
      expect(code, contains("data: '''{\"name\":\"Ada\"}'''"));
      expect(code, contains("method: 'POST'"));
    });

    test('generatePythonRequests includes headers and data payload', () {
      final code = CodeGenerator.generatePythonRequests(session);
      expect(code, contains("'Content-Type': 'application/json'"));
      expect(code, contains('payload ='));
      expect(code, contains('requests.request('));
      expect(code, contains("  'POST',"));
    });

    test('generatePythonHttpx async client with content', () {
      final code = CodeGenerator.generatePythonHttpx(session);
      expect(code, contains('import httpx'));
      expect(code, contains('async def main():'));
      expect(code, contains('content = """{"name":"Ada"}"""'));
      expect(code, contains('await client.request('));
    });

    test('generateRustReqwest builds client request', () {
      final code = CodeGenerator.generateRustReqwest(session);
      expect(code, contains('use reqwest::Client'));
      expect(code, contains('.post("https://api.example.com/users")'));
      expect(code, contains('headers.insert("Authorization"'));
      expect(code, contains('let body = r#"{"name":"Ada"}"#'));
    });

    test('generateGoNative builds http request with headers', () {
      final code = CodeGenerator.generateGoNative(session);
      expect(code, contains('package main'));
      expect(code, contains('payload := strings.NewReader'));
      expect(code, contains('req.Header.Add("Authorization"'));
      expect(code, contains('method := "POST"'));
    });

    test('generators handle empty headers and body', () {
      final minimal = RequestSession(
        id: 'min',
        method: 'GET',
        url: 'https://api.example.com',
        headers: const [],
        params: const [],
      );

      expect(
        CodeGenerator.generateDartDio(minimal),
        isNot(contains('headers: {')),
      );
      expect(
        CodeGenerator.generatePythonRequests(minimal),
        contains('payload = {}'),
      );
      expect(
        CodeGenerator.generatePythonHttpx(minimal),
        contains('content = None'),
      );
      expect(
        CodeGenerator.generateRustReqwest(minimal),
        isNot(contains('.body(body)')),
      );
      expect(
        CodeGenerator.generateGoNative(minimal),
        contains('payload := nil'),
      );
    });
  });
}
