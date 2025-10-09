import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer' as developer;
import '../domain/models/couple_goals_models.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../../shared/services/firebase_service.dart';

/// Repository for managing couple goals data with offline-first approach
class CoupleGoalsRepository {
  static final CoupleGoalsRepository _instance =
      CoupleGoalsRepository._internal();
  factory CoupleGoalsRepository() => _instance;
  CoupleGoalsRepository._internal();

  late Box<CoupleGoalsData> _goalsBox;
  late Box<Achievement> _achievementsBox;
  late Box<MiniChallenge> _challengesBox;

  final QuizRepository _quizRepository = QuizRepository();
  final FirebaseService _firebaseService = FirebaseService();

  /// Initialize Hive boxes
  Future<void> initialize() async {
    _goalsBox = await Hive.openBox<CoupleGoalsData>('couple_goals');
    _achievementsBox = await Hive.openBox<Achievement>('achievements');
    _challengesBox = await Hive.openBox<MiniChallenge>('challenges');
  }

  /// Get couple goals data for a specific couple
  Future<CoupleGoalsData> getCoupleGoalsData(String coupleId) async {
    var data = _goalsBox.get(coupleId);

    if (data == null) {
      // Create initial data
      data = await _createInitialCoupleGoalsData(coupleId);
      await _goalsBox.put(coupleId, data);
    } else {
      // Update with latest quiz data
      data = await _updateCoupleGoalsFromQuizzes(data);
      await _goalsBox.put(coupleId, data);
    }

    return data;
  }

  /// Create initial couple goals data
  Future<CoupleGoalsData> _createInitialCoupleGoalsData(String coupleId) async {
    final challenges = await _generateInitialChallenges();

    return CoupleGoalsData(
      coupleId: coupleId,
      lovePercentage: 0.0,
      totalQuizzesCompleted: 0,
      totalGamesCompleted: 0,
      totalPuzzlesSolved: 0,
      insights: [],
      achievements: [],
      activeChallenges: challenges,
      completedChallenges: [],
      lastUpdated: DateTime.now(),
      currentLevel: 1,
      totalPoints: 0,
    );
  }

  /// Update couple goals data based on quiz progress
  Future<CoupleGoalsData> _updateCoupleGoalsFromQuizzes(
      CoupleGoalsData data) async {
    final userId = 'user_123'; // TODO: Get from auth
    final quizProgress = await _quizRepository.getUserProgress(userId);
    final statistics = await _quizRepository.getQuizStatistics(userId);

    // Get real quiz data
    final perfectScores = await _quizRepository.getPerfectScoresCount(userId);
    final currentStreak = await _quizRepository.getCurrentStreak(userId);
    final longestStreak = await _quizRepository.getLongestStreak(userId);
    final categoryScores = await _quizRepository.getCategoryScores(userId);
    final firstQuizDate = await _quizRepository.getFirstQuizDate(userId);
    final puzzlesSolved = await _quizRepository.calculatePuzzlesSolved(userId);

    // Calculate love percentage based on quiz performance
    final lovePercentage = _calculateLovePercentage(quizProgress, statistics);

    // Generate insights based on quiz data
    final insights = await _generateInsights(
        quizProgress, statistics, perfectScores, currentStreak);

    // Check for new achievements
    final newAchievements = await _checkForNewAchievements(
        data, quizProgress, statistics, perfectScores, currentStreak);

    // Update challenges
    final updatedChallenges = await _updateChallenges(data.activeChallenges);

    return data.copyWith(
      lovePercentage: lovePercentage,
      totalQuizzesCompleted: statistics['totalQuizzesCompleted'] as int,
      totalGamesCompleted: quizProgress.totalQuizzesCompleted,
      totalPuzzlesSolved: puzzlesSolved,
      insights: insights,
      achievements: [...data.achievements, ...newAchievements],
      activeChallenges: updatedChallenges,
      lastUpdated: DateTime.now(),
      currentLevel: _calculateLevel(statistics['totalScore'] as int),
      totalPoints: statistics['totalScore'] as int,
    );
  }

