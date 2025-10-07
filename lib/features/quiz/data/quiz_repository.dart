import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/quiz_models.dart';
import 'quiz_data_source.dart';

/// Repository for managing quiz data with offline-first approach
class QuizRepository {
  static final QuizRepository _instance = QuizRepository._internal();
  factory QuizRepository() => _instance;
  QuizRepository._internal();

  late Box<QuizCategoryModel> _categoriesBox;
  late Box<UserQuizProgress> _progressBox;
  late Box<QuizSession> _sessionsBox;

  final QuizDataSource _dataSource = QuizDataSource();

  /// Initialize Hive boxes
  Future<void> initialize() async {
    _categoriesBox = await Hive.openBox<QuizCategoryModel>('quiz_categories');
    _progressBox = await Hive.openBox<UserQuizProgress>('quiz_progress');
    _sessionsBox = await Hive.openBox<QuizSession>('quiz_sessions');

    // Initialize with default data if empty
    if (_categoriesBox.isEmpty) {
      await _initializeDefaultData();
    }
  }

  /// Initialize default quiz data
  Future<void> _initializeDefaultData() async {
    final categories = _dataSource.getAllQuizCategories();
    for (final category in categories) {
      await _categoriesBox.put(category.id, category);
    }
  }

  /// Get all quiz categories
  Future<List<QuizCategoryModel>> getAllCategories() async {
    final categories = _categoriesBox.values.toList();
    if (categories.isEmpty) {
      await _initializeDefaultData();
      return _categoriesBox.values.toList();
    }
    return categories;
  }

  /// Get category by ID
  Future<QuizCategoryModel?> getCategoryById(String categoryId) async {
    return _categoriesBox.get(categoryId);
  }

  /// Get user progress
  Future<UserQuizProgress> getUserProgress(String userId) async {
    var progress = _progressBox.get(userId);
    if (progress == null) {
      progress = UserQuizProgress(userId: userId);
      await _progressBox.put(userId, progress);
    }
    return progress;
  }

  /// Update user progress
  Future<void> updateUserProgress(UserQuizProgress progress) async {
    await _progressBox.put(progress.userId, progress);
  }

  /// Start a new quiz session
  Future<QuizSession> startQuizSession({
    required String categoryId,
    required String levelId,
    required String userId,
  }) async {
    final sessionId =
        '${categoryId}_${levelId}_${DateTime.now().millisecondsSinceEpoch}';
    final session = QuizSession(
      id: sessionId,
      categoryId: categoryId,
      levelId: levelId,
      startedAt: DateTime.now(),
    );

    await _sessionsBox.put(sessionId, session);
    return session;
  }

  /// Update quiz session
  Future<void> updateQuizSession(QuizSession session) async {
    await _sessionsBox.put(session.id, session);
  }

  /// Complete quiz session and update progress
  Future<void> completeQuizSession({
    required QuizSession session,
    required String userId,
    required int finalScore,
  }) async {
    // Update session
    final completedSession = session.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      score: finalScore,
    );
    await _sessionsBox.put(session.id, completedSession);

    // Update user progress
    final progress = await getUserProgress(userId);
    final category = await getCategoryById(session.categoryId);

