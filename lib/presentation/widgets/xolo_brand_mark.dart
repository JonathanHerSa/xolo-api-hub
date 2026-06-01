import 'package:flutter/material.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/core/theme/xolo_theme_extension.dart';

class XoloBrandMark extends StatelessWidget {
  const XoloBrandMark({
    super.key,
    this.size = 36,
    this.showLabel = true,
    this.subtitle,
    this.compact = false,
  });

  final double size;
  final bool showLabel;
  final String? subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final xoloTheme = XoloThemeExtension.of(context);
    final gradient =
        xoloTheme?.accentGradient ??
        XoloSurfaces.accentGradient(colorScheme.primary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.pets_rounded,
            color: colorScheme.onPrimary,
            size: size * 0.52,
          ),
        ),
        if (showLabel) ...[
          SizedBox(width: compact ? 10 : 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'XOLO',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                    height: 1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
