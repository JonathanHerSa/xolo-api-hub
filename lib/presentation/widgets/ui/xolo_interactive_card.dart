import 'package:flutter/material.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';

class XoloInteractiveCard extends StatefulWidget {
  const XoloInteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: XoloSpacing.lg,
      vertical: XoloSpacing.md,
    ),
    this.margin = const EdgeInsets.only(bottom: XoloSpacing.md),
    this.borderRadius = XoloRadius.lg,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;

  @override
  State<XoloInteractiveCard> createState() => _XoloInteractiveCardState();
}

class _XoloInteractiveCardState extends State<XoloInteractiveCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: XoloMotion.fast,
        curve: Curves.easeOut,
        margin: widget.margin,
        decoration: XoloSurfaces.card(
          colorScheme,
          borderRadius: widget.borderRadius,
          hovered: _hovered,
          selected: widget.selected,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius,
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
