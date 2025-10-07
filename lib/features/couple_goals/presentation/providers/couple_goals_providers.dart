import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/couple_goals_models.dart';
import '../../data/couple_goals_repository.dart';

/// Couple Goals repository provider
final coupleGoalsRepositoryProvider = Provider<CoupleGoalsRepository>((ref) {
  return CoupleGoalsRepository();
});

/// Current couple ID provider (would come from auth in real app)
final currentCoupleIdProvider = Provider<String>((ref) {
  return 'couple_123'; // TODO: Get from authentication
});

/// Couple goals data provider
final coupleGoalsDataProvider = FutureProvider<CoupleGoalsData>((ref) async {
  final repository = ref.read(coupleGoalsRepositoryProvider);
  final coupleId = ref.read(currentCoupleIdProvider);
  return await repository.getCoupleGoalsData(coupleId);
});

/// Couple statistics provider
final coupleStatisticsProvider = FutureProvider<CoupleStatistics>((ref) async {
  final repository = ref.read(coupleGoalsRepositoryProvider);
  final coupleId = ref.read(currentCoupleIdProvider);
  return await repository.getCoupleStatistics(coupleId);
});

/// Active challenges provider
final activeChallengesProvider =
    FutureProvider<List<MiniChallenge>>((ref) async {
  final coupleGoalsData = await ref.watch(coupleGoalsDataProvider.future);
  return coupleGoalsData.activeChallenges;
});

/// Completed challenges provider
final completedChallengesProvider =
    FutureProvider<List<MiniChallenge>>((ref) async {
  final coupleGoalsData = await ref.watch(coupleGoalsDataProvider.future);
  return coupleGoalsData.completedChallenges;
});

/// Recent achievements provider
final recentAchievementsProvider =
    FutureProvider<List<Achievement>>((ref) async {
  final coupleGoalsData = await ref.watch(coupleGoalsDataProvider.future);
  final recentAchievements = coupleGoalsData.achievements
      .where((achievement) =>
          DateTime.now().difference(achievement.unlockedAt).inDays <= 7)
      .toList();
  recentAchievements.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
  return recentAchievements;
});

/// Love percentage provider with animation support
final lovePercentageProvider =
    StateNotifierProvider<LovePercentageNotifier, LovePercentageState>((ref) {
  return LovePercentageNotifier(ref.read(coupleGoalsRepositoryProvider));
});

/// Love percentage state for animations
class LovePercentageState {
  final double currentPercentage;
  final double targetPercentage;
  final bool isAnimating;
  final String status;
  final String emoji;

  const LovePercentageState({
    required this.currentPercentage,
    required this.targetPercentage,
    required this.isAnimating,
    required this.status,
    required this.emoji,
  });

  LovePercentageState copyWith({
    double? currentPercentage,
    double? targetPercentage,
    bool? isAnimating,
    String? status,
    String? emoji,
  }) {
    return LovePercentageState(
      currentPercentage: currentPercentage ?? this.currentPercentage,
      targetPercentage: targetPercentage ?? this.targetPercentage,
      isAnimating: isAnimating ?? this.isAnimating,
      status: status ?? this.status,
      emoji: emoji ?? this.emoji,
    );
  }
}

/// Love percentage notifier for smooth animations
class LovePercentageNotifier extends StateNotifier<LovePercentageState> {
  final CoupleGoalsRepository _repository;

  LovePercentageNotifier(this._repository)
      : super(const LovePercentageState(
          currentPercentage: 0.0,
          targetPercentage: 0.0,
          isAnimating: false,
          status: 'Just Started 💝',
          emoji: '💝',
        )) {
    _loadLovePercentage();
  }

  Future<void> _loadLovePercentage() async {
    try {
      final coupleData = await _repository.getCoupleGoalsData('couple_123');

      state = state.copyWith(
        targetPercentage: coupleData.lovePercentage,
        status: coupleData.loveStatus,
        emoji: coupleData.loveEmoji,
      );

      // Animate to target percentage
      await _animateToTarget();
    } catch (error) {
      // Handle error
    }
  }

  Future<void> _animateToTarget() async {
    if (state.currentPercentage == state.targetPercentage) return;

    state = state.copyWith(isAnimating: true);

    const steps = 60; // 60 FPS
    const stepDuration = Duration(milliseconds: 33); // ~30ms per step

    final startPercentage = state.currentPercentage;
    final endPercentage = state.targetPercentage;
    final difference = endPercentage - startPercentage;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(stepDuration);

      if (mounted) {
        final progress = i / steps;
        final easedProgress = _easeOutCubic(progress);
        final currentValue = startPercentage + (difference * easedProgress);

        state = state.copyWith(currentPercentage: currentValue);
      }
    }

