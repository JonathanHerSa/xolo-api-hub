import 'package:flutter/material.dart';

class SphereBottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onComposerTap;

  const SphereBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onComposerTap,
  });

  @override
  State<SphereBottomBar> createState() => _SphereBottomBarState();
}

class _SphereBottomBarState extends State<SphereBottomBar> {
  static const double barHeight = 70.0;
  static const double sphereSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.of(context).size.width;

    // 5 slots: 0, 1, CENTER, 2, 3
    final slotWidth = width / 5;

    double getSpherePosition(int index) {
      if (index == -1) return width / 2;
      int visualIndex = index;
      if (index > 1) visualIndex++;
      return (visualIndex * slotWidth) + (slotWidth / 2);
    }

    final sphereLeft =
        getSpherePosition(widget.currentIndex) - (sphereSize / 2);

    return SizedBox(
      height: barHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            left: sphereLeft,
            bottom: 15,
            child: Container(
              width: sphereSize,
              height: sphereSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.2),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _buildNavItem(0, Icons.folder_open_outlined, 'Projects'),
              _buildNavItem(1, Icons.history, 'History'),
              SizedBox(
                width: slotWidth,
                child: Center(
                  child: GestureDetector(
                    onTap: widget.onComposerTap,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add,
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              _buildNavItem(3, Icons.cloud_outlined, 'Sync'),
              _buildNavItem(4, Icons.settings_outlined, 'Settings'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isSelected = widget.currentIndex == index;
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
