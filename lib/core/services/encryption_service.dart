import 'package:encrypt/encrypt.dart' as enc;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class EncryptionService {
  /// Generates a 32-byte key from the password using SHA-256.
  /// In production, PBKDF2 with salt is better, but SHA-256 is decent for local mvp.
  /// We will use a random Salt stored in the first 16 bytes of output for better security if possible,
  /// but to keep it simple and stateless (password = key), we'll stick to a deterministic key for now,
  /// OR prepend a random IV to the file.

  enc.Key _deriveKey(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  /// Encrypts a string
  String encryptString(String plainText, String password) {
    final key = _deriveKey(password);
    final iv = enc.IV.fromLength(16); // Random IV
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Return IV + EncryptedData (Base64 combined)
    // Format: iv_base64:ciphertext_base64
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a string
  String decryptString(String combined, String password) {
    final parts = combined.split(':');
    if (parts.length != 2) throw Exception('Invalid encrypted format');

    final iv = enc.IV.fromBase64(parts[0]);
    final cipherText = enc.Encrypted.fromBase64(parts[1]);

    final key = _deriveKey(password);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    return encrypter.decrypt(cipherText, iv: iv);
  }

  /// Encrypts bytes (for file operations)
  List<int> encryptBytes(List<int> plainBytes, String password) {
    final key = _deriveKey(password);
    final iv = enc.IV.fromLength(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);

    // Initial 16 bytes = IV
    return [...iv.bytes, ...encrypted.bytes];
  }

  /// Decrypts bytes
  List<int> decryptBytes(List<int> cipherBytes, String password) {
    if (cipherBytes.length < 16) throw Exception('Invalid data length');

    final ivBytes = cipherBytes.sublist(0, 16);
    final contentBytes = cipherBytes.sublist(16);

    final key = _deriveKey(password);
    final iv = enc.IV(Uint8List.fromList(ivBytes));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    return encrypter.decryptBytes(
      enc.Encrypted(Uint8List.fromList(contentBytes)),
      iv: iv,
    );
  }

  /// Helper to generate a random strong password if user wants one
  String generateRandomPassword() {
    final r = Random.secure();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890!@#\$%^&*';
    return List.generate(16, (index) => chars[r.nextInt(chars.length)]).join();
  }
}

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});
