import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassDockBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassDockBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      (icon: Icons.folder_open_outlined, label: 'Projects'),
      (icon: Icons.history, label: 'History'),
      (icon: Icons.add_rounded, label: 'New'),
      (icon: Icons.cloud_outlined, label: 'Sync'),
      (icon: Icons.settings_outlined, label: 'Settings'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), // Float from bottom
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30), // Pill Shape
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Heavy Glass Blur
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E).withOpacity(
                      0.70,
                    ) // Dark transparency
                  : Colors.white.withOpacity(0.70), // Light transparency
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1) // Subtle frosted border
                    : Colors.black.withOpacity(0.05),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 25,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final isSelected = currentIndex == index;
                final isCenter = index == 2;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(index);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: _GlassDockItem(
                    icon: items[index].icon,
                    isSelected: isSelected,
                    isCenter: isCenter,
                    activeColor: theme.colorScheme.primary,
                    isDark: isDark,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassDockItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool isCenter;
  final Color activeColor;
  final bool isDark;

  const _GlassDockItem({
    required this.icon,
    required this.isSelected,
    required this.isCenter,
    required this.activeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      width: 60,
      height: 70,
      // Scale effect for selected item
      // Center item is always slightly emphasised? No, standard logic.
      transform: Matrix4.identity()..scale(isSelected ? 1.0 : 0.9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isCenter ? 12 : 8),
            decoration: BoxDecoration(
              // Center Button Highlight (optional)
              color: isCenter && isSelected ? activeColor : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: (isCenter && isSelected)
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.4),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              // If it's the center button and selected, make it white.
              // Else use activeColor if selected, or grey if not.
              color: (isCenter && isSelected)
                  ? Colors.white
                  : (isSelected
                        ? activeColor
                        : (isDark ? Colors.white38 : Colors.grey)),
              size: isCenter ? 28 : 26,
            ),
          ),

          const SizedBox(height: 4),

          // Indicator Dot (VisionOS Style)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            width: isSelected ? 4 : 0, // Appears only when selected
            decoration: BoxDecoration(
              color: isCenter
                  ? Colors.transparent
                  : activeColor, // Don't show dot for center if it has BG
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
