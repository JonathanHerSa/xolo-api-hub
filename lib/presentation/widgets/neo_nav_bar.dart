import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NeoNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NeoNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      (
        index: 0,
        iconOut: Icons.folder_open_outlined,
        iconIn: Icons.folder_rounded,
        label: 'Projects',
      ),
      (
        index: 1,
        iconOut: Icons.history_outlined,
        iconIn: Icons.history_rounded,
        label: 'History',
      ),
      (
        index: 2,
        iconOut: Icons.add_circle_outline_rounded,
        iconIn: Icons.add_circle_rounded,
        label: 'New',
      ),
      (
        index: 3,
        iconOut: Icons.cloud_outlined,
        iconIn: Icons.cloud_rounded,
        label: 'Sync',
      ),
      (
        index: 4,
        iconOut: Icons.settings_outlined,
        iconIn: Icons.settings_rounded,
        label: 'Settings',
      ),
    ];

    return Container(
      height: 80, // Fixed height area
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ), // Remove vertical padding to align coordinate systems
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.9), // Subtle scrim
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final totalHeight = constraints.maxHeight;
          final itemWidth = totalWidth / items.length;

          // Calculate Pill Position and Width
          // We want the pill to center on the item.
          // Let's say we want a pill that expands for text.
          // BUT resizing pills cause "jumps" if adjacent items don't move smoothly.
          // For MAX FLUIDITY: Sliding pill of fixed width OR smoothly interpolated width.
          // Let's do: Sliding Pill (Capsule). Text fades in.

          // Pill Width: Large enough for text?
          // Let's try a dynamic width pill that centers itself.
          // Actually, let's use AnimatedAlign with a fraction.

          // Pill Dimensions
          const pillHeight = 44.0;
          final pillTop = (totalHeight - pillHeight) / 2;

          return Stack(
            children: [
              // 1. Sliding Pill Background
              // 1. Sliding Pill Background
              AnimatedPositioned(
                duration: const Duration(
                  milliseconds: 600,
                ), // Slower, more fluid
                curve: Curves.easeInOutCubicEmphasized,
                left:
                    currentIndex * itemWidth +
                    (itemWidth - (itemWidth * 0.8)) /
                        2, // Center pill in the slot
                top: pillTop, // Dynamic vertical centering
                child: Container(
                  width: itemWidth * 0.8,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Icons Row
              Row(
                children: items.map((item) {
                  final isSelected = currentIndex == item.index;

                  // User requested White for selected state
                  final activeFg = Colors.white;
                  final inactiveFg = isDark ? Colors.white38 : Colors.black45;

                  return SizedBox(
                    width: itemWidth,
                    height: 80, // Full height hit area
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(item.index);
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Center(
                        child: AnimatedScale(
                          scale: isSelected ? 1.0 : 0.9,
                          duration: const Duration(
                            milliseconds: 400,
                          ), // Slower scale to match slide
                          curve: Curves.easeOut,
                          child: Icon(
                            isSelected ? item.iconIn : item.iconOut,
                            color: isSelected ? activeFg : inactiveFg,
                            size: 28, // Slightly larger icons since no text
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Custom Spring for organic feel
const spring = SpringCurve();

class SpringCurve extends Curve {
  final double a;
  final double w;

  const SpringCurve({this.a = 0.15, this.w = 12}); // Softer spring

  @override
  double transformInternal(double t) {
    return (1 - math.exp(-t * 6) * math.cos(t * w)).clamp(0.0, 1.0);
  }
}
