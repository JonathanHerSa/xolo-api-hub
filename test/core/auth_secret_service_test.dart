import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/services/auth_secret_service.dart';
import 'package:xolo/core/services/security_service.dart';

class _InMemorySecurityService extends SecurityService {
  final Map<String, String> _store = {};

  @override
  Future<void> saveSecure(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> readSecure(String key) async {
    return _store[key];
  }

  @override
  Future<void> deleteSecure(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _store.clear();
  }
}

void main() {
  group('AuthSecretService', () {
    test('stores auth data and resolves from reference', () async {
      final security = _InMemorySecurityService();
      final service = AuthSecretService(security);

      const raw = '{"token":"abc123"}';
      final ref = await service.storeAuthData(raw);
      final resolved = await service.resolveAuthData(ref);

      expect(ref, isNotNull);
      expect(service.isReference(ref), isTrue);
      expect(resolved, raw);
    });
  });
}
