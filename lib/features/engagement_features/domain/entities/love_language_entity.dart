import 'package:equatable/equatable.dart';

/// Love language entity
/// Follows master plan clean architecture
class LoveLanguageEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final LoveLanguageType type;
  final List<String> examples;
  final String iconUrl;
  final int score;
  final DateTime createdAt;

  const LoveLanguageEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.examples,
    required this.iconUrl,
    required this.score,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        examples,
        iconUrl,
        score,
        createdAt,
      ];

  LoveLanguageEntity copyWith({
    String? id,
    String? title,
    String? description,
    LoveLanguageType? type,
    List<String>? examples,
    String? iconUrl,
    int? score,
    DateTime? createdAt,
  }) {
    return LoveLanguageEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      examples: examples ?? this.examples,
      iconUrl: iconUrl ?? this.iconUrl,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Love language type enum
enum LoveLanguageType {
  wordsOfAffirmation,
  actsOfService,
  receivingGifts,
  qualityTime,
  physicalTouch,
}

/// Love language question entity
class LoveLanguageQuestionEntity extends Equatable {
  final String id;
  final String question;
  final List<LoveLanguageAnswerEntity> answers;
  final LoveLanguageType category;
  final int order;

  const LoveLanguageQuestionEntity({
    required this.id,
    required this.question,
    required this.answers,
    required this.category,
    required this.order,
  });

  @override
  List<Object?> get props => [id, question, answers, category, order];
}

/// Love language answer entity
class LoveLanguageAnswerEntity extends Equatable {
  final String id;
  final String text;
  final LoveLanguageType type;
  final int points;

  const LoveLanguageAnswerEntity({
    required this.id,
    required this.text,
    required this.type,
    required this.points,
  });

  @override
  List<Object?> get props => [id, text, type, points];
}

/// Love language quiz result entity
class LoveLanguageQuizResultEntity extends Equatable {
  final String id;
  final List<LoveLanguageEntity> results;
  final LoveLanguageEntity primaryLanguage;
  final LoveLanguageEntity secondaryLanguage;
  final int totalScore;
  final DateTime completedAt;
  final String userId;

  const LoveLanguageQuizResultEntity({
    required this.id,
    required this.results,
    required this.primaryLanguage,
    required this.secondaryLanguage,
    required this.totalScore,
    required this.completedAt,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        id,
        results,
        primaryLanguage,
        secondaryLanguage,
        totalScore,
        completedAt,
        userId,
      ];
}

/// Love language quiz request
class LoveLanguageQuizRequest extends Equatable {
  final String userId;
  final List<Map<String, String>> answers; // questionId -> answerId

  const LoveLanguageQuizRequest({
    required this.userId,
    required this.answers,
  });

  @override
  List<Object?> get props => [userId, answers];
}
