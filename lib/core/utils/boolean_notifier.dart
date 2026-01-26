import 'package:flutter_riverpod/flutter_riverpod.dart';

class BooleanNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
  void toggle() => state = !state;
}
