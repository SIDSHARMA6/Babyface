/// Quiz category types - 5 main categories as per requirements
enum QuizCategory {
  babyGame,
  coupleGame,
  partingGame,
  couplesGoals,
  knowEachOther,
}

extension QuizCategoryExtension on QuizCategory {
  String get displayName {
    switch (this) {
      case QuizCategory.babyGame:
        return 'Baby Game';
      case QuizCategory.coupleGame:
        return 'Couple Game';
      case QuizCategory.partingGame:
        return 'Parting Game';
      case QuizCategory.couplesGoals:
        return 'Couples Goals';
      case QuizCategory.knowEachOther:
        return 'Know Each Other';
    }
  }

  String get description {
    switch (this) {
      case QuizCategory.babyGame:
        return 'Fun predictions & games for baby planning';
      case QuizCategory.coupleGame:
        return 'Bonding & fun couple games';
      case QuizCategory.partingGame:
        return 'Compatibility/puzzle games';
      case QuizCategory.couplesGoals:
        return 'Goal setting & interactive quizzes';
      case QuizCategory.knowEachOther:
        return 'Emotional & fun Q&A to know partner';
    }
  }

  String get iconPath {
    switch (this) {
      case QuizCategory.babyGame:
        return 'assets/icons/baby_game.png';
      case QuizCategory.coupleGame:
        return 'assets/icons/couple_game.png';
      case QuizCategory.partingGame:
        return 'assets/icons/parting_game.png';
      case QuizCategory.couplesGoals:
        return 'assets/icons/couples_goals.png';
      case QuizCategory.knowEachOther:
        return 'assets/icons/know_each_other.png';
    }
  }

  int get colorValue {
    switch (this) {
      case QuizCategory.babyGame:
        return 0xFFFF6B81; // Pink
      case QuizCategory.coupleGame:
        return 0xFF6BCBFF; // Blue
      case QuizCategory.partingGame:
        return 0xFFFFE066; // Yellow
      case QuizCategory.couplesGoals:
        return 0xFFFF9A8B; // Peach
      case QuizCategory.knowEachOther:
        return 0xFFA8E6CF; // Green
    }
  }
}

/// Question types
enum QuestionType {
  multipleChoice,
  puzzle,
  dragDrop,
  matching,
  emoji,
}

/// Difficulty levels
enum DifficultyLevel {
  easy,
  medium,
  hard,
  expert,
}

/// Quiz question model
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final QuestionType type;
  final String? explanation;
  final String? imageUrl;
  final Map<String, dynamic>? puzzleData;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.type,
    this.explanation,
    this.imageUrl,
    this.puzzleData,
  });

  QuizQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    QuestionType? type,
    String? explanation,
    String? imageUrl,
    Map<String, dynamic>? puzzleData,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      type: type ?? this.type,
      explanation: explanation ?? this.explanation,
      imageUrl: imageUrl ?? this.imageUrl,
      puzzleData: puzzleData ?? this.puzzleData,
    );
  }
}

/// Quiz level model
class QuizLevel {
  final String id;
  final int levelNumber;
  final String title;
  final String description;
  final DifficultyLevel difficulty;
  final List<QuizQuestion> questions; // Always 5 questions (4 MCQ + 1 puzzle)
  final int requiredScore; // Score needed to pass (usually 5/5)
  final List<String> rewards; // Badges, points, etc.
  final bool isUnlocked;
  final DateTime? completedAt;
  final int? userScore;

  QuizLevel({
    required this.id,
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.questions,
    this.requiredScore = 5,
    this.rewards = const [],
    this.isUnlocked = false,
    this.completedAt,
    this.userScore,
  });

  QuizLevel copyWith({
    String? id,
    int? levelNumber,
    String? title,
    String? description,
    DifficultyLevel? difficulty,
    List<QuizQuestion>? questions,
    int? requiredScore,
    List<String>? rewards,
    bool? isUnlocked,
    DateTime? completedAt,
    int? userScore,
  }) {
    return QuizLevel(
      id: id ?? this.id,
      levelNumber: levelNumber ?? this.levelNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      questions: questions ?? this.questions,
      requiredScore: requiredScore ?? this.requiredScore,
      rewards: rewards ?? this.rewards,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      completedAt: completedAt ?? this.completedAt,
      userScore: userScore ?? this.userScore,
    );
  }

  bool get isCompleted => userScore != null && userScore! >= requiredScore;
  bool get isPerfectScore => userScore == questions.length;
  double get progressPercentage =>
      userScore != null ? (userScore! / questions.length) * 100 : 0;
}

