import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../providers/user_provider.dart';
import '../services/qibla_service.dart';
import '../widgets/glass_container.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _heading = 0;
  double _qiblaDirection = 0;
  bool _isAligned = false;

  @override
  void initState() {
    super.initState();
    _initQibla();
    _listenToCompass();
  }

  void _initQibla() {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user?.latitude != null && user?.longitude != null) {
      _qiblaDirection = QiblaService.calculateQiblaDirection(
        userLatitude: user!.latitude!,
        userLongitude: user.longitude!,
      );
    }
  }

  void _listenToCompass() {
    magnetometerEventStream().listen((MagnetometerEvent event) {
      // Calculate heading from magnetometer
      final heading = atan2(event.y, event.x) * (180 / pi);
      final normalizedHeading = (heading + 360) % 360;

      setState(() {
        _heading = normalizedHeading;
        _isAligned = QiblaService.isPointingToQibla(
          qiblaDirection: _qiblaDirection,
          deviceHeading: _heading,
        );
      });

      // Haptic feedback when aligned
      if (_isAligned) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (user?.latitude == null || user?.longitude == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Qibla Finder'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Location not set',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enable location to find Qibla',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => userProvider.getCurrentLocation(),
                  icon: const Icon(Icons.my_location),
                  label: const Text('Get Location'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final distance = QiblaService.calculateDistanceToKaaba(
      userLatitude: user!.latitude!,
      userLongitude: user.longitude!,
    );

    final angle = (_qiblaDirection - _heading) * (pi / 180);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Qibla Finder'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${distance.toStringAsFixed(0)} km to Kaaba',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    QiblaService.getCompassDirection(_qiblaDirection),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Compass
            SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass background
                  Transform.rotate(
                    angle: -_heading * (pi / 180),
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: CompassPainter(),
                    ),
                  ),
                  // Qibla arrow
                  Transform.rotate(
                    angle: angle,
                    child: Icon(
                      Icons.navigation,
                      size: 100,
                      color: _isAligned ? Colors.greenAccent : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (_isAligned)
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: const Text(
                  '✓ Aligned with Qibla',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw circle
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final x = center.dx + (radius - 30) * sin(angle);
      final y = center.dy - (radius - 30) * cos(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) => false;
}

