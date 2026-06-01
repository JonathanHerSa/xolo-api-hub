import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/domain/entities/key_value_pair.dart';

void main() {
  group('KeyValuePair', () {
    test('defaults and copyWith', () {
      final pair = KeyValuePair();
      expect(pair.key, isEmpty);
      expect(pair.value, isEmpty);
      expect(pair.isActive, isTrue);

      final updated = pair.copyWith(
        key: 'Authorization',
        value: 'Bearer x',
        isActive: false,
      );
      expect(updated.key, 'Authorization');
      expect(updated.value, 'Bearer x');
      expect(updated.isActive, isFalse);
      expect(pair.key, isEmpty);
    });
  });
}
