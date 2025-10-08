import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../data/models/memory_model.dart';

/// Road Painter for 3D curved road visualization
/// Follows memory_journey.md specification for journey preview
class RoadPainter extends CustomPainter {
  final List<Offset> roadPoints;
  final List<MemoryModel> memories;
  final double animationValue;
  final bool isSelected;
  final int? selectedMemoryIndex;
  final Color primaryColor;
  final Color secondaryColor;

  RoadPainter({
    required this.roadPoints,
    required this.memories,
    this.animationValue = 1.0,
    this.isSelected = false,
    this.selectedMemoryIndex,
    this.primaryColor = AppTheme.primaryPink,
    this.secondaryColor = AppTheme.primaryBlue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (roadPoints.isEmpty) return;

    _drawRoadBackground(canvas, size);
    _drawRoadPath(canvas, size);
    _drawRoadMarkings(canvas, size);
    _drawMemoryPositions(canvas, size);
    _drawForeverPoint(canvas, size);
  }

  void _drawRoadBackground(Canvas canvas, Size size) {
    // Create gradient background for the road area
    final roadRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final gradient = LinearGradient(
      colors: [
        primaryColor.withValues(alpha: 0.1),
        secondaryColor.withValues(alpha: 0.05),
        primaryColor.withValues(alpha: 0.1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(roadRect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(roadRect, paint);
  }

  void _drawRoadPath(Canvas canvas, Size size) {
    if (roadPoints.length < 2) return;

    final path = Path();
    final roadWidth = 60.0;

    // Create smooth curved path
    path.moveTo(roadPoints.first.dx, roadPoints.first.dy);

    for (int i = 1; i < roadPoints.length; i++) {
      final current = roadPoints[i];
      final previous = roadPoints[i - 1];

      // Create smooth curves between points
      if (i < roadPoints.length - 1) {
        final next = roadPoints[i + 1];
        final controlPoint1 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.5,
          previous.dy + (current.dy - previous.dy) * 0.5,
        );
        final controlPoint2 = Offset(
          current.dx - (next.dx - current.dx) * 0.5,
          current.dy - (next.dy - current.dy) * 0.5,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          current.dx,
          current.dy,
        );
      } else {
        path.lineTo(current.dx, current.dy);
      }
    }

    // Draw road shadow
    final shadowPath = Path();
    shadowPath.addPath(path, const Offset(2, 2));

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = roadWidth + 4;

    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main road
    final roadPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = roadWidth;

    canvas.drawPath(path, roadPaint);

    // Draw road edges
    _drawRoadEdges(canvas, path, roadWidth);
  }

  void _drawRoadEdges(Canvas canvas, Path centerPath, double roadWidth) {
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Create parallel paths for road edges
    final leftEdge = _createParallelPath(centerPath, -roadWidth / 2);
    final rightEdge = _createParallelPath(centerPath, roadWidth / 2);

    canvas.drawPath(leftEdge, edgePaint);
    canvas.drawPath(rightEdge, edgePaint);
  }

  Path _createParallelPath(Path originalPath, double offset) {
    // Simplified parallel path creation
    // In a real implementation, you'd use more sophisticated path offsetting
    final path = Path();
    path.addPath(originalPath, Offset(0, offset));
    return path;
  }

  void _drawRoadMarkings(Canvas canvas, Size size) {
    if (roadPoints.length < 2) return;

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw dashed center line
    for (int i = 0; i < roadPoints.length - 1; i++) {
      final start = roadPoints[i];
      final end = roadPoints[i + 1];

      if (i % 3 == 0) {
        // Every 3rd segment
        canvas.drawLine(start, end, dashPaint);
      }
    }
  }

  void _drawMemoryPositions(Canvas canvas, Size size) {
    for (int i = 0; i < memories.length && i < roadPoints.length; i++) {
      final memory = memories[i];
      final position = roadPoints[i];
      final isSelected = selectedMemoryIndex == i;

      _drawMemoryPin(canvas, position, memory, isSelected);
    }
  }

  void _drawMemoryPin(
      Canvas canvas, Offset position, MemoryModel memory, bool isSelected) {
    final pinSize = isSelected ? 16.0 : 12.0;
    final glowRadius = isSelected ? 20.0 : 0.0;

    // Draw glow effect for selected pin
    if (isSelected) {
      final glowPaint = Paint()
        ..color = _getMoodColor(memory.mood).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(position, glowRadius, glowPaint);
    }

    // Draw pin background
    final pinPaint = Paint()
      ..color = _getMoodColor(memory.mood)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, pinSize, pinPaint);

    // Draw pin border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(position, pinSize, borderPaint);

    // Draw memory emoji or icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: memory.emoji,
        style: TextStyle(
          fontSize: pinSize * 0.8,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawForeverPoint(Canvas canvas, Size size) {
    if (roadPoints.isEmpty) return;

    final endPoint = roadPoints.last;
    final foreverPointSize = 24.0;

    // Draw sparkle effect
    _drawSparkles(canvas, endPoint, foreverPointSize);

    // Draw forever point (ring)
    final ringPaint = Paint()
      ..color = AppTheme.accentYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(endPoint, foreverPointSize, ringPaint);

    // Draw inner circle
    final innerPaint = Paint()
      ..color = AppTheme.accentYellow.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(endPoint, foreverPointSize * 0.7, innerPaint);

    // Draw ring icon
    _drawRingIcon(canvas, endPoint, foreverPointSize * 0.5);
  }

  void _drawSparkles(Canvas canvas, Offset center, double size) {
    final sparklePaint = Paint()
      ..color = AppTheme.accentYellow.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Draw multiple sparkles around the forever point
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final sparkleDistance = size * 1.5;
      final sparkleX = center.dx + math.cos(angle) * sparkleDistance;
      final sparkleY = center.dy + math.sin(angle) * sparkleDistance;

      // Animate sparkles
      final sparkleSize =
          3.0 * (0.5 + 0.5 * math.sin(animationValue * math.pi * 2 + angle));

      canvas.drawCircle(
        Offset(sparkleX, sparkleY),
        sparkleSize,
        sparklePaint,
      );
    }
  }

  void _drawRingIcon(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppTheme.accentYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw ring shape
    canvas.drawCircle(center, radius, paint);

    // Draw small circle in center
    canvas.drawCircle(center, radius * 0.3, paint);
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'excited':
        return Colors.orange;
      case 'romantic':
        return Colors.pink;
      case 'grateful':
        return Colors.purple;
      case 'peaceful':
        return Colors.blue;
      case 'nostalgic':
        return Colors.indigo;
      default:
        return AppTheme.primaryPink;
    }
  }

  @override
  bool shouldRepaint(RoadPainter oldDelegate) {
    return oldDelegate.roadPoints != roadPoints ||
        oldDelegate.memories != memories ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.selectedMemoryIndex != selectedMemoryIndex;
  }
}

/// Journey Road Painter with enhanced 3D effects
class JourneyRoadPainter extends CustomPainter {
  final List<Offset> roadPoints;
  final List<MemoryModel> memories;
  final double animationValue;
  final int? selectedMemoryIndex;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showShimmer;

  JourneyRoadPainter({
    required this.roadPoints,
    required this.memories,
    this.animationValue = 1.0,
    this.selectedMemoryIndex,
    this.primaryColor = AppTheme.primaryPink,
    this.secondaryColor = AppTheme.primaryBlue,
    this.showShimmer = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (roadPoints.isEmpty) return;

    _drawRoadBackground(canvas, size);
    _drawRoadPath(canvas, size);
    _drawRoadMarkings(canvas, size);
    _drawMemoryPositions(canvas, size);
    _drawForeverPoint(canvas, size);

    if (showShimmer) {
      _drawShimmerEffect(canvas, size);
    }
  }

  void _drawRoadBackground(Canvas canvas, Size size) {
    // Create 3D gradient background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final gradient = LinearGradient(
      colors: [
        primaryColor.withValues(alpha: 0.15),
        secondaryColor.withValues(alpha: 0.08),
        primaryColor.withValues(alpha: 0.12),
        secondaryColor.withValues(alpha: 0.06),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  void _drawRoadPath(Canvas canvas, Size size) {
    if (roadPoints.length < 2) return;

    final path = _createSmoothPath();
    final roadWidth = 80.0;

    // Draw road shadow with 3D effect
    final shadowPath = Path();
    shadowPath.addPath(path, const Offset(3, 3));

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = roadWidth + 6;

    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main road with gradient
    _drawGradientRoad(canvas, path, roadWidth);

    // Draw road edges with 3D effect
    _drawRoadEdges3D(canvas, path, roadWidth);
  }

  Path _createSmoothPath() {
    final path = Path();

    if (roadPoints.isEmpty) return path;

    path.moveTo(roadPoints.first.dx, roadPoints.first.dy);

    for (int i = 1; i < roadPoints.length; i++) {
      final current = roadPoints[i];
      final previous = roadPoints[i - 1];

      if (i < roadPoints.length - 1) {
        final next = roadPoints[i + 1];

        // Create smooth cubic bezier curves
        final controlPoint1 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.6,
          previous.dy + (current.dy - previous.dy) * 0.6,
        );
        final controlPoint2 = Offset(
          current.dx - (next.dx - current.dx) * 0.6,
          current.dy - (next.dy - current.dy) * 0.6,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          current.dx,
          current.dy,
        );
      } else {
        path.lineTo(current.dx, current.dy);
      }
    }

    return path;
  }

  void _drawGradientRoad(Canvas canvas, Path path, double roadWidth) {
    // Create gradient for road surface
    final rect =
        Rect.fromLTWH(0, 0, 1000, 1000); // Large enough to cover the path

    final gradient = LinearGradient(
      colors: [
        primaryColor.withValues(alpha: 0.9),
        primaryColor.withValues(alpha: 0.7),
        secondaryColor.withValues(alpha: 0.6),
        primaryColor.withValues(alpha: 0.8),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = roadWidth;

    canvas.drawPath(path, paint);
  }

  void _drawRoadEdges3D(Canvas canvas, Path centerPath, double roadWidth) {
    final edgeWidth = 3.0;

    // Left edge
    final leftEdgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = edgeWidth;

    final leftEdge = _createParallelPath(centerPath, -roadWidth / 2);
    canvas.drawPath(leftEdge, leftEdgePaint);

    // Right edge
    final rightEdge = _createParallelPath(centerPath, roadWidth / 2);
    canvas.drawPath(rightEdge, leftEdgePaint);

    // Add 3D highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final leftHighlight = _createParallelPath(centerPath, -roadWidth / 2 + 1);
    final rightHighlight = _createParallelPath(centerPath, roadWidth / 2 - 1);

    canvas.drawPath(leftHighlight, highlightPaint);
    canvas.drawPath(rightHighlight, highlightPaint);
  }

  Path _createParallelPath(Path originalPath, double offset) {
    // Simplified parallel path creation
    final path = Path();
    path.addPath(originalPath, Offset(0, offset));
    return path;
  }

  void _drawRoadMarkings(Canvas canvas, Size size) {
    if (roadPoints.length < 2) return;

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw animated dashed center line
    for (int i = 0; i < roadPoints.length - 1; i++) {
      final start = roadPoints[i];
      final end = roadPoints[i + 1];

      if ((i + (animationValue * 10).toInt()) % 4 < 2) {
        canvas.drawLine(start, end, dashPaint);
      }
    }
  }

  void _drawMemoryPositions(Canvas canvas, Size size) {
    for (int i = 0; i < memories.length && i < roadPoints.length; i++) {
      final memory = memories[i];
      final position = roadPoints[i];
      final isSelected = selectedMemoryIndex == i;

      _drawEnhancedMemoryPin(canvas, position, memory, isSelected);
    }
  }

  void _drawEnhancedMemoryPin(
      Canvas canvas, Offset position, MemoryModel memory, bool isSelected) {
    final pinSize = isSelected ? 20.0 : 14.0;
    final glowRadius = isSelected ? 30.0 : 0.0;

    // Draw glow effect
    if (isSelected) {
      final glowPaint = Paint()
        ..color = _getMoodColor(memory.mood).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawCircle(position, glowRadius, glowPaint);
    }

    // Draw pin with 3D effect
    _drawPin3D(canvas, position, pinSize, memory);
  }

  void _drawPin3D(
      Canvas canvas, Offset position, double size, MemoryModel memory) {
    final color = _getMoodColor(memory.mood);

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(position.dx + 2, position.dy + 2),
      size,
      shadowPaint,
    );

    // Draw main pin
    final pinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, size, pinPaint);

    // Draw highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(position.dx - size * 0.3, position.dy - size * 0.3),
      size * 0.3,
      highlightPaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(position, size, borderPaint);

    // Draw memory emoji
    final textPainter = TextPainter(
      text: TextSpan(
        text: memory.emoji,
        style: TextStyle(
          fontSize: size * 0.7,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawForeverPoint(Canvas canvas, Size size) {
    if (roadPoints.isEmpty) return;

    final endPoint = roadPoints.last;
    final foreverPointSize = 32.0;

    // Draw enhanced forever point
    _drawEnhancedForeverPoint(canvas, endPoint, foreverPointSize);
  }

  void _drawEnhancedForeverPoint(Canvas canvas, Offset center, double size) {
    // Draw outer glow
    final outerGlowPaint = Paint()
      ..color = AppTheme.accentYellow.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, size * 1.5, outerGlowPaint);

    // Draw sparkles
    _drawAnimatedSparkles(canvas, center, size);

    // Draw main ring
    final ringPaint = Paint()
      ..color = AppTheme.accentYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, size, ringPaint);

    // Draw inner circle
    final innerPaint = Paint()
      ..color = AppTheme.accentYellow.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size * 0.7, innerPaint);

    // Draw ring icon
    _drawRingIcon(canvas, center, size * 0.5);
  }

  void _drawAnimatedSparkles(Canvas canvas, Offset center, double size) {
    final sparklePaint = Paint()
      ..color = AppTheme.accentYellow.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2) / 12;
      final sparkleDistance = size * 2.0;
      final sparkleX = center.dx + math.cos(angle) * sparkleDistance;
      final sparkleY = center.dy + math.sin(angle) * sparkleDistance;

      // Animate sparkles
      final sparkleSize =
          4.0 * (0.3 + 0.7 * math.sin(animationValue * math.pi * 3 + angle));

      canvas.drawCircle(
        Offset(sparkleX, sparkleY),
        sparkleSize,
        sparklePaint,
      );
    }
  }

  void _drawRingIcon(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppTheme.accentYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw ring
    canvas.drawCircle(center, radius, paint);

    // Draw small center circle
    canvas.drawCircle(center, radius * 0.4, paint);
  }

  void _drawShimmerEffect(Canvas canvas, Size size) {
    final shimmerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Create shimmer effect along the road
    for (int i = 0; i < roadPoints.length - 1; i++) {
      final start = roadPoints[i];
      final end = roadPoints[i + 1];

      if ((i + (animationValue * 20).toInt()) % 10 < 3) {
        final shimmerRect = Rect.fromPoints(start, end);
        canvas.drawRect(shimmerRect, shimmerPaint);
      }
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'excited':
        return Colors.orange;
      case 'romantic':
        return Colors.pink;
      case 'grateful':
        return Colors.purple;
      case 'peaceful':
        return Colors.blue;
      case 'nostalgic':
        return Colors.indigo;
      default:
        return AppTheme.primaryPink;
    }
  }

  @override
  bool shouldRepaint(JourneyRoadPainter oldDelegate) {
    return oldDelegate.roadPoints != roadPoints ||
        oldDelegate.memories != memories ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.selectedMemoryIndex != selectedMemoryIndex ||
        oldDelegate.showShimmer != showShimmer;
  }
}
