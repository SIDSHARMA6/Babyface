enum QuizCategory {
  babyPrediction,
  coupleCompatibility,
  loveLanguage,
  futureHome,
  parentingStyle,
  relationshipMilestones,
  couplePuzzles,
  rolePlayScenarios,
  futurePredictions,
  anniversaryMemories,
}

enum PlayerType {
  boy,
  girl,
  both,
}

enum QuestionType {
  multipleChoice,
  trueFalse,
  slider,
  textInput,
  imageSelection,
  puzzle,
}

class QuizQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final PlayerType targetPlayer;
  final List<String> options;
  final String correctAnswer;
  final String? hint;
  final String? explanation;
  final Map<String, dynamic>? metadata;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.targetPlayer,
    required this.options,
    required this.correctAnswer,
    this.hint,
    this.explanation,
    this.metadata,
  });
}

class QuizLevel {
  final int levelNumber;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final QuizQuestion puzzle;
  final bool isUnlocked;
  final bool isCompleted;
  final int? score;
  final DateTime? completedAt;

  const QuizLevel({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.questions,
    required this.puzzle,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.score,
    this.completedAt,
  });

  QuizLevel copyWith({
    int? levelNumber,
    String? title,
    String? description,
    List<QuizQuestion>? questions,
    QuizQuestion? puzzle,
    bool? isUnlocked,
    bool? isCompleted,
    int? score,
    DateTime? completedAt,
  }) {
    return QuizLevel(
      levelNumber: levelNumber ?? this.levelNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      puzzle: puzzle ?? this.puzzle,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class Quiz {
  final QuizCategory category;
  final String title;
  final String description;
  final String icon;
  final List<QuizLevel> levels;
  final int totalLevels;
  final int completedLevels;
  final double progressPercentage;
  final bool isFeatured;

  const Quiz({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.levels,
    required this.totalLevels,
    required this.completedLevels,
    required this.progressPercentage,
    this.isFeatured = false,
  });

  Quiz copyWith({
    QuizCategory? category,
    String? title,
    String? description,
    String? icon,
    List<QuizLevel>? levels,
    int? totalLevels,
    int? completedLevels,
    double? progressPercentage,
    bool? isFeatured,
  }) {
    return Quiz(
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      levels: levels ?? this.levels,
      totalLevels: totalLevels ?? this.totalLevels,
      completedLevels: completedLevels ?? this.completedLevels,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

class QuizProgress {
  final String userId;
  final QuizCategory category;
  final int currentLevel;
  final int totalScore;
  final Map<int, int> levelScores;
  final DateTime lastPlayed;
  final int streakDays;

  const QuizProgress({
    required this.userId,
    required this.category,
    required this.currentLevel,
    required this.totalScore,
    required this.levelScores,
    required this.lastPlayed,
    required this.streakDays,
  });

  QuizProgress copyWith({
    String? userId,
    QuizCategory? category,
    int? currentLevel,
    int? totalScore,
    Map<int, int>? levelScores,
    DateTime? lastPlayed,
    int? streakDays,
  }) {
    return QuizProgress(
      userId: userId ?? this.userId,
      category: category ?? this.category,
      currentLevel: currentLevel ?? this.currentLevel,
      totalScore: totalScore ?? this.totalScore,
      levelScores: levelScores ?? this.levelScores,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}

class CoupleQuizSession {
  final String sessionId;
  final String boyUserId;
  final String girlUserId;
  final QuizCategory category;
  final int level;
  final PlayerType currentPlayer;
  final Map<String, String> boyAnswers;
  final Map<String, String> girlAnswers;
  final int boyScore;
  final int girlScore;
  final bool isCompleted;
  final DateTime startedAt;
  final DateTime? completedAt;

  const CoupleQuizSession({
    required this.sessionId,
    required this.boyUserId,
    required this.girlUserId,
    required this.category,
    required this.level,
    required this.currentPlayer,
    required this.boyAnswers,
    required this.girlAnswers,
    required this.boyScore,
    required this.girlScore,
    required this.isCompleted,
    required this.startedAt,
    this.completedAt,
  });

  CoupleQuizSession copyWith({
    String? sessionId,
    String? boyUserId,
    String? girlUserId,
    QuizCategory? category,
    int? level,
    PlayerType? currentPlayer,
    Map<String, String>? boyAnswers,
    Map<String, String>? girlAnswers,
    int? boyScore,
    int? girlScore,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return CoupleQuizSession(
      sessionId: sessionId ?? this.sessionId,
      boyUserId: boyUserId ?? this.boyUserId,
      girlUserId: girlUserId ?? this.girlUserId,
      category: category ?? this.category,
      level: level ?? this.level,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      boyAnswers: boyAnswers ?? this.boyAnswers,
      girlAnswers: girlAnswers ?? this.girlAnswers,
      boyScore: boyScore ?? this.boyScore,
      girlScore: girlScore ?? this.girlScore,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
