import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LiquidNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LiquidNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<LiquidNavBar> createState() => _LiquidNavBarState();
}

class _LiquidNavBarState extends State<LiquidNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.currentIndex.toDouble(),
    );
  }

  @override
  void didUpdateWidget(covariant LiquidNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.animateTo(
        widget.currentIndex.toDouble(),
        curve: Curves.easeOutQuad,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final activeColor = colorScheme.primary;

    final items = [
      (icon: Icons.folder_open_outlined, label: 'Projects'),
      (icon: Icons.history, label: 'History'),
      (icon: Icons.add, label: 'New'),
      (icon: Icons.cloud_outlined, label: 'Sync'),
      (icon: Icons.settings_outlined, label: 'Settings'),
    ];

    const double barHeight = 84.0;
    const double fillHeight = 64.0;
    const double bubbleRadius = 24.0;
    const double gap = 6.0;

    return SizedBox(
      height: barHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final width = MediaQuery.of(context).size.width;
          final itemWidth = width / items.length;
          final centerX = (_controller.value * itemWidth) + (itemWidth / 2);

          // Calculate Bubble Position
          // Center of bubble aligns with TOP edge of fillHeight (which is at bottom:fillHeight or top:barHeight-fillHeight)
          // Wait, 'bottom: 0' means fill is at bottom.
          // Top of fill is at (barHeight - fillHeight)? No.
          // height of stack is 84. height of fill is 64.
          // fill is Positioned(bottom:0). So fill occupies Y=[20..84].
          // We want bubble center at Y=20.
          // Bubble size 48x48. Radius 24.
          // Bubble Top = 20 - 24 = -4. Bubble Bottom = 84 - (-4) = 88?
          // Let's use 'bottom'.
          // Center Y from bottom = 64.
          // Bubble Bottom = 64 - 24 = 40.

          final bubbleBottom = fillHeight - bubbleRadius;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // 1. Bar Background + Notch
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: fillHeight,
                child: CustomPaint(
                  painter: _PerfectNotchPainter(
                    position: _controller.value,
                    itemsCount: items.length,
                    color: bgColor,
                    bubbleRadius: bubbleRadius,
                    gap: gap,
                  ),
                ),
              ),

              // 2. Clickable Icons
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: fillHeight,
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(items.length, (index) {
                      final dist = (index - _controller.value).abs();
                      final opacity = (dist - 0.4).clamp(0.0, 1.0);

                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onTap(index);
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Opacity(
                            opacity: opacity,
                            child: Icon(
                              items[index].icon,
                              color: isDark ? Colors.white54 : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // 3. Floating Bubble
              Positioned(
                left: centerX - bubbleRadius,
                bottom: bubbleBottom,
                child: IgnorePointer(
                  child: Container(
                    width: bubbleRadius * 2,
                    height: bubbleRadius * 2,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      items[widget.currentIndex].icon,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PerfectNotchPainter extends CustomPainter {
  final double position;
  final int itemsCount;
  final Color color;
  final double bubbleRadius;
  final double gap;

  _PerfectNotchPainter({
    required this.position,
    required this.itemsCount,
    required this.color,
    required this.bubbleRadius,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Full Rectangle
    final rectPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 2. Notch Circle
    final itemWidth = size.width / itemsCount;
    final centerX = (position * itemWidth) + (itemWidth / 2);

    // Notch center is on the TOP Edge (Y=0).
    final notchCenter = Offset(centerX, 0);
    final notchRadius = bubbleRadius + gap;

    // Use Oval (Circle) for perfect cutout
    final notchPath = Path()
      ..addOval(Rect.fromCircle(center: notchCenter, radius: notchRadius));

    // 3. Difference
    final barPath = Path.combine(PathOperation.difference, rectPath, notchPath);

    canvas.drawShadow(barPath, Colors.black.withOpacity(0.15), 4.0, true);
    canvas.drawPath(barPath, paint);
  }

  @override
  bool shouldRepaint(covariant _PerfectNotchPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.color != color ||
        oldDelegate.gap != gap;
  }
}
