import 'package:flutter/material.dart';

class SparklinePainter extends CustomPainter {
  final List<int> values;
  final double maxValue;
  final Color color;

  SparklinePainter({
    required this.values,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withAlpha(50), color.withAlpha(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final stepX = size.width / (values.length - 1);

    double getX(int i) => i * stepX;
    double getY(int i) {
      final val = values[i].toDouble();
      return size.height - (val / maxValue * size.height);
    }

    path.moveTo(getX(0), getY(0));

    for (var i = 1; i < values.length; i++) {
        final x = getX(i);
        final y = getY(i);
        final prevX = getX(i - 1);
        final prevY = getY(i - 1);
        
        // Smooth curve
        final cp1x = prevX + (x - prevX) / 2;
        path.cubicTo(cp1x, prevY, cp1x, y, x, y);
    }

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    
    final pointPaint = Paint()..color = Colors.white;
    for (var i = 0; i < values.length; i++) {
        canvas.drawCircle(Offset(getX(i), getY(i)), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.color != color;
  }
}
