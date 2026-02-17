import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_theme.dart';

// --- Physics-based falling prayer tags widget ---
class PrayerTag {
  double x, y;
  late double vx, vy;
  late double rotation, rotationSpeed;
  double width, height;
  String label;

  static const double gravity = 0.56;
  static const double bounce = 0.32;
  static const double friction = 0.965;
  static const double rotationFriction = 0.92;

  PrayerTag({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
  }) {
    vx = (math.Random().nextDouble() - 0.5) * 2.4;
    vy = 0;
    rotation = (math.Random().nextDouble() - 0.5) * 10;
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.9;
  }

  void update(double containerWidth, double containerHeight) {
    vy += gravity;
    vx *= friction;
    rotationSpeed *= rotationFriction;
    x += vx;
    y += vy;
    rotation += rotationSpeed;

    if (y + height >= containerHeight) {
      y = containerHeight - height;
      if (vy > 0) {
        vy *= -bounce;
      }
      if (vy.abs() < 1.1) vy = 0;
      vx *= 0.82;
      rotationSpeed *= 0.6;
    }
    if (x <= 0) {
      x = 0;
      vx *= -bounce;
    }
    if (x + width >= containerWidth) {
      x = containerWidth - width;
      vx *= -bounce;
    }
  }
}

class FallingPrayersWidget extends StatefulWidget {
  final List<String> prayers;
  final List<bool> completed;
  final double scale;
  final bool showCollision;

  const FallingPrayersWidget({
    super.key,
    required this.prayers,
    required this.completed,
    required this.scale,
    this.showCollision = false,
  });

  @override
  State<FallingPrayersWidget> createState() => FallingPrayersWidgetState();
}

