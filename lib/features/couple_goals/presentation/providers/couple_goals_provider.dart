import 'package:flutter/foundation.dart';
import 'dart:math' as math;

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAt,
  });
}

/// Insight model
class CoupleInsight {
  final String title;
  final String description;
  final double value;
  final String trend; // 'up', 'down', 'stable'

  const CoupleInsight({
    required this.title,
    required this.description,
    required this.value,
    required this.trend,
  });
}

/// Couple Goals Provider for managing relationship insights and achievements
class CoupleGoalsProvider extends ChangeNotifier {
  bool _isDisposed = false;
  double _lovePercentage = 0.0;
  List<Achievement> _achievements = [];
  List<CoupleInsight> _insights = [];
  bool _isLoading = false;
  int _streakDays = 0;
  int _totalQuizzesTaken = 0;
  int _babiesGenerated = 0;

  // Getters
  double get lovePercentage => _lovePercentage;
  List<Achievement> get achievements => _achievements;
  List<CoupleInsight> get insights => _insights;
  bool get isLoading => _isLoading;
  int get streakDays => _streakDays;
  int get totalQuizzesTaken => _totalQuizzesTaken;
  int get babiesGenerated => _babiesGenerated;

  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  CoupleGoalsProvider() {
    _initializeData();
  }

  /// Initialize mock data
  void _initializeData() {
    _generateMockData();
    _calculateLovePercentage();
    notifyListeners();
  }

  /// Generate mock achievements and insights
  void _generateMockData() {
    // Mock achievements
    _achievements = [
      Achievement(
        id: 'first_quiz',
        title: 'Quiz Masters',
        description: 'Complete your first quiz together',
        icon: '🎯',
        isUnlocked: _totalQuizzesTaken > 0,
        unlockedAt: _totalQuizzesTaken > 0
            ? DateTime.now().subtract(const Duration(days: 1))
            : null,
      ),
      Achievement(
        id: 'first_baby',
        title: 'Future Parents',
        description: 'Generate your first baby image',
        icon: '👶',
        isUnlocked: _babiesGenerated > 0,
        unlockedAt: _babiesGenerated > 0
            ? DateTime.now().subtract(const Duration(hours: 2))
            : null,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warriors',
        description: 'Use the app for 7 days straight',
        icon: '🔥',
        isUnlocked: _streakDays >= 7,
        unlockedAt: _streakDays >= 7
            ? DateTime.now().subtract(const Duration(days: 1))
            : null,
      ),
      Achievement(
        id: 'love_80',
        title: 'Perfect Match',
        description: 'Reach 80% love compatibility',
        icon: '💕',
        isUnlocked: _lovePercentage >= 80,
        unlockedAt: _lovePercentage >= 80 ? DateTime.now() : null,
      ),
    ];

    // Mock insights
    _insights = [
      CoupleInsight(
        title: 'Communication Score',
        description: 'Based on quiz responses',
        value: 85.0,
        trend: 'up',
      ),
      CoupleInsight(
        title: 'Shared Interests',
        description: 'Common hobbies and activities',
        value: 72.0,
        trend: 'stable',
      ),
      CoupleInsight(
        title: 'Future Planning',
        description: 'Alignment on life goals',
        value: 90.0,
        trend: 'up',
      ),
      CoupleInsight(
        title: 'Fun Factor',
        description: 'Playfulness and humor',
        value: 88.0,
        trend: 'up',
      ),
    ];

    // Mock stats
    _streakDays = 5;
    _totalQuizzesTaken = 3;
    _babiesGenerated = 2;
  }

  /// Calculate love percentage based on various factors
  void _calculateLovePercentage() {
    _isLoading = true;
    if (!_isDisposed) {
      notifyListeners();
    }

    // Simulate calculation delay
    Future.delayed(const Duration(milliseconds: 800), () {
      // Mock calculation based on insights
      double total = 0;
      for (final insight in _insights) {
        total += insight.value;
      }

      _lovePercentage = _insights.isNotEmpty ? total / _insights.length : 0;

      // Add bonus for achievements
      final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
      _lovePercentage += unlockedCount * 2; // 2% bonus per achievement

      // Cap at 100%
      _lovePercentage = math.min(_lovePercentage, 100.0);

      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  /// Update quiz completion
  void onQuizCompleted(int score) {
    _totalQuizzesTaken++;

    // Update insights based on quiz performance
    if (score > 80) {
      _updateInsight('Communication Score', 2.0);
    }

    _calculateLovePercentage();
    _checkAchievements();
  }

  /// Update baby generation
  void onBabyGenerated() {
    _babiesGenerated++;
    _updateInsight('Future Planning', 1.5);
    _calculateLovePercentage();
    _checkAchievements();
  }

  /// Update daily streak
  void updateStreak() {
    _streakDays++;
    _checkAchievements();
  }

  /// Update specific insight value
  void _updateInsight(String title, double increment) {
    final index = _insights.indexWhere((i) => i.title == title);
    if (index != -1) {
      final insight = _insights[index];
      final newValue = math.min(insight.value + increment, 100.0);
      _insights[index] = CoupleInsight(
        title: insight.title,
        description: insight.description,
        value: newValue,
        trend: newValue > insight.value ? 'up' : 'stable',
      );
    }
  }

  /// Check and unlock achievements
  void _checkAchievements() {
    bool hasNewAchievement = false;

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (!achievement.isUnlocked) {
        bool shouldUnlock = false;

        switch (achievement.id) {
          case 'first_quiz':
            shouldUnlock = _totalQuizzesTaken > 0;
            break;
          case 'first_baby':
            shouldUnlock = _babiesGenerated > 0;
            break;
          case 'streak_7':
            shouldUnlock = _streakDays >= 7;
            break;
          case 'love_80':
            shouldUnlock = _lovePercentage >= 80;
            break;
        }

        if (shouldUnlock) {
          _achievements[i] = Achievement(
            id: achievement.id,
            title: achievement.title,
            description: achievement.description,
            icon: achievement.icon,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
          hasNewAchievement = true;
        }
      }
    }

    if (hasNewAchievement) {
      notifyListeners();
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    _generateMockData();
    _calculateLovePercentage();
  }

  /// Reset all data
  void reset() {
    _lovePercentage = 0.0;
    _achievements.clear();
    _insights.clear();
    _streakDays = 0;
    _totalQuizzesTaken = 0;
    _babiesGenerated = 0;
    _isLoading = false;

    _initializeData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
