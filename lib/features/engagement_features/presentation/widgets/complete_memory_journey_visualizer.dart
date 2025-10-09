import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../domain/entities/memory_journey_entity.dart';
import '../../data/models/memory_model.dart';

/// Simple Memory Journey Visualizer - Exact Image Match
/// Just like the uploaded image: white background, dark gray road, colored pins
class CompleteMemoryJourneyVisualizer extends ConsumerStatefulWidget {
  final MemoryJourneyEntity journey;
  final VoidCallback? onClose;
  final Function(MemoryModel)? onMemoryTap;

  const CompleteMemoryJourneyVisualizer({
    super.key,
    required this.journey,
    this.onClose,
    this.onMemoryTap,
  });

  @override
  ConsumerState<CompleteMemoryJourneyVisualizer> createState() =>
      _CompleteMemoryJourneyVisualizerState();
}

class _CompleteMemoryJourneyVisualizerState
    extends ConsumerState<CompleteMemoryJourneyVisualizer> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  void _onMemoryTap(MemoryModel memory) {
    HapticFeedback.lightImpact();
    widget.onMemoryTap?.call(memory);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Exact white background like image
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.journey.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),
      body: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 3.0,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: RoadPainter(memories: widget.journey.memories),
            child: Stack(
              children: [
                // Memory pins - colored like the image
                for (final entry
                    in widget.journey.memories.asMap().entries) ...[
                  Builder(
                    builder: (context) {
                      final index = entry.key;
                      final memory = entry.value;
                      final position = _calculateMemoryPosition(index);

                      return Positioned(
                        left: position.dx - 20,
                        top: position.dy - 40,
                        child: GestureDetector(
                          onTap: () => _onMemoryTap(memory),
                          child: _buildMapPin(index, memory),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPin(int index, MemoryModel memory) {
    // Different colors for each pin like in the image
    final colors = [
      Colors.lightBlue, // Light blue
      Colors.yellow, // Yellow
      Colors.purple, // Purple
      Colors.red, // Red
      Colors.teal, // Teal/mint green
    ];

    final pinColor = colors[index % colors.length];

    return CustomPaint(
      size: const Size(40, 50),
      painter: MapPinPainter(
        color: pinColor,
        emoji: memory.emoji,
        photoPath: memory.photoPath,
      ),
    );
  }

  Offset _calculateMemoryPosition(int index) {
    if (widget.journey.memories.isEmpty) return Offset.zero;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Create winding road path like in the image
    final progress = (index + 1) / (widget.journey.memories.length + 1);
    final x = screenWidth * (0.15 + progress * 0.7);

    // More dramatic curves like the image
    final y = screenHeight *
        (0.2 +
            math.sin(progress * math.pi * 3) * 0.3 +
            math.sin(progress * math.pi * 6) * 0.1);

    return Offset(x, y);
  }
}

/// Road painter - draws dark gray road with white dashed lines like the image
class RoadPainter extends CustomPainter {
  final List<MemoryModel> memories;

  RoadPainter({required this.memories});

  @override
  void paint(Canvas canvas, Size size) {
    if (memories.isEmpty) return;

    // Draw road shadow first
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPath = _createRoadPath(size);
    shadowPath.addPath(shadowPath, const Offset(3, 3));
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main road (dark gray like image)
    final roadPaint = Paint()
      ..color = const Color(0xFF4A4A4A) // Dark gray like image
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPath = _createRoadPath(size);
    canvas.drawPath(roadPath, roadPaint);

    // Draw white dashed center line
    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedLine(canvas, dashPaint, roadPath);
  }

  Path _createRoadPath(Size size) {
    final path = Path();
    final points = <Offset>[];

    // Create winding road points
    for (int i = 0; i <= memories.length + 1; i++) {
      final progress = i / (memories.length + 1);
      final x = size.width * (0.15 + progress * 0.7);
      final y = size.height *
          (0.2 +
              math.sin(progress * math.pi * 3) * 0.3 +
              math.sin(progress * math.pi * 6) * 0.1);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        final current = points[i];
        final previous = points[i - 1];

        // Smooth curves
        final controlPoint1 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.5,
          previous.dy,
        );
        final controlPoint2 = Offset(
          current.dx - (current.dx - previous.dx) * 0.5,
          current.dy,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          current.dx,
          current.dy,
        );
      }
    }

    return path;
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Path path) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      const dashLength = 20.0;
      const dashSpace = 15.0;

      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          distance + dashLength,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Map pin painter - draws colored pins like in the image
class MapPinPainter extends CustomPainter {
  final Color color;
  final String emoji;
  final String? photoPath;

  MapPinPainter({
    required this.color,
    required this.emoji,
    this.photoPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Draw pin shadow
    canvas.drawPath(_createPinPath(size, const Offset(2, 2)), shadowPaint);

    // Draw main pin
    canvas.drawPath(_createPinPath(size, Offset.zero), paint);

    // Draw white circle in center
    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 - 5),
      12,
      centerPaint,
    );

    // Draw emoji or photo in center
    if (photoPath != null) {
      // Would need to load image here - for now just show emoji
      _drawEmoji(canvas, size);
    } else {
      _drawEmoji(canvas, size);
    }
  }

  Path _createPinPath(Size size, Offset offset) {
    final path = Path();
    final centerX = size.width / 2 + offset.dx;
    final centerY = size.height / 2 + offset.dy;

    // Pin shape: circle with pointed bottom
    path.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY - 5),
      radius: 15,
    ));

    // Pointed bottom
    path.moveTo(centerX - 8, centerY + 10);
    path.lineTo(centerX, centerY + 20);
    path.lineTo(centerX + 8, centerY + 10);
    path.close();

    return path;
  }

  void _drawEmoji(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 - 5,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
