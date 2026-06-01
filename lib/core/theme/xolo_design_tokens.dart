import 'package:flutter/material.dart';

/// Shared spacing, radii, motion, and surface helpers for the Xolo design system.
class XoloSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class XoloRadius {
  static const double smValue = 8;
  static const double mdValue = 12;
  static const double lgValue = 16;
  static const double xlValue = 20;
  static const double pillValue = 999;

  static const BorderRadius sm = BorderRadius.all(Radius.circular(smValue));
  static const BorderRadius md = BorderRadius.all(Radius.circular(mdValue));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(lgValue));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(xlValue));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(pillValue));
}

class XoloMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);
  static const Curve standard = Curves.easeOutCubic;
}

class XoloA11y {
  static const double minTouchTarget = 44;
}

class XoloPalette {
  static const Color obsidian = Color(0xFF070809);
  static const Color graphite = Color(0xFF0F1218);
  static const Color slate = Color(0xFF171C26);
  static const Color elevated = Color(0xFF1E2532);
  static const Color border = Color(0xFF2A3344);
  static const Color borderSubtle = Color(0xFF1F2735);

  static const Color textPrimary = Color(0xFFF4F7FB);
  static const Color textSecondary = Color(0xFF9AA7BD);
  static const Color textMuted = Color(0xFF5C677A);

  static const Color ember = Color(0xFFF97316);
  static const Color emberSoft = Color(0xFFFFB067);
  static const Color teal = Color(0xFF2DD4BF);

  static const Color lightCanvas = Color(0xFFF4F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD8E1EC);
}

class XoloSurfaces {
  static BoxDecoration panel(
    ColorScheme colorScheme, {
    BorderRadius borderRadius = XoloRadius.md,
    Color? color,
  }) {
    return BoxDecoration(
      color:
          color ?? colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: borderRadius,
      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.45)),
    );
  }

  static BoxDecoration accentPanel(
    ColorScheme colorScheme, {
    BorderRadius borderRadius = XoloRadius.md,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.primary.withValues(alpha: 0.14),
          colorScheme.primary.withValues(alpha: 0.04),
        ],
      ),
      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
    );
  }

  static LinearGradient appBackground(ColorScheme colorScheme) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colorScheme.surface,
        Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.05),
          colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  static LinearGradient accentGradient(Color primary) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary, Color.lerp(primary, XoloPalette.emberSoft, 0.35)!],
    );
  }

  static List<BoxShadow> floatingShadow({double opacity = 0.28}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: 28,
        offset: const Offset(0, 12),
      ),
    ];
  }
}
