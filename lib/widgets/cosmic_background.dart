import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Premium Nebula Background — 2025 Ultra
/// Multi-layered: deep space gradient + animated nebula clouds + subtle star particles
class CosmicBackground extends StatefulWidget {
  final Widget child;
  final String? currentPrayer;

  const CosmicBackground({
    super.key,
    required this.child,
    this.currentPrayer,
  });

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _nebulaFlow;
  late AnimationController _nebulaPulse;
  late AnimationController _starTwinkle;

  @override
  void initState() {
    super.initState();
    _nebulaFlow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _nebulaPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _starTwinkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nebulaFlow.dispose();
    _nebulaPulse.dispose();
    _starTwinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayer = widget.currentPrayer?.toLowerCase();
    final palette = _getPalette(prayer);

    return Stack(
      children: [
        // Layer 1: Deep space gradient
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.5),
              radius: 1.8,
              colors: [
                palette.deepCore,
                palette.midSpace,
                palette.outerVoid,
                Colors.black,
              ],
              stops: const [0.0, 0.3, 0.65, 1.0],
            ),
          ),
        ),

        // Layer 2: Secondary radial for depth
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.6, 0.8),
              radius: 1.2,
              colors: [
                palette.secondaryGlow.withAlpha(35),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),

        // Layer 3: Animated nebula clouds
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_nebulaFlow, _nebulaPulse]),
            builder: (context, _) {
              return CustomPaint(
                painter: _NebulaPainter(
                  flowValue: _nebulaFlow.value,
                  pulseValue: _nebulaPulse.value,
                  palette: palette,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),

        // Layer 4: Star particles
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _starTwinkle,
            builder: (context, _) {
              return CustomPaint(
                painter: _StarFieldPainter(
                  twinkleValue: _starTwinkle.value,
                  accentColor: palette.starTint,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),

        // Layer 5: Top vignette for depth
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Colors.black.withAlpha(90),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Content
        widget.child,
      ],
    );
  }

  _NebulaPalette _getPalette(String? prayer) {
    switch (prayer) {
      case 'fajr':
        return _NebulaPalette(
          deepCore: const Color(0xFF0A1832),
          midSpace: const Color(0xFF0D1F3C),
          outerVoid: const Color(0xFF040B18),
          primaryNebula: const Color(0xFF4F6D8F),
          secondaryNebula: const Color(0xFF7EB5E0),
          tertiaryNebula: const Color(0xFF2A5A7A),
          secondaryGlow: const Color(0xFF5C84B5),
          starTint: const Color(0xFF7EB5E0),
        );
      case 'dhuhr':
        return _NebulaPalette(
          deepCore: const Color(0xFF12100A),
          midSpace: const Color(0xFF1A1508),
          outerVoid: const Color(0xFF080604),
          primaryNebula: const Color(0xFFD4A052),
          secondaryNebula: const Color(0xFF8B6914),
          tertiaryNebula: const Color(0xFF6B5B3A),
          secondaryGlow: const Color(0xFFB8860B),
          starTint: const Color(0xFFF2CE6B),
        );
      case 'asr':
        return _NebulaPalette(
          deepCore: const Color(0xFF140E08),
          midSpace: const Color(0xFF1E140A),
          outerVoid: const Color(0xFF0A0705),
          primaryNebula: const Color(0xFFE08A4A),
          secondaryNebula: const Color(0xFFC46A30),
          tertiaryNebula: const Color(0xFF8B5CF6),
          secondaryGlow: const Color(0xFFD97706),
          starTint: const Color(0xFFF5B07A),
        );
      case 'maghrib':
        return _NebulaPalette(
          deepCore: const Color(0xFF140810),
          midSpace: const Color(0xFF200D18),
          outerVoid: const Color(0xFF0A050A),
          primaryNebula: const Color(0xFFD35E7A),
          secondaryNebula: const Color(0xFF8B3A5E),
          tertiaryNebula: const Color(0xFFE08A4A),
          secondaryGlow: const Color(0xFFA8446A),
          starTint: const Color(0xFFF28B9E),
        );
      default: // isha
        return _NebulaPalette(
          deepCore: const Color(0xFF030312),
          midSpace: const Color(0xFF08081E),
          outerVoid: const Color(0xFF010108),
          primaryNebula: const Color(0xFF00D9FF),
          secondaryNebula: const Color(0xFF8B5CF6),
          tertiaryNebula: const Color(0xFF3B82F6),
          secondaryGlow: const Color(0xFF6366F1),
          starTint: const Color(0xFF00D9FF),
        );
    }
  }
}

class _NebulaPalette {
  final Color deepCore, midSpace, outerVoid;
  final Color primaryNebula, secondaryNebula, tertiaryNebula;
  final Color secondaryGlow, starTint;

