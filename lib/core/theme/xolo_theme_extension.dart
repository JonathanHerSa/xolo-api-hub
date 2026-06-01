import 'package:flutter/material.dart';

/// Theme extension for mono typography and accent utilities.
@immutable
class XoloThemeExtension extends ThemeExtension<XoloThemeExtension> {
  const XoloThemeExtension({
    required this.mono,
    required this.monoSmall,
    required this.accentGradient,
  });

  final TextStyle mono;
  final TextStyle monoSmall;
  final LinearGradient accentGradient;

  static XoloThemeExtension? of(BuildContext context) {
    return Theme.of(context).extension<XoloThemeExtension>();
  }

  @override
  XoloThemeExtension copyWith({
    TextStyle? mono,
    TextStyle? monoSmall,
    LinearGradient? accentGradient,
  }) {
    return XoloThemeExtension(
      mono: mono ?? this.mono,
      monoSmall: monoSmall ?? this.monoSmall,
      accentGradient: accentGradient ?? this.accentGradient,
    );
  }

  @override
  XoloThemeExtension lerp(ThemeExtension<XoloThemeExtension>? other, double t) {
    if (other is! XoloThemeExtension) return this;
    return XoloThemeExtension(
      mono: TextStyle.lerp(mono, other.mono, t)!,
      monoSmall: TextStyle.lerp(monoSmall, other.monoSmall, t)!,
      accentGradient:
          LinearGradient.lerp(accentGradient, other.accentGradient, t) ??
          accentGradient,
    );
  }
}
