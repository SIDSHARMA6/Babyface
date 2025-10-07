import 'package:equatable/equatable.dart';

/// Growth timeline entity
/// Follows master plan clean architecture
class GrowthTimelineEntity extends Equatable {
  final String id;
  final int month;
  final String title;
  final String description;
  final List<String> milestones;
  final List<String> tips;
  final String imageUrl;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;

  const GrowthTimelineEntity({
    required this.id,
    required this.month,
    required this.title,
    required this.description,
    required this.milestones,
    required this.tips,
    required this.imageUrl,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        month,
        title,
        description,
        milestones,
        tips,
        imageUrl,
        createdAt,
        isCompleted,
        completedAt,
      ];

  GrowthTimelineEntity copyWith({
    String? id,
    int? month,
    String? title,
    String? description,
    List<String>? milestones,
    List<String>? tips,
    String? imageUrl,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return GrowthTimelineEntity(
      id: id ?? this.id,
      month: month ?? this.month,
      title: title ?? this.title,
      description: description ?? this.description,
      milestones: milestones ?? this.milestones,
      tips: tips ?? this.tips,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Growth timeline request
class GrowthTimelineRequest extends Equatable {
  final int? currentMonth;
  final String? gender;
  final List<String>? interests;

  const GrowthTimelineRequest({
    this.currentMonth,
    this.gender,
    this.interests,
  });

  @override
  List<Object?> get props => [currentMonth, gender, interests];
}
