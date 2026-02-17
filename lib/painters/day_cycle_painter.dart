import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class DayCyclePainter extends CustomPainter {
  const DayCyclePainter({
    required this.scale,
    required this.baselineY,
    required this.fajrPoint,
    required this.sunrisePoint,
    required this.controlPoint,
    required this.maghribPoint,
    required this.ishaPoint,
    required this.sunPoint,
  });

  final double scale;
  final double baselineY;
  final Offset fajrPoint;
  final Offset sunrisePoint;
  final Offset controlPoint;
  final Offset maghribPoint;
  final Offset ishaPoint;
  final Offset sunPoint;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Atmospheric Dunes (Layered)
    final backDunePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, baselineY + (10 * scale))
      ..quadraticBezierTo(size.width * 0.35, baselineY - (2 * scale), size.width * 0.6, baselineY + (12 * scale))
      ..quadraticBezierTo(size.width * 0.85, baselineY + (22 * scale), size.width, baselineY + (8 * scale))
      ..lineTo(size.width, size.height)
      ..close();

    final backDunePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1A1410).withAlpha(50),
          const Color(0xFF0A0A0A).withAlpha(180),
        ],
      ).createShader(Rect.fromLTWH(0, baselineY - 10, size.width, size.height - baselineY + 10));
    canvas.drawPath(backDunePath, backDunePaint);

    final frontDunePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, baselineY + (6 * scale))
      ..quadraticBezierTo(size.width * 0.25, baselineY - (6 * scale), size.width * 0.5, baselineY + (4 * scale))
      ..quadraticBezierTo(size.width * 0.75, baselineY + (14 * scale), size.width, baselineY + (2 * scale))
      ..lineTo(size.width, size.height)
      ..close();

    final frontDunePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1C1814).withAlpha(100),
          const Color(0xFF080808).withAlpha(220),
        ],
      ).createShader(Rect.fromLTWH(0, baselineY - 10, size.width, size.height - baselineY + 10));
    canvas.drawPath(frontDunePath, frontDunePaint);

    // Rim Lighting on Dunes
    final rimPaint = Paint()
      ..color = AppTheme.accentGold.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * scale
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 * scale);
    canvas.drawPath(frontDunePath, rimPaint);

    // 2. Glowing Horizon Line
    final groundPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withAlpha(0),
          Colors.white.withAlpha(20),
          Colors.white.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, sunrisePoint.dy, size.width, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale;
    canvas.drawLine(Offset(0, sunrisePoint.dy), Offset(size.width, sunrisePoint.dy), groundPaint);

    // 3. Orbital Path (Full Continuous Trail)
    final fullPath = Path()
      ..moveTo(fajrPoint.dx - (10 * scale), fajrPoint.dy + (4 * scale)) // Vanishing start
      ..cubicTo(
        fajrPoint.dx,
        fajrPoint.dy + (2 * scale),
        (fajrPoint.dx + sunrisePoint.dx) * 0.5,
        sunrisePoint.dy + (6 * scale),
        sunrisePoint.dx,
        sunrisePoint.dy,
      )
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, maghribPoint.dx, maghribPoint.dy)
      ..cubicTo(
        (maghribPoint.dx + ishaPoint.dx) * 0.5,
        maghribPoint.dy + (6 * scale),
        ishaPoint.dx,
        ishaPoint.dy + (2 * scale),
        ishaPoint.dx + (10 * scale),
        ishaPoint.dy + (4 * scale), // Vanishing end
      );

    // Multistage Arc Glow (Apply to full path)
    final wideGlow = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFF6B00).withAlpha(0),
          const Color(0xFFFF6B00).withAlpha(15),
          const Color(0xFFFF6B00).withAlpha(15),
          const Color(0xFFFF6B00).withAlpha(0),
        ],
        stops: const [0.0, 0.1, 0.9, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * scale
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * scale);
    canvas.drawPath(fullPath, wideGlow);

    final midGlow = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.accentGold.withAlpha(0),
          AppTheme.accentGold.withAlpha(35),
          AppTheme.accentGold.withAlpha(35),
          AppTheme.accentGold.withAlpha(0),
        ],
        stops: const [0.0, 0.1, 0.9, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * scale
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * scale);
    canvas.drawPath(fullPath, midGlow);

    final arcPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFFFFB020).withAlpha(0),
          const Color(0xFFFFB020).withAlpha(180),
          AppTheme.accentGold,
          const Color(0xFFFFB020).withAlpha(180),
          const Color(0xFFFFB020).withAlpha(0),
        ],
        stops: const [0.0, 0.1, 0.5, 0.9, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(fullPath, arcPaint);

    // 5. Cinematic Sun Indicator
    // Star Spikes (Diffraction)
    final spikePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withAlpha(180), Colors.white.withAlpha(0)],
      ).createShader(Rect.fromCircle(center: sunPoint, radius: 25 * scale))
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromCenter(center: sunPoint, width: 45 * scale, height: 0.8 * scale), spikePaint);
    canvas.drawRect(Rect.fromCenter(center: sunPoint, width: 0.8 * scale, height: 45 * scale), spikePaint);

    // Core Glows
    canvas.drawCircle(sunPoint, 16 * scale, Paint()
      ..shader = RadialGradient(
        colors: [AppTheme.accentGold.withAlpha(80), Colors.transparent],
      ).createShader(Rect.fromCircle(center: sunPoint, radius: 16 * scale)));

    canvas.drawCircle(sunPoint, 5 * scale, Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, AppTheme.accentGold],
      ).createShader(Rect.fromCircle(center: sunPoint, radius: 5 * scale)));
  }

  @override
  bool shouldRepaint(covariant DayCyclePainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.baselineY != baselineY ||
        oldDelegate.fajrPoint != fajrPoint ||
        oldDelegate.sunrisePoint != sunrisePoint ||
        oldDelegate.controlPoint != controlPoint ||
        oldDelegate.maghribPoint != maghribPoint ||
        oldDelegate.ishaPoint != ishaPoint ||
        oldDelegate.sunPoint != sunPoint;
  }
}
