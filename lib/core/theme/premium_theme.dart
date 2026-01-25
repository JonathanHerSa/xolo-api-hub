import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class XoloPremiumTheme {
  // Paleta de colores "Zinc" (Fija para el background Dark)
  static const Color _bgDeep = Color(0xFF09090B);
  static const Color _bgSurface = Color(0xFF18181B);
  static const Color _bgElevated = Color(0xFF27272A);
  static const Color _border = Color(0xFF3F3F46);

  // Colores Semánticos (Fijos)
  static const Color methodGet = Color(0xFF3B82F6);
  static const Color methodPost = Color(0xFF10B981);
  static const Color methodPut = Color(0xFFF59E0B);
  static const Color methodDelete = Color(0xFFEF4444);
  static const Color methodPatch = Color(0xFF8B5CF6);

  // Textos
  static const Color _textPrimary = Color(0xFFFAFAFA);
  static const Color _textSecondary = Color(0xFFA1A1AA);
  static const Color _textDisabled = Color(0xFF52525B);

  /// Genera el tema oscuro usando un color primario personalizado
  static ThemeData darkTheme(int primaryColorValue) {
    final primary = Color(primaryColorValue);
    final onPrimary =
        ThemeData.estimateBrightnessForColor(primary) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bgDeep,
      fontFamily: 'Inter',

      // Ajuste de System UI para Edge-to-Edge
      appBarTheme: const AppBarTheme(
        backgroundColor: _bgSurface,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: _textSecondary),
        actionsIconTheme: IconThemeData(color: _textSecondary),
        shape: Border(bottom: BorderSide(color: _border, width: 1)),
        systemOverlayStyle: SystemUiOverlayStyle.light, // Status bar blanca
      ),

      colorScheme: ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        secondary: primary,
        surface: _bgSurface,
        surfaceContainer: _bgElevated,
        surfaceContainerHighest: _bgElevated,
        onSurface: _textPrimary,
        onSurfaceVariant: _textSecondary,
        outline: _border,
        error: methodDelete,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _bgElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: _textDisabled, fontSize: 13),
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 13),
      ),

      // Botones
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textPrimary,
          side: const BorderSide(color: _border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Menus
      popupMenuTheme: PopupMenuThemeData(
        color: _bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _border),
        ),
        textStyle: const TextStyle(color: _textPrimary, fontSize: 13),
        elevation: 8,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: _border,
        thickness: 1,
        space: 1,
      ),

      // ListTiles
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        selectedColor: _textPrimary, // Texto blanco al seleccionar? O Primary?
        // Flutter usa selectedColor para texto e icono.
        // Si usamos primary, queda bien.
        // El background se maneja con 'selectedTileColor' que definimos en widgets a mano o themes.
      ),

      iconTheme: const IconThemeData(color: _textSecondary, size: 20),
    );
  }

  static Color getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return methodGet;
      case 'POST':
        return methodPost;
      case 'PUT':
        return methodPut;
      case 'DELETE':
        return methodDelete;
      case 'PATCH':
        return methodPatch;
      default:
        return _textSecondary;
    }
  }
}
