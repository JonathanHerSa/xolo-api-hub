import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/core/theme/xolo_theme_extension.dart';

class XoloPremiumTheme {
  static const Color methodGet = Color(0xFF38BDF8);
  static const Color methodPost = Color(0xFF4ADE80);
  static const Color methodPut = Color(0xFFFBBF24);
  static const Color methodDelete = Color(0xFFF87171);
  static const Color methodPatch = Color(0xFFC084FC);
  static const Color methodDefault = XoloPalette.textSoft;

  static ThemeData darkTheme(int primaryColorValue) {
    final primary = const Color(0xFF10B981);
    const onPrimary = Colors.black;
    final mono = GoogleFonts.jetBrainsMono(fontSize: 14, height: 1.35);
    final monoSmall = mono.copyWith(fontSize: 12);
    final textTheme = _textTheme(Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: XoloPalette.black,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: textTheme,
      extensions: [XoloThemeExtension(mono: mono, monoSmall: monoSmall)],
      appBarTheme: AppBarTheme(
        backgroundColor: XoloPalette.black,
        foregroundColor: XoloPalette.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF10B981),
        onPrimary: Colors.black,
        secondary: Color(0xFF10B981),
        surface: XoloPalette.base,
        surfaceContainerLowest: XoloPalette.black,
        surfaceContainerLow: XoloPalette.base,
        surfaceContainer: XoloPalette.raised,
        surfaceContainerHigh: XoloPalette.raised,
        surfaceContainerHighest: XoloPalette.hover,
        onSurface: XoloPalette.text,
        onSurfaceVariant: XoloPalette.textSoft,
        outline: XoloPalette.line,
        outlineVariant: XoloPalette.lineSoft,
        error: methodDelete,
      ),
      dividerColor: XoloPalette.line,
      iconTheme: const IconThemeData(color: XoloPalette.textSoft, size: 22),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          minimumSize: const Size(64, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: XoloPalette.raised,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.jetBrainsMono(
          color: XoloPalette.textMuted,
          fontSize: 14,
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: XoloPalette.raised,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: XoloPalette.raised,
        shape: RoundedRectangleBorder(borderRadius: XoloRadius.lg),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: XoloPalette.hover,
        side: const BorderSide(color: XoloPalette.line),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: XoloPalette.text),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF10B981),
        linearTrackColor: XoloPalette.line,
      ),
    );
  }

  static ThemeData lightTheme(int primaryColorValue) {
    final mono = GoogleFonts.jetBrainsMono(fontSize: 14);
    final textTheme = _textTheme(Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: XoloPalette.lightBg,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: textTheme,
      extensions: [
        XoloThemeExtension(mono: mono, monoSmall: mono.copyWith(fontSize: 12)),
      ],
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF059669),
        onPrimary: Colors.white,
        surface: XoloPalette.lightSurface,
        onSurface: Color(0xFF171717),
        onSurfaceVariant: Color(0xFF525252),
        outline: XoloPalette.lightLine,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF059669),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: XoloRadius.md),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    return GoogleFonts.interTextTheme(base)
        .apply(
          bodyColor: brightness == Brightness.dark
              ? XoloPalette.text
              : const Color(0xFF171717),
          displayColor: brightness == Brightness.dark
              ? XoloPalette.text
              : const Color(0xFF171717),
        )
        .copyWith(
          titleLarge: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          bodyLarge: GoogleFonts.inter(fontSize: 15, height: 1.5),
          bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.45),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
