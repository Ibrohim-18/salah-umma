import 'package:flutter/material.dart';

class TimeOfDayMountainPainter extends CustomPainter {
  final DateTime now;

  TimeOfDayMountainPainter({required this.now});

  int _bucket(DateTime t) {
    final h = t.hour;
    if (h < 5 || h >= 20) return 0; // night
    if (h < 8) return 1; // dawn
    if (h < 17) return 2; // day
    return 3; // sunset
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bucket = _bucket(now);

    late final Color skyTop;
    late final Color skyBottom;
    late final Color haze;
    late final Color mountainBackTop;
    late final Color mountainBackBottom;
    late final Color mountainFrontTop;
    late final Color mountainFrontBottom;
    late final bool showSun;

    switch (bucket) {
      case 1: // dawn
        skyTop = const Color(0xFF355480);
        skyBottom = const Color(0xFF7FA5CB);
        haze = const Color(0xFFE7C69D).withAlpha(72);
        mountainBackTop = const Color(0xFF4A5F79);
        mountainBackBottom = const Color(0xFF33455A);
        mountainFrontTop = const Color(0xFF3A5069);
        mountainFrontBottom = const Color(0xFF2A3B4F);
        showSun = true;
        break;
      case 2: // day
        skyTop = const Color(0xFF4C80B5);
        skyBottom = const Color(0xFF9BC8ED);
        haze = const Color(0xFFFFFFFF).withAlpha(40);
        mountainBackTop = const Color(0xFF4C6380);
        mountainBackBottom = const Color(0xFF334861);
        mountainFrontTop = const Color(0xFF3C546F);
        mountainFrontBottom = const Color(0xFF2C4158);
        showSun = true;
        break;
      case 3: // sunset
        skyTop = const Color(0xFF3B4A78);
        skyBottom = const Color(0xFFC47E68);
        haze = const Color(0xFFFFC58A).withAlpha(86);
        mountainBackTop = const Color(0xFF4F556E);
        mountainBackBottom = const Color(0xFF363D55);
        mountainFrontTop = const Color(0xFF434A63);
        mountainFrontBottom = const Color(0xFF2E364A);
        showSun = true;
        break;
      default: // night
        skyTop = const Color(0xFF112542);
        skyBottom = const Color(0xFF29496B);
        haze = const Color(0xFF7FA8D8).withAlpha(34);
        mountainBackTop = const Color(0xFF3A4E66);
        mountainBackBottom = const Color(0xFF27384D);
        mountainFrontTop = const Color(0xFF2F435B);
        mountainFrontBottom = const Color(0xFF1F3044);
        showSun = false;
        break;
    }

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyTop, skyBottom],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    if (showSun) {
      final dayProgress = ((now.hour + now.minute / 60.0) - 5.0) / 14.0;
      final sunX = (dayProgress.clamp(0.12, 0.88)) * size.width;
      final sunY = size.height * (bucket == 3 ? 0.28 : 0.22);
      final sunPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF7C9).withAlpha(210),
            const Color(0xFFFFE08B).withAlpha(120),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: size.height * 0.18));
      canvas.drawCircle(Offset(sunX, sunY), size.height * 0.18, sunPaint);
    } else {
      final moonCenter = Offset(size.width * 0.78, size.height * 0.2);
      final moonPaint = Paint()..color = const Color(0xFFDDEBFF).withAlpha(210);
      canvas.drawCircle(moonCenter, size.height * 0.045, moonPaint);
      final cutPaint = Paint()..color = skyTop;
      canvas.drawCircle(moonCenter.translate(size.height * 0.02, -size.height * 0.012), size.height * 0.04, cutPaint);

      final starPaint = Paint()..color = Colors.white.withAlpha(170);
      final stars = <Offset>[
        Offset(size.width * 0.13, size.height * 0.17),
        Offset(size.width * 0.27, size.height * 0.1),
        Offset(size.width * 0.42, size.height * 0.14),
        Offset(size.width * 0.6, size.height * 0.09),
        Offset(size.width * 0.88, size.height * 0.12),
      ];
      for (final star in stars) {
        canvas.drawCircle(star, 1.4, starPaint);
      }
    }

    final hazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, haze],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, hazePaint);

    final backMountains = Path()
      ..moveTo(0, size.height * 0.66)
      ..quadraticBezierTo(size.width * 0.18, size.height * 0.55, size.width * 0.36, size.height * 0.69)
      ..quadraticBezierTo(size.width * 0.52, size.height * 0.5, size.width * 0.72, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.88, size.height * 0.61, size.width, size.height * 0.68)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final backPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [mountainBackTop, mountainBackBottom],
      ).createShader(Offset.zero & size);
    canvas.drawPath(backMountains, backPaint);

    final frontMountains = Path()
      ..moveTo(0, size.height * 0.79)
      ..quadraticBezierTo(size.width * 0.12, size.height * 0.67, size.width * 0.28, size.height * 0.82)
      ..quadraticBezierTo(size.width * 0.48, size.height * 0.63, size.width * 0.68, size.height * 0.84)
      ..quadraticBezierTo(size.width * 0.83, size.height * 0.7, size.width, size.height * 0.81)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [mountainFrontTop, mountainFrontBottom],
      ).createShader(Offset.zero & size);
    canvas.drawPath(frontMountains, frontPaint);
  }

  @override
  bool shouldRepaint(covariant TimeOfDayMountainPainter oldDelegate) {
    return _bucket(oldDelegate.now) != _bucket(now);
  }
}
