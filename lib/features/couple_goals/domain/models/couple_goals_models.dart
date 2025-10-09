/// Couple Goals domain models for relationship insights and progress tracking
class CoupleGoalsData {
  final String coupleId;
  final double lovePercentage;
  final int totalQuizzesCompleted;
  final int totalGamesCompleted;
  final int totalPuzzlesSolved;
  final List<RelationshipInsight> insights;
  final List<Achievement> achievements;
  final List<MiniChallenge> activeChallenges;
  final List<MiniChallenge> completedChallenges;
  final DateTime lastUpdated;
  final int currentLevel;
  final int totalPoints;

  const CoupleGoalsData({
    required this.coupleId,
    required this.lovePercentage,
    required this.totalQuizzesCompleted,
    required this.totalGamesCompleted,
    required this.totalPuzzlesSolved,
    required this.insights,
    required this.achievements,
    required this.activeChallenges,
    required this.completedChallenges,
    required this.lastUpdated,
    required this.currentLevel,
    required this.totalPoints,
  });

  CoupleGoalsData copyWith({
    String? coupleId,
    double? lovePercentage,
    int? totalQuizzesCompleted,
    int? totalGamesCompleted,
    int? totalPuzzlesSolved,
    List<RelationshipInsight>? insights,
    List<Achievement>? achievements,
    List<MiniChallenge>? activeChallenges,
    List<MiniChallenge>? completedChallenges,
    DateTime? lastUpdated,
    int? currentLevel,
    int? totalPoints,
  }) {
    return CoupleGoalsData(
      coupleId: coupleId ?? this.coupleId,
      lovePercentage: lovePercentage ?? this.lovePercentage,
      totalQuizzesCompleted:
          totalQuizzesCompleted ?? this.totalQuizzesCompleted,
      totalGamesCompleted: totalGamesCompleted ?? this.totalGamesCompleted,
      totalPuzzlesSolved: totalPuzzlesSolved ?? this.totalPuzzlesSolved,
      insights: insights ?? this.insights,
      achievements: achievements ?? this.achievements,
      activeChallenges: activeChallenges ?? this.activeChallenges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentLevel: currentLevel ?? this.currentLevel,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  String get loveStatus {
    if (lovePercentage >= 90) return 'Soulmates 💕';
    if (lovePercentage >= 75) return 'Strong Bond 💖';
    if (lovePercentage >= 50) return 'Growing Love 💗';
    if (lovePercentage >= 25) return 'Getting Closer 💓';
    return 'Just Started 💝';
  }

  String get loveEmoji {
    if (lovePercentage >= 90) return '💕';
    if (lovePercentage >= 75) return '💖';
    if (lovePercentage >= 50) return '💗';
    if (lovePercentage >= 25) return '💓';
    return '💝';
  }
}

/// Relationship insights based on quiz performance
class RelationshipInsight {
  final String id;
  final String title;
  final String description;
  final String category; // compatibility, communication, fun, etc.
  final double score; // 0-100
  final String recommendation;
  final DateTime generatedAt;
  final bool isPositive;

  const RelationshipInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.score,
    required this.recommendation,
    required this.generatedAt,
    required this.isPositive,
  });

  String get emoji {
    switch (category.toLowerCase()) {
      case 'compatibility':
        return '🤝';
      case 'communication':
        return '💬';
      case 'fun':
        return '🎉';
      case 'intimacy':
        return '💕';
      case 'goals':
        return '🎯';
      default:
        return '💖';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'score': score,
      'recommendation': recommendation,
      'generatedAt': generatedAt.toIso8601String(),
      'isPositive': isPositive,
    };
  }

  factory RelationshipInsight.fromMap(Map<String, dynamic> map) {
    return RelationshipInsight(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      score: (map['score'] ?? 0.0).toDouble(),
      recommendation: map['recommendation'] ?? '',
      generatedAt: DateTime.parse(
          map['generatedAt'] ?? DateTime.now().toIso8601String()),
      isPositive: map['isPositive'] ?? true,
    );
  }
}