  /// Calculate love percentage based on quiz performance
  double _calculateLovePercentage(
      dynamic quizProgress, Map<String, dynamic> statistics) {
    final totalQuizzes = statistics['totalQuizzesCompleted'] as int;
    final totalScore = statistics['totalScore'] as int;
    final completionPercentage = statistics['completionPercentage'] as double;

    if (totalQuizzes == 0) return 0.0;

    // Base score from quiz performance (0-60%)
    double baseScore =
        (totalScore / (totalQuizzes * 5)) * 60; // Assuming 5 points per quiz

    // Bonus for completion percentage (0-25%)
    double completionBonus = (completionPercentage / 100) * 25;

    // Bonus for consistency (0-15%)
    double consistencyBonus =
        totalQuizzes >= 10 ? 15.0 : (totalQuizzes / 10) * 15;

    final lovePercentage =
        (baseScore + completionBonus + consistencyBonus).clamp(0.0, 100.0);
    return double.parse(lovePercentage.toStringAsFixed(1));
  }

  /// Generate relationship insights based on quiz data
  Future<List<RelationshipInsight>> _generateInsights(
      dynamic quizProgress,
      Map<String, dynamic> statistics,
      int perfectScores,
      int currentStreak) async {
    final insights = <RelationshipInsight>[];
    final totalQuizzes = statistics['totalQuizzesCompleted'] as int;

    if (totalQuizzes >= 3) {
      insights.add(RelationshipInsight(
        id: 'compatibility_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Great Compatibility!',
        description:
            'You\'ve completed $totalQuizzes quizzes together, showing strong commitment to understanding each other.',
        category: 'compatibility',
        score: 85.0,
        recommendation:
            'Keep exploring different quiz categories to deepen your bond!',
        generatedAt: DateTime.now(),
        isPositive: true,
      ));
    }

    if (perfectScores >= 3) {
      insights.add(RelationshipInsight(
        id: 'perfect_scores_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Perfect Harmony!',
        description:
            'You\'ve achieved $perfectScores perfect scores! Your understanding of each other is exceptional.',
        category: 'communication',
        score: 95.0,
        recommendation:
            'Try advanced quiz levels to challenge your knowledge even more.',
        generatedAt: DateTime.now(),
        isPositive: true,
      ));
    }

    if (currentStreak >= 7) {
      insights.add(RelationshipInsight(
        id: 'streak_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Consistent Connection!',
        description:
            'You\'ve maintained a $currentStreak-day streak! Your dedication to growing together is inspiring.',
        category: 'commitment',
        score: 90.0,
        recommendation:
            'Keep up the great work! Consistency builds stronger relationships.',
        generatedAt: DateTime.now(),
        isPositive: true,
      ));
    }

    if (statistics['totalScore'] as int >= 50) {
      insights.add(RelationshipInsight(
        id: 'knowledge_${DateTime.now().millisecondsSinceEpoch}',
        title: 'You Know Each Other Well!',
        description:
            'Your high quiz scores show you really pay attention to each other.',
        category: 'communication',
        score: 90.0,
        recommendation:
            'Try the "Know Each Other" advanced levels for even deeper connection.',
        generatedAt: DateTime.now(),
        isPositive: true,
      ));
    }

    return insights;
  }

  /// Check for new achievements
  Future<List<Achievement>> _checkForNewAchievements(
      CoupleGoalsData data,
      dynamic quizProgress,
      Map<String, dynamic> statistics,
      int perfectScores,
      int currentStreak) async {
    final newAchievements = <Achievement>[];
    final existingAchievementIds = data.achievements.map((a) => a.id).toSet();

    // First Quiz Achievement
    if (statistics['totalQuizzesCompleted'] as int >= 1 &&
        !existingAchievementIds.contains('first_quiz')) {
      newAchievements.add(Achievement(
        id: 'first_quiz',
        title: 'First Steps Together',
        description: 'Completed your first quiz as a couple!',
        iconPath: 'assets/icons/first_quiz.png',
        type: AchievementType.firstQuiz,
        unlockedAt: DateTime.now(),
        pointsAwarded: 10,
        isRare: false,
      ));
    }

    // Perfect Score Achievement
    if (statistics['totalScore'] as int >= 25 && // 5 perfect quizzes
        !existingAchievementIds.contains('perfect_score')) {
      newAchievements.add(Achievement(
        id: 'perfect_score',
        title: 'Perfect Harmony',
        description: 'Achieved perfect scores on multiple quizzes!',
        iconPath: 'assets/icons/perfect_score.png',
        type: AchievementType.perfectScore,
        unlockedAt: DateTime.now(),
        pointsAwarded: 50,
        isRare: true,
      ));
    }

    // Love Expert Achievement
    if (data.lovePercentage >= 75 &&
        !existingAchievementIds.contains('love_expert')) {
      newAchievements.add(Achievement(
        id: 'love_expert',
        title: 'Love Expert',
        description: 'Reached 75% love score - you two are amazing together!',
        iconPath: 'assets/icons/love_expert.png',
        type: AchievementType.loveExpert,
        unlockedAt: DateTime.now(),
        pointsAwarded: 100,
        isRare: true,
      ));
    }

    return newAchievements;
  }

