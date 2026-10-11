import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper to render custom bitmap markers (Person, Car, Pin) for Google Maps
class MapMarkerHelper {
  MapMarkerHelper._();

  static BitmapDescriptor? _personIcon;
  static BitmapDescriptor? _carIcon;
  static BitmapDescriptor? _pinIcon;

  /// Creates a person icon marker for passenger pickup / starting location (Vibrant Green Dot with User)
  static Future<BitmapDescriptor> getPersonMarker({
    Color backgroundColor = const Color(0xFF10B981),
    Color iconColor = Colors.white,
    double size = 34,
  }) async {
    if (_personIcon != null) return _personIcon!;
    try {
      _personIcon = await _drawIconMarker(
        icon: Icons.person_rounded,
        bgColor: backgroundColor,
        iconColor: iconColor,
        size: size,
      );
      return _personIcon!;
    } catch (e) {
      debugPrint('[MapMarkerHelper] getPersonMarker error: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  /// Creates a vehicle / car icon marker for driver position (Vibrant Blue Navigation Car)
  static Future<BitmapDescriptor> getCarMarker({
    Color backgroundColor = const Color(0xFF2563EB),
    Color iconColor = Colors.white,
    double size = 36,
  }) async {
    if (_carIcon != null) return _carIcon!;
    try {
      _carIcon = await _drawIconMarker(
        icon: Icons.directions_car_rounded,
        bgColor: backgroundColor,
        iconColor: iconColor,
        size: size,
      );
      return _carIcon!;
    } catch (e) {
      debugPrint('[MapMarkerHelper] getCarMarker error: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }

  /// Creates a destination pin marker for drop-off location (Vibrant Red Pin)
  static Future<BitmapDescriptor> getDropPinMarker({
    Color backgroundColor = const Color(0xFFEF4444),
    Color iconColor = Colors.white,
    double size = 34,
  }) async {
    if (_pinIcon != null) return _pinIcon!;
    try {
      _pinIcon = await _drawIconMarker(
        icon: Icons.place_rounded,
        bgColor: backgroundColor,
        iconColor: iconColor,
        size: size,
      );
      return _pinIcon!;
    } catch (e) {
      debugPrint('[MapMarkerHelper] getDropPinMarker error: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  /// Draws a clean, ultra-crisp circular badge with high contrast and sharp 3x resolution
  static Future<BitmapDescriptor> _drawIconMarker({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required double size,
  }) async {
    // Render at 3.0x pixel ratio for maximum sharpness without any blur or fading
    const double pixelRatio = 3.0;
    final double logicalSize = size;
    final double physicalSize = logicalSize * pixelRatio;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    canvas.scale(pixelRatio, pixelRatio);

    final double width = logicalSize;
    final double center = width / 2;

    // 1. Darker, sharper drop shadow (no blur washout)
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(
      Offset(center, center + 1.0),
      center - 1.5,
      shadowPaint,
    );

    // 2. Crisp, solid white outer border ring
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center, center),
      center - 1.0,
      borderPaint,
    );

    // 3. Vibrant solid colored inner circle
    final Paint circlePaint = Paint()
      ..color = bgColor
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center, center),
      center - 3.2,
      circlePaint,
    );

    // 4. Centered Icon with crisp solid glyph rendering
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: (width * 0.52),
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: iconColor,
        fontWeight: FontWeight.w900,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (width - textPainter.width) / 2,
        (width - textPainter.height) / 2,
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      physicalSize.toInt(),
      physicalSize.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    return BitmapDescriptor.bytes(
      data.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
      width: logicalSize,
      height: logicalSize,
    );
  }
}
