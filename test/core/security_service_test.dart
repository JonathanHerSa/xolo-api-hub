import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/services/security_service.dart';

void main() {
  group('SecurityService', () {
    late SecurityService service;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      service = SecurityService();
    });

    test('saveSecure and readSecure round-trip', () async {
      await service.saveSecure('api_key', 'secret-value');
      expect(await service.readSecure('api_key'), 'secret-value');
    });

    test('readSecure returns null for missing key', () async {
      expect(await service.readSecure('missing'), isNull);
    });

    test('deleteSecure removes a key', () async {
      await service.saveSecure('temp', 'v');
      await service.deleteSecure('temp');
      expect(await service.readSecure('temp'), isNull);
    });

    test('clearAll removes all stored values', () async {
      await service.saveSecure('a', '1');
      await service.saveSecure('b', '2');
      await service.clearAll();
      expect(await service.readSecure('a'), isNull);
      expect(await service.readSecure('b'), isNull);
    });
  });
}
