import 'package:flutter/material.dart';

class FloatingNotchBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNotchBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF1E1E1E) // Dark gray
        : Colors.white;

    final activeColor = colorScheme.primary;
    final inactiveColor = isDark ? Colors.white54 : Colors.grey;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background with Notch
          CustomPaint(
            size: const Size(double.infinity, 70),
            painter: NotchPainter(color: bgColor),
          ),

          // Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(
                0,
                Icons.folder_open_outlined,
                Icons.folder_open,
                activeColor,
                inactiveColor,
              ),
              _buildItem(
                1,
                Icons.history,
                Icons.history,
                activeColor,
                inactiveColor,
              ),
              const SizedBox(width: 60), // Space for FAB
              _buildItem(
                3,
                Icons.cloud_outlined,
                Icons.cloud,
                activeColor,
                inactiveColor,
              ), // Index 3 is Sync now
              _buildItem(
                4,
                Icons.settings_outlined,
                Icons.settings,
                activeColor,
                inactiveColor,
              ), // Index 4 is Settings
            ],
          ),

          // Center Floating Button
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: () => onTap(2), // Center Index is 2 (Composer)
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(Icons.edit, color: colorScheme.onPrimary, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    int index,
    IconData icon,
    IconData activeIcon,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isActive = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            // Dot Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotchPainter extends CustomPainter {
  final Color color;

  NotchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const cornerRadius = 24.0;
    const notchRadius = 40.0; // Width of notch curve
    final center = size.width / 2;

    path.moveTo(cornerRadius, 0);

    // Left Line to Notch Start
    path.lineTo(center - notchRadius - 10, 0);

    // Left Smooth Curve
    path.quadraticBezierTo(
      center - notchRadius,
      0,
      center - notchRadius + 10,
      20, // Downwards
    );

    // Bottom Curve (Notch bottom)
    path.arcToPoint(
      Offset(center + notchRadius - 10, 20),
      radius: const Radius.circular(30),
      clockwise: false,
    );

    // Right Smooth Curve
    path.quadraticBezierTo(
      center + notchRadius,
      0,
      center + notchRadius + 10,
      0, // Upwards back to top
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    path.close();
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.1), 5.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
