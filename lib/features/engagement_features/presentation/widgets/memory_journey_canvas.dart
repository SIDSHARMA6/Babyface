import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/memory_journey_entity.dart';
import '../../data/models/memory_model.dart';

/// Memory Journey Canvas Widget
/// Handles the 3D rendering and map-style navigation for the memory journey
class MemoryJourneyCanvas extends StatefulWidget {
  final MemoryJourneyEntity journey;
  final double progress;
  final Function(MemoryModel)? onMemoryTap;
  final Function(double)? onProgressChange;

  const MemoryJourneyCanvas({
    Key? key,
    required this.journey,
    required this.progress,
    this.onMemoryTap,
    this.onProgressChange,
  }) : super(key: key);

  @override
  State<MemoryJourneyCanvas> createState() => _MemoryJourneyCanvasState();
}

class _MemoryJourneyCanvasState extends State<MemoryJourneyCanvas>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _cameraController;
  late AnimationController _pathAnimationController;

  late Animation<double> _pathAnimation;

  double _currentZoom = 1.0;
  Offset _currentPan = Offset.zero;

  final double _minZoom = 0.5;
  final double _maxZoom = 4.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _cameraController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pathAnimationController = AnimationController(
      duration: Duration(seconds: widget.journey.memories.length * 2),
      vsync: this,
    );

    _pathAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pathAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _pathAnimationController.addListener(() {
      widget.onProgressChange?.call(_pathAnimation.value);
    });

    // Start the path animation
    _pathAnimationController.forward();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _cameraController.dispose();
    _pathAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: _minZoom,
      maxScale: _maxZoom,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      onInteractionStart: _onInteractionStart,
      onInteractionUpdate: _onInteractionUpdate,
      onInteractionEnd: _onInteractionEnd,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: MemoryJourneyPainter(
            journey: widget.journey,
            progress: _pathAnimation.value,
            zoom: _currentZoom,
            pan: _currentPan,
          ),
          child: Stack(
            children: [
              // Memory markers
              ...widget.journey.memories.asMap().entries.map((entry) {
                final index = entry.key;
                final memory = entry.value;
                final position = _calculateMemoryPosition(index);

                if (position == null) return const SizedBox.shrink();

                return Positioned(
                  left: position.dx - 30,
                  top: position.dy - 30,
                  child: GestureDetector(
                    onTap: () => widget.onMemoryTap?.call(memory),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getMemoryColor(memory.mood),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          memory.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Offset? _calculateMemoryPosition(int index) {
    if (widget.journey.memories.isEmpty) return null;

    final totalMemories = widget.journey.memories.length;
    final progress = (index + 1) / totalMemories;

    // Create a curved path
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final x = screenWidth * (0.1 + progress * 0.8);
    final y = screenHeight * (0.3 + math.sin(progress * math.pi * 2) * 0.2);

    return Offset(x, y);
  }

  Color _getMemoryColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'joyful':
        return Colors.yellow.shade400;
      case 'romantic':
        return Colors.pink.shade400;
      case 'fun':
        return Colors.orange.shade400;
      case 'sweet':
        return Colors.purple.shade400;
      case 'emotional':
        return Colors.blue.shade400;
      case 'excited':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  void _onInteractionStart(ScaleStartDetails details) {
    // Handle interaction start
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    // Update zoom and pan
    final scale = details.scale;

    setState(() {
      _currentZoom = (_currentZoom * scale).clamp(_minZoom, _maxZoom);
      _currentPan += details.focalPointDelta;
    });
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    // Handle interaction end
  }
}

/// Custom painter for the memory journey
class MemoryJourneyPainter extends CustomPainter {
  final MemoryJourneyEntity journey;
  final double progress;
  final double zoom;
  final Offset pan;

  MemoryJourneyPainter({
    required this.journey,
    required this.progress,
    required this.zoom,
    required this.pan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (journey.memories.isEmpty) return;

    // Draw background gradient
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.pink.shade100,
          Colors.purple.shade200,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw the path
    _drawPath(canvas, size);

    // Draw progress stroke
    _drawProgressStroke(canvas, size);
  }

  void _drawPath(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final shadowPath = Path();

    // Create curved path
    for (int i = 0; i <= journey.memories.length; i++) {
      final progress = i / journey.memories.length;
      final x = size.width * (0.1 + progress * 0.8);
      final y = size.height * (0.3 + math.sin(progress * math.pi * 2) * 0.2);

      if (i == 0) {
        path.moveTo(x, y);
        shadowPath.moveTo(x + 2, y + 2);
      } else {
        path.lineTo(x, y);
        shadowPath.lineTo(x + 2, y + 2);
      }
    }

    // Draw shadow first
    canvas.drawPath(shadowPath, shadowPaint);
    // Draw main path
    canvas.drawPath(path, pathPaint);
  }

  void _drawProgressStroke(Canvas canvas, Size size) {
    final progressPaint = Paint()
      ..color = Colors.pink.shade400
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Create curved path up to progress point
    final progressPoint = (journey.memories.length * progress).floor();
    for (int i = 0; i <= progressPoint; i++) {
      final progress = i / journey.memories.length;
      final x = size.width * (0.1 + progress * 0.8);
      final y = size.height * (0.3 + math.sin(progress * math.pi * 2) * 0.2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, progressPaint);
  }

  @override
  bool shouldRepaint(covariant MemoryJourneyPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.zoom != zoom ||
        oldDelegate.pan != pan ||
        oldDelegate.journey != journey;
  }
}
