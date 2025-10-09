import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/memory_journey_entity.dart';

/// Snake Path Painter
/// Paints the organic, flowing road path for the memory journey
class SnakePathPainter extends CustomPainter {
  final MemoryJourneyEntity journey;
  final MemoryJourneyThemeEntity theme;
  final double animationProgress;
  final int currentMemoryIndex;

  SnakePathPainter({
    required this.journey,
    required this.theme,
    required this.animationProgress,
    required this.currentMemoryIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (journey.memories.isEmpty) return;

    _paintBackground(canvas, size);
    _paintSnakePath(canvas, size);
    _paintProgressStroke(canvas, size);
    _paintParticles(canvas, size);
  }

  void _paintBackground(Canvas canvas, Size size) {
    // Create gradient background
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.backgroundColor,
        theme.backgroundColor.withValues(alpha: 0.8),
        theme.backgroundColor.withValues(alpha: 0.6),
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Add subtle vignette effect
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.1),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  void _paintSnakePath(Canvas canvas, Size size) {
    final path = _createSnakePath(size);

    // Paint road shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final shadowPath = Path();
    shadowPath.addPath(path, const Offset(2, 2));
    canvas.drawPath(shadowPath, shadowPaint);

    // Paint road base
    final roadPaint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, roadPaint);

    // Paint road highlight
    final highlightPaint = Paint()
      ..color = theme.primaryColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, highlightPaint);

    // Paint road center line
    final centerLinePaint = Paint()
      ..color = theme.secondaryColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerLinePath = _createCenterLinePath(size);
    canvas.drawPath(centerLinePath, centerLinePaint);
  }

  void _paintProgressStroke(Canvas canvas, Size size) {
    if (animationProgress <= 0) return;

    final path = _createSnakePath(size);
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      final progressLength = pathMetric.length * animationProgress;
      final progressPath = pathMetric.extractPath(0, progressLength);

      final progressPaint = Paint()
        ..color = theme.primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(progressPath, progressPaint);

      // Add glowing effect at the end
      final glowPaint = Paint()
        ..color = theme.primaryColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(progressPath, glowPaint);
    }
  }

  void _paintParticles(Canvas canvas, Size size) {
    if (!journey.settings.particleEffects) return;

    final particleCount = (20 * animationProgress).round();

    for (int i = 0; i < particleCount; i++) {
      final progress = (i / particleCount) * animationProgress;
      final path = _createSnakePath(size);
      final pathMetrics = path.computeMetrics();

      for (final pathMetric in pathMetrics) {
        final position =
            pathMetric.getTangentForOffset(pathMetric.length * progress);
        if (position != null) {
          final particlePosition = position.position;

          // Add some randomness
          final randomOffset = Offset(
            (math.Random().nextDouble() - 0.5) * 20,
            (math.Random().nextDouble() - 0.5) * 20,
          );

          final finalPosition = particlePosition + randomOffset;

          // Paint particle
          final particlePaint = Paint()
            ..color = theme.primaryColor.withValues(alpha: 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

          canvas.drawCircle(finalPosition, 2, particlePaint);
        }
      }
    }
  }

  Path _createSnakePath(Size size) {
    final path = Path();

    if (journey.memories.isEmpty) return path;

    // Create a smooth, organic curve through the memory positions
    final points = journey.memories
        .where((memory) => memory.roadPosition != null)
        .map((memory) => memory.roadPosition!)
        .toList();

    if (points.isEmpty) return path;

    // Start point
    path.moveTo(points.first.dx, points.first.dy);

    // Create smooth curves between points
    for (int i = 1; i < points.length; i++) {
      final currentPoint = points[i];
      final previousPoint = points[i - 1];

      // Calculate control points for smooth curves
      final controlPoint1 = Offset(
        previousPoint.dx + (currentPoint.dx - previousPoint.dx) * 0.3,
        previousPoint.dy + (currentPoint.dy - previousPoint.dy) * 0.3,
      );

      final controlPoint2 = Offset(
        previousPoint.dx + (currentPoint.dx - previousPoint.dx) * 0.7,
        previousPoint.dy + (currentPoint.dy - previousPoint.dy) * 0.7,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        currentPoint.dx,
        currentPoint.dy,
      );
    }

    return path;
  }

  Path _createCenterLinePath(Size size) {
    final path = Path();
    final snakePath = _createSnakePath(size);

    // Create a dashed center line along the snake path
    final pathMetrics = snakePath.computeMetrics();

    for (final pathMetric in pathMetrics) {
      final dashLength = 10.0;
      final gapLength = 5.0;
      double distance = 0.0;

      while (distance < pathMetric.length) {
        final startPoint = pathMetric.getTangentForOffset(distance);
        final endPoint = pathMetric.getTangentForOffset(
          (distance + dashLength).clamp(0.0, pathMetric.length),
        );

        if (startPoint != null && endPoint != null) {
          path.moveTo(startPoint.position.dx, startPoint.position.dy);
          path.lineTo(endPoint.position.dx, endPoint.position.dy);
        }

        distance += dashLength + gapLength;
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(SnakePathPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.currentMemoryIndex != currentMemoryIndex ||
        oldDelegate.journey != journey;
  }
}