  /// Generate initial challenges for new couples
  Future<List<MiniChallenge>> _generateInitialChallenges() async {
    final now = DateTime.now();

    return [
      MiniChallenge(
        id: 'welcome_quiz',
        title: 'Take Your First Quiz Together',
        description: 'Complete any quiz category to start your journey!',
        type: ChallengeType.quiz,
        pointsReward: 20,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
        isCompleted: false,
      ),
      MiniChallenge(
        id: 'daily_love_message',
        title: 'Send a Love Message',
        description: 'Send your partner a sweet message today 💕',
        type: ChallengeType.daily,
        pointsReward: 10,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 1)),
        isCompleted: false,
      ),
      MiniChallenge(
        id: 'know_each_other_level1',
        title: 'Complete "Know Each Other" Level 1',
        description: 'Discover something new about your partner!',
        type: ChallengeType.quiz,
        pointsReward: 30,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 3)),
        isCompleted: false,
      ),
    ];
  }

  /// Update active challenges
  Future<List<MiniChallenge>> _updateChallenges(
      List<MiniChallenge> challenges) async {
    final updatedChallenges = <MiniChallenge>[];

    for (final challenge in challenges) {
      if (!challenge.isExpired && !challenge.isCompleted) {
        updatedChallenges.add(challenge);
      }
    }

    // Add new challenges if needed
    if (updatedChallenges.length < 3) {
      updatedChallenges
          .addAll(await _generateNewChallenges(3 - updatedChallenges.length));
    }

    return updatedChallenges;
  }

  /// Generate new challenges
  Future<List<MiniChallenge>> _generateNewChallenges(int count) async {
    final now = DateTime.now();
    final challenges = <MiniChallenge>[];

    final challengeTemplates = [
      {
        'title': 'Complete Baby Game Level 2',
        'description': 'Explore fun baby predictions together!',
        'type': ChallengeType.quiz,
        'points': 25,
        'days': 3,
      },
      {
        'title': 'Share a Memory',
        'description': 'Tell your partner about a favorite childhood memory',
        'type': ChallengeType.communication,
        'points': 15,
        'days': 1,
      },
      {
        'title': 'Plan a Date Night',
        'description': 'Plan something fun to do together this week',
        'type': ChallengeType.romantic,
        'points': 20,
        'days': 7,
      },
      {
        'title': 'Complete Couple Game',
        'description': 'Test how well you know each other!',
        'type': ChallengeType.quiz,
        'points': 30,
        'days': 5,
      },
    ];

    challengeTemplates.shuffle();

    for (int i = 0; i < count && i < challengeTemplates.length; i++) {
      final template = challengeTemplates[i];
      challenges.add(MiniChallenge(
        id: 'challenge_${now.millisecondsSinceEpoch}_$i',
        title: template['title'] as String,
        description: template['description'] as String,
        type: template['type'] as ChallengeType,
        pointsReward: template['points'] as int,
        createdAt: now,
        expiresAt: now.add(Duration(days: template['days'] as int)),
        isCompleted: false,
      ));
    }

    return challenges;
  }

  /// Complete a challenge
  Future<void> completeChallenge(String coupleId, String challengeId,
      {String? note}) async {
    final data = await getCoupleGoalsData(coupleId);
    final challengeIndex =
        data.activeChallenges.indexWhere((c) => c.id == challengeId);

    if (challengeIndex != -1) {
      final challenge = data.activeChallenges[challengeIndex];
      final completedChallenge = challenge.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        completionNote: note,
      );

      final updatedActiveChallenges =
          List<MiniChallenge>.from(data.activeChallenges);
      updatedActiveChallenges.removeAt(challengeIndex);

      final updatedCompletedChallenges =
          List<MiniChallenge>.from(data.completedChallenges);
      updatedCompletedChallenges.add(completedChallenge);

      final updatedData = data.copyWith(
        activeChallenges: updatedActiveChallenges,
        completedChallenges: updatedCompletedChallenges,
        totalPoints: data.totalPoints + challenge.pointsReward,
        lastUpdated: DateTime.now(),
      );

      await _goalsBox.put(coupleId, updatedData);
    }
  }

  /// Calculate puzzles solved from quiz progress
  int _calculatePuzzlesSolved(dynamic quizProgress) {
    // Each level has 1 puzzle (5th question), so count completed levels
    int puzzlesSolved = 0;
    // This would need to be implemented based on the actual quiz progress structure
    return puzzlesSolved;
  }

  /// Calculate current level based on total points
  int _calculateLevel(int totalPoints) {
    if (totalPoints < 50) return 1;
    if (totalPoints < 150) return 2;
    if (totalPoints < 300) return 3;
    if (totalPoints < 500) return 4;
    if (totalPoints < 750) return 5;
    return 6 +
        ((totalPoints - 750) ~/ 200); // Each additional level needs 200 points
  }

  /// Get couple statistics
  Future<CoupleStatistics> getCoupleStatistics(String coupleId) async {
    final data = await getCoupleGoalsData(coupleId);
    final userId = 'user_123'; // TODO: Get from auth

    // Get real quiz data
    final perfectScores = await _quizRepository.getPerfectScoresCount(userId);
    final currentStreak = await _quizRepository.getCurrentStreak(userId);
    final longestStreak = await _quizRepository.getLongestStreak(userId);
    final categoryScores = await _quizRepository.getCategoryScores(userId);
    final firstQuizDate = await _quizRepository.getFirstQuizDate(userId);

    return CoupleStatistics(
      totalQuizzes: data.totalQuizzesCompleted,
      perfectScores: perfectScores,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      averageScore: data.totalQuizzesCompleted > 0
          ? data.totalPoints / data.totalQuizzesCompleted
          : 0,
      categoryScores: categoryScores,
      firstQuizDate:
          firstQuizDate ?? DateTime.now().subtract(const Duration(days: 30)),
      lastActiveDate: data.lastUpdated,
    );
  }

  /// Sync with cloud
  Future<void> syncWithCloud(String coupleId) async {
    try {
      developer.log(
          '🔄 [CoupleGoalsRepository] Starting cloud sync for couple: $coupleId');

      // Get local data
      final localData = await getCoupleGoalsData(coupleId);

      // Save to Firebase
      await _firebaseService.saveToFirestore(
        collection: 'couple_goals',
        documentId: coupleId,
        data: {
          'coupleId': localData.coupleId,
          'lovePercentage': localData.lovePercentage,
          'totalQuizzesCompleted': localData.totalQuizzesCompleted,
          'totalGamesCompleted': localData.totalGamesCompleted,
          'totalPuzzlesSolved': localData.totalPuzzlesSolved,
          'currentLevel': localData.currentLevel,
          'totalPoints': localData.totalPoints,
          'lastUpdated': localData.lastUpdated.toIso8601String(),
          'insights': localData.insights.map((i) => i.toMap()).toList(),
          'achievements': localData.achievements.map((a) => a.toMap()).toList(),
          'activeChallenges':
              localData.activeChallenges.map((c) => c.toMap()).toList(),
          'completedChallenges':
              localData.completedChallenges.map((c) => c.toMap()).toList(),
        },
      );

      // Sync achievements separately
      for (final achievement in localData.achievements) {
        await _firebaseService.saveToFirestore(
          collection: 'achievements',
          documentId: achievement.id,
          data: achievement.toMap(),
        );
      }

      // Sync challenges separately
      for (final challenge in localData.activeChallenges) {
        await _firebaseService.saveToFirestore(
          collection: 'challenges',
          documentId: challenge.id,
          data: challenge.toMap(),
        );
      }

      for (final challenge in localData.completedChallenges) {
        await _firebaseService.saveToFirestore(
          collection: 'challenges',
          documentId: challenge.id,
          data: challenge.toMap(),
        );
      }

      developer.log('✅ [CoupleGoalsRepository] Cloud sync completed successfully');
    } catch (e) {
      developer.log('❌ [CoupleGoalsRepository] Cloud sync failed: $e');
      rethrow;
    }
  }

  /// Load data from cloud
  Future<CoupleGoalsData?> loadFromCloud(String coupleId) async {
    try {
      developer.log(
          '📥 [CoupleGoalsRepository] Loading data from cloud for couple: $coupleId');

      final doc = await _firebaseService.getFromFirestore(
        collection: 'couple_goals',
        documentId: coupleId,
      );

      if (!doc.exists) {
        developer.log(
            '📥 [CoupleGoalsRepository] No cloud data found for couple: $coupleId');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;

      // Convert Firebase data to CoupleGoalsData
      final coupleGoalsData = CoupleGoalsData(
        coupleId: data['coupleId'] as String,
        lovePercentage: (data['lovePercentage'] as num).toDouble(),
        totalQuizzesCompleted: data['totalQuizzesCompleted'] as int,
        totalGamesCompleted: data['totalGamesCompleted'] as int,
        totalPuzzlesSolved: data['totalPuzzlesSolved'] as int,
        insights: (data['insights'] as List<dynamic>)
            .map((i) =>
                RelationshipInsight.fromMap(Map<String, dynamic>.from(i)))
            .toList(),
        achievements: (data['achievements'] as List<dynamic>)
            .map((a) => Achievement.fromMap(Map<String, dynamic>.from(a)))
            .toList(),
        activeChallenges: (data['activeChallenges'] as List<dynamic>)
            .map((c) => MiniChallenge.fromMap(Map<String, dynamic>.from(c)))
            .toList(),
        completedChallenges: (data['completedChallenges'] as List<dynamic>)
            .map((c) => MiniChallenge.fromMap(Map<String, dynamic>.from(c)))
            .toList(),
        lastUpdated: DateTime.parse(data['lastUpdated'] as String),
        currentLevel: data['currentLevel'] as int,
        totalPoints: data['totalPoints'] as int,
      );

      // Save to local storage
      await _goalsBox.put(coupleId, coupleGoalsData);

      developer.log('✅ [CoupleGoalsRepository] Data loaded from cloud successfully');
      return coupleGoalsData;
    } catch (e) {
      developer.log('❌ [CoupleGoalsRepository] Failed to load from cloud: $e');
      return null;
    }
  }

  /// Sync achievements with cloud
  Future<void> syncAchievementsWithCloud(String coupleId) async {
    try {
      final achievements = _achievementsBox.values.toList();

      for (final achievement in achievements) {
        await _firebaseService.saveToFirestore(
          collection: 'achievements',
          documentId: achievement.id,
          data: achievement.toMap(),
        );
      }

      developer.log('✅ [CoupleGoalsRepository] Achievements synced with cloud');
    } catch (e) {
      developer.log('❌ [CoupleGoalsRepository] Failed to sync achievements: $e');
    }
  }

  /// Sync challenges with cloud
  Future<void> syncChallengesWithCloud(String coupleId) async {
    try {
      final challenges = _challengesBox.values.toList();

      for (final challenge in challenges) {
        await _firebaseService.saveToFirestore(
          collection: 'challenges',
          documentId: challenge.id,
          data: challenge.toMap(),
        );
      }

      developer.log('✅ [CoupleGoalsRepository] Challenges synced with cloud');
    } catch (e) {
      developer.log('❌ [CoupleGoalsRepository] Failed to sync challenges: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _goalsBox.close();
    await _achievementsBox.close();
    await _challengesBox.close();
  }
}
