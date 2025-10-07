import 'package:flutter/material.dart';
import 'quiz_type.dart';

/// Comprehensive quiz item model with all required properties
/// for industry-level quiz system with scoring and analytics
class QuizItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final QuizDifficulty difficulty;
  final QuizType type;
  final int estimatedTime; // in minutes
  final int questionsCount;
  final int popularityScore; // 0-100 for sorting
  final List<String> tags;
  final bool isPremium;
  final String? imageUrl;
  final DateTime? lastUpdated;

  const QuizItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.type,
    required this.estimatedTime,
    required this.questionsCount,
    this.popularityScore = 50,
    this.tags = const [],
    this.isPremium = false,
    this.imageUrl,
    this.lastUpdated,
  });

  /// Calculate maximum possible score for this quiz
  int get maxScore {
    return (questionsCount *
            10 *
            difficulty.pointsMultiplier *
            type.scoreMultiplier)
        .round();
  }

  /// Get difficulty color for UI display
  Color get difficultyColor {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return Colors.green;
      case QuizDifficulty.medium:
        return Colors.orange;
      case QuizDifficulty.hard:
        return Colors.red;
    }
  }

  /// Check if quiz is trending (high popularity)
  bool get isTrending => popularityScore >= 80;

  /// Check if quiz is new (updated within last 30 days)
  bool get isNew {
    if (lastUpdated == null) return false;
    return DateTime.now().difference(lastUpdated!).inDays <= 30;
  }

  /// Get estimated completion time with buffer
  String get estimatedTimeString {
    if (estimatedTime <= 1) return '< 1 min';
    if (estimatedTime >= 60) return '${(estimatedTime / 60).ceil()}h';
    return '$estimatedTime min';
  }

  /// Create copy with updated properties
  QuizItem copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    QuizDifficulty? difficulty,
    QuizType? type,
    int? estimatedTime,
    int? questionsCount,
    int? popularityScore,
    List<String>? tags,
    bool? isPremium,
    String? imageUrl,
    DateTime? lastUpdated,
  }) {
    return QuizItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      questionsCount: questionsCount ?? this.questionsCount,
      popularityScore: popularityScore ?? this.popularityScore,
      tags: tags ?? this.tags,
      isPremium: isPremium ?? this.isPremium,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      // ignore: deprecated_member_use
      'color': color.value,
      'difficulty': difficulty.name,
      'type': type.name,
      'estimatedTime': estimatedTime,
      'questionsCount': questionsCount,
      'popularityScore': popularityScore,
      'tags': tags,
      'isPremium': isPremium,
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory QuizItem.fromJson(Map<String, dynamic> json) {
    return QuizItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      difficulty: QuizDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => QuizDifficulty.medium,
      ),
      type: QuizType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuizType.personality,
      ),
      estimatedTime: json['estimatedTime'] as int,
      questionsCount: json['questionsCount'] as int,
      popularityScore: json['popularityScore'] as int? ?? 50,
      tags: List<String>.from(json['tags'] as List? ?? []),
      isPremium: json['isPremium'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuizItem(id: $id, title: $title, type: $type, difficulty: $difficulty)';
  }
}
