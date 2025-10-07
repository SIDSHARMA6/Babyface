import 'package:equatable/equatable.dart';

/// Couple challenge entity
/// Follows master plan clean architecture
class CoupleChallengeEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int duration; // in minutes
  final List<String> instructions;
  final String? reward;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> tags;

  const CoupleChallengeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.duration,
    required this.instructions,
    this.reward,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.expiresAt,
    required this.tags,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        difficulty,
        duration,
        instructions,
        reward,
        isCompleted,
        completedAt,
        createdAt,
        expiresAt,
        tags,
      ];

  CoupleChallengeEntity copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    ChallengeDifficulty? difficulty,
    int? duration,
    List<String>? instructions,
    String? reward,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? tags,
  }) {
    return CoupleChallengeEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      reward: reward ?? this.reward,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      tags: tags ?? this.tags,
    );
  }
}

/// Challenge type enum
enum ChallengeType {
  romantic,
  fun,
  adventure,
  learning,
  creative,
  fitness,
  cooking,
  communication,
}

/// Challenge difficulty enum
enum ChallengeDifficulty {
  easy,
  medium,
  hard,
  expert,
}

/// Couple challenge request
class CoupleChallengeRequest extends Equatable {
  final ChallengeType? type;
  final ChallengeDifficulty? difficulty;
  final int? duration;
  final List<String>? tags;

  const CoupleChallengeRequest({
    this.type,
    this.difficulty,
    this.duration,
    this.tags,
  });

  @override
  List<Object?> get props => [type, difficulty, duration, tags];
}
