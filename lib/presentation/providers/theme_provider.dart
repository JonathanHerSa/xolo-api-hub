import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_providers.dart';

// Key para guardar en AppSettings
const String kThemeColorKey = 'theme_primary_color';
const String kThemeModeKey = 'theme_mode';

/// Provider para el color primario (Accent Color)
final themeColorProvider = NotifierProvider<ThemeColorNotifier, int>(() {
  return ThemeColorNotifier();
});

class ThemeColorNotifier extends Notifier<int> {
  // Color por defecto: Indigo (0xFF6366F1)
  static const int defaultColor = 0xFF6366F1;

  @override
  int build() {
    // Inicializar con default y cargar asíncronamente
    _loadColor();
    return defaultColor;
  }

  Future<void> _loadColor() async {
    final db = ref.read(databaseProvider);
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
    final db = ref.read(databaseProvider);
    await db.setSetting(kThemeColorKey, colorValue.toString());
  }
}