/// Quiz category model
class QuizCategoryModel {
  final String id;
  final QuizCategory category;
  final String title;
  final String description;
  final String iconPath;
  final int colorValue;
  final List<QuizLevel> levels;
  final int totalLevels;
  final int completedLevels;
  final int totalScore;
  final DateTime? lastPlayedAt;

  QuizCategoryModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.colorValue,
    required this.levels,
    this.totalLevels = 0,
    this.completedLevels = 0,
    this.totalScore = 0,
    this.lastPlayedAt,
  });

  QuizCategoryModel copyWith({
    String? id,
    QuizCategory? category,
    String? title,
    String? description,
    String? iconPath,
    int? colorValue,
    List<QuizLevel>? levels,
    int? totalLevels,
    int? completedLevels,
    int? totalScore,
    DateTime? lastPlayedAt,
  }) {
    return QuizCategoryModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      colorValue: colorValue ?? this.colorValue,
      levels: levels ?? this.levels,
      totalLevels: totalLevels ?? this.totalLevels,
      completedLevels: completedLevels ?? this.completedLevels,
      totalScore: totalScore ?? this.totalScore,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  double get progressPercentage =>
      totalLevels > 0 ? (completedLevels / totalLevels) * 100 : 0;
  int get nextLevelNumber => completedLevels + 1;
  bool get isCompleted => completedLevels >= totalLevels;
}

/// User quiz progress model
class UserQuizProgress {
  final String userId;
  final Map<String, int> categoryScores; // categoryId -> totalScore
  final Map<String, int>
      categoryLevelsCompleted; // categoryId -> levelsCompleted
  final List<String> earnedBadges;
  final int totalQuizzesCompleted;
  final int totalScore;
  final DateTime? lastPlayedAt;
  final Map<String, DateTime> categoryLastPlayed; // categoryId -> lastPlayedAt

  UserQuizProgress({
    required this.userId,
    this.categoryScores = const {},
    this.categoryLevelsCompleted = const {},
    this.earnedBadges = const [],
    this.totalQuizzesCompleted = 0,
    this.totalScore = 0,
    this.lastPlayedAt,
    this.categoryLastPlayed = const {},
  });

  UserQuizProgress copyWith({
    String? userId,
    Map<String, int>? categoryScores,
    Map<String, int>? categoryLevelsCompleted,
    List<String>? earnedBadges,
    int? totalQuizzesCompleted,
    int? totalScore,
    DateTime? lastPlayedAt,
    Map<String, DateTime>? categoryLastPlayed,
  }) {
    return UserQuizProgress(
      userId: userId ?? this.userId,
      categoryScores: categoryScores ?? this.categoryScores,
      categoryLevelsCompleted:
          categoryLevelsCompleted ?? this.categoryLevelsCompleted,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      totalQuizzesCompleted:
          totalQuizzesCompleted ?? this.totalQuizzesCompleted,
      totalScore: totalScore ?? this.totalScore,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      categoryLastPlayed: categoryLastPlayed ?? this.categoryLastPlayed,
    );
  }

  int getCategoryScore(String categoryId) => categoryScores[categoryId] ?? 0;
  int getCategoryLevelsCompleted(String categoryId) =>
      categoryLevelsCompleted[categoryId] ?? 0;
  bool hasBadge(String badgeId) => earnedBadges.contains(badgeId);
}

/// Quiz session model for tracking current gameplay
class QuizSession {
  final String id;
  final String categoryId;
  final String levelId;
  final int currentQuestionIndex;
  final List<int> userAnswers;
  final int score;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final Map<String, dynamic>? sessionData; // For storing puzzle states, etc.

  QuizSession({
    required this.id,
    required this.categoryId,
    required this.levelId,
    this.currentQuestionIndex = 0,
    this.userAnswers = const [],
    this.score = 0,
    required this.startedAt,
    this.completedAt,
    this.isCompleted = false,
    this.sessionData,
  });

  QuizSession copyWith({
    String? id,
    String? categoryId,
    String? levelId,
    int? currentQuestionIndex,
    List<int>? userAnswers,
    int? score,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isCompleted,
    Map<String, dynamic>? sessionData,
  }) {
    return QuizSession(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      levelId: levelId ?? this.levelId,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      score: score ?? this.score,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      sessionData: sessionData ?? this.sessionData,
    );
  }

  bool get canProceedToNext => currentQuestionIndex < 4; // 0-4 for 5 questions
  double get progressPercentage => ((currentQuestionIndex + 1) / 5) * 100;
  Duration get sessionDuration =>
      (completedAt ?? DateTime.now()).difference(startedAt);
}