class FallingPrayersWidgetState extends State<FallingPrayersWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<PrayerTag> tags = [];
  bool _initialized = false;
  double _containerWidth = 0, _containerHeight = 0;
  final double _tagWidthBase = 88, _tagHeightBase = 36;

  // collision tuning
  final double _collisionFactor = 1.05;
  final double _collisionPadding = 1.0;
  final double _velTransfer = 0.82;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(days: 365))
      ..addListener(() {
        if (!mounted) return;
        if (_containerWidth <= 0 || _containerHeight <= 0) return;
        setState(() {
          for (var tag in tags) {
            tag.update(_containerWidth, _containerHeight);
          }

          // Two passes improve stability for stacked capsules.
          for (int pass = 0; pass < 2; pass++) {
            for (int i = 0; i < tags.length; i++) {
              for (int j = i + 1; j < tags.length; j++) {
                _checkCollision(tags[i], tags[j]);
              }
            }
          }

          // After resolving collisions, ensure floor-touching tags are snapped to the floor
          const floorEps = 1.0;
          for (var tag in tags) {
            if (tag.y + tag.height >= _containerHeight - floorEps) {
              tag.y = _containerHeight - tag.height;
              tag.vy = 0;
              tag.vx *= 0.65;
              tag.rotationSpeed *= 0.65;
            }
          }
        });
      })
      ..repeat();
  }

  double _estimateTagWidth(String label, double maxWidth) {
    final fontSize = 12.5 * widget.scale;
    final textWidth = label.length * fontSize * 0.62;
    final horizontalPadding = 20 * widget.scale;
    final iconAndGap = 20 * widget.scale;
    final safety = 6 * widget.scale;
    final minWidth = 72 * widget.scale;
    final base = _tagWidthBase * widget.scale;
    final desired =
        math.max(base, horizontalPadding + iconAndGap + textWidth + safety);
    return desired.clamp(minWidth, maxWidth).toDouble();
  }

  void _createTagsIfNeeded() {
    if (_initialized) return;
    if (_containerWidth <= 0 || _containerHeight <= 0) return;
    tags = [];
    final tagH = _tagHeightBase * widget.scale;
    final count = math.max(1, widget.prayers.length);
    final floorGap = 6.0 * widget.scale;
    final maxTagWidth = ((_containerWidth - (count - 1) * floorGap) / count)
        .clamp(72.0 * widget.scale, 112.0 * widget.scale)
        .toDouble();
    for (int i = 0; i < widget.prayers.length; i++) {
      final tagW = _estimateTagWidth(widget.prayers[i], maxTagWidth);
      final x = math.Random().nextDouble() * math.max(0.0, _containerWidth - tagW);
      final y = -(tagH * (i + 1)) - math.Random().nextDouble() * 140.0;
      tags.add(
          PrayerTag(x: x, y: y, width: tagW, height: tagH, label: widget.prayers[i]));
    }
    _initialized = true;
  }

  void _checkCollision(PrayerTag a, PrayerTag b) {
    double dx = (b.x + b.width / 2) - (a.x + a.width / 2);
    double dy = (b.y + b.height / 2) - (a.y + a.height / 2);
    double distance = math.sqrt(dx * dx + dy * dy);

    if (distance <= 0) {
      dx = (math.Random().nextDouble() - 0.5) * 0.01;
      dy = (math.Random().nextDouble() - 0.5) * 0.01;
      distance = math.sqrt(dx * dx + dy * dy);
    }
    final nx = dx / distance;
    final ny = dy / distance;

    final aRx = (a.width * 0.5) * _collisionFactor;
    final aRy = (a.height * 0.5) * _collisionFactor;
    final bRx = (b.width * 0.5) * _collisionFactor;
    final bRy = (b.height * 0.5) * _collisionFactor;
    final ra = math.sqrt((aRx * nx) * (aRx * nx) + (aRy * ny) * (aRy * ny));
    final rb = math.sqrt((bRx * nx) * (bRx * nx) + (bRy * ny) * (bRy * ny));
    final minDistance = (ra + rb) * _collisionPadding;

    if (distance < minDistance) {
      final overlap = (minDistance - distance);
      final correctionX = nx * overlap;
      final correctionY = ny * overlap;

      final ma = math.max(1.0, a.width * a.height / 100.0);
      final mb = math.max(1.0, b.width * b.height / 100.0);

      const floorEps = 6.0;
      final aOnFloor = a.y + a.height >= _containerHeight - floorEps;
      final bOnFloor = b.y + b.height >= _containerHeight - floorEps;
      const double immovableMass = 1e8;
      final maAdj = aOnFloor ? immovableMass : ma;
      final mbAdj = bOnFloor ? immovableMass : mb;

      double moveAx = correctionX * (mbAdj / (maAdj + mbAdj));
      double moveAy = correctionY * (mbAdj / (maAdj + mbAdj));
      double moveBx = correctionX * (maAdj / (maAdj + mbAdj));
      double moveBy = correctionY * (maAdj / (maAdj + mbAdj));

      a.x -= moveAx;
      a.y -= moveAy;
      b.x += moveBx;
      b.y += moveBy;

      a.x = a.x.clamp(0.0, _containerWidth - a.width);
      a.y = a.y.clamp(0.0, _containerHeight - a.height);
      b.x = b.x.clamp(0.0, _containerWidth - b.width);
      b.y = b.y.clamp(0.0, _containerHeight - b.height);

      final rvx = b.vx - a.vx;
      final rvy = b.vy - a.vy;
      final velAlongNormal = rvx * nx + rvy * ny;

      if (velAlongNormal > 0) return;

      const restitution = 0.0;
      final j = -(1 + restitution) *
          velAlongNormal /
          ((1 / maAdj) + (1 / mbAdj));
      final jx = j * nx;
      final jy = j * ny;

      a.vx -= (jx / maAdj) * _velTransfer;
      a.vy -= (jy / maAdj) * _velTransfer;
      b.vx += (jx / mbAdj) * _velTransfer;
      b.vy += (jy / mbAdj) * _velTransfer;

      a.vx *= 0.88;
      a.vy *= 0.88;
      b.vx *= 0.88;
      b.vy *= 0.88;

      if (a.y + a.height >= _containerHeight - floorEps) {
        a.y = _containerHeight - a.height;
        a.vy = 0;
      }
      if (b.y + b.height >= _containerHeight - floorEps) {
        b.y = _containerHeight - b.height;
        b.vy = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _containerWidth = constraints.maxWidth;
      _containerHeight = constraints.maxHeight;
      _createTagsIfNeeded();

      return ClipRRect(
        borderRadius: BorderRadius.circular(12 * widget.scale),
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            ...List.generate(tags.length, (i) {
              final tag = tags[i];
              final isCompleted =
                  widget.completed.length > i && widget.completed[i];
              return Positioned(
                left: tag.x,
                top: tag.y,
                child: Transform.rotate(
                  angle: tag.rotation * math.pi / 180,
                  child: Container(
                    width: tag.width,
                    height: tag.height,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12 * widget.scale),
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? const LinearGradient(
                              colors: AppTheme.successGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                AppTheme.glassWhite,
                                AppTheme.glassWhite.withAlpha(6)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(18 * widget.scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isCompleted ? 60 : 30),
                          blurRadius: 8 * widget.scale,
                          offset: Offset(0, 4 * widget.scale),
                        ),
                      ],
                      border: Border.all(
                        color: isCompleted
                            ? AppTheme.successMint.withAlpha(140)
                            : Colors.white.withAlpha(24),
                        width: 1.0 * widget.scale,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isCompleted) ...[
                          Icon(Icons.check,
                              color: Colors.white, size: 14 * widget.scale),
                          SizedBox(width: 6 * widget.scale),
                        ],
                        Expanded(
                          child: Text(
                            tag.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isCompleted
                                  ? Colors.white
                                  : Colors.white.withAlpha(210),
                              fontSize: 12.5 * widget.scale,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (widget.showCollision)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                      painter: HitboxPainter(
                          tags: tags, collisionFactor: _collisionFactor)),
                ),
              ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class HitboxPainter extends CustomPainter {
  final List<PrayerTag> tags;
  final double collisionFactor;
  HitboxPainter({required this.tags, required this.collisionFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.red.withValues(alpha: 0.9);
    final fill = Paint()..color = Colors.red.withValues(alpha: 0.06);
    for (final tag in tags) {
      final cx = tag.x + tag.width / 2;
      final cy = tag.y + tag.height / 2;
      final r = math.min(tag.width, tag.height) * 0.5 * collisionFactor;
      canvas.drawCircle(Offset(cx, cy), r, fill);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HitboxPainter old) {
    if (old.tags.length != tags.length) return true;
    for (var i = 0; i < tags.length; i++) {
      if (old.tags[i].x != tags[i].x || old.tags[i].y != tags[i].y) return true;
    }
    return old.collisionFactor != collisionFactor;
  }
}
