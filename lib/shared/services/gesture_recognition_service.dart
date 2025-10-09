import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;

/// Gesture point model
class GesturePoint {
  final double x;
  final double y;
  final DateTime timestamp;

  GesturePoint({
    required this.x,
    required this.y,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GesturePoint.fromMap(Map<String, dynamic> map) {
    return GesturePoint(
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Love reaction model
class LoveReaction {
  final String id;
  final String userId;
  final String partnerId;
  final ReactionType type;
  final List<GesturePoint> gesturePoints;
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoveReaction({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.type,
    required this.gesturePoints,
    this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'type': type.name,
      'gesturePoints': gesturePoints.map((p) => p.toMap()).toList(),
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LoveReaction.fromMap(Map<String, dynamic> map) {
    return LoveReaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      type: ReactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReactionType.heart,
      ),
      gesturePoints: (map['gesturePoints'] as List?)
              ?.map((p) => GesturePoint.fromMap(Map<String, dynamic>.from(p)))
              .toList() ??
          [],
      message: map['message'],
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Reaction types
enum ReactionType {
  heart,
  kiss,
  hug,
  smile,
  star,
  custom,
}

/// Gesture recognition service
class GestureRecognitionService {
  static final GestureRecognitionService _instance =
      GestureRecognitionService._internal();
  factory GestureRecognitionService() => _instance;
  GestureRecognitionService._internal();

  /// Recognize gesture from points
  ReactionType recognizeGesture(List<GesturePoint> points) {
    if (points.isEmpty) return ReactionType.custom;

    try {
      // Normalize points
      final normalizedPoints = _normalizePoints(points);

      // Check for heart shape
      if (_isHeartShape(normalizedPoints)) {
        return ReactionType.heart;
      }

      // Check for kiss shape (lips)
      if (_isKissShape(normalizedPoints)) {
        return ReactionType.kiss;
      }

      // Check for hug shape (arms)
      if (_isHugShape(normalizedPoints)) {
        return ReactionType.hug;
      }

      // Check for smile shape
      if (_isSmileShape(normalizedPoints)) {
        return ReactionType.smile;
      }

      // Check for star shape
      if (_isStarShape(normalizedPoints)) {
        return ReactionType.star;
      }

      return ReactionType.custom;
    } catch (e) {
      developer.log('❌ [GestureRecognitionService] Error recognizing gesture: $e');
      return ReactionType.custom;
    }
  }

  /// Normalize points to 0-1 range
  List<GesturePoint> _normalizePoints(List<GesturePoint> points) {
    if (points.isEmpty) return [];

    double minX = points.first.x;
    double maxX = points.first.x;
    double minY = points.first.y;
    double maxY = points.first.y;

    // Find bounds
    for (final point in points) {
      minX = math.min(minX, point.x);
      maxX = math.max(maxX, point.x);
      minY = math.min(minY, point.y);
      maxY = math.max(maxY, point.y);
    }

    final width = maxX - minX;
    final height = maxY - minY;

    if (width == 0 || height == 0) return points;

    // Normalize
    return points
        .map((point) => GesturePoint(
              x: (point.x - minX) / width,
              y: (point.y - minY) / height,
              timestamp: point.timestamp,
            ))
        .toList();
  }

  /// Check if points form a heart shape
  bool _isHeartShape(List<GesturePoint> points) {
    if (points.length < 10) return false;

    // Heart shape characteristics:
    // - Two rounded tops (left and right)
    // - Pointed bottom
    // - Symmetrical

    final centerX = 0.5;
    final centerY = 0.5;

    // Check for symmetry
    final leftPoints = points.where((p) => p.x < centerX).length;
    final rightPoints = points.where((p) => p.x > centerX).length;

    if ((leftPoints - rightPoints).abs() > points.length * 0.3) return false;

    // Check for rounded tops
    final topPoints = points.where((p) => p.y < centerY).toList();
    if (topPoints.length < 4) return false;

    // Check for pointed bottom
    final bottomPoints = points.where((p) => p.y > centerY).toList();
    if (bottomPoints.length < 2) return false;

    // Check if bottom is more pointed than top
    final topSpread = _calculateSpread(topPoints);
    final bottomSpread = _calculateSpread(bottomPoints);

    return bottomSpread < topSpread * 0.7;
  }

  /// Check if points form a kiss shape (lips)
  bool _isKissShape(List<GesturePoint> points) {
    if (points.length < 8) return false;

    // Kiss shape characteristics:
    // - Horizontal oval shape
    // - Wider than tall
    // - Smooth curves

    final width = _calculateWidth(points);
    final height = _calculateHeight(points);

    if (height >= width) return false; // Should be wider than tall

    // Check for smooth curves (low curvature variation)
    final curvature = _calculateCurvature(points);
    return curvature < 0.5; // Low curvature = smooth
  }

  /// Check if points form a hug shape (arms)
  bool _isHugShape(List<GesturePoint> points) {
    if (points.length < 12) return false;

    // Hug shape characteristics:
    // - Two arms extending outward
    // - Curved inward
    // - Symmetrical

    final centerX = 0.5;

    // Check for two distinct arms
    final leftArm = points.where((p) => p.x < centerX - 0.1).toList();
    final rightArm = points.where((p) => p.x > centerX + 0.1).toList();

    if (leftArm.length < 3 || rightArm.length < 3) return false;

    // Check for curved inward motion
    final leftCurve = _calculateCurvature(leftArm);
    final rightCurve = _calculateCurvature(rightArm);

    return leftCurve > 0.3 && rightCurve > 0.3; // High curvature = curved
  }

  /// Check if points form a smile shape
  bool _isSmileShape(List<GesturePoint> points) {
    if (points.length < 6) return false;

    // Smile shape characteristics:
    // - Upward curve
    // - Horizontal orientation
    // - Smooth curve

    final width = _calculateWidth(points);
    final height = _calculateHeight(points);

    if (width <= height) return false; // Should be wider than tall

    // Check for upward curve
    final startY = points.first.y;
    final endY = points.last.y;
    final middleY = points[points.length ~/ 2].y;

    // Upward curve: middle should be higher than start/end
    return middleY < startY && middleY < endY;
  }

  /// Check if points form a star shape
  bool _isStarShape(List<GesturePoint> points) {
    if (points.length < 10) return false;

    // Star shape characteristics:
    // - Multiple sharp points
    // - Radial symmetry
    // - High curvature variation

    final centerX = _calculateCenterX(points);
    final centerY = _calculateCenterY(points);

    // Check for radial symmetry
    final angles = <double>[];
    for (final point in points) {
      final angle = math.atan2(point.y - centerY, point.x - centerX);
      angles.add(angle);
    }

    // Check for multiple distinct angles (star points)
    final distinctAngles = <double>[];
    for (final angle in angles) {
      bool isDistinct = true;
      for (final distinctAngle in distinctAngles) {
        if ((angle - distinctAngle).abs() < 0.5) {
          isDistinct = false;
          break;
        }
      }
      if (isDistinct) distinctAngles.add(angle);
    }

    return distinctAngles.length >= 5; // At least 5 points for a star
  }

  /// Calculate spread of points
  double _calculateSpread(List<GesturePoint> points) {
    if (points.isEmpty) return 0.0;

    double minX = points.first.x;
    double maxX = points.first.x;
    double minY = points.first.y;
    double maxY = points.first.y;

    for (final point in points) {
      minX = math.min(minX, point.x);
      maxX = math.max(maxX, point.x);
      minY = math.min(minY, point.y);
      maxY = math.max(maxY, point.y);
    }

    return math.sqrt(math.pow(maxX - minX, 2) + math.pow(maxY - minY, 2));
  }

  /// Calculate width of points
  double _calculateWidth(List<GesturePoint> points) {
    if (points.isEmpty) return 0.0;

    double minX = points.first.x;
    double maxX = points.first.x;

    for (final point in points) {
      minX = math.min(minX, point.x);
      maxX = math.max(maxX, point.x);
    }

    return maxX - minX;
  }

  /// Calculate height of points
  double _calculateHeight(List<GesturePoint> points) {
    if (points.isEmpty) return 0.0;

    double minY = points.first.y;
    double maxY = points.first.y;

    for (final point in points) {
      minY = math.min(minY, point.y);
      maxY = math.max(maxY, point.y);
    }

    return maxY - minY;
  }

  /// Calculate center X coordinate
  double _calculateCenterX(List<GesturePoint> points) {
    if (points.isEmpty) return 0.0;

    double sum = 0.0;
    for (final point in points) {
      sum += point.x;
    }

    return sum / points.length;
  }

  /// Calculate center Y coordinate
  double _calculateCenterY(List<GesturePoint> points) {
    if (points.isEmpty) return 0.0;

    double sum = 0.0;
    for (final point in points) {
      sum += point.y;
    }

    return sum / points.length;
  }

  /// Calculate curvature of points
  double _calculateCurvature(List<GesturePoint> points) {
    if (points.length < 3) return 0.0;

    double totalCurvature = 0.0;
    int count = 0;

    for (int i = 1; i < points.length - 1; i++) {
      final p1 = points[i - 1];
      final p2 = points[i];
      final p3 = points[i + 1];

      // Calculate angle between vectors
      final v1x = p2.x - p1.x;
      final v1y = p2.y - p1.y;
      final v2x = p3.x - p2.x;
      final v2y = p3.y - p2.y;

      final dot = v1x * v2x + v1y * v2y;
      final mag1 = math.sqrt(v1x * v1x + v1y * v1y);
      final mag2 = math.sqrt(v2x * v2x + v2y * v2y);

      if (mag1 > 0 && mag2 > 0) {
        final cosAngle = dot / (mag1 * mag2);
        final angle = math.acos(cosAngle.clamp(-1.0, 1.0));
        totalCurvature += angle;
        count++;
      }
    }

    return count > 0 ? totalCurvature / count : 0.0;
  }

  /// Get reaction emoji
  String getReactionEmoji(ReactionType type) {
    switch (type) {
      case ReactionType.heart:
        return '❤️';
      case ReactionType.kiss:
        return '💋';
      case ReactionType.hug:
        return '🤗';
      case ReactionType.smile:
        return '😊';
      case ReactionType.star:
        return '⭐';
      case ReactionType.custom:
        return '💝';
    }
  }

  /// Get reaction color
  Color getReactionColor(ReactionType type) {
    switch (type) {
      case ReactionType.heart:
        return Colors.red;
      case ReactionType.kiss:
        return Colors.pink;
      case ReactionType.hug:
        return Colors.blue;
      case ReactionType.smile:
        return Colors.yellow;
      case ReactionType.star:
        return Colors.orange;
      case ReactionType.custom:
        return Colors.purple;
    }
  }

  /// Get reaction name
  String getReactionName(ReactionType type) {
    switch (type) {
      case ReactionType.heart:
        return 'Heart';
      case ReactionType.kiss:
        return 'Kiss';
      case ReactionType.hug:
        return 'Hug';
      case ReactionType.smile:
        return 'Smile';
      case ReactionType.star:
        return 'Star';
      case ReactionType.custom:
        return 'Custom';
    }
  }
}
