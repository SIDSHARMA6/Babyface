import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/memory_model.dart';

/// Enhanced Snake Path Painter with 3D Road Design
/// Implements glossy material, metallic highlights, and realistic depth
class EnhancedSnakePathPainter extends CustomPainter {
  final double progress;
  final List<MemoryModel> memories;
  final String theme;
  final double zoom;
  final Offset pan;
  final bool showDepthOfField;

  EnhancedSnakePathPainter({
    required this.progress,
    required this.memories,
    required this.theme,
    this.zoom = 1.0,
    this.pan = Offset.zero,
    this.showDepthOfField = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (memories.isEmpty) return;

    // Apply zoom and pan transformations
    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(zoom);

    // Draw background gradient
    _drawBackgroundGradient(canvas, size);

    // Draw atmospheric particles
    _drawAtmosphericParticles(canvas, size);

    // Draw the 3D road with depth
    _draw3DRoad(canvas, size);

    // Draw progress stroke with glow
    _drawProgressStroke(canvas, size);

    // Draw road highlights and reflections
    _drawRoadHighlights(canvas, size);

    canvas.restore();
  }

  void _drawBackgroundGradient(Canvas canvas, Size size) {
    final themeColors = _getThemeColors();

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        themeColors['skyStart']!,
        themeColors['skyEnd']!,
      ],
    );

    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawAtmosphericParticles(Canvas canvas, Size size) {
    final themeColors = _getThemeColors();
    final particleColor = themeColors['particle']!;

    // Draw floating sparkles
    for (int i = 0; i < 20; i++) {
      final x = (i * 37.0) % size.width;
      final y = (i * 23.0) % size.height;
      final alpha =
          (math.sin(DateTime.now().millisecondsSinceEpoch * 0.001 + i) + 1) / 2;

      final paint = Paint()
        ..color = particleColor.withValues(alpha: alpha * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }

    // Draw heart particles occasionally
    if (DateTime.now().millisecondsSinceEpoch % 3000 < 100) {
      final heartX = (DateTime.now().millisecondsSinceEpoch * 0.1) % size.width;
      final heartY =
          (DateTime.now().millisecondsSinceEpoch * 0.05) % size.height;

      _drawHeartParticle(canvas, Offset(heartX, heartY), particleColor);
    }
  }

  void _drawHeartParticle(Canvas canvas, Offset position, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    // Simple heart shape using circles and triangle
    canvas.drawCircle(Offset(position.dx - 2, position.dy - 1), 2, paint);
    canvas.drawCircle(Offset(position.dx + 2, position.dy - 1), 2, paint);

    final path = Path();
    path.moveTo(position.dx - 4, position.dy);
    path.lineTo(position.dx, position.dy + 4);
    path.lineTo(position.dx + 4, position.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _draw3DRoad(Canvas canvas, Size size) {
    final themeColors = _getThemeColors();
    final roadPath = _createRoadPath(size);

    // Draw road shadow
    _drawRoadShadow(canvas, roadPath, themeColors);

    // Draw main road surface
    _drawRoadSurface(canvas, roadPath, themeColors);

    // Draw road edges with metallic highlights
    _drawRoadEdges(canvas, roadPath, themeColors);

    // Draw road center line
    _drawRoadCenterLine(canvas, roadPath, themeColors);
  }

  Path _createRoadPath(Size size) {
    final path = Path();
    if (memories.isEmpty) return path;

    // Create organic spline curve
    final points = <Offset>[];
    for (int i = 0; i <= memories.length; i++) {
      final t = i / memories.length;
      final x = size.width * (0.1 + t * 0.8);
      final y = size.height *
          (0.3 +
              math.sin(t * math.pi * 2) * 0.2 +
              math.sin(t * math.pi * 4) * 0.05);
      points.add(Offset(x, y));
    }

    // Create smooth spline through points
    if (points.length >= 2) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        if (i == 1) {
          // First curve
          final controlPoint1 = Offset(
            points[0].dx + (points[1].dx - points[0].dx) * 0.3,
            points[0].dy,
          );
          final controlPoint2 = Offset(
            points[1].dx - (points[1].dx - points[0].dx) * 0.3,
            points[1].dy,
          );
          path.cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            points[1].dx,
            points[1].dy,
          );
        } else {
          // Subsequent curves
          final prevPoint = points[i - 1];
          final currentPoint = points[i];
          final nextPoint =
              i < points.length - 1 ? points[i + 1] : currentPoint;

          final controlPoint1 = Offset(
            prevPoint.dx + (currentPoint.dx - prevPoint.dx) * 0.5,
            prevPoint.dy,
          );
          final controlPoint2 = Offset(
            currentPoint.dx - (nextPoint.dx - currentPoint.dx) * 0.5,
            currentPoint.dy,
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
      }
    }

    return path;
  }

  void _drawRoadShadow(
      Canvas canvas, Path roadPath, Map<String, Color> themeColors) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    // Offset shadow path
    final shadowPath = Path();
    final pathMetrics = roadPath.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final shadowPathSegment = pathMetric.extractPath(0, pathMetric.length);
      shadowPath.addPath(shadowPathSegment, const Offset(3, 3));
    }

    canvas.drawPath(shadowPath, shadowPaint);
  }

