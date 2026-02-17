import 'dart:ui';
import 'package:flutter/material.dart';

/// Glass Container Variants
enum GlassVariant {
  standard,   // Subtle glass — default
  elevated,   // Stronger blur + shadow lift
  accent,     // Tinted border with glow
}

/// Modern Glass Card - Premium UI 2025
/// Features: Variants, subtle blur, gradient border, soft glow
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool forceGlass;
  final Color? accentColor;
  final double borderRadius;
  final GlassVariant variant;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.forceGlass = false,
    this.accentColor,
    this.borderRadius = 24,
    this.variant = GlassVariant.standard,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isElevated = variant == GlassVariant.elevated;
    final isAccent = variant == GlassVariant.accent;
    final effectiveAccent = accentColor ?? const Color(0xFF00E5FF);

    // Optimized blur values for performance
    final blurSigma = isElevated ? 20.0 : 10.0;

    // Refined gradients for 2026 "Ultra-Glass" look
    final bgColors = isAccent
        ? [effectiveAccent.withAlpha(20), effectiveAccent.withAlpha(5)]
        : isElevated
            ? [const Color(0xFFFFFFFF).withAlpha(15), const Color(0xFFFFFFFF).withAlpha(5)]
            : [const Color(0xFFFFFFFF).withAlpha(8), const Color(0xFFFFFFFF).withAlpha(2)];

    // Thin, crisp border with gradient
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isAccent
          ? [effectiveAccent.withAlpha(100), effectiveAccent.withAlpha(20)]
          : isElevated
              ? [Colors.white.withAlpha(40), Colors.white.withAlpha(10)]
              : [Colors.white.withAlpha(25), Colors.white.withAlpha(5)],
    );

    Widget card = Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        boxShadow: isElevated
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                  spreadRadius: -5,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: Colors.transparent), // Placeholder for gradient border
                gradient: borderGradient, // This paints the border? No, Gradient doesn't work in BoxDecoration with border.
              ),
              child: CustomPaint(
                painter: _GradientBorderPainter(
                  radius: borderRadius,
                  gradient: borderGradient,
                  strokeWidth: 1.0,
                ),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(20),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: card,
      );
    }

    return card;
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double radius;
  final Gradient gradient;
  final double strokeWidth;

  _GradientBorderPainter({required this.radius, required this.gradient, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.gradient != gradient || oldDelegate.strokeWidth != strokeWidth;
}

/// Responsive layout helper
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? desktop;
  final double breakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.desktop,
    this.breakpoint = 640,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > breakpoint && desktop != null) {
      return desktop!;
    }
    return mobile;
  }
}
