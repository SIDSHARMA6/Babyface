import 'package:flutter/material.dart';

/// Memory model for Hive storage
/// Follows memory_journey.md specification
class MemoryModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String? photoPath;
  final String date;
  final String? voicePath;
  final String mood; // joyful, sweet, emotional
  final int positionIndex;
  final int timestamp;
  final bool isFavorite;
  final String? location;
  final List<String> tags;
  
  // For journey visualization
  Offset? roadPosition;

  MemoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.photoPath,
    required this.date,
    this.voicePath,
    required this.mood,
    required this.positionIndex,
    required this.timestamp,
    this.isFavorite = false,
    this.location,
    this.tags = const [],
    this.roadPosition,
  });

  /// Convert to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'photoPath': photoPath,
      'date': date,
      'voicePath': voicePath,
      'mood': mood,
      'positionIndex': positionIndex,
      'timestamp': timestamp,
      'isFavorite': isFavorite,
      'location': location,
      'tags': tags,
    };
  }

  /// Create from Map
  factory MemoryModel.fromMap(Map<String, dynamic> map) {
    return MemoryModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '💕',
      photoPath: map['photoPath'],
      date: map['date'] ?? '',
      voicePath: map['voicePath'],
      mood: map['mood'] ?? 'joyful',
      positionIndex: map['positionIndex'] ?? 0,
      timestamp: map['timestamp'] ?? 0,
      isFavorite: map['isFavorite'] ?? false,
      location: map['location'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  /// Copy with method
  MemoryModel copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    String? photoPath,
    String? date,
    String? voicePath,
    String? mood,
    int? positionIndex,
    int? timestamp,
    bool? isFavorite,
    String? location,
    List<String>? tags,
    Offset? roadPosition,
  }) {
    return MemoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      photoPath: photoPath ?? this.photoPath,
      date: date ?? this.date,
      voicePath: voicePath ?? this.voicePath,
      mood: mood ?? this.mood,
      positionIndex: positionIndex ?? this.positionIndex,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      roadPosition: roadPosition ?? this.roadPosition,
    );
  }

  @override
  String toString() {
    return 'MemoryModel(id: $id, title: $title, description: $description, emoji: $emoji, photoPath: $photoPath, date: $date, mood: $mood, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Memory mood enum
enum MemoryMood {
  joyful('joyful', '😊'),
  sweet('sweet', '💕'),
  emotional('emotional', '🥺'),
  romantic('romantic', '💖'),
  fun('fun', '😄'),
  excited('excited', '🤩');

  const MemoryMood(this.value, this.emoji);
  final String value;
  final String emoji;

  static MemoryMood fromString(String value) {
    return MemoryMood.values.firstWhere(
      (mood) => mood.value == value,
      orElse: () => MemoryMood.joyful,
    );
  }
}
