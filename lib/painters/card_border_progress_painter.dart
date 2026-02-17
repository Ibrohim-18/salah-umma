import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_theme.dart';

class CardBorderProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final double radius;
  final double strokeWidth;

  CardBorderProgressPainter({
    required this.progress,
    required this.animationValue,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final p = progress.clamp(0.0, 1.0);
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - (inset * 2),
      size.height - (inset * 2),
    );
    if (rect.width <= 0 || rect.height <= 0) return;

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // LAYER 1: BACKGROUND TRACK
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF1A3D63).withAlpha(210);
    canvas.drawRRect(rrect, basePaint);

    final trackGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 1.6
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.accentGold.withAlpha(28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(rrect, trackGlow);

    if (p <= 0.0) return;

    // LAYER 2: PROGRESS GRADIENT
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final totalLength = metric.length;
    final progressLength = totalLength * p;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFD700), // gold
          Color(0xFFFFB020), // amber
          Color(0xFFFF6B00), // orange
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPath = p >= 0.999 ? (Path()..addRRect(rrect)) : metric.extractPath(0, progressLength);
    canvas.drawPath(progressPath, progressPaint);

    // LAYER 3: RUNNING FIRE SPARK
    final sparkPosition = progressLength * animationValue;
    final sparkLength = 60.0;
    final sparkStart = math.max(0.0, sparkPosition - sparkLength / 2);
    final sparkEnd = math.min(progressLength, sparkPosition + sparkLength / 2);

    if (sparkEnd > sparkStart) {
      final sparkPath = metric.extractPath(sparkStart, sparkEnd);

      final sparkPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFFFD700).withAlpha(80),
            const Color(0xFFFFD700),
            const Color(0xFFFF6B00),
            const Color(0xFFFFD700),
            const Color(0xFFFFD700).withAlpha(80),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0],
        ).createShader(Rect.fromLTWH(sparkStart, 0, sparkEnd - sparkStart, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(sparkPath, sparkPaint);

      // LAYER 4: SPARK GLOW
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withAlpha(160)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawPath(sparkPath, glowPaint);

      // Extra bright center point
      final sparkCenter = metric.getTangentForOffset(sparkPosition);
      if (sparkCenter != null) {
        final centerGlow = Paint()
          ..color = const Color(0xFFFFFFFF).withAlpha(200)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(sparkCenter.position, strokeWidth * 0.7, centerGlow);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CardBorderProgressPainter oldDelegate) {
    return (oldDelegate.progress - progress).abs() > 0.001 ||
        (oldDelegate.animationValue - animationValue).abs() > 0.001 ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
