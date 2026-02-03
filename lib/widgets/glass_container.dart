import 'dart:ui';
import 'package:flutter/material.dart';

/// Modern Glass Card - 2024/2025 Premium UI
/// Features: Subtle blur, gradient border, soft glow
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool forceGlass;
  final Color? accentColor;
  final double borderRadius;

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
  });

  @override
  Widget build(BuildContext context) {
    // Always use glass effect for modern look
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withAlpha(18), // ~7%
                  Colors.white.withAlpha(8),  // ~3%
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withAlpha(25), // ~10%
                width: 1,
              ),
            ),
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Prayer Card with checkbox - Modern design
class PrayerCard extends StatelessWidget {
  final String name;
  final String adhanTime;
  final String iqamaTime;
  final bool isCompleted;
  final bool isNext;
  final VoidCallback? onToggle;

  const PrayerCard({
    super.key,
    required this.name,
    required this.adhanTime,
    required this.iqamaTime,
    this.isCompleted = false,
    this.isNext = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isNext
                ? [
                    const Color(0xFF3B82F6).withAlpha(40),
                    const Color(0xFF8B5CF6).withAlpha(25),
                  ]
                : isCompleted
                    ? [
                        const Color(0xFF10B981).withAlpha(30),
                        const Color(0xFF14B8A6).withAlpha(18),
                      ]
                    : [
                        Colors.white.withAlpha(12),
                        Colors.white.withAlpha(6),
                      ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNext
                ? const Color(0xFF3B82F6).withAlpha(80)
                : isCompleted
                    ? const Color(0xFF10B981).withAlpha(60)
                    : Colors.white.withAlpha(20),
            width: isNext ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : Colors.white.withAlpha(80),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            // Prayer name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isNext ? FontWeight.w600 : FontWeight.w500,
                      color: Colors.white.withAlpha(isCompleted ? 180 : 240),
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white.withAlpha(100),
                    ),
                  ),
                  if (isNext)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withAlpha(50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF60A5FA),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Times
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  adhanTime,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withAlpha(isCompleted ? 150 : 230),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  'Iqama $iqamaTime',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(100),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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

