import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/memory_model.dart';

/// Journey Helper Utility
/// Follows memory_journey.md specification for road calculations and journey logic
class JourneyHelper {
  /// Generate road points for journey visualization
  static List<Offset> generateRoadPoints({
    required Size screenSize,
    required int memoryCount,
    double startY = 0.1,
    double endY = 0.9,
    double curveIntensity = 0.3,
  }) {
    if (memoryCount == 0) return [];

    final points = <Offset>[];
    final random = math.Random(42); // Fixed seed for consistent results
    
    // Calculate spacing between points
    final ySpacing = (endY - startY) / (memoryCount + 1);
    
    for (int i = 0; i <= memoryCount; i++) {
      final y = startY + (i * ySpacing);
      
      // Create curved path with some randomness
      double x;
      if (i == 0) {
        x = 0.1; // Start from left
      } else if (i == memoryCount) {
        x = 0.9; // End at right
      } else {
        // Create smooth curve with some variation
        final progress = i / memoryCount;
        final baseX = 0.1 + (progress * 0.8);
        final curveOffset = math.sin(progress * math.pi * 2) * curveIntensity * 0.3;
        final randomOffset = (random.nextDouble() - 0.5) * curveIntensity * 0.2;
        x = (baseX + curveOffset + randomOffset).clamp(0.1, 0.9);
      }
      
      points.add(Offset(
        x * screenSize.width,
        y * screenSize.height,
      ));
    }
    
    return points;
  }

  /// Calculate memory positions along the road
  static List<Offset> calculateMemoryPositions({
    required List<Offset> roadPoints,
    required List<MemoryModel> memories,
  }) {
    if (roadPoints.isEmpty || memories.isEmpty) return [];

    final positions = <Offset>[];
    
    // Distribute memories evenly along the road
    final memoryCount = memories.length;
    final roadLength = roadPoints.length;
    
    for (int i = 0; i < memoryCount; i++) {
      final roadIndex = ((i + 1) * roadLength / (memoryCount + 1)).floor();
      final clampedIndex = roadIndex.clamp(0, roadLength - 1);
      positions.add(roadPoints[clampedIndex]);
    }
    
    return positions;
  }

  /// Generate smooth curved path from points
  static Path createSmoothPath(List<Offset> points) {
    if (points.length < 2) return Path();

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    for (int i = 1; i < points.length; i++) {
      final current = points[i];
      final previous = points[i - 1];
      
      if (i < points.length - 1) {
        final next = points[i + 1];
        
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
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          current.dx, current.dy,
        );
      } else {
        path.lineTo(current.dx, current.dy);
      }
    }
    