/// Achievement system for gamification
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final AchievementType type;
  final DateTime unlockedAt;
  final int pointsAwarded;
  final bool isRare;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.unlockedAt,
    required this.pointsAwarded,
    required this.isRare,
  });

  String get emoji {
    switch (type) {
      case AchievementType.firstQuiz:
        return '🎯';
      case AchievementType.perfectScore:
        return '⭐';
      case AchievementType.streakMaster:
        return '🔥';
      case AchievementType.loveExpert:
        return '💕';
      case AchievementType.puzzleMaster:
        return '🧩';
      case AchievementType.communicator:
        return '💬';
      case AchievementType.goalSetter:
        return '🏆';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'type': type.name,
      'unlockedAt': unlockedAt.toIso8601String(),
      'pointsAwarded': pointsAwarded,
      'isRare': isRare,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      iconPath: map['iconPath'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AchievementType.firstQuiz,
      ),
      unlockedAt:
          DateTime.parse(map['unlockedAt'] ?? DateTime.now().toIso8601String()),
      pointsAwarded: map['pointsAwarded'] ?? 0,
      isRare: map['isRare'] ?? false,
    );
  }
}

enum AchievementType {
  firstQuiz,
  perfectScore,
  streakMaster,
  loveExpert,
  puzzleMaster,
  communicator,
  goalSetter,
}

/// Mini challenges to keep couples engaged
class MiniChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int pointsReward;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime expiresAt;
  final bool isCompleted;
  final String? completionNote;

  const MiniChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.pointsReward,
    required this.createdAt,
    this.completedAt,
    required this.expiresAt,
    required this.isCompleted,
    this.completionNote,
  });

  MiniChallenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    int? pointsReward,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? expiresAt,
    bool? isCompleted,
    String? completionNote,
  }) {
    return MiniChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      pointsReward: pointsReward ?? this.pointsReward,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completionNote: completionNote ?? this.completionNote,
    );
  }

  String get emoji {
    switch (type) {
      case ChallengeType.daily:
        return '📅';
      case ChallengeType.weekly:
        return '📆';
      case ChallengeType.quiz:
        return '🎯';
      case ChallengeType.communication:
        return '💬';
      case ChallengeType.fun:
        return '🎉';
      case ChallengeType.romantic:
        return '💕';
    }
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeRemaining => expiresAt.difference(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'pointsReward': pointsReward,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isCompleted': isCompleted,
      'completionNote': completionNote,
    };
  }

  factory MiniChallenge.fromMap(Map<String, dynamic> map) {
    return MiniChallenge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ChallengeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ChallengeType.daily,
      ),
      pointsReward: map['pointsReward'] ?? 0,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      expiresAt:
          DateTime.parse(map['expiresAt'] ?? DateTime.now().toIso8601String()),
      isCompleted: map['isCompleted'] ?? false,
      completionNote: map['completionNote'],
    );
  }
}

enum ChallengeType {
  daily,
  weekly,
  quiz,
  communication,
  fun,
  romantic,
}

/// Level progression system
class CoupleLevel {
  final int level;
  final String title;
  final String description;
  final int pointsRequired;
  final List<String> rewards;
  final bool isUnlocked;

  const CoupleLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.rewards,
    required this.isUnlocked,
  });

  String get emoji {
    if (level <= 5) return '💝';
    if (level <= 10) return '💗';
    if (level <= 15) return '💖';
    if (level <= 20) return '💕';
    return '👑';
  }
}

/// Statistics for couple progress
class CoupleStatistics {
  final int totalQuizzes;
  final int perfectScores;
  final int currentStreak;
  final int longestStreak;
  final double averageScore;
  final Map<String, int> categoryScores;
  final DateTime firstQuizDate;
  final DateTime lastActiveDate;

  const CoupleStatistics({
    required this.totalQuizzes,
    required this.perfectScores,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageScore,
    required this.categoryScores,
    required this.firstQuizDate,
    required this.lastActiveDate,
  });

  double get perfectScorePercentage =>
      totalQuizzes > 0 ? (perfectScores / totalQuizzes) * 100 : 0;

  int get daysActive => DateTime.now().difference(firstQuizDate).inDays + 1;
}
