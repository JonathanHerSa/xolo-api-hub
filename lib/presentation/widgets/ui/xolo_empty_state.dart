import 'package:flutter/material.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';

class XoloEmptyState extends StatelessWidget {
  const XoloEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = iconColor ?? colorScheme.primary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(XoloSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: XoloRadius.lg,
                  border: Border.all(color: accent.withValues(alpha: 0.22)),
                ),
                child: Icon(icon, size: 34, color: accent),
              ),
              const SizedBox(height: XoloSpacing.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: XoloTypography.cardTitle(colorScheme).copyWith(
                  fontSize: 17,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: XoloSpacing.sm),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: XoloTypography.cardSubtitle(colorScheme),
                ),
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: XoloSpacing.xl),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: XoloSpacing.sm,
                  runSpacing: XoloSpacing.sm,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
