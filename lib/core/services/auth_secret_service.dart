import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/services/security_service.dart';
import 'package:xolo/data/local/database.dart';

class AuthSecretService {
  AuthSecretService(this._securityService);

  static const _prefix = 'secure_auth_ref:';
  static const _storagePrefix = 'auth_secret:';

  final SecurityService _securityService;

  bool isReference(String? value) {
    return value != null && value.startsWith(_prefix);
  }

  String? extractReferenceKey(String? value) {
    if (!isReference(value)) return null;
    return value!.substring(_prefix.length);
  }

  Future<String?> storeAuthData(String? authDataJson) async {
    if (authDataJson == null || authDataJson.isEmpty) return null;
    final key = _buildStorageKey(authDataJson);
    await _securityService.saveSecure(_storagePrefix + key, authDataJson);
    return _prefix + key;
  }

  Future<String?> resolveAuthData(String? value) async {
    if (value == null || value.isEmpty) return null;
    final key = extractReferenceKey(value);
    if (key == null) {
      return value;
    }
    return _securityService.readSecure(_storagePrefix + key);
  }

  Future<void> deleteAuthData(String? value) async {
    final key = extractReferenceKey(value);
    if (key == null) return;
    await _securityService.deleteSecure(_storagePrefix + key);
  }

  Future<int> migrateCollectionAuthData(AppDatabase db) async {
    final legacyCollections = await db.getCollectionsWithPlainAuthData();
    var migrated = 0;
    for (final collection in legacyCollections) {
      final legacy = collection.authData;
      if (legacy == null || legacy.isEmpty || isReference(legacy)) {
        continue;
      }
      final newRef = await storeAuthData(legacy);
      await db.updateCollectionAuthDataById(collection.id, newRef);
      migrated++;
    }
    return migrated;
  }

  String _buildStorageKey(String rawJson) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final hash = base64Url.encode(utf8.encode(rawJson)).substring(0, 12);
    return '$timestamp-$hash';
  }
}

final authSecretServiceProvider = Provider<AuthSecretService>((ref) {
  return AuthSecretService(ref.read(securityServiceProvider));
});
