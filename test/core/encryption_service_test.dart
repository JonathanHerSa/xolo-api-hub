import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
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

    test('decrypts legacy iv:ciphertext format', () {
      const password = 'legacy-pass';
      const plain = 'legacy-secret';
      final key = enc.Key(
        Uint8List.fromList(sha256.convert(utf8.encode(password)).bytes),
      );
      final iv = enc.IV.fromLength(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(plain, iv: iv);
      final legacyPayload = '${iv.base64}:${encrypted.base64}';

      expect(service.decryptString(legacyPayload, password), plain);
    });

    test('rejects invalid encrypted string format', () {
      expect(
        () => service.decryptString('not-valid', 'password'),
        throwsA(isA<Exception>()),
      );
    });

    test('rejects truncated byte payloads and invalid mac', () {
      expect(
        () => service.decryptBytes([1, 2, 3], 'password'),
        throwsA(isA<Exception>()),
      );

      final bytes = utf8.encode('payload');
      final encrypted = service.encryptBytes(bytes, 'password');
      final tampered = List<int>.from(encrypted)
        ..[encrypted.length - 1] ^= 0xFF;

      expect(
        () => service.decryptBytes(tampered, 'password'),
        throwsA(isA<Exception>()),
      );
    });

    test('generateRandomPassword returns 16 chars', () {
      final password = service.generateRandomPassword();
      expect(password.length, 16);
      expect(password, isNotEmpty);
    });
  });
}
