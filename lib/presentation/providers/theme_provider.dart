import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';

/// Provider para el modo de tema (dark/light)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Provider para saber si está en modo oscuro
final isDarkModeProvider = StateProvider<bool>((ref) {
  return ref.watch(themeModeProvider) == ThemeMode.dark;
});
