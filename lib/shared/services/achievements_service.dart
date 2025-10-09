import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';
import '../models/achievement_model.dart';

/// Service for managing user achievements
class AchievementsService {
  static final AchievementsService _instance = AchievementsService._internal();
  factory AchievementsService() => _instance;
  AchievementsService._internal();

  static AchievementsService get instance => _instance;

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();

  /// Get all achievements for the user
  Future<List<Achievement>> getAllAchievements() async {
    try {
      await _hiveService.ensureBoxOpen('achievements_box');

      if (!_hiveService.isBoxOpen('achievements_box')) {
        developer.log('🔐 [AchievementsService] Box not open, returning empty list');
        return _getDefaultAchievements();
      }

      final achievementsJson =
          _hiveService.retrieve('achievements_box', 'user_achievements');

      if (achievementsJson == null) {
        return _getDefaultAchievements();
      }

      final List<dynamic> achievementsList = achievementsJson;
      return achievementsList
          .map((json) => Achievement.fromJson(json))
          .toList();
    } catch (e) {
      developer.log('Error getting achievements: $e');
      return _getDefaultAchievements();
    }
  }

  /// Get unlocked achievements count
  Future<int> getUnlockedAchievementsCount() async {
    try {
      final achievements = await getAllAchievements();
      return achievements.where((a) => a.isUnlocked).length;
    } catch (e) {
      developer.log('Error getting unlocked achievements count: $e');
      return 0;
    }
  }

  /// Unlock an achievement
  Future<bool> unlockAchievement(String achievementId) async {
    try {
      final achievements = await getAllAchievements();
      final achievementIndex =
          achievements.indexWhere((a) => a.id == achievementId);

      if (achievementIndex == -1) {
        developer.log('Achievement not found: $achievementId');
        return false;
      }

      if (achievements[achievementIndex].isUnlocked) {
        developer.log('Achievement already unlocked: $achievementId');
        return true;
      }

      // Update achievement
      achievements[achievementIndex] = achievements[achievementIndex].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      // Save to Hive
      await _hiveService.ensureBoxOpen('achievements_box');
      if (_hiveService.isBoxOpen('achievements_box')) {
        final achievementsJson = achievements.map((a) => a.toJson()).toList();
        _hiveService.store(
            'achievements_box', 'user_achievements', achievementsJson);
      }

      // Save to Firebase
      await _saveToFirebase(achievements[achievementIndex]);

      developer.log('✅ Achievement unlocked: ${achievements[achievementIndex].title}');
      return true;
    } catch (e) {
      developer.log('Error unlocking achievement: $e');
      return false;
    }
  }

  /// Check and unlock achievements based on user activity
  Future<void> checkAndUnlockAchievements({
    int? quizzesCompleted,
    int? babiesGenerated,
    int? memoriesCreated,
    int? daysTogether,
    int? eventsCreated,
  }) async {
    try {
      final achievements = await getAllAchievements();
      bool hasUpdates = false;

      for (int i = 0; i < achievements.length; i++) {
        final achievement = achievements[i];

        if (achievement.isUnlocked) continue;

        bool shouldUnlock = false;

        switch (achievement.id) {
          case 'first_quiz':
            shouldUnlock = (quizzesCompleted ?? 0) >= 1;
            break;
          case 'quiz_master':
            shouldUnlock = (quizzesCompleted ?? 0) >= 10;
            break;
          case 'first_baby':
            shouldUnlock = (babiesGenerated ?? 0) >= 1;
            break;
          case 'baby_factory':
            shouldUnlock = (babiesGenerated ?? 0) >= 5;
            break;
          case 'first_memory':
            shouldUnlock = (memoriesCreated ?? 0) >= 1;
            break;
          case 'memory_keeper':
            shouldUnlock = (memoriesCreated ?? 0) >= 10;
            break;
          case 'week_together':
            shouldUnlock = (daysTogether ?? 0) >= 7;
            break;
          case 'month_together':
            shouldUnlock = (daysTogether ?? 0) >= 30;
            break;
          case 'year_together':
            shouldUnlock = (daysTogether ?? 0) >= 365;
            break;
          case 'first_event':
            shouldUnlock = (eventsCreated ?? 0) >= 1;
            break;
          case 'event_planner':
            shouldUnlock = (eventsCreated ?? 0) >= 5;
            break;
        }

        if (shouldUnlock) {
          achievements[i] = achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
          hasUpdates = true;
          developer.log('🎉 Achievement unlocked: ${achievement.title}');
        }
      }

      if (hasUpdates) {
        // Save updated achievements
        await _hiveService.ensureBoxOpen('achievements_box');
        if (_hiveService.isBoxOpen('achievements_box')) {
          final achievementsJson = achievements.map((a) => a.toJson()).toList();
          _hiveService.store(
              'achievements_box', 'user_achievements', achievementsJson);
        }
      }
    } catch (e) {
      developer.log('Error checking achievements: $e');
    }
  }

  /// Get default achievements
  List<Achievement> _getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_quiz',
        title: 'First Quiz',
        description: 'Complete your first quiz',
        icon: '🎯',
        isUnlocked: false,
      ),
      Achievement(
        id: 'quiz_master',
        title: 'Quiz Master',
        description: 'Complete 10 quizzes',
        icon: '🏆',
        isUnlocked: false,
      ),
      Achievement(
        id: 'first_baby',
        title: 'First Baby',
        description: 'Generate your first baby',
        icon: '👶',
        isUnlocked: false,
      ),
      Achievement(
        id: 'baby_factory',
        title: 'Baby Factory',
        description: 'Generate 5 babies',
        icon: '🏭',
        isUnlocked: false,
      ),
      Achievement(
        id: 'first_memory',
        title: 'First Memory',
        description: 'Create your first memory',
        icon: '📝',
        isUnlocked: false,
      ),
      Achievement(
        id: 'memory_keeper',
        title: 'Memory Keeper',
        description: 'Create 10 memories',
        icon: '📚',
        isUnlocked: false,
      ),
      Achievement(
        id: 'week_together',
        title: 'Week Together',
        description: 'Spend a week together',
        icon: '📅',
        isUnlocked: false,
      ),
      Achievement(
        id: 'month_together',
        title: 'Month Together',
        description: 'Spend a month together',
        icon: '🗓️',
        isUnlocked: false,
      ),
      Achievement(
        id: 'year_together',
        title: 'Year Together',
        description: 'Spend a year together',
        icon: '🎂',
        isUnlocked: false,
      ),
      Achievement(
        id: 'first_event',
        title: 'First Event',
        description: 'Create your first anniversary event',
        icon: '🎉',
        isUnlocked: false,
      ),
      Achievement(
        id: 'event_planner',
        title: 'Event Planner',
        description: 'Create 5 anniversary events',
        icon: '📋',
        isUnlocked: false,
      ),
    ];
  }

  /// Save achievement to Firebase
  Future<void> _saveToFirebase(Achievement achievement) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'achievements',
        documentId: achievement.id,
        data: achievement.toJson(),
      );
    } catch (e) {
      developer.log('Error saving achievement to Firebase: $e');
    }
  }

  /// Clear all achievements (for testing)
  Future<void> clearAllAchievements() async {
    try {
      await _hiveService.ensureBoxOpen('achievements_box');
      if (_hiveService.isBoxOpen('achievements_box')) {
        _hiveService.store('achievements_box', 'user_achievements', []);
      }
    } catch (e) {
      developer.log('Error clearing achievements: $e');
    }
  }
}
