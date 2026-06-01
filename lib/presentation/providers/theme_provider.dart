import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/presentation/providers/database_providers.dart';

// Key para guardar en AppSettings
const String kThemeColorKey = 'theme_primary_color';
const String kThemeModeKey = 'theme_mode';

/// Provider para el color primario (Accent Color)
final themeColorProvider = NotifierProvider<ThemeColorNotifier, int>(() {
  return ThemeColorNotifier();
});

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeColorNotifier extends Notifier<int> {
  // Color por defecto: azul sistema
  static const int defaultColor = 0xFF0A84FF;

  @override
  int build() {
    // Inicializar con default y cargar asíncronamente
    _loadColor();
    return defaultColor;
  }

  Future<void> _loadColor() async {
    final db = ref.read(xoloRepositoryProvider);
    final colorStr = await db.getSetting(kThemeColorKey);
    if (colorStr != null) {
      final value = int.tryParse(colorStr);
      if (value != null) {
        state = value;
      }
    }
  }

  Future<void> setColor(int colorValue) async {
    state = colorValue;
    final db = ref.read(xoloRepositoryProvider);
    await db.setSetting(kThemeColorKey, colorValue.toString());
  }
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadMode();
    return ThemeMode.dark;
  }

  Future<void> _loadMode() async {
    final db = ref.read(xoloRepositoryProvider);
    final modeStr = await db.getSetting(kThemeModeKey);
    if (modeStr == null) return;
    state = _fromString(modeStr);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final db = ref.read(xoloRepositoryProvider);
    await db.setSetting(kThemeModeKey, mode.name);
  }

  ThemeMode _fromString(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }
}
