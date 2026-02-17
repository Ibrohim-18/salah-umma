import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../providers/user_provider.dart';
import '../services/qibla_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/cosmic_background.dart';
import '../constants/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  double _heading = 0;
  double _qiblaDirection = 0;
  bool _isAligned = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _initQibla();
    _listenToCompass();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
      final heading = atan2(event.y, event.x) * (180 / pi);
      final normalizedHeading = (heading + 360) % 360;

      setState(() {
        _heading = normalizedHeading;
        final wasAligned = _isAligned;
        _isAligned = QiblaService.isPointingToQibla(
          qiblaDirection: _qiblaDirection,
          deviceHeading: _heading,
        );

        if (_isAligned && !wasAligned) {
          HapticFeedback.heavyImpact();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    // Back Button
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    final double scaleFactor = user?.uiScale ?? 1.0;
    final buttonPadding = (isCompact ? 10 : isMedium ? 11 : 12) * scaleFactor;
    final buttonRadius = (isCompact ? 10 : 12) * scaleFactor;
    final iconSize = (isCompact ? 20 : isMedium ? 21 : 22) * scaleFactor;
    final topPosition = (isCompact ? 12 : 16) * scaleFactor;
    final leftPosition = (isCompact ? 12 : 16) * scaleFactor;
    
    final backButton = Positioned(
      top: topPosition,
      left: leftPosition,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(buttonPadding),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(buttonRadius),
              border: Border.all(
                color: Colors.white.withAlpha(20),
                width: isCompact ? 0.8 : 1.0,
              ),
            ),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );

    if (user?.latitude == null || user?.longitude == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            backButton,
            Center(
              child: GlassContainer(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_disabled_rounded, size: 64, color: Colors.white.withAlpha(150)),
                    const SizedBox(height: 24),
                    const Text(
                      'LOCATION NEEDED',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please enable location to align with the Qibla.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 32),
                     GestureDetector(
                      onTap: () => userProvider.getCurrentLocation(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentGold.withAlpha(100)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGold.withAlpha(40),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.my_location, color: AppTheme.accentGold),
                            SizedBox(width: 12),
                            Text(
                              'DETECT LOCATION',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final distance = QiblaService.calculateDistanceToKaaba(
      userLatitude: user!.latitude!,
      userLongitude: user.longitude!,
    );

    final angle = (_qiblaDirection - _heading) * (pi / 180);


    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(user.uiScale),
      ),
      child: CosmicBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            alignment: Alignment.center,
            children: [
            backButton,

            // HUD Layout
            Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Stats
              // Top Stats with Glass Effect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHudStat('DISTANCE', '${distance.toStringAsFixed(0)} km'),
                  const SizedBox(width: 12),
                  _buildHudStat('HEADING', '${_heading.toStringAsFixed(0)}°'),
                ],
              ),
              
              const SizedBox(height: 60),

              // THE COMPASS DRAWING
              SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Glow
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                            BoxShadow(
                                color: AppTheme.accentGold.withAlpha(30),
                                blurRadius: 60,
                                spreadRadius: -10,
                            ),
                        ],
                      ),
                    ),
                    // Outer Ring (Static)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(20), width: 1.5),
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withAlpha(5),
                          ],
                          stops: const [0.8, 1.0],
                        ),
                      ),
                    ),
                    
                    // Rotating Compass Dial
                    Transform.rotate(
                      angle: -_heading * (pi / 180),
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(300, 300),
                            painter: PremiumCompassPainter(),
                          );
                        },
                      ),
                    ),

                    // Qibla Indicator (The "Target")
                    Transform.rotate(
                      angle: angle,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            // Arrow Pointer
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: _isAligned ? AppTheme.accentGold.withAlpha(30) : Colors.transparent,
                                shape: BoxShape.circle,
                                boxShadow: _isAligned ? [
                                    BoxShadow(
                                        color: AppTheme.accentGold.withAlpha(100),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                    )
                                ] : [],
                            ),
                            child: Icon(
                                Icons.keyboard_arrow_up,
                                size: 36,
                                color: _isAligned ? AppTheme.accentGold : Colors.white.withAlpha(150),
                            ),
                          ),
                          const SizedBox(height: 230), // Push arrow to edge
                        ],
                      ),
                    ),
                    
                    // Center Kaaba Icon / Indicator
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E0E14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isAligned ? AppTheme.accentGold : Colors.white.withAlpha(40),
                          width: 2,
                        ),
                        boxShadow: [
                          if (_isAligned)
                            const BoxShadow(
                              color: AppTheme.accentGold,
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                           BoxShadow(
                              color: Colors.black.withAlpha(100),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: const Icon(Icons.mosque, color: Colors.white, size: 26),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Status Text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isAligned
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withAlpha(20),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppTheme.accentGold.withAlpha(100)),
                        ),
                        child: const Text(
                          'QIBLA ALIGNED',
                          style: TextStyle(
                            color: Color(0xFF00FF9D),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      )
                    : Text(
                        'ROTATE TO FIND QIBLA',
                        style: TextStyle(
                          color: Colors.white.withAlpha(100),
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ],
          ),
          Positioned(top: 0, left: 0, child: backButton),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildHudStat(String label, String value) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      variant: GlassVariant.standard,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withAlpha(120),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'monospace',
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw cardinal ticks
    for (int i = 0; i < 360; i += 2) {
      final isMajor = i % 90 == 0;
      final isMinor = i % 10 == 0;
      
      if (!isMinor) continue;

      final length = isMajor ? 15.0 : 8.0;
      final angle = (i - 90) * pi / 180;
      
      final p1 = Offset(
        center.dx + (radius - length) * cos(angle),
        center.dy + (radius - length) * sin(angle),
      );
      final p2 = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      paint.color = isMajor ? AppTheme.accentGold : Colors.white.withAlpha(50);
      paint.strokeWidth = isMajor ? 2 : 1;
      
      canvas.drawLine(p1, p2, paint);

      // Draw Labels
      if (isMajor) {
        final textPainter = TextPainter(
          textDirection: TextDirection.ltr,
        );
        String label = '';
        if (i == 0) label = 'N';
        if (i == 90) label = 'E';
        if (i == 180) label = 'S';
        if (i == 270) label = 'W';

        textPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            color: AppTheme.accentGold,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [
              BoxShadow(
                color: AppTheme.accentGold.withAlpha(100),
                blurRadius: 10,
              ),
            ],
          ),
        );
        textPainter.layout();
        
        final labelPos = Offset(
          center.dx + (radius - 35) * cos(angle) - textPainter.width / 2,
          center.dy + (radius - 35) * sin(angle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, labelPos);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