    return path;
  }

  /// Calculate distance between two points
  static double calculateDistance(Offset point1, Offset point2) {
    final dx = point2.dx - point1.dx;
    final dy = point2.dy - point1.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Find closest point on path to given point
  static Offset findClosestPointOnPath(Path path, Offset point) {
    // Simplified implementation - in a real app, you'd use more sophisticated path sampling
    return point;
  }

  /// Calculate journey progress percentage
  static double calculateJourneyProgress({
    required List<MemoryModel> memories,
    required DateTime startDate,
    DateTime? endDate,
  }) {
    if (memories.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final journeyEnd = endDate ?? now;
    final journeyDuration = journeyEnd.difference(startDate).inDays;
    
    if (journeyDuration <= 0) return 1.0;
    
    final elapsedDays = now.difference(startDate).inDays;
    return (elapsedDays / journeyDuration).clamp(0.0, 1.0);
  }

  /// Get seasonal theme colors based on date
  static SeasonalColors getSeasonalColors(DateTime date) {
    final month = date.month;
    
    if (month >= 3 && month <= 5) {
      // Spring
      return SeasonalColors(
        primary: const Color(0xFFFFB6C1), // Light Pink
        secondary: const Color(0xFF98FB98), // Light Green
        accent: const Color(0xFFFFE4B5), // Moccasin
      );
    } else if (month >= 6 && month <= 8) {
      // Summer
      return SeasonalColors(
        primary: const Color(0xFFFFA500), // Orange
        secondary: const Color(0xFFFFD700), // Gold
        accent: const Color(0xFFFFE4E1), // Misty Rose
      );
    } else if (month >= 9 && month <= 11) {
      // Autumn
      return SeasonalColors(
        primary: const Color(0xFFCD853F), // Peru
        secondary: const Color(0xFFD2691E), // Chocolate
        accent: const Color(0xFFFFE4B5), // Moccasin
      );
    } else {
      // Winter
      return SeasonalColors(
        primary: const Color(0xFFB0C4DE), // Light Steel Blue
        secondary: const Color(0xFFDDA0DD), // Plum
        accent: const Color(0xFFF0F8FF), // Alice Blue
      );
    }
  }

  /// Calculate memory density for a given time period
  static double calculateMemoryDensity({
    required List<MemoryModel> memories,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final periodMemories = memories.where((memory) {
      final memoryDate = DateTime.fromMillisecondsSinceEpoch(memory.timestamp);
      return memoryDate.isAfter(startDate) && memoryDate.isBefore(endDate);
    }).length;
    
    final periodDays = endDate.difference(startDate).inDays;
    if (periodDays <= 0) return 0.0;
    
    return periodMemories / periodDays;
  }

  /// Generate anniversary dates
  static List<DateTime> generateAnniversaryDates({
    required DateTime startDate,
    int years = 5,
  }) {
    final anniversaries = <DateTime>[];
    
    for (int i = 1; i <= years; i++) {
      anniversaries.add(DateTime(
        startDate.year + i,
        startDate.month,
        startDate.day,
      ));
    }
    
    return anniversaries;
  }

  /// Calculate love streak (consecutive days with memories)
  static int calculateLoveStreak(List<MemoryModel> memories) {
    if (memories.isEmpty) return 0;
    
    // Sort memories by date (newest first)
    final sortedMemories = List<MemoryModel>.from(memories);
    sortedMemories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    int streak = 0;
    DateTime? lastMemoryDate;
    
    for (final memory in sortedMemories) {
      final memoryDate = DateTime.fromMillisecondsSinceEpoch(memory.timestamp);
      final memoryDay = DateTime(memoryDate.year, memoryDate.month, memoryDate.day);
      
      if (lastMemoryDate == null) {
        lastMemoryDate = memoryDay;
        streak = 1;
      } else {
        final daysDifference = lastMemoryDate.difference(memoryDay).inDays;
        if (daysDifference == 1) {
          streak++;
          lastMemoryDate = memoryDay;
        } else if (daysDifference > 1) {
          break; // Streak broken
        }
      }
    }
    
    return streak;
  }

  /// Generate memory statistics
  static MemoryStatistics generateMemoryStatistics(List<MemoryModel> memories) {
    if (memories.isEmpty) {
      return MemoryStatistics.empty();
    }
    
    final totalMemories = memories.length;
    final favoriteMemories = memories.where((m) => m.isFavorite).length;
    final memoriesWithPhotos = memories.where((m) => m.photoPath != null).length;
    final memoriesWithVoice = memories.where((m) => m.voicePath != null).length;
    
    // Calculate mood distribution
    final moodCounts = <String, int>{};
    for (final memory in memories) {
      moodCounts[memory.mood] = (moodCounts[memory.mood] ?? 0) + 1;
    }
    
    // Find most common mood
    String mostCommonMood = 'joyful';
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonMood = mood;
      }
    });
    
    // Calculate memory frequency
    final now = DateTime.now();
    final firstMemory = memories.reduce((a, b) => 
      a.timestamp < b.timestamp ? a : b
    );
    final lastMemory = memories.reduce((a, b) => 
      a.timestamp > b.timestamp ? a : b
    );
    
    final totalDays = now.difference(
      DateTime.fromMillisecondsSinceEpoch(firstMemory.timestamp)
    ).inDays;
    
    final memoryFrequency = totalDays > 0 ? totalMemories / totalDays : 0.0;
    
    return MemoryStatistics(
      totalMemories: totalMemories,
      favoriteMemories: favoriteMemories,
      memoriesWithPhotos: memoriesWithPhotos,
      memoriesWithVoice: memoriesWithVoice,
      mostCommonMood: mostCommonMood,
      memoryFrequency: memoryFrequency,
      firstMemoryDate: DateTime.fromMillisecondsSinceEpoch(firstMemory.timestamp),
      lastMemoryDate: DateTime.fromMillisecondsSinceEpoch(lastMemory.timestamp),
      loveStreak: calculateLoveStreak(memories),
    );
  }

  /// Generate journey milestones
  static List<JourneyMilestone> generateJourneyMilestones({
    required List<MemoryModel> memories,
    required DateTime relationshipStartDate,
  }) {
    final milestones = <JourneyMilestone>[];
    
    if (memories.isEmpty) return milestones;
    
    // Sort memories by date
    final sortedMemories = List<MemoryModel>.from(memories);
    sortedMemories.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // First memory milestone
    if (sortedMemories.isNotEmpty) {
      milestones.add(JourneyMilestone(
        title: 'First Memory',
        description: 'Your journey began with "${sortedMemories.first.title}"',
        date: DateTime.fromMillisecondsSinceEpoch(sortedMemories.first.timestamp),
        type: MilestoneType.firstMemory,
        memory: sortedMemories.first,
      ));
    }
    
    // 10th memory milestone
    if (sortedMemories.length >= 10) {
      milestones.add(JourneyMilestone(
        title: 'Memory Collector',
        description: 'You\'ve created 10 beautiful memories together',
        date: DateTime.fromMillisecondsSinceEpoch(sortedMemories[9].timestamp),
        type: MilestoneType.memoryCount,
        memory: sortedMemories[9],
      ));
    }
    
    // 50th memory milestone
    if (sortedMemories.length >= 50) {
      milestones.add(JourneyMilestone(
        title: 'Memory Master',
        description: '50 memories and counting! You\'re true memory masters',
        date: DateTime.fromMillisecondsSinceEpoch(sortedMemories[49].timestamp),
        type: MilestoneType.memoryCount,
        memory: sortedMemories[49],
      ));
    }
    
    // 100th memory milestone
    if (sortedMemories.length >= 100) {
      milestones.add(JourneyMilestone(
        title: 'Memory Legend',
        description: '100 memories! You\'ve created a lifetime of love',
        date: DateTime.fromMillisecondsSinceEpoch(sortedMemories[99].timestamp),
        type: MilestoneType.memoryCount,
        memory: sortedMemories[99],
      ));
    }
    
    // Anniversary milestones
    final anniversaries = generateAnniversaryDates(
      startDate: relationshipStartDate,
      years: 5,
    );
    
    for (final anniversary in anniversaries) {
      if (anniversary.isBefore(DateTime.now())) {
        milestones.add(JourneyMilestone(
          title: '${anniversary.year - relationshipStartDate.year} Year Anniversary',
          description: 'Celebrating ${anniversary.year - relationshipStartDate.year} years together',
          date: anniversary,
          type: MilestoneType.anniversary,
        ));
      }
    }
    
    return milestones;
  }
}

