import 'package:flutter/material.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';

/// Underline section tabs — Hoppscotch / Insomnia style.
class RequestSectionTabs extends StatelessWidget {
  const RequestSectionTabs({
    super.key,
    required this.controller,
    required this.labels,
    this.trailing,
    this.statusCode,
  });

  final TabController controller;
  final List<String> labels;
  final Widget? trailing;
  final int? statusCode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: XoloLayout.sectionTabHeight,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.8),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: List.generate(labels.length, (index) {
                      final selected = controller.index == index;
                      final isResponse = index == labels.length - 1;

                      return InkWell(
                        onTap: () => controller.animateTo(index),
                        child: Container(
                          height: XoloLayout.sectionTabHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: selected
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                labels[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: selected
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurfaceVariant,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              if (isResponse && statusCode != null) ...[
                                const SizedBox(width: 8),
                                _StatusDot(statusCode: statusCode!),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: trailing,
                ),
            ],
          ),
        );
      },
    );
  }

  static List<String> labelsFor(AppLocalizations l10n) => [
    l10n.tabParams,
    l10n.tabAuth,
    l10n.tabHeaders,
    l10n.tabBody,
    l10n.tabScripts,
    l10n.tabResponse,
  ];
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.statusCode});

  final int statusCode;

  @override
  Widget build(BuildContext context) {
    final ok = statusCode >= 200 && statusCode < 300;
    final color = ok ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: XoloRadius.sm,
      ),
      child: Text(
        '$statusCode',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
