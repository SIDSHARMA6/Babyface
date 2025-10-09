import 'package:equatable/equatable.dart';

/// Recurring options for anniversary events
enum RecurringType {
  none,
  monthly,
  yearly,
}

/// Anniversary Event Model
/// Represents a special event/anniversary with all details
class AnniversaryEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? photoPath;
  final bool isRecurring;
  final RecurringType recurringType;
  final String? customEventName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnniversaryEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.photoPath,
    this.isRecurring = false,
    this.recurringType = RecurringType.none,
    this.customEventName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create AnniversaryEvent from JSON
  factory AnniversaryEvent.fromJson(Map<String, dynamic> json) {
    return AnniversaryEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      photoPath: json['photoPath'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringType: RecurringType.values.firstWhere(
        (e) => e.name == json['recurringType'],
        orElse: () => RecurringType.none,
      ),
      customEventName: json['customEventName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert AnniversaryEvent to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'photoPath': photoPath,
      'isRecurring': isRecurring,
      'recurringType': recurringType.name,
      'customEventName': customEventName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  AnniversaryEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? photoPath,
    bool? isRecurring,
    RecurringType? recurringType,
    String? customEventName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnniversaryEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      photoPath: photoPath ?? this.photoPath,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      customEventName: customEventName ?? this.customEventName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get days until this event
  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate.isBefore(today)) {
      // If event has passed this year, calculate for next year
      final nextYearEvent = DateTime(date.year + 1, date.month, date.day);
      return nextYearEvent.difference(today).inDays;
    }

    return eventDate.difference(today).inDays;
  }

  /// Check if this is the nearest upcoming event
  bool isNearestEvent(List<AnniversaryEvent> allEvents) {
    if (allEvents.isEmpty) return true;

    final sortedEvents = allEvents.where((e) => e.daysUntil > 0).toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

    return sortedEvents.isNotEmpty && sortedEvents.first.id == id;
  }

  /// Get display title (custom name or default title)
  String get displayTitle => customEventName ?? title;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        photoPath,
        isRecurring,
        customEventName,
        createdAt,
        updatedAt,
      ];
}
