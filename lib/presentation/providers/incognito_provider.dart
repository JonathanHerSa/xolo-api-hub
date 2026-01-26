import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/boolean_notifier.dart';

/// Tracks if Incognito Mode is enabled.
/// If true, no history should be recorded.
final isIncognitoProvider = NotifierProvider<BooleanNotifier, bool>(
  BooleanNotifier.new,
);
