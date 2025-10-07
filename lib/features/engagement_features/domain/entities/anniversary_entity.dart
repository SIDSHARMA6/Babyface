import 'package:equatable/equatable.dart';

/// Anniversary entity
/// Follows master plan clean architecture
class AnniversaryEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final AnniversaryType type;
  final int years;
  final String? imageUrl;
  final List<String> tags;
  final bool isRecurring;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AnniversaryEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.years,
    this.imageUrl,
    this.tags = const [],
    this.isRecurring = true,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        type,
        years,
        imageUrl,
        tags,
        isRecurring,
        isCompleted,
        completedAt,
        createdAt,
        updatedAt,
      ];

  AnniversaryEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    AnniversaryType? type,
    int? years,
    String? imageUrl,
    List<String>? tags,
    bool? isRecurring,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnniversaryEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      years: years ?? this.years,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if anniversary is today
  bool get isToday {
    final now = DateTime.now();
    return date.month == now.month && date.day == now.day;
  }

  /// Check if anniversary is upcoming (within next 30 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final upcomingDate = DateTime(now.year, date.month, date.day);
    if (upcomingDate.isBefore(now)) {
      upcomingDate.add(const Duration(days: 365));
    }
    return upcomingDate.difference(now).inDays <= 30;
  }

  /// Get days until anniversary
  int get daysUntil {
    final now = DateTime.now();
    final anniversaryDate = DateTime(now.year, date.month, date.day);
    if (anniversaryDate.isBefore(now)) {
      anniversaryDate.add(const Duration(days: 365));
    }
    return anniversaryDate.difference(now).inDays;
  }
}

/// Anniversary type enum
enum AnniversaryType {
  relationship,
  marriage,
  engagement,
  firstDate,
  firstKiss,
  movingIn,
  custom,
}

/// Anniversary request
class AnniversaryRequest extends Equatable {
  final String title;
  final String description;
  final DateTime date;
  final AnniversaryType type;
  final String? imageUrl;
  final List<String> tags;
  final bool isRecurring;

  const AnniversaryRequest({
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.imageUrl,
    this.tags = const [],
    this.isRecurring = true,
  });

  @override
  List<Object?> get props =>
      [title, description, date, type, imageUrl, tags, isRecurring];
}
