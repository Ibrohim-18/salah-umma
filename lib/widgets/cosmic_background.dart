import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Modern Aurora Gradient Background - 2024/2025 UI Trend
/// Inspired by iOS Liquid Glass and premium app designs
class CosmicBackground extends StatefulWidget {
  final Widget child;

  const CosmicBackground({super.key, required this.child});

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _auroraController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D0D0D),
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F0F0F),
              ],
              stops: [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        ),
        // Animated aurora blobs
        AnimatedBuilder(
          animation: Listenable.merge([_auroraController, _pulseController]),
          builder: (context, child) {
            return CustomPaint(
              painter: AuroraPainter(
                animationValue: _auroraController.value,
                pulseValue: _pulseController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

/// Modern Aurora Painter with mesh gradient effect
class AuroraPainter extends CustomPainter {
  final double animationValue;
  final double pulseValue;

  AuroraPainter({required this.animationValue, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Blob 1 - Teal/Cyan (top-right)
    _drawBlob(canvas,
      center: Offset(
        w * (0.75 + 0.1 * math.sin(animationValue * math.pi * 2)),
        h * (0.12 + 0.05 * math.cos(animationValue * math.pi * 2)),
      ),
      radius: w * (0.5 + 0.1 * pulseValue),
      color1: const Color(0xFF00D9FF).withAlpha((45 + 20 * pulseValue).toInt()),
      color2: const Color(0xFF00FFD1).withAlpha((30 + 15 * pulseValue).toInt()),
    );

    // Blob 2 - Purple/Violet (center-left)
    _drawBlob(canvas,
      center: Offset(
        w * (0.2 + 0.12 * math.cos(animationValue * math.pi * 2 + 1)),
        h * (0.4 + 0.08 * math.sin(animationValue * math.pi * 2 + 1)),
      ),
      radius: w * (0.55 + 0.1 * pulseValue),
      color1: const Color(0xFF8B5CF6).withAlpha((40 + 15 * pulseValue).toInt()),
      color2: const Color(0xFFA855F7).withAlpha((25 + 10 * pulseValue).toInt()),
    );

    // Blob 3 - Blue (bottom-center)
    _drawBlob(canvas,
      center: Offset(
        w * (0.55 + 0.15 * math.sin(animationValue * math.pi * 2 + 2)),
        h * (0.85 + 0.04 * math.cos(animationValue * math.pi * 2 + 2)),
      ),
      radius: w * (0.5 + 0.08 * pulseValue),
      color1: const Color(0xFF3B82F6).withAlpha((35 + 15 * pulseValue).toInt()),
      color2: const Color(0xFF6366F1).withAlpha((22 + 10 * pulseValue).toInt()),
    );

    // Blob 4 - Emerald accent (top-left)
    _drawBlob(canvas,
      center: Offset(
        w * (0.1 + 0.08 * math.cos(animationValue * math.pi * 2 + 3)),
        h * (0.08 + 0.04 * math.sin(animationValue * math.pi * 2 + 3)),
      ),
      radius: w * (0.32 + 0.05 * pulseValue),
      color1: const Color(0xFF10B981).withAlpha((28 + 12 * pulseValue).toInt()),
      color2: const Color(0xFF14B8A6).withAlpha((18 + 8 * pulseValue).toInt()),
    );
  }

  void _drawBlob(Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color1,
    required Color color2,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color1, color2, Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.pulseValue != pulseValue;
  }
}

