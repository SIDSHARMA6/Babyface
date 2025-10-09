import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/quiz_models.dart';
import 'quiz_data_source.dart';

/// Repository for managing quiz data with offline-first approach
class QuizRepository {
  static final QuizRepository _instance = QuizRepository._internal();
  factory QuizRepository() => _instance;
  QuizRepository._internal();

  late Box _categoriesBox;
  late Box _progressBox;
  late Box _sessionsBox;
  bool _isInitialized = false;

  final QuizDataSource _dataSource = QuizDataSource();

  /// Initialize Hive boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Use dynamic boxes to avoid type conflicts
    _categoriesBox = await Hive.openBox('quiz_categories');
    _progressBox = await Hive.openBox('quiz_progress');
    _sessionsBox = await Hive.openBox('quiz_sessions');

    // Initialize with default data if empty
    if (_categoriesBox.isEmpty) {
      await _initializeDefaultData();
    }

    _isInitialized = true;
  }

  /// Ensure repository is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
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
      return _categoriesBox.values.cast<QuizCategoryModel>().toList();
    }
    return categories.cast<QuizCategoryModel>();
  }

  /// Get category by ID
  Future<QuizCategoryModel?> getCategoryById(String categoryId) async {
    return _categoriesBox.get(categoryId) as QuizCategoryModel?;
  }

  /// Get user progress
  Future<UserQuizProgress> getUserProgress(String userId) async {
    await _ensureInitialized();

    var progress = _progressBox.get(userId) as UserQuizProgress?;
    if (progress == null) {
      progress = UserQuizProgress(userId: userId);
      await _progressBox.put(userId, progress);
    }
    return progress;
  }

  /// Update user progress
  Future<void> updateUserProgress(UserQuizProgress progress) async {
    await _ensureInitialized();
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

  /// Get perfect scores count
  Future<int> getPerfectScoresCount(String userId) async {
    final progress = await getUserProgress(userId);
    return progress.earnedBadges
        .where((badge) => badge == 'perfect_score')
        .length;
  }

  /// Get current streak (consecutive days with quiz completion)
  Future<int> getCurrentStreak(String userId) async {
    final progress = await getUserProgress(userId);
    final sessions =
        _sessionsBox.values.where((session) => session.isCompleted).toList();

    if (sessions.isEmpty) return 0;

    // Sort sessions by completion date
    sessions.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    int streak = 0;
    DateTime? lastDate;

    for (final session in sessions) {
      final sessionDate = session.completedAt!;
      final today = DateTime.now();
      final daysDiff = today.difference(sessionDate).inDays;

      if (lastDate == null) {
        // First session
        if (daysDiff <= 1) {
          streak = 1;
          lastDate = sessionDate;
        }
      } else {
        // Check if this session is consecutive
        final daysBetween = lastDate.difference(sessionDate).inDays;
        if (daysBetween == 1) {
          streak++;
          lastDate = sessionDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  /// Get longest streak
  Future<int> getLongestStreak(String userId) async {
    final progress = await getUserProgress(userId);
    final sessions =
        _sessionsBox.values.where((session) => session.isCompleted).toList();

    if (sessions.isEmpty) return 0;

    // Sort sessions by completion date
    sessions.sort((a, b) => a.completedAt!.compareTo(b.completedAt!));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final session in sessions) {
      final sessionDate = session.completedAt!;

      if (lastDate == null) {
        currentStreak = 1;
        lastDate = sessionDate;
      } else {
        final daysBetween = sessionDate.difference(lastDate).inDays;
        if (daysBetween == 1) {
          currentStreak++;
        } else {
          longestStreak =
              longestStreak > currentStreak ? longestStreak : currentStreak;
          currentStreak = 1;
        }
        lastDate = sessionDate;
      }
    }

    return longestStreak > currentStreak ? longestStreak : currentStreak;
  }

  /// Get category scores
  Future<Map<String, int>> getCategoryScores(String userId) async {
    final progress = await getUserProgress(userId);
    return Map<String, int>.from(progress.categoryScores);
  }

  /// Get first quiz date
  Future<DateTime?> getFirstQuizDate(String userId) async {
    final sessions =
        _sessionsBox.values.where((session) => session.isCompleted).toList();

    if (sessions.isEmpty) return null;

    sessions.sort((a, b) => a.completedAt!.compareTo(b.completedAt!));
    return sessions.first.completedAt!;
  }

  /// Calculate puzzles solved from quiz progress
  Future<int> calculatePuzzlesSolved(String userId) async {
    final progress = await getUserProgress(userId);
    // Count completed levels as "puzzles solved"
    int puzzlesSolved = 0;
    for (final categoryId in progress.categoryLevelsCompleted.keys) {
      puzzlesSolved += progress.getCategoryLevelsCompleted(categoryId);
    }
    return puzzlesSolved;
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
