import 'package:flutter/material.dart';

/// Theme extension for mono typography.
@immutable
class XoloThemeExtension extends ThemeExtension<XoloThemeExtension> {
  const XoloThemeExtension({required this.mono, required this.monoSmall});

  final TextStyle mono;
  final TextStyle monoSmall;

  static XoloThemeExtension? of(BuildContext context) {
    return Theme.of(context).extension<XoloThemeExtension>();
  }

  @override
  XoloThemeExtension copyWith({TextStyle? mono, TextStyle? monoSmall}) {
    return XoloThemeExtension(
      mono: mono ?? this.mono,
      monoSmall: monoSmall ?? this.monoSmall,
    );
  }

  @override
  XoloThemeExtension lerp(ThemeExtension<XoloThemeExtension>? other, double t) {
    if (other is! XoloThemeExtension) return this;
    return XoloThemeExtension(
      mono: TextStyle.lerp(mono, other.mono, t)!,
      monoSmall: TextStyle.lerp(monoSmall, other.monoSmall, t)!,
    );
  }
}
