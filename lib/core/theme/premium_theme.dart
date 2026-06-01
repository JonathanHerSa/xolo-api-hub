import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/core/theme/xolo_theme_extension.dart';

class XoloPremiumTheme {
  static const Color methodGet = Color(0xFF38BDF8);
  static const Color methodPost = Color(0xFF34D399);
  static const Color methodPut = Color(0xFFFBBF24);
  static const Color methodDelete = Color(0xFFF87171);
  static const Color methodPatch = Color(0xFFC084FC);
  static const Color methodDefault = XoloPalette.textSecondary;

  static ThemeData darkTheme(int primaryColorValue) {
    final primary = Color(primaryColorValue);
    final onPrimary =
        ThemeData.estimateBrightnessForColor(primary) == Brightness.dark
        ? Colors.white
        : Colors.black;
    final accentGradient = XoloSurfaces.accentGradient(primary);
    final mono = GoogleFonts.jetBrainsMono(
      fontSize: 13,
      height: 1.35,
      letterSpacing: 0,
    );
    final monoSmall = mono.copyWith(fontSize: 11);
    final textTheme = _buildTextTheme(Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: XoloPalette.obsidian,
      fontFamily: GoogleFonts.outfit().fontFamily,
      textTheme: textTheme,
      extensions: [
        XoloThemeExtension(
          mono: mono,
          monoSmall: monoSmall,
          accentGradient: accentGradient,
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: XoloPalette.graphite,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: XoloPalette.textSecondary),
        actionsIconTheme: const IconThemeData(color: XoloPalette.textSecondary),
        shape: const Border(
          bottom: BorderSide(color: XoloPalette.borderSubtle, width: 1),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      colorScheme: ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        secondary: XoloPalette.teal,
        onSecondary: XoloPalette.obsidian,
        tertiary: XoloPalette.emberSoft,
        surface: XoloPalette.graphite,
        surfaceContainerLowest: XoloPalette.obsidian,
        surfaceContainerLow: XoloPalette.slate,
        surfaceContainer: XoloPalette.slate,
        surfaceContainerHigh: XoloPalette.elevated,
        surfaceContainerHighest: XoloPalette.elevated,
        onSurface: XoloPalette.textPrimary,
        onSurfaceVariant: XoloPalette.textSecondary,
        outline: XoloPalette.border,
        outlineVariant: XoloPalette.borderSubtle,
        error: methodDelete,
      ),
      cardTheme: CardThemeData(
        color: XoloPalette.slate,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: XoloRadius.lg,
          side: BorderSide(color: XoloPalette.border.withValues(alpha: 0.75)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: XoloPalette.elevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: XoloRadius.md,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: XoloRadius.md,
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: XoloRadius.md,
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.jetBrainsMono(
          color: XoloPalette.textMuted,
          fontSize: 13,
        ),
        labelStyle: GoogleFonts.outfit(
          color: XoloPalette.textSecondary,
          fontSize: 13,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          minimumSize: const Size(44, 44),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: XoloPalette.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
          minimumSize: const Size(44, 44),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: XoloPalette.textPrimary,
          side: BorderSide(color: XoloPalette.border.withValues(alpha: 0.9)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
          minimumSize: const Size(44, 44),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: XoloPalette.elevated,
        shape: RoundedRectangleBorder(
          borderRadius: XoloRadius.lg,
          side: BorderSide(color: XoloPalette.border.withValues(alpha: 0.8)),
        ),
        textStyle: GoogleFonts.outfit(
          color: XoloPalette.textPrimary,
          fontSize: 13,
        ),
        elevation: 12,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: XoloPalette.graphite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: XoloPalette.textSecondary,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: XoloPalette.borderSubtle,
        labelStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: XoloRadius.lg),
      ),
      dividerTheme: const DividerThemeData(
        color: XoloPalette.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
        selectedColor: XoloPalette.textPrimary,
      ),
      iconTheme: const IconThemeData(
        color: XoloPalette.textSecondary,
        size: 20,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: XoloPalette.borderSubtle,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: XoloPalette.elevated,
        contentTextStyle: GoogleFonts.outfit(color: XoloPalette.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: XoloPalette.slate,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: XoloRadius.lg,
          side: BorderSide(color: XoloPalette.border.withValues(alpha: 0.8)),
        ),
        titleTextStyle: GoogleFonts.outfit(
          color: XoloPalette.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  static ThemeData lightTheme(int primaryColorValue) {
    final primary = Color(primaryColorValue);
    final onPrimary =
        ThemeData.estimateBrightnessForColor(primary) == Brightness.dark
        ? Colors.white
        : Colors.black;
    final accentGradient = XoloSurfaces.accentGradient(primary);
    final mono = GoogleFonts.jetBrainsMono(fontSize: 13, height: 1.35);
    final monoSmall = mono.copyWith(fontSize: 11);
    final textTheme = _buildTextTheme(Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: XoloPalette.lightCanvas,
      fontFamily: GoogleFonts.outfit().fontFamily,
      textTheme: textTheme,
      extensions: [
        XoloThemeExtension(
          mono: mono,
          monoSmall: monoSmall,
          accentGradient: accentGradient,
        ),
      ],
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: const Color(0xFF0D9488),
        surface: XoloPalette.lightSurface,
        surfaceContainerHighest: const Color(0xFFE8EEF5),
        onSurface: const Color(0xFF111827),
        onSurfaceVariant: const Color(0xFF5B6472),
        outline: XoloPalette.lightBorder,
        outlineVariant: const Color(0xFFE3E9F1),
        error: methodDelete,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: XoloPalette.lightCanvas,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: XoloPalette.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: XoloRadius.lg,
          side: const BorderSide(color: XoloPalette.lightBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: XoloRadius.md,
          borderSide: const BorderSide(color: XoloPalette.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: XoloRadius.md,
          borderSide: const BorderSide(color: XoloPalette.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: XoloRadius.md,
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.jetBrainsMono(
          color: const Color(0xFF94A3B8),
          fontSize: 13,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
          minimumSize: const Size(44, 44),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: XoloPalette.lightSurface,
        surfaceTintColor: Colors.transparent,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: primary,
        labelStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: XoloPalette.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: XoloRadius.lg),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    return GoogleFonts.outfitTextTheme(base).copyWith(
      headlineLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      bodyLarge: GoogleFonts.outfit(height: 1.45),
      bodyMedium: GoogleFonts.outfit(height: 1.4),
      labelLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
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
        return methodDefault;
    }
  }
}