    state = state.copyWith(
      currentPercentage: endPercentage,
      isAnimating: false,
    );
  }

  double _easeOutCubic(double t) {
    return 1 - (1 - t) * (1 - t) * (1 - t);
  }

  Future<void> refreshLovePercentage() async {
    await _loadLovePercentage();
  }
}

/// Challenge completion provider
final challengeCompletionProvider =
    StateNotifierProvider<ChallengeCompletionNotifier, AsyncValue<void>>((ref) {
  return ChallengeCompletionNotifier(
    ref.read(coupleGoalsRepositoryProvider),
    ref.read(currentCoupleIdProvider),
  );
});

/// Challenge completion notifier
class ChallengeCompletionNotifier extends StateNotifier<AsyncValue<void>> {
  final CoupleGoalsRepository _repository;
  final String _coupleId;

  ChallengeCompletionNotifier(this._repository, this._coupleId)
      : super(const AsyncValue.data(null));

  Future<void> completeChallenge(String challengeId, {String? note}) async {
    state = const AsyncValue.loading();

    try {
      await _repository.completeChallenge(_coupleId, challengeId, note: note);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Insights provider with filtering
final relationshipInsightsProvider =
    FutureProvider.family<List<RelationshipInsight>, String?>(
        (ref, category) async {
  final coupleGoalsData = await ref.watch(coupleGoalsDataProvider.future);

  if (category == null || category.isEmpty) {
    return coupleGoalsData.insights;
  }

  return coupleGoalsData.insights
      .where(
          (insight) => insight.category.toLowerCase() == category.toLowerCase())
      .toList();
});

/// Level progress provider
final levelProgressProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final coupleGoalsData = await ref.watch(coupleGoalsDataProvider.future);

  final currentLevel = coupleGoalsData.currentLevel;
  final currentPoints = coupleGoalsData.totalPoints;

  // Calculate points needed for next level
  int pointsForNextLevel;
  if (currentLevel == 1) {
    pointsForNextLevel = 50;
  } else if (currentLevel == 2) {
    pointsForNextLevel = 150;
  } else if (currentLevel == 3) {
    pointsForNextLevel = 300;
  } else if (currentLevel == 4) {
    pointsForNextLevel = 500;
  } else if (currentLevel == 5) {
    pointsForNextLevel = 750;
  } else {
    pointsForNextLevel = 750 + ((currentLevel - 5) * 200);
  }

  final pointsNeeded = pointsForNextLevel - currentPoints;
  final progressPercentage = currentPoints / pointsForNextLevel * 100;

  return {
    'currentLevel': currentLevel,
    'currentPoints': currentPoints,
    'pointsForNextLevel': pointsForNextLevel,
    'pointsNeeded': pointsNeeded > 0 ? pointsNeeded : 0,
    'progressPercentage': progressPercentage.clamp(0.0, 100.0),
    'isMaxLevel': currentLevel >= 20, // Arbitrary max level
  };
});

/// Daily progress provider
final dailyProgressProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final coupleGoalsData = await ref.watch(coupleGoalsDataProvider.future);

  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  // Count today's activities
  final todaysChallenges = coupleGoalsData.completedChallenges
      .where((challenge) =>
          challenge.completedAt != null &&
          challenge.completedAt!.isAfter(todayStart))
      .length;

  final todaysQuizzes = 0; // TODO: Get from quiz repository

  return {
    'challengesCompleted': todaysChallenges,
    'quizzesCompleted': todaysQuizzes,
    'totalActivities': todaysChallenges + todaysQuizzes,
    'streakDays': 1, // TODO: Calculate actual streak
  };
});

/// Motivational message provider
final motivationalMessageProvider = FutureProvider<String>((ref) async {
  final coupleGoalsData = await ref.watch(coupleGoalsDataProvider.future);
  final lovePercentage = coupleGoalsData.lovePercentage;

  final messages = [
    'You two are growing stronger every day! 💕',
    'Love is in the details - keep discovering each other! 💖',
    'Your bond is beautiful and unique! ✨',
    'Together, you can achieve anything! 🌟',
    'Every quiz brings you closer! 💗',
    'Your love story is just beginning! 📖💕',
    'Keep nurturing your beautiful relationship! 🌱💖',
    'You make a perfect team! 👫💕',
  ];

  if (lovePercentage >= 90) {
    return 'You two are absolutely perfect together! Keep being amazing! 👑💕';
  } else if (lovePercentage >= 75) {
    return 'Your love is inspiring! You\'re doing everything right! 🌟💖';
  } else if (lovePercentage >= 50) {
    return 'Your relationship is blossoming beautifully! 🌸💗';
  } else {
    messages.shuffle();
    return messages.first;
  }
});