  void _drawRoadSurface(
      Canvas canvas, Path roadPath, Map<String, Color> themeColors) {
    // Create gradient for road surface
    final roadGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        themeColors['roadLight']!,
        themeColors['roadDark']!,
      ],
    );

    final roadPaint = Paint()
      ..shader = roadGradient.createShader(Rect.fromLTWH(0, 0, 1000, 1000))
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(roadPath, roadPaint);
  }

  void _drawRoadEdges(
      Canvas canvas, Path roadPath, Map<String, Color> themeColors) {
    // Draw metallic edges
    final edgePaint = Paint()
      ..color = themeColors['metallic']!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create parallel paths for edges
    final pathMetrics = roadPath.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final leftEdgeSegment = pathMetric.extractPath(0, pathMetric.length);
      final rightEdgeSegment = pathMetric.extractPath(0, pathMetric.length);

      canvas.drawPath(leftEdgeSegment, edgePaint);
      canvas.drawPath(rightEdgeSegment, edgePaint);
    }
  }

  void _drawRoadCenterLine(
      Canvas canvas, Path roadPath, Map<String, Color> themeColors) {
    final centerPaint = Paint()
      ..color = themeColors['centerLine']!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    canvas.drawPath(roadPath, centerPaint);
  }

  void _drawProgressStroke(Canvas canvas, Size size) {
    final themeColors = _getThemeColors();
    final roadPath = _createRoadPath(size);

    final progressPaint = Paint()
      ..color = themeColors['progress']!
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Draw progress stroke
    final pathMetrics = roadPath.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final progressLength = pathMetric.length * progress;
      final progressPath = pathMetric.extractPath(0, progressLength);
      canvas.drawPath(progressPath, progressPaint);
    }

    // Draw glow trail
    final glowPaint = Paint()
      ..color = themeColors['progressGlow']!
      ..strokeWidth = 16.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    for (final pathMetric in pathMetrics) {
      final progressLength = pathMetric.length * progress;
      final progressPath = pathMetric.extractPath(0, progressLength);
      canvas.drawPath(progressPath, glowPaint);
    }
  }

  void _drawRoadHighlights(Canvas canvas, Size size) {
    final themeColors = _getThemeColors();
    final roadPath = _createRoadPath(size);

    // Draw subtle highlights along the road
    final highlightPaint = Paint()
      ..color = themeColors['highlight']!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final pathMetrics = roadPath.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final highlightSegment = pathMetric.extractPath(0, pathMetric.length);
      canvas.drawPath(highlightSegment, highlightPaint);
    }
  }

  Map<String, Color> _getThemeColors() {
    switch (theme) {
      case 'romantic-sunset':
        return {
          'skyStart': const Color(0xFFFF6B9D).withValues(alpha: 0.3),
          'skyEnd': const Color(0xFF2C3E50).withValues(alpha: 0.8),
          'roadLight': const Color(0xFFFFB347),
          'roadDark': const Color(0xFFE67E22),
          'metallic': const Color(0xFFFFD700),
          'centerLine': Colors.white.withValues(alpha: 0.8),
          'progress': const Color(0xFFFF6B9D),
          'progressGlow': const Color(0xFFFF6B9D).withValues(alpha: 0.6),
          'highlight': Colors.white.withValues(alpha: 0.6),
          'particle': const Color(0xFFFFD700),
        };
      case 'love-garden':
        return {
          'skyStart': const Color(0xFFFFB6C1).withValues(alpha: 0.3),
          'skyEnd': const Color(0xFF9CAF88).withValues(alpha: 0.8),
          'roadLight': const Color(0xFF98FB98),
          'roadDark': const Color(0xFF9CAF88),
          'metallic': const Color(0xFFD4A5A5),
          'centerLine': Colors.white.withValues(alpha: 0.8),
          'progress': const Color(0xFFFFB6C1),
          'progressGlow': const Color(0xFFFFB6C1).withValues(alpha: 0.6),
          'highlight': Colors.white.withValues(alpha: 0.6),
          'particle': const Color(0xFF98FB98),
        };
      case 'midnight-romance':
        return {
          'skyStart': const Color(0xFF4B0082).withValues(alpha: 0.3),
          'skyEnd': const Color(0xFF191970).withValues(alpha: 0.8),
          'roadLight': const Color(0xFFC0C0C0),
          'roadDark': const Color(0xFF4B0082),
          'metallic': const Color(0xFFE8B4B8),
          'centerLine': Colors.white.withValues(alpha: 0.8),
          'progress': const Color(0xFFE8B4B8),
          'progressGlow': const Color(0xFFE8B4B8).withValues(alpha: 0.6),
          'highlight': Colors.white.withValues(alpha: 0.6),
          'particle': const Color(0xFFC0C0C0),
        };
      default:
        return {
          'skyStart': const Color(0xFFFF6B9D).withValues(alpha: 0.3),
          'skyEnd': const Color(0xFF2C3E50).withValues(alpha: 0.8),
          'roadLight': const Color(0xFFFFB347),
          'roadDark': const Color(0xFFE67E22),
          'metallic': const Color(0xFFFFD700),
          'centerLine': Colors.white.withValues(alpha: 0.8),
          'progress': const Color(0xFFFF6B9D),
          'progressGlow': const Color(0xFFFF6B9D).withValues(alpha: 0.6),
          'highlight': Colors.white.withValues(alpha: 0.6),
          'particle': const Color(0xFFFFD700),
        };
    }
  }

  @override
  bool shouldRepaint(covariant EnhancedSnakePathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.memories != memories ||
        oldDelegate.theme != theme ||
        oldDelegate.zoom != zoom ||
        oldDelegate.pan != pan ||
        oldDelegate.showDepthOfField != showDepthOfField;
  }
}
