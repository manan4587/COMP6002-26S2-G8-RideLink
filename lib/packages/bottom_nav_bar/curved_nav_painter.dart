import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurvedNavPainter extends CustomPainter {
  final Color color;
  final Color indicatorColor;
  final double indicatorSize;
  final double borderRadius;
  final double loc;

  CurvedNavPainter({
    required double startingLoc,
    required int itemsLength,
    required this.color,
    required this.indicatorColor,
    this.indicatorSize = 6,
    this.borderRadius = 20,
  }) : loc = (startingLoc + 0.5) / itemsLength;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint circlePaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    final double centerX = loc * width;
    final double valleyWidth = 50.w;
    final double valleyDepth = 15.w;

    Path path = Path()
      ..moveTo(0, borderRadius)
      ..quadraticBezierTo(0, 0, borderRadius, 0)
      ..lineTo(centerX - valleyWidth / 2, 0)
      ..cubicTo(
        centerX - valleyWidth / 4,
        0,
        centerX - valleyWidth / 4,
        valleyDepth,
        centerX,
        valleyDepth,
      )
      ..cubicTo(
        centerX + valleyWidth / 4,
        valleyDepth,
        centerX + valleyWidth / 4,
        0,
        centerX + valleyWidth / 2,
        0,
      )
      ..lineTo(width - borderRadius, 0)
      ..quadraticBezierTo(width, 0, width, borderRadius)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    canvas.drawPath(path, paint);

    // Draw the dot exactly above the curve center
    canvas.drawCircle(
      Offset(centerX, indicatorSize),
      indicatorSize,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CurvedNavPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.loc != loc ||
        oldDelegate.indicatorColor != indicatorColor ||
        oldDelegate.indicatorSize != indicatorSize ||
        oldDelegate.borderRadius != borderRadius;
  }
}
