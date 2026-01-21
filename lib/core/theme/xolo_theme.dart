import 'package:flutter/material.dart';

/// Sistema de temas para Xolo
/// Estilo: Dark Elegant + Vibrant Modern
/// Paleta: Carmesí/Vino

class XoloTheme {
  // ============================================================================
  // COLORES PRIMARIOS - CARMESÍ/VINO
  // ============================================================================

  // Color primario: Carmesí oscuro elegante
  static const Color primary = Color(0xFFB91C1C); // Carmesí
  static const Color primaryLight = Color(0xFFDC2626); // Rojo más claro
  static const Color primaryDark = Color(0xFF991B1B); // Vino oscuro
  static const Color accent = Color(0xFFF87171); // Coral suave

  // ============================================================================
  // COLORES DE MÉTODOS HTTP
  // ============================================================================

  static const Color methodGet = Color(0xFF3B82F6); // Azul
  static const Color methodPost = Color(0xFF22C55E); // Verde
  static const Color methodPut = Color(0xFFF59E0B); // Naranja
  static const Color methodPatch = Color(0xFFA855F7); // Púrpura
  static const Color methodDelete = Color(0xFFEF4444); // Rojo
  static const Color methodHead = Color(0xFF6B7280); // Gris
  static const Color methodOptions = Color(0xFF14B8A6); // Teal

  // Status codes
  static const Color statusSuccess = Color(0xFF22C55E);
  static const Color statusRedirect = Color(0xFFF59E0B);
  static const Color statusClientError = Color(0xFFEF4444);
  static const Color statusServerError = Color(0xFFDC2626);

  /// Obtener color según método HTTP
  static Color getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return methodGet;
      case 'POST':
        return methodPost;
      case 'PUT':
        return methodPut;
      case 'PATCH':
        return methodPatch;
      case 'DELETE':
        return methodDelete;
      case 'HEAD':
        return methodHead;
      case 'OPTIONS':
        return methodOptions;
      default:
        return methodHead;
    }
  }

  /// Obtener color según status code
  static Color getStatusColor(int? statusCode) {
    if (statusCode == null) return methodHead;
    if (statusCode >= 200 && statusCode < 300) return statusSuccess;
    if (statusCode >= 300 && statusCode < 400) return statusRedirect;
    if (statusCode >= 400 && statusCode < 500) return statusClientError;
    return statusServerError;
  }

  // ============================================================================
  // DARK THEME
  // ============================================================================

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',

    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF0A0A0B),
      primary: Color(0xFFB91C1C), // Carmesí
      primaryContainer: Color(0xFF991B1B), // Vino
      secondary: Color(0xFFF87171), // Coral
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFF8E8E93),
      outline: Color(0xFF2A2A2E),
      surfaceContainerHighest: Color(0xFF141416),
      error: Color(0xFFEF4444),
    ),

    scaffoldBackgroundColor: const Color(0xFF0A0A0B),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0A0B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF141416),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2A2A2E), width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A2E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A2E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF6B6B70)),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A2E),
      thickness: 1,
    ),

    tabBarTheme: const TabBarThemeData(
      labelColor: Color(0xFFB91C1C),
      unselectedLabelColor: Color(0xFF8E8E93),
      indicatorColor: Color(0xFFB91C1C),
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB91C1C),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFF87171),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: const Color(0xFF8E8E93)),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF141416),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1E1E22),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF141416),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF0F0F10)),
  );

  // ============================================================================
  // LIGHT THEME
  // ============================================================================

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',

    colorScheme: const ColorScheme.light(
      surface: Color(0xFFFAFAFA),
      primary: Color(0xFFB91C1C), // Carmesí
      primaryContainer: Color(0xFFDC2626),
      secondary: Color(0xFFF87171),
      onSurface: Color(0xFF1A1A1A),
      onSurfaceVariant: Color(0xFF6B6B70),
      outline: Color(0xFFE5E5E5),
      surfaceContainerHighest: Color(0xFFFFFFFF),
      error: Color(0xFFDC2626),
    ),

    scaffoldBackgroundColor: const Color(0xFFFAFAFA),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
        letterSpacing: -0.5,
      ),
      surfaceTintColor: Colors.transparent,
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E5E5),
      thickness: 1,
    ),

    tabBarTheme: const TabBarThemeData(
      labelColor: Color(0xFFB91C1C),
      unselectedLabelColor: Color(0xFF6B6B70),
      indicatorColor: Color(0xFFB91C1C),
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB91C1C),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFB91C1C),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: const Color(0xFF6B6B70)),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1A1A1A),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFFAFAFA)),
  );
}

// ============================================================================
// EXTENSIONES
// ============================================================================

extension XoloColors on BuildContext {
  Color get surfaceColor => Theme.of(this).colorScheme.surfaceContainerHighest;
  Color get borderColor => Theme.of(this).colorScheme.outline;
  Color get secondaryTextColor => Theme.of(this).colorScheme.onSurfaceVariant;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
