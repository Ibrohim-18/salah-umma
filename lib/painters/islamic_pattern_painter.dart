import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Islamic Geometric Pattern - drawn with CustomPainter
/// Creates a repeating star pattern band for the drawer header
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final unitSize = h * 0.8;
    final count = (w / unitSize).ceil() + 1;
    final offsetX = (w - count * unitSize) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (int i = 0; i < count; i++) {
      final cx = offsetX + i * unitSize + unitSize / 2;
      final cy = h / 2;

      // Draw 8-pointed star pattern
      _drawStar(canvas, cx, cy, unitSize * 0.4, 8, paint,
          AppTheme.accentGold.withAlpha(30));
      _drawStar(canvas, cx, cy, unitSize * 0.25, 8, paint,
          const Color(0xFFFFB020).withAlpha(22));

      // Connecting diamonds
      if (i < count - 1) {
        final nextCx = cx + unitSize;
        final midX = (cx + nextCx) / 2;
        paint.color = AppTheme.accentGold.withAlpha(20);
        final diamond = Path()
          ..moveTo(midX, cy - unitSize * 0.2)
          ..lineTo(midX + unitSize * 0.15, cy)
          ..lineTo(midX, cy + unitSize * 0.2)
          ..lineTo(midX - unitSize * 0.15, cy)
          ..close();
        canvas.drawPath(diamond, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double r, int points,
      Paint paint, Color color) {
    paint.color = color;
    final path = Path();
    for (int i = 0; i < points; i++) {
      final angle = (i * math.pi * 2 / points) - math.pi / 2;
      final nextAngle = ((i + 1) * math.pi * 2 / points) - math.pi / 2;
      final innerAngle = angle + math.pi / points;

      final outerX = cx + r * math.cos(angle);
      final outerY = cy + r * math.sin(angle);
      final innerX = cx + r * 0.45 * math.cos(innerAngle);
      final innerY = cy + r * 0.45 * math.sin(innerAngle);
      final nextOuterX = cx + r * math.cos(nextAngle);
      final nextOuterY = cy + r * math.sin(nextAngle);

      if (i == 0) path.moveTo(outerX, outerY);
      path.lineTo(innerX, innerY);
      path.lineTo(nextOuterX, nextOuterY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
