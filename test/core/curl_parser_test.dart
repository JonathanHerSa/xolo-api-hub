import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/utils/curl_parser.dart';

void main() {
  group('CurlParser', () {
    test('parses GET curl with headers', () {
      const command =
          "curl -X GET 'https://api.example.com/users' -H 'Authorization: Bearer token'";
      final parsed = CurlParser.parse(command);

      expect(parsed, isNotNull);
      expect(parsed!.method, 'GET');
      expect(parsed.url, 'https://api.example.com/users');
      expect(parsed.headers['Authorization'], 'Bearer token');
    });

    test('parses POST curl with JSON body', () {
      const command =
          "curl -X POST 'https://api.example.com/users' -d '{\"name\":\"Ada\"}'";
      final parsed = CurlParser.parse(command);

      expect(parsed, isNotNull);
      expect(parsed!.method, 'POST');
      expect(parsed.body, contains('Ada'));
    });

    test('returns null for non-curl input', () {
      expect(CurlParser.parse('wget https://example.com'), isNull);
    });
  });
}
