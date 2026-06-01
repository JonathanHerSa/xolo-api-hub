import 'package:flutter/material.dart';

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

  static const BorderRadius sm = BorderRadius.all(Radius.circular(smValue));
  static const BorderRadius md = BorderRadius.all(Radius.circular(mdValue));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(lgValue));
}

class XoloMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
}

class XoloPalette {
  static const Color black = Color(0xFF000000);
  static const Color base = Color(0xFF0A0A0A);
  static const Color raised = Color(0xFF141414);
  static const Color hover = Color(0xFF1C1C1C);
  static const Color line = Color(0xFF262626);
  static const Color lineSoft = Color(0xFF1A1A1A);

  static const Color text = Color(0xFFFAFAFA);
  static const Color textSoft = Color(0xFFA3A3A3);
  static const Color textMuted = Color(0xFF737373);

  static const Color accent = Color(0xFF10B981);
  static const Color accentHover = Color(0xFF34D399);

  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightLine = Color(0xFFE5E5E5);
}

class XoloLayout {
  static const double railWidth = 72;
  static const double urlBarHeight = 56;
  static const double sectionTabHeight = 48;
  static const double requestTabHeight = 40;
}

class XoloA11y {
  static const double minTouchTarget = 44;
}

class XoloSurfaces {
  static BoxDecoration panel(ColorScheme colorScheme, {BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: borderRadius ?? XoloRadius.lg,
      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.55)),
    );
  }

  static BoxDecoration card(
    ColorScheme colorScheme, {
    BorderRadius? borderRadius,
    bool hovered = false,
    bool selected = false,
  }) {
    final Color bg;
    final Color border;
    if (selected) {
      bg = colorScheme.primary.withValues(alpha: 0.08);
      border = colorScheme.primary.withValues(alpha: 0.45);
    } else if (hovered) {
      bg = colorScheme.surfaceContainerHighest;
      border = colorScheme.outline.withValues(alpha: 0.85);
    } else {
      bg = colorScheme.surfaceContainerHigh;
      border = colorScheme.outlineVariant.withValues(alpha: 0.75);
    }
    return BoxDecoration(
      color: bg,
      borderRadius: borderRadius ?? XoloRadius.lg,
      border: Border.all(color: border),
    );
  }
}

class XoloTypography {
  static TextStyle sectionLabel(ColorScheme colorScheme) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: colorScheme.onSurfaceVariant,
      );

  static TextStyle cardTitle(ColorScheme colorScheme) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: -0.2,
      );

  static TextStyle cardSubtitle(ColorScheme colorScheme) => TextStyle(
        fontSize: 13,
        height: 1.4,
        color: colorScheme.onSurfaceVariant,
      );

  static TextStyle meta(ColorScheme colorScheme) => TextStyle(
        fontSize: 12,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
      );
}
