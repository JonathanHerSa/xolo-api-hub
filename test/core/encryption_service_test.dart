import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    final service = EncryptionService();

    test('encrypt/decrypt string roundtrip with v2 format', () {
      const text = 'super-secret-token';
      const password = 'StrongPassword123!';

      final encrypted = service.encryptString(text, password);
      final decrypted = service.decryptString(encrypted, password);

      expect(encrypted.startsWith('v2:'), isTrue);
      expect(decrypted, text);
    });

    test('encrypt/decrypt bytes roundtrip', () {
      final bytes = utf8.encode('{"hello":"world"}');
      const password = 'StrongPassword123!';

      final encrypted = service.encryptBytes(bytes, password);
      final decrypted = service.decryptBytes(encrypted, password);

      expect(decrypted, bytes);
    });
  });
}