    if (category != null) {
      // Update category scores
      final currentCategoryScore =
          progress.getCategoryScore(session.categoryId);
      final newCategoryScores = Map<String, int>.from(progress.categoryScores);
      newCategoryScores[session.categoryId] = currentCategoryScore + finalScore;

      // Update levels completed if perfect score
      final newLevelsCompleted =
          Map<String, int>.from(progress.categoryLevelsCompleted);
      if (finalScore >= 5) {
        // Perfect score unlocks next level
        final currentLevels =
            progress.getCategoryLevelsCompleted(session.categoryId);
        final level =
            category.levels.firstWhere((l) => l.id == session.levelId);
        if (level.levelNumber > currentLevels) {
          newLevelsCompleted[session.categoryId] = level.levelNumber;
        }
      }

      // Update category last played
      final newCategoryLastPlayed =
          Map<String, DateTime>.from(progress.categoryLastPlayed);
      newCategoryLastPlayed[session.categoryId] = DateTime.now();

      // Check for new badges
      final newBadges = List<String>.from(progress.earnedBadges);
      final earnedBadges =
          _checkForNewBadges(progress, finalScore, session.categoryId);
      newBadges.addAll(earnedBadges);

      final updatedProgress = progress.copyWith(
        categoryScores: newCategoryScores,
        categoryLevelsCompleted: newLevelsCompleted,
        totalQuizzesCompleted: progress.totalQuizzesCompleted + 1,
        totalScore: progress.totalScore + finalScore,
        lastPlayedAt: DateTime.now(),
        categoryLastPlayed: newCategoryLastPlayed,
        earnedBadges: newBadges,
      );

      await updateUserProgress(updatedProgress);

      // Update category with new progress
      await _updateCategoryProgress(session.categoryId, updatedProgress);
    }
  }

  /// Check for new badges earned
  List<String> _checkForNewBadges(
      UserQuizProgress progress, int score, String categoryId) {
    final badges = <String>[];

    // Perfect score badge
    if (score >= 5 && !progress.hasBadge('perfect_score')) {
      badges.add('perfect_score');
    }

    // Category completion badges
    final categoryLevels = progress.getCategoryLevelsCompleted(categoryId);
    if (categoryLevels >= 5 && !progress.hasBadge('${categoryId}_master')) {
      badges.add('${categoryId}_master');
    }

    // Total quizzes badges
    final totalQuizzes = progress.totalQuizzesCompleted + 1;
    if (totalQuizzes >= 10 && !progress.hasBadge('quiz_enthusiast')) {
      badges.add('quiz_enthusiast');
    }
    if (totalQuizzes >= 50 && !progress.hasBadge('quiz_master')) {
      badges.add('quiz_master');
    }

    return badges;
  }

  /// Update category with user progress
  Future<void> _updateCategoryProgress(
      String categoryId, UserQuizProgress progress) async {
    final category = await getCategoryById(categoryId);
    if (category != null) {
      final updatedCategory = category.copyWith(
        completedLevels: progress.getCategoryLevelsCompleted(categoryId),
        totalScore: progress.getCategoryScore(categoryId),
        lastPlayedAt: progress.categoryLastPlayed[categoryId],
      );
      await _categoriesBox.put(categoryId, updatedCategory);
    }
  }

  /// Unlock next level in category
  Future<void> unlockNextLevel(String categoryId, int currentLevel) async {
    final category = await getCategoryById(categoryId);
    if (category != null && currentLevel < category.levels.length) {
      final levels = List<QuizLevel>.from(category.levels);
      if (currentLevel < levels.length) {
        levels[currentLevel] = levels[currentLevel].copyWith(isUnlocked: true);
        final updatedCategory = category.copyWith(levels: levels);
        await _categoriesBox.put(categoryId, updatedCategory);
      }
    }
  }

  /// Get active quiz session
  Future<QuizSession?> getActiveSession(String userId) async {
    final sessions =
        _sessionsBox.values.where((session) => !session.isCompleted);
    return sessions.isNotEmpty ? sessions.first : null;
  }

  /// Get quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics(String userId) async {
    final progress = await getUserProgress(userId);
    final categories = await getAllCategories();

    int totalLevelsAvailable = 0;
    int totalLevelsCompleted = 0;

    for (final category in categories) {
      totalLevelsAvailable += category.totalLevels;
      totalLevelsCompleted += progress.getCategoryLevelsCompleted(category.id);
    }

    return {
      'totalQuizzesCompleted': progress.totalQuizzesCompleted,
      'totalScore': progress.totalScore,
      'totalBadges': progress.earnedBadges.length,
      'totalLevelsCompleted': totalLevelsCompleted,
      'totalLevelsAvailable': totalLevelsAvailable,
      'completionPercentage': totalLevelsAvailable > 0
          ? (totalLevelsCompleted / totalLevelsAvailable) * 100
          : 0.0,
      'lastPlayedAt': progress.lastPlayedAt,
    };
  }

  /// Reset user progress (for testing or user request)
  Future<void> resetUserProgress(String userId) async {
    await _progressBox.delete(userId);

    // Reset all categories to initial state
    await _initializeDefaultData();
  }

  /// Sync with cloud (placeholder for future implementation)
  Future<void> syncWithCloud(String userId) async {
    // TODO: Implement cloud sync
    // This would sync local progress with Firebase/backend
  }

  /// Get leaderboard data
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final allProgress = _progressBox.values.toList();
    allProgress.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return allProgress
        .take(10)
        .map((progress) => {
              'userId': progress.userId,
              'totalScore': progress.totalScore,
              'totalQuizzes': progress.totalQuizzesCompleted,
              'badges': progress.earnedBadges.length,
            })
        .toList();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _categoriesBox.close();
    await _progressBox.close();
    await _sessionsBox.close();
  }
}
