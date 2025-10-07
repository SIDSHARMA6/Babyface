import 'package:equatable/equatable.dart';

/// Memory journal entity
/// Follows master plan clean architecture
class MemoryJournalEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final MemoryType type;
  final String? location;
  final List<String> tags;
  final bool isFavorite;

  const MemoryJournalEntity({
    required this.id,
    required this.title,
    required this.content,
    this.imagePaths = const [],
    required this.createdAt,
    this.updatedAt,
    required this.type,
    this.location,
    this.tags = const [],
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        imagePaths,
        createdAt,
        updatedAt,
        type,
        location,
        tags,
        isFavorite,
      ];

  MemoryJournalEntity copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    MemoryType? type,
    String? location,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return MemoryJournalEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Memory type enum
enum MemoryType {
  date,
  anniversary,
  vacation,
  milestone,
  everyday,
  special,
}

/// Memory journal entry request
class MemoryJournalRequest extends Equatable {
  final String title;
  final String content;
  final List<String> imagePaths;
  final MemoryType type;
  final String? location;
  final List<String> tags;

  const MemoryJournalRequest({
    required this.title,
    required this.content,
    this.imagePaths = const [],
    required this.type,
    this.location,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [title, content, imagePaths, type, location, tags];
}
