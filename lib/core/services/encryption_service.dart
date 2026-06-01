import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _pbkdf2Rounds = 120000;
const _keyLength = 32;
const _saltLength = 16;
const _ivLength = 16;

class EncryptionService {
  enc.Key _deriveKeyPbkdf2(String password, List<int> salt) {
    var block = <int>[];
    final output = <int>[];
    var counter = 1;

    while (output.length < _keyLength) {
      final hmacSha256 = Hmac(sha256, utf8.encode(password));
      final initial = <int>[...salt, 0, 0, 0, counter];
      var u = hmacSha256.convert(initial).bytes;
      block = List<int>.from(u);
      for (var i = 1; i < _pbkdf2Rounds; i++) {
        u = hmacSha256.convert(u).bytes;
        for (var j = 0; j < block.length; j++) {
          block[j] ^= u[j];
        }
      }
      output.addAll(block);
      counter++;
    }

    return enc.Key(Uint8List.fromList(output.sublist(0, _keyLength)));
  }

  enc.Key _legacyKey(String password) {
    final digest = sha256.convert(utf8.encode(password));
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List.generate(length, (_) => random.nextInt(256));
  }

  String encryptString(String plainText, String password) {
    final salt = _randomBytes(_saltLength);
    final key = _deriveKeyPbkdf2(password, salt);
    final iv = enc.IV(Uint8List.fromList(_randomBytes(_ivLength)));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final payload = [...salt, ...iv.bytes, ...encrypted.bytes];
    final mac = Hmac(sha256, key.bytes).convert(payload).bytes;
    final finalPayload = [...payload, ...mac];
    return 'v2:${base64Encode(finalPayload)}';
  }

  String decryptString(String combined, String password) {
    if (combined.startsWith('v2:')) {
      final data = base64Decode(combined.substring(3));
      return utf8.decode(decryptBytes(data, password));
    }

    // Legacy format compatibility.
    final parts = combined.split(':');
    if (parts.length != 2) throw Exception('Invalid encrypted format');

    final iv = enc.IV.fromBase64(parts[0]);
    final cipherText = enc.Encrypted.fromBase64(parts[1]);

    final key = _legacyKey(password);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    return encrypter.decrypt(cipherText, iv: iv);
  }

  List<int> encryptBytes(List<int> plainBytes, String password) {
    final salt = _randomBytes(_saltLength);
    final key = _deriveKeyPbkdf2(password, salt);
    final iv = enc.IV(Uint8List.fromList(_randomBytes(_ivLength)));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);
    final payload = [...salt, ...iv.bytes, ...encrypted.bytes];
    final mac = Hmac(sha256, key.bytes).convert(payload).bytes;
    return [...payload, ...mac];
  }

  List<int> decryptBytes(List<int> cipherBytes, String password) {
    if (cipherBytes.length <= _saltLength + _ivLength + 32) {
      throw Exception('Invalid encrypted payload');
    }

    final salt = cipherBytes.sublist(0, _saltLength);
    final ivBytes = cipherBytes.sublist(_saltLength, _saltLength + _ivLength);
    final contentBytes = cipherBytes.sublist(
      _saltLength + _ivLength,
      cipherBytes.length - 32,
    );
    final mac = cipherBytes.sublist(cipherBytes.length - 32);

    final key = _deriveKeyPbkdf2(password, salt);
    final payload = cipherBytes.sublist(0, cipherBytes.length - 32);
    final expectedMac = Hmac(sha256, key.bytes).convert(payload).bytes;
    if (!_constantTimeEquals(mac, expectedMac)) {
      throw Exception('Invalid MAC');
    }

    final iv = enc.IV(Uint8List.fromList(ivBytes));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    return encrypter.decryptBytes(
      enc.Encrypted(Uint8List.fromList(contentBytes)),
      iv: iv,
    );
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
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
