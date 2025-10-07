import 'package:equatable/equatable.dart';

/// Future planning entity
/// Follows master plan clean architecture
class FuturePlanningEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final FuturePlanningCategory category;
  final DateTime targetDate;
  final FuturePlanningStatus status;
  final int priority;
  final List<String> tags;
  final String? imageUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const FuturePlanningEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetDate,
    required this.status,
    required this.priority,
    this.tags = const [],
    this.imageUrl,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        targetDate,
        status,
        priority,
        tags,
        imageUrl,
        notes,
        createdAt,
        updatedAt,
        completedAt,
      ];

  FuturePlanningEntity copyWith({
    String? id,
    String? title,
    String? description,
    FuturePlanningCategory? category,
    DateTime? targetDate,
    FuturePlanningStatus? status,
    int? priority,
    List<String>? tags,
    String? imageUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return FuturePlanningEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Check if goal is overdue
  bool get isOverdue {
    return targetDate.isBefore(DateTime.now()) &&
        status != FuturePlanningStatus.completed;
  }

  /// Check if goal is due soon (within 30 days)
  bool get isDueSoon {
    final now = DateTime.now();
    final daysUntil = targetDate.difference(now).inDays;
    return daysUntil <= 30 &&
        daysUntil >= 0 &&
        status != FuturePlanningStatus.completed;
  }

  /// Get days until target date
  int get daysUntil {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }
}

/// Future planning category enum
enum FuturePlanningCategory {
  relationship,
  career,
  family,
  health,
  finance,
  travel,
  home,
  personal,
  education,
  hobbies,
}

/// Future planning status enum
enum FuturePlanningStatus {
  planning,
  inProgress,
  onHold,
  completed,
  cancelled,
}

/// Future planning request
class FuturePlanningRequest extends Equatable {
  final String title;
  final String description;
  final FuturePlanningCategory category;
  final DateTime targetDate;
  final int priority;
  final List<String> tags;
  final String? imageUrl;
  final String? notes;

  const FuturePlanningRequest({
    required this.title,
    required this.description,
    required this.category,
    required this.targetDate,
    required this.priority,
    this.tags = const [],
    this.imageUrl,
    this.notes,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        category,
        targetDate,
        priority,
        tags,
        imageUrl,
        notes
      ];
}