/// Seasonal Colors
class SeasonalColors {
  final Color primary;
  final Color secondary;
  final Color accent;

  const SeasonalColors({
    required this.primary,
    required this.secondary,
    required this.accent,
  });
}

/// Memory Statistics
class MemoryStatistics {
  final int totalMemories;
  final int favoriteMemories;
  final int memoriesWithPhotos;
  final int memoriesWithVoice;
  final String mostCommonMood;
  final double memoryFrequency;
  final DateTime firstMemoryDate;
  final DateTime lastMemoryDate;
  final int loveStreak;

  const MemoryStatistics({
    required this.totalMemories,
    required this.favoriteMemories,
    required this.memoriesWithPhotos,
    required this.memoriesWithVoice,
    required this.mostCommonMood,
    required this.memoryFrequency,
    required this.firstMemoryDate,
    required this.lastMemoryDate,
    required this.loveStreak,
  });

  factory MemoryStatistics.empty() {
    final now = DateTime.now();
    return MemoryStatistics(
      totalMemories: 0,
      favoriteMemories: 0,
      memoriesWithPhotos: 0,
      memoriesWithVoice: 0,
      mostCommonMood: 'joyful',
      memoryFrequency: 0.0,
      firstMemoryDate: now,
      lastMemoryDate: now,
      loveStreak: 0,
    );
  }
}

/// Journey Milestone
class JourneyMilestone {
  final String title;
  final String description;
  final DateTime date;
  final MilestoneType type;
  final MemoryModel? memory;

  const JourneyMilestone({
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.memory,
  });
}

/// Milestone Type
enum MilestoneType {
  firstMemory,
  memoryCount,
  anniversary,
  special,
}

/// Journey Path Generator
class JourneyPathGenerator {
  /// Generate a romantic winding path
  static List<Offset> generateRomanticPath({
    required Size screenSize,
    required int pointCount,
    double startX = 0.1,
    double endX = 0.9,
    double startY = 0.1,
    double endY = 0.9,
    double curveIntensity = 0.4,
  }) {
    final points = <Offset>[];
    final random = math.Random(42);
    
    for (int i = 0; i < pointCount; i++) {
      final progress = i / (pointCount - 1);
      
      // Create smooth S-curve with some randomness
      final baseX = startX + (endX - startX) * progress;
      final baseY = startY + (endY - startY) * progress;
      
      // Add romantic curve
      final curveOffset = math.sin(progress * math.pi * 3) * curveIntensity * 0.3;
      final randomOffset = (random.nextDouble() - 0.5) * curveIntensity * 0.1;
      
      final x = (baseX + curveOffset + randomOffset).clamp(0.0, 1.0);
      final y = (baseY + randomOffset).clamp(0.0, 1.0);
      
      points.add(Offset(
        x * screenSize.width,
        y * screenSize.height,
      ));
    }
    
    return points;
  }

  /// Generate a heart-shaped path
  static List<Offset> generateHeartPath({
    required Size screenSize,
    required int pointCount,
  }) {
    final points = <Offset>[];
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    final radius = math.min(screenSize.width, screenSize.height) * 0.3;
    
    for (int i = 0; i < pointCount; i++) {
      final angle = (i * 2 * math.pi) / pointCount;
      
      // Heart equation: r = a(1 + cos(θ))
      final heartRadius = radius * (1 + math.cos(angle));
      
      final x = centerX + heartRadius * math.cos(angle);
      final y = centerY - heartRadius * math.sin(angle) * 0.8; // Compress vertically
      
      points.add(Offset(x, y));
    }
    
    return points;
  }
}