  _NebulaPalette({
    required this.deepCore, required this.midSpace, required this.outerVoid,
    required this.primaryNebula, required this.secondaryNebula,
    required this.tertiaryNebula, required this.secondaryGlow,
    required this.starTint,
  });
}

/// Nebula cloud painter — large, soft, overlapping blobs with motion
class _NebulaPainter extends CustomPainter {
  final double flowValue;
  final double pulseValue;
  final _NebulaPalette palette;

  _NebulaPainter({
    required this.flowValue,
    required this.pulseValue,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final phase = flowValue * math.pi * 2;

    // Cloud 1: Primary nebula — large, top-right drift
    _paintCloud(canvas,
      center: Offset(
        w * (0.7 + 0.12 * math.sin(phase)),
        h * (0.18 + 0.06 * math.cos(phase * 0.7)),
      ),
      radiusX: w * (0.55 + 0.08 * pulseValue),
      radiusY: h * (0.35 + 0.05 * pulseValue),
      color: palette.primaryNebula,
      alpha: 28 + (14 * pulseValue).toInt(),
      blurRadius: 100,
    );

    // Cloud 2: Secondary — bottom-left swirl
    _paintCloud(canvas,
      center: Offset(
        w * (0.25 + 0.1 * math.cos(phase * 0.6)),
        h * (0.72 + 0.05 * math.sin(phase * 0.8)),
      ),
      radiusX: w * (0.45 + 0.06 * pulseValue),
      radiusY: h * (0.3 + 0.04 * pulseValue),
      color: palette.secondaryNebula,
      alpha: 22 + (10 * pulseValue).toInt(),
      blurRadius: 90,
    );

    // Cloud 3: Tertiary — center accent
    _paintCloud(canvas,
      center: Offset(
        w * (0.4 + 0.08 * math.sin(phase * 1.2)),
        h * (0.45 + 0.04 * math.cos(phase * 0.5)),
      ),
      radiusX: w * (0.35 + 0.05 * pulseValue),
      radiusY: h * (0.25 + 0.03 * pulseValue),
      color: palette.tertiaryNebula,
      alpha: 18 + (8 * pulseValue).toInt(),
      blurRadius: 110,
    );

    // Cloud 4: Very subtle secondary glow wash across bottom
    _paintCloud(canvas,
      center: Offset(
        w * (0.5 + 0.15 * math.cos(phase * 0.4)),
        h * 0.92,
      ),
      radiusX: w * 0.7,
      radiusY: h * 0.2,
      color: palette.secondaryGlow,
      alpha: 12 + (6 * pulseValue).toInt(),
      blurRadius: 120,
    );
  }

  void _paintCloud(Canvas canvas, {
    required Offset center,
    required double radiusX,
    required double radiusY,
    required Color color,
    required int alpha,
    required double blurRadius,
  }) {
    final rect = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withAlpha(alpha),
          color.withAlpha((alpha * 0.4).toInt()),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(_NebulaPainter old) =>
      old.flowValue != flowValue || old.pulseValue != pulseValue;
}

/// Star field painter — scattered twinkling dots
class _StarFieldPainter extends CustomPainter {
  final double twinkleValue;
  final Color accentColor;

  // Pre-generated star positions (seeded for consistency)
  static final List<_Star> _stars = _generateStars(45);

  _StarFieldPainter({required this.twinkleValue, required this.accentColor});

  static List<_Star> _generateStars(int count) {
    final rng = math.Random(42); // Fixed seed for stable layout
    return List.generate(count, (_) => _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: 0.5 + rng.nextDouble() * 1.5,
      twinklePhase: rng.nextDouble() * math.pi * 2,
      isAccent: rng.nextDouble() > 0.8,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in _stars) {
      final twinkle = (math.sin(twinkleValue * math.pi * 2 + star.twinklePhase) + 1) / 2;
      final opacity = 0.15 + 0.55 * twinkle;
      final color = star.isAccent
          ? accentColor.withAlpha((opacity * 200).toInt())
          : Colors.white.withAlpha((opacity * 120).toInt());

      final paint = Paint()..color = color;
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * (0.8 + 0.2 * twinkle),
        paint,
      );

      // Glow for accent stars — subtle overlay instead of heavy blur
      if (star.isAccent && twinkle > 0.6) {
        final glowPaint = Paint()
          ..color = accentColor.withAlpha((15 * twinkle).toInt());
        canvas.drawCircle(
          Offset(star.x * size.width, star.y * size.height),
          star.size * 2.5,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) =>
      old.twinkleValue != twinkleValue;
}

class _Star {
  final double x, y, size, twinklePhase;
  final bool isAccent;

  _Star({
    required this.x, required this.y, required this.size,
    required this.twinklePhase, required this.isAccent,
  });
}
