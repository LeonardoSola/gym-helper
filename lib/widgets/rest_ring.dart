import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular progress ring that follows the edge of a round watch face.
class RestRing extends StatelessWidget {
  const RestRing({
    super.key,
    required this.progress,
    required this.color,
    this.strokeWidth = 6,
  });

  /// Elapsed fraction, from 0 (full ring) to 1 (empty ring).
  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _RestRingPainter(
          progress: progress,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _RestRingPainter extends CustomPainter {
  _RestRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - strokeWidth) / 2 - 2;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );

    final track = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    final remaining = (1 - progress).clamp(0.0, 1.0);
    if (remaining == 0) return;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * remaining, false, arc);
  }

  @override
  bool shouldRepaint(_RestRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
