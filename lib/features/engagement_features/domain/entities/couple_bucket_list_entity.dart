import 'package:equatable/equatable.dart';

/// Couple bucket list entity
/// Follows master plan clean architecture
class CoupleBucketListEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final BucketListCategory category;
  final BucketListStatus status;
  final int priority;
  final DateTime? targetDate;
  final String? location;
  final double? estimatedCost;
  final List<String> tags;
  final String? imageUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const CoupleBucketListEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    this.targetDate,
    this.location,
    this.estimatedCost,
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
        status,
        priority,
        targetDate,
        location,
        estimatedCost,
        tags,
        imageUrl,
        notes,
        createdAt,
        updatedAt,
        completedAt,
      ];

  CoupleBucketListEntity copyWith({
    String? id,
    String? title,
    String? description,
    BucketListCategory? category,
    BucketListStatus? status,
    int? priority,
    DateTime? targetDate,
    String? location,
    double? estimatedCost,
    List<String>? tags,
    String? imageUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return CoupleBucketListEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      targetDate: targetDate ?? this.targetDate,
      location: location ?? this.location,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Check if item is overdue
  bool get isOverdue {
    if (targetDate == null) return false;
    return targetDate!.isBefore(DateTime.now()) &&
        status != BucketListStatus.completed;
  }

  /// Check if item is due soon (within 30 days)
  bool get isDueSoon {
    if (targetDate == null) return false;
    final now = DateTime.now();
    final daysUntil = targetDate!.difference(now).inDays;
    return daysUntil <= 30 &&
        daysUntil >= 0 &&
        status != BucketListStatus.completed;
  }

  /// Get days until target date
  int get daysUntil {
    if (targetDate == null) return 0;
    final now = DateTime.now();
    return targetDate!.difference(now).inDays;
  }
}

/// Bucket list category enum
enum BucketListCategory {
  travel,
  adventure,
  romantic,
  food,
  entertainment,
  learning,
  fitness,
  creative,
  social,
  personal,
}

/// Bucket list status enum
enum BucketListStatus {
  wishlist,
  planned,
  inProgress,
  completed,
  cancelled,
}

/// Couple bucket list request
class CoupleBucketListRequest extends Equatable {
  final String title;
  final String description;
  final BucketListCategory category;
  final int priority;
  final DateTime? targetDate;
  final String? location;
  final double? estimatedCost;
  final List<String> tags;
  final String? imageUrl;
  final String? notes;

  const CoupleBucketListRequest({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.targetDate,
    this.location,
    this.estimatedCost,
    this.tags = const [],
    this.imageUrl,
    this.notes,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        category,
        priority,
        targetDate,
        location,
        estimatedCost,
        tags,
        imageUrl,
        notes
      ];
}
