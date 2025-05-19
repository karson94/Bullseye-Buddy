import 'package:flutter/material.dart';
import 'dart:math';

class DartboardWidget extends StatelessWidget {
  final void Function(int segment, int multiplier) onZoneSelected;
  final double size;

  // Standard dartboard order, starting with 20 at the top
  static const List<int> dartboardNumbers = [
    20, 1, 18, 4, 13, 6, 10, 15, 2, 17,
    3, 19, 7, 16, 8, 11, 14, 9, 12, 5
  ];

  // Proportional radii for each ring (relative to board radius)
  static const double bullRadiusProp = 0.07;
  static const double bullseyeRadiusProp = 0.16;
  static const double tripleRingInnerProp = 0.53;
  static const double tripleRingOuterProp = 0.60;
  static const double doubleRingInnerProp = 0.87;
  static const double doubleRingOuterProp = 0.95;

  const DartboardWidget({
    Key? key,
    required this.onZoneSelected,
    this.size = 320,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset local = box.globalToLocal(details.globalPosition);
        final result = _detectZone(local, size);
        if (result != null) {
          onZoneSelected(result[0], result[1]);
        }
      },
      child: CustomPaint(
        size: Size(size, size),
        painter: _DartboardPainter(),
        foregroundPainter: _DartboardNumberPainter(size: size),
      ),
    );
  }

  /// Returns [segment, multiplier] or null if outside board
  List<int>? _detectZone(Offset pos, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = pos.dx - center.dx;
    final dy = pos.dy - center.dy;
    final r = sqrt(dx * dx + dy * dy);
    final theta = atan2(dy, dx); // -pi to pi, 0 is 3 o'clock
    // Each segment is 18 degrees (pi/10 radians)
    double segmentAngle = 2 * pi / 20;
    double startAngle = -pi / 2 - segmentAngle / 2; // Match drawing offset
    int segment = 20; // Default to 20 if not found
    for (int i = 0; i < 20; i++) {
      double segStart = startAngle + i * segmentAngle;
      double segEnd = segStart + segmentAngle;
      // Normalize theta to [0, 2pi)
      double normTheta = (theta + 2 * pi) % (2 * pi);
      double normSegStart = (segStart + 2 * pi) % (2 * pi);
      double normSegEnd = (segEnd + 2 * pi) % (2 * pi);
      bool inSegment = normSegStart < normSegEnd
        ? (normTheta >= normSegStart && normTheta < normSegEnd)
        : (normTheta >= normSegStart || normTheta < normSegEnd);
      if (inSegment) {
        segment = dartboardNumbers[i];
        break;
      }
    }
    final boardRadius = size / 2;
    final bullRadius = boardRadius * bullRadiusProp;
    final bullseyeRadius = boardRadius * bullseyeRadiusProp;
    final tripleRingInner = boardRadius * tripleRingInnerProp;
    final tripleRingOuter = boardRadius * tripleRingOuterProp;
    final doubleRingInner = boardRadius * doubleRingInnerProp;
    final doubleRingOuter = boardRadius * doubleRingOuterProp;
    // Check zones in order: bullseye, bull, inner single, triple, outer single, double
    if (r <= bullRadius) return [25, 2]; // Bullseye (double bull)
    if (r > bullRadius && r <= bullseyeRadius) return [25, 1]; // Bull (single bull)
    if (r > bullseyeRadius && r < tripleRingInner) return [segment, 1]; // Inner single
    if (r >= tripleRingInner && r <= tripleRingOuter) return [segment, 3]; // Triple ring
    if (r > tripleRingOuter && r < doubleRingInner) return [segment, 1]; // Outer single
    if (r >= doubleRingInner && r <= doubleRingOuter) return [segment, 2]; // Double ring
    return null; // Outside board
  }
}

class _DartboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final boardRadius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;
    // Draw background
    paint.color = Colors.black;
    canvas.drawCircle(center, boardRadius, paint);
    // Draw segments
    double segmentAngle = 2 * pi / 20;
    double startAngle = -pi / 2 - segmentAngle / 2; // Offset so 20 is centered at top
    for (int i = 0; i < 20; i++) {
      final segStart = startAngle + i * segmentAngle;
      final sweep = segmentAngle;
      paint.color = i % 2 == 0 ? Colors.white : Colors.grey.shade400;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: boardRadius * DartboardWidget.doubleRingOuterProp),
        segStart,
        sweep,
        true,
        paint,
      );
    }
    // Draw double ring
    paint.color = Colors.red;
    canvas.drawCircle(center, boardRadius * DartboardWidget.doubleRingOuterProp, paint..style = PaintingStyle.stroke..strokeWidth = boardRadius * (DartboardWidget.doubleRingOuterProp - DartboardWidget.doubleRingInnerProp));
    // Draw triple ring
    paint.color = Colors.green;
    canvas.drawCircle(center, boardRadius * ((DartboardWidget.tripleRingInnerProp + DartboardWidget.tripleRingOuterProp) / 2), paint..style = PaintingStyle.stroke..strokeWidth = boardRadius * (DartboardWidget.tripleRingOuterProp - DartboardWidget.tripleRingInnerProp));
    // Draw bull
    paint.color = Colors.green;
    canvas.drawCircle(center, boardRadius * DartboardWidget.bullseyeRadiusProp, paint..style = PaintingStyle.fill);
    paint.color = Colors.red;
    canvas.drawCircle(center, boardRadius * DartboardWidget.bullRadiusProp, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DartboardNumberPainter extends CustomPainter {
  final double size;
  _DartboardNumberPainter({required this.size});

  static const List<int> dartboardNumbers = [
    20, 1, 18, 4, 13, 6, 10, 15, 2, 17,
    3, 19, 7, 16, 8, 11, 14, 9, 12, 5
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final boardRadius = size.width / 2;
    final numberRadius = boardRadius * 1.07; // Just outside the double ring
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: boardRadius * 0.13,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
      shadows: [Shadow(blurRadius: 2, color: Colors.white, offset: Offset(0, 0))],
    );
    double segmentAngle = 2 * pi / 20;
    double startAngle = -pi / 2 - segmentAngle / 2; // Offset so 20 is centered at top
    for (int i = 0; i < 20; i++) {
      final angle = startAngle + i * segmentAngle + segmentAngle / 2;
      final number = dartboardNumbers[i].toString();
      final offset = Offset(
        center.dx + numberRadius * cos(angle),
        center.dy + numberRadius * sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(text: number, style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      // Center the text horizontally and vertically
      final textOffset = Offset(
        offset.dx - tp.width / 2,
        offset.dy - tp.height / 2,
      );
      tp.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 