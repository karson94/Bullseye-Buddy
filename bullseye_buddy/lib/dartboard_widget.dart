import 'package:flutter/material.dart';
import 'dart:math';

class DartboardWidget extends StatefulWidget {
  final void Function(int segment, int multiplier) onZoneSelected;
  final double size;

  const DartboardWidget({
    Key? key,
    required this.onZoneSelected,
    this.size = 320,
  }) : super(key: key);

  @override
  State<DartboardWidget> createState() => _DartboardWidgetState();
}

class _DartboardWidgetState extends State<DartboardWidget> {
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

  int? hoveredSegment;
  int? hoveredMultiplier;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        
        final size = box.size;
        Offset local = box.globalToLocal(event.position);
        final result = _detectZone(local, size.width);
        
        setState(() {
          if (result != null) {
            hoveredSegment = result[0];
            hoveredMultiplier = result[1];
          } else {
            hoveredSegment = null;
            hoveredMultiplier = null;
          }
        });
      },
      onExit: (event) {
        setState(() {
          hoveredSegment = null;
          hoveredMultiplier = null;
        });
      },
      child: GestureDetector(
        onTapUp: (details) {
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset local = box.globalToLocal(details.globalPosition);
          final result = _detectZone(local, widget.size);
          if (result != null) {
            widget.onZoneSelected(result[0], result[1]);
          }
        },
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _DartboardPainter(),
          foregroundPainter: _DartboardNumberPainter(size: widget.size),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _DartboardHighlightPainter(
              size: widget.size,
              hoveredSegment: hoveredSegment,
              hoveredMultiplier: hoveredMultiplier,
            ),
          ),
        ),
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
    print('Main painter center: ${center.dx}, ${center.dy}');
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
        Rect.fromCircle(center: center, radius: boardRadius * _DartboardWidgetState.doubleRingOuterProp),
        segStart,
        sweep,
        true,
        paint,
      );
    }
    // Draw double ring
    paint.color = Colors.red;
    canvas.drawCircle(center, boardRadius * _DartboardWidgetState.doubleRingOuterProp, paint..style = PaintingStyle.stroke..strokeWidth = boardRadius * (_DartboardWidgetState.doubleRingOuterProp - _DartboardWidgetState.doubleRingInnerProp));
    // Draw triple ring
    paint.color = Colors.green;
    canvas.drawCircle(center, boardRadius * ((_DartboardWidgetState.tripleRingInnerProp + _DartboardWidgetState.tripleRingOuterProp) / 2), paint..style = PaintingStyle.stroke..strokeWidth = boardRadius * (_DartboardWidgetState.tripleRingOuterProp - _DartboardWidgetState.tripleRingInnerProp));
    // Draw bull
    paint.color = Colors.green;
    canvas.drawCircle(center, boardRadius * _DartboardWidgetState.bullseyeRadiusProp, paint..style = PaintingStyle.fill);
    paint.color = Colors.red;
    canvas.drawCircle(center, boardRadius * _DartboardWidgetState.bullRadiusProp, paint..style = PaintingStyle.fill);
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

class _DartboardHighlightPainter extends CustomPainter {
  final double size;
  final int? hoveredSegment;
  final int? hoveredMultiplier;

