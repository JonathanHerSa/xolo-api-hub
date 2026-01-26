import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeTabProvider = NotifierProvider<HomeTabNotifier, int>(
  HomeTabNotifier.new,
);

class HomeTabNotifier extends Notifier<int> {
  @override
  int build() => 2; // Default to Composer (Index 2)

  void setIndex(int index) {
    state = index;
  }
}
