import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Decorative light-blue cloud shapes behind the splash illustration.
class SplashClouds extends StatelessWidget {
  const SplashClouds({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SplashCloudsPainter(), size: Size.infinite);
  }
}

class _SplashCloudsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.splashCloud
      ..style = PaintingStyle.fill;

    _drawCloud(
      canvas,
      paint,
      Offset(size.width * 0.15, size.height * 0.55),
      70,
    );
    _drawCloud(
      canvas,
      paint,
      Offset(size.width * 0.55, size.height * 0.68),
      90,
    );
    _drawCloud(
      canvas,
      paint,
      Offset(size.width * 0.82, size.height * 0.48),
      60,
    );
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double radius) {
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.65, center.dy + radius * 0.1),
      radius * 0.72,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.7, center.dy + radius * 0.15),
      radius * 0.68,
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.35),
        width: radius * 2.4,
        height: radius * 0.9,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