  _DartboardHighlightPainter({
    required this.size,
    this.hoveredSegment,
    this.hoveredMultiplier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (hoveredSegment == null || hoveredMultiplier == null) return;

    final center = Offset(size.width / 2, size.height / 2);
    final boardRadius = size.width / 2;
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Special handling for bull/bullseye
    if (hoveredSegment == 25) {
      if (hoveredMultiplier == 2) {
        // Bullseye
        canvas.drawCircle(center, boardRadius * _DartboardWidgetState.bullRadiusProp, paint);
      } else {
        // Bull ring
        final bullRadius = boardRadius * _DartboardWidgetState.bullRadiusProp;
        final bullseyeRadius = boardRadius * _DartboardWidgetState.bullseyeRadiusProp;
        final path = Path()
          ..addOval(Rect.fromCircle(center: center, radius: bullseyeRadius))
          ..addOval(Rect.fromCircle(center: center, radius: bullRadius));
        path.fillType = PathFillType.evenOdd;
        canvas.drawPath(path, paint);
      }
      return;
    }

    // Find segment index
    final segmentIndex = _DartboardWidgetState.dartboardNumbers.indexOf(hoveredSegment!);
    if (segmentIndex == -1) return;

    // Calculate segment angles - match main painter exactly
    double segmentAngle = 2 * pi / 20;
    double startAngle = -pi / 2 - segmentAngle / 2;
    double segStart = startAngle + segmentIndex * segmentAngle;

    // Determine ring radii based on multiplier - accounting for stroke boundaries
    double innerRadius, outerRadius;
    if (hoveredMultiplier == 2) {
      // Double ring - use actual stroke boundaries
      final strokeCenter = boardRadius * _DartboardWidgetState.doubleRingOuterProp;
      final strokeWidth = boardRadius * (_DartboardWidgetState.doubleRingOuterProp - _DartboardWidgetState.doubleRingInnerProp);
      innerRadius = strokeCenter - strokeWidth / 2;
      outerRadius = strokeCenter + strokeWidth / 2;
    } else if (hoveredMultiplier == 3) {
      // Triple ring - use actual stroke boundaries
      final strokeCenter = boardRadius * ((_DartboardWidgetState.tripleRingInnerProp + _DartboardWidgetState.tripleRingOuterProp) / 2);
      final strokeWidth = boardRadius * (_DartboardWidgetState.tripleRingOuterProp - _DartboardWidgetState.tripleRingInnerProp);
      innerRadius = strokeCenter - strokeWidth / 2;
      outerRadius = strokeCenter + strokeWidth / 2;
    } else {
      // Single areas - highlight both inner and outer single zones
      final tripleOuterStrokeCenter = boardRadius * ((_DartboardWidgetState.tripleRingInnerProp + _DartboardWidgetState.tripleRingOuterProp) / 2);
      final tripleStrokeWidth = boardRadius * (_DartboardWidgetState.tripleRingOuterProp - _DartboardWidgetState.tripleRingInnerProp);
      final tripleInnerEdge = tripleOuterStrokeCenter - tripleStrokeWidth / 2;
      final tripleOuterEdge = tripleOuterStrokeCenter + tripleStrokeWidth / 2;
      
      final doubleOuterStrokeCenter = boardRadius * _DartboardWidgetState.doubleRingOuterProp;
      final doubleStrokeWidth = boardRadius * (_DartboardWidgetState.doubleRingOuterProp - _DartboardWidgetState.doubleRingInnerProp);
      final doubleInnerEdge = doubleOuterStrokeCenter - doubleStrokeWidth / 2;
      
      final bullseyeRadius = boardRadius * _DartboardWidgetState.bullseyeRadiusProp;
      
      final path = Path();
      
      // Inner single area (between bull and triple ring)
      path.addArc(Rect.fromCircle(center: center, radius: tripleInnerEdge), segStart, segmentAngle);
      path.arcTo(Rect.fromCircle(center: center, radius: bullseyeRadius), segStart + segmentAngle, -segmentAngle, false);
      path.close();
      
      // Outer single area (between triple and double rings)
      path.moveTo(center.dx, center.dy);
      path.addArc(Rect.fromCircle(center: center, radius: doubleInnerEdge), segStart, segmentAngle);
      path.arcTo(Rect.fromCircle(center: center, radius: tripleOuterEdge), segStart + segmentAngle, -segmentAngle, false);
      path.close();
      
      canvas.drawPath(path, paint);
      return;
    }

    // Draw the highlighted segment arc for double/triple rings
    final path = Path();
    path.addArc(Rect.fromCircle(center: center, radius: outerRadius), segStart, segmentAngle);
    path.arcTo(Rect.fromCircle(center: center, radius: innerRadius), segStart + segmentAngle, -segmentAngle, false);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _DartboardHighlightPainter ||
        oldDelegate.hoveredSegment != hoveredSegment ||
        oldDelegate.hoveredMultiplier != hoveredMultiplier;
  }
} 