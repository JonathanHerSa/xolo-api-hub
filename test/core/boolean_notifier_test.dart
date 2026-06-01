import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/utils/boolean_notifier.dart';

class _TestBooleanNotifier extends BooleanNotifier {
  @override
  bool build() => false;
}

final _testBooleanProvider = NotifierProvider<BooleanNotifier, bool>(
  _TestBooleanNotifier.new,
);

void main() {
  group('BooleanNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('set updates state', () {
      final notifier = container.read(_testBooleanProvider.notifier);
      notifier.set(true);
      expect(container.read(_testBooleanProvider), isTrue);
      notifier.set(false);
      expect(container.read(_testBooleanProvider), isFalse);
    });

    test('toggle flips state', () {
      final notifier = container.read(_testBooleanProvider.notifier);
      notifier.toggle();
      expect(container.read(_testBooleanProvider), isTrue);
      notifier.toggle();
      expect(container.read(_testBooleanProvider), isFalse);
    });
  });
}
