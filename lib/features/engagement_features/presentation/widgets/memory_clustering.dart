import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/memory_model.dart';
import '../services/theme_manager.dart';

/// Memory Clustering System
/// Groups nearby memories at low zoom levels and highlights path segments
class MemoryClustering extends StatefulWidget {
  final List<MemoryModel> memories;
  final double zoom;
  final Offset pan;
  final String theme;
  final Function(MemoryModel) onMemoryTap;
  final Function(List<MemoryModel>) onClusterTap;

  const MemoryClustering({
    Key? key,
    required this.memories,
    required this.zoom,
    required this.pan,
    required this.theme,
    required this.onMemoryTap,
    required this.onClusterTap,
  }) : super(key: key);

  @override
  State<MemoryClustering> createState() => _MemoryClusteringState();
}

class _MemoryClusteringState extends State<MemoryClustering>
    with TickerProviderStateMixin {
  late AnimationController _clusterAnimationController;
  late Animation<double> _clusterAnimation;

  List<MemoryCluster> _clusters = [];
  List<PathSegment> _pathSegments = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _calculateClusters();
  }

  void _initializeAnimations() {
    _clusterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _clusterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _clusterAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(MemoryClustering oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.zoom != oldWidget.zoom ||
        widget.memories != oldWidget.memories) {
      _calculateClusters();
      _clusterAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _clusterAnimationController.dispose();
    super.dispose();
  }

  void _calculateClusters() {
    _clusters.clear();
    _pathSegments.clear();

    if (widget.memories.isEmpty) return;

    // Determine clustering threshold based on zoom level
    final clusteringThreshold = _getClusteringThreshold();

    if (widget.zoom < clusteringThreshold) {
      // Create clusters
      _createClusters();
    } else {
      // Show individual memories
      _createIndividualMemories();
    }

    // Calculate path segments for highlighting
    _calculatePathSegments();
  }

  double _getClusteringThreshold() {
    // Cluster when zoom is below 1.5x
    return 1.5;
  }

  void _createClusters() {
    final clusters = <MemoryCluster>[];
    final processed = <int>{};

    for (int i = 0; i < widget.memories.length; i++) {
      if (processed.contains(i)) continue;

      final memory = widget.memories[i];
      final memories = <MemoryModel>[memory];
      Offset clusterCenter = _calculateMemoryPosition(i);

      // Find nearby memories to cluster
      for (int j = i + 1; j < widget.memories.length; j++) {
        if (processed.contains(j)) continue;

        final otherMemory = widget.memories[j];
        final otherPosition = _calculateMemoryPosition(j);
        final distance = (clusterCenter - otherPosition).distance;

        if (distance < 80.0) {
          // Cluster radius
          memories.add(otherMemory);
          clusterCenter = Offset(
            (clusterCenter.dx + otherPosition.dx) / 2,
            (clusterCenter.dy + otherPosition.dy) / 2,
          );
          processed.add(j);
        }
      }

      // Create final cluster
      final cluster = MemoryCluster(
        center: clusterCenter,
        memories: memories,
        radius: 30.0,
        theme: widget.theme,
      );

      processed.add(i);
      clusters.add(cluster);
    }

    _clusters = clusters;
  }

  void _createIndividualMemories() {
    // Create single-memory clusters for individual display
    _clusters = widget.memories.asMap().entries.map((entry) {
      final index = entry.key;
      final memory = entry.value;
      return MemoryCluster(
        center: _calculateMemoryPosition(index),
        memories: [memory],
        radius: 25.0,
        theme: widget.theme,
      );
    }).toList();
  }

  void _calculatePathSegments() {
    if (widget.memories.length < 2) return;

    _pathSegments.clear();

    for (int i = 0; i < widget.memories.length - 1; i++) {
      final start = _calculateMemoryPosition(i);
      final end = _calculateMemoryPosition(i + 1);

      _pathSegments.add(PathSegment(
        start: start,
        end: end,
        isHighlighted: _shouldHighlightSegment(i),
        theme: widget.theme,
      ));
    }
  }

  bool _shouldHighlightSegment(int index) {
    // Highlight segments based on zoom level and memory importance
    final memory = widget.memories[index];
    final mood = MemoryMood.fromString(memory.mood);
    final isImportant = memory.isFavorite ||
        mood == MemoryMood.joyful ||
        mood == MemoryMood.romantic;

    return widget.zoom > 1.0 && isImportant;
  }

  Offset _calculateMemoryPosition(int index) {
    // Calculate memory position based on index and journey layout
    final totalMemories = widget.memories.length;
    final progress = index / (totalMemories - 1).clamp(1, double.infinity);

    // Create a curved path for memories
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final x = screenWidth * 0.1 + (screenWidth * 0.8) * progress;
    final y = screenHeight * 0.3 +
        math.sin(progress * math.pi * 2) * 100 +
        math.sin(progress * math.pi * 4) * 50;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _clusterAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: MemoryClusteringPainter(
            clusters: _clusters,
            pathSegments: _pathSegments,
            animationValue: _clusterAnimation.value,
            zoom: widget.zoom,
            pan: widget.pan,
          ),
          size: Size.infinite,
          child: _buildInteractiveOverlay(),
        );
      },
    );
  }

  Widget _buildInteractiveOverlay() {
    return Stack(
      children: [
        // Path segments
        ..._pathSegments.map((segment) => _buildPathSegmentOverlay(segment)),

        // Memory clusters
        ..._clusters.map((cluster) => _buildClusterOverlay(cluster)),
      ],
    );
  }

  Widget _buildPathSegmentOverlay(PathSegment segment) {
    return Positioned(
      left: math.min(segment.start.dx, segment.end.dx) - 10,
      top: math.min(segment.start.dy, segment.end.dy) - 10,
      child: GestureDetector(
        onTap: () {
          // Handle path segment tap
        },
        child: Container(
          width: (segment.end.dx - segment.start.dx).abs() + 20,
          height: (segment.end.dy - segment.start.dy).abs() + 20,
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildClusterOverlay(MemoryCluster cluster) {
    return Positioned(
      left: cluster.center.dx - cluster.radius,
      top: cluster.center.dy - cluster.radius,
      child: GestureDetector(
        onTap: () {
          if (cluster.memories.length == 1) {
            widget.onMemoryTap(cluster.memories.first);
          } else {
            widget.onClusterTap(cluster.memories);
          }
        },
        child: Container(
          width: cluster.radius * 2,
          height: cluster.radius * 2,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

/// Memory cluster data class
class MemoryCluster {
  final Offset center;
  final List<MemoryModel> memories;
  final double radius;
  final String theme;

  MemoryCluster({
    required this.center,
    required this.memories,
    required this.radius,
    required this.theme,
  });
}

/// Path segment data class
class PathSegment {
  final Offset start;
  final Offset end;
  final bool isHighlighted;
  final String theme;

  PathSegment({
    required this.start,
    required this.end,
    required this.isHighlighted,
    required this.theme,
  });
}

/// Custom painter for memory clustering
class MemoryClusteringPainter extends CustomPainter {
  final List<MemoryCluster> clusters;
  final List<PathSegment> pathSegments;
  final double animationValue;
  final double zoom;
  final Offset pan;

  MemoryClusteringPainter({
    required this.clusters,
    required this.pathSegments,
    required this.animationValue,
    required this.zoom,
    required this.pan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = Matrix4.identity()
      ..translate(pan.dx, pan.dy)
      ..scale(zoom);

    canvas.save();
    canvas.transform(matrix.storage);

    // Draw path segments
    _drawPathSegments(canvas);

    // Draw memory clusters
    _drawMemoryClusters(canvas);

    canvas.restore();
  }

  void _drawPathSegments(Canvas canvas) {
    for (final segment in pathSegments) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = segment.isHighlighted ? 4.0 : 2.0
        ..strokeCap = StrokeCap.round;

      final themeColors = ThemeManager.getThemeColors(segment.theme);
      paint.color = segment.isHighlighted
          ? (themeColors['roadHighlight'] ?? Colors.yellow)
          : (themeColors['road'] ?? Colors.grey);

      // Add glow effect for highlighted segments
      if (segment.isHighlighted) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      }

      canvas.drawLine(segment.start, segment.end, paint);
    }
  }

  void _drawMemoryClusters(Canvas canvas) {
    for (final cluster in clusters) {
      if (cluster.memories.length == 1) {
        _drawSingleMemory(canvas, cluster);
      } else {
        _drawMemoryCluster(canvas, cluster);
      }
    }
  }

  void _drawSingleMemory(Canvas canvas, MemoryCluster cluster) {
    final memory = cluster.memories.first;
    final themeColors = ThemeManager.getThemeColors(cluster.theme);

    // Draw memory marker
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = themeColors['marker'] ?? Colors.blue;

    canvas.drawCircle(cluster.center, cluster.radius, paint);

    // Draw memory photo if available
    if (memory.photoPath != null) {
      _drawMemoryPhoto(
          canvas, cluster.center, cluster.radius, memory.photoPath!);
    }

    // Draw memory label
    _drawMemoryLabel(canvas, cluster.center, memory.title, themeColors);
  }

  void _drawMemoryCluster(Canvas canvas, MemoryCluster cluster) {
    final themeColors = ThemeManager.getThemeColors(cluster.theme);

    // Draw cluster background
    final backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (themeColors['marker'] ?? Colors.blue).withValues(alpha: 0.3);

    canvas.drawCircle(cluster.center, cluster.radius, backgroundPaint);

    // Draw cluster border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = themeColors['marker'] ?? Colors.blue;

    canvas.drawCircle(cluster.center, cluster.radius, borderPaint);

    // Draw memory count
    _drawClusterLabel(
        canvas, cluster.center, '${cluster.memories.length}', themeColors);

    // Draw individual memory indicators
    _drawClusterMemories(canvas, cluster);
  }

  void _drawMemoryPhoto(
      Canvas canvas, Offset center, double radius, String photoPath) {
    // This would typically load and draw the actual photo
    // For now, we'll draw a placeholder circle
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    canvas.drawCircle(center, radius * 0.8, paint);
  }

  void _drawMemoryLabel(Canvas canvas, Offset center, String label,
      Map<String, Color> themeColors) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: themeColors['text'] ?? Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + 30 + 5, // Use fixed radius value
      ),
    );
  }

  void _drawClusterLabel(Canvas canvas, Offset center, String label,
      Map<String, Color> themeColors) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: themeColors['text'] ?? Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawClusterMemories(Canvas canvas, MemoryCluster cluster) {
    final themeColors = ThemeManager.getThemeColors(cluster.theme);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = themeColors['marker'] ?? Colors.blue;

    // Draw small circles around the cluster center
    final angleStep = 2 * math.pi / cluster.memories.length;
    for (int i = 0; i < cluster.memories.length; i++) {
      final angle = i * angleStep;
      final x = cluster.center.dx + math.cos(angle) * (cluster.radius * 0.6);
      final y = cluster.center.dy + math.sin(angle) * (cluster.radius * 0.6);

      canvas.drawCircle(Offset(x, y), 8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
