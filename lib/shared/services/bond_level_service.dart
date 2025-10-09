import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

/// Bond level model
class BondLevel {
  final int level;
  final int currentXP;
  final int xpToNextLevel;
  final String title;
  final String description;
  final String emoji;
  final String color;
  final List<String> unlockedFeatures;
  final DateTime achievedAt;

  BondLevel({
    required this.level,
    required this.currentXP,
    required this.xpToNextLevel,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.unlockedFeatures,
    required this.achievedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'currentXP': currentXP,
      'xpToNextLevel': xpToNextLevel,
      'title': title,
      'description': description,
      'emoji': emoji,
      'color': color,
      'unlockedFeatures': unlockedFeatures,
      'achievedAt': achievedAt.toIso8601String(),
    };
  }

  factory BondLevel.fromMap(Map<String, dynamic> map) {
    return BondLevel(
      level: map['level'] ?? 1,
      currentXP: map['currentXP'] ?? 0,
      xpToNextLevel: map['xpToNextLevel'] ?? 100,
      title: map['title'] ?? 'New Couple',
      description: map['description'] ?? 'Just starting your journey together',
      emoji: map['emoji'] ?? '💕',
      color: map['color'] ?? '#FF6B9D',
      unlockedFeatures: List<String>.from(map['unlockedFeatures'] ?? []),
      achievedAt:
          DateTime.parse(map['achievedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  BondLevel copyWith({
    int? level,
    int? currentXP,
    int? xpToNextLevel,
    String? title,
    String? description,
    String? emoji,
    String? color,
    List<String>? unlockedFeatures,
    DateTime? achievedAt,
  }) {
    return BondLevel(
      level: level ?? this.level,
      currentXP: currentXP ?? this.currentXP,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }
}

/// XP activity model
class XPActivity {
  final String id;
  final String activityType;
  final String description;
  final int xpEarned;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  XPActivity({
    required this.id,
    required this.activityType,
    required this.description,
    required this.xpEarned,
    required this.createdAt,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityType': activityType,
      'description': description,
      'xpEarned': xpEarned,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory XPActivity.fromMap(Map<String, dynamic> map) {
    return XPActivity(
      id: map['id'] ?? '',
      activityType: map['activityType'] ?? '',
      description: map['description'] ?? '',
      xpEarned: map['xpEarned'] ?? 0,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

/// Bond level service
class BondLevelService {
  static final BondLevelService _instance = BondLevelService._internal();
  factory BondLevelService() => _instance;
  BondLevelService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'bond_level_box';
  static const String _levelKey = 'bond_level';
  static const String _activitiesKey = 'xp_activities';

  /// Get bond level service instance
  static BondLevelService get instance => _instance;

  /// Get current bond level
  Future<BondLevel> getCurrentLevel() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _levelKey);

      if (data != null) {
        return BondLevel.fromMap(Map<String, dynamic>.from(data));
      }

      // Return default level if none exists
      return _createDefaultLevel();
    } catch (e) {
      developer.log('❌ [BondLevelService] Error getting current level: $e');
      return _createDefaultLevel();
    }
  }

  /// Add XP for an activity
  Future<bool> addXP(String activityType, String description, int xpAmount,
      {Map<String, dynamic>? metadata}) async {
    try {
      final currentLevel = await getCurrentLevel();
      final newXP = currentLevel.currentXP + xpAmount;

      // Check if level up
      final newLevel = _calculateLevel(newXP);
      final xpToNextLevel = _calculateXPToNextLevel(newLevel);

      final updatedLevel = currentLevel.copyWith(
        level: newLevel,
        currentXP: newXP,
        xpToNextLevel: xpToNextLevel,
        title: _getLevelTitle(newLevel),
        description: _getLevelDescription(newLevel),
        emoji: _getLevelEmoji(newLevel),
        color: _getLevelColor(newLevel),
        unlockedFeatures: _getUnlockedFeatures(newLevel),
        achievedAt: newLevel > currentLevel.level
            ? DateTime.now()
            : currentLevel.achievedAt,
      );

      // Save updated level
      await _hiveService.store(_boxName, _levelKey, updatedLevel.toMap());

      // Add XP activity
      final activity = XPActivity(
        id: 'activity_${DateTime.now().millisecondsSinceEpoch}',
        activityType: activityType,
        description: description,
        xpEarned: xpAmount,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      await _addXPActivity(activity);

      // Sync to Firebase
      await _saveLevelToFirebase(updatedLevel);
      await _saveActivityToFirebase(activity);

      developer.log('✅ [BondLevelService] XP added: $xpAmount for $activityType');
      return true;
    } catch (e) {
      developer.log('❌ [BondLevelService] Error adding XP: $e');
      return false;
    }
  }

  /// Get XP activities
  Future<List<XPActivity>> getXPActivities({int? limit}) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _activitiesKey);

      if (data != null) {
        final activities = (data as List)
            .map((item) => XPActivity.fromMap(Map<String, dynamic>.from(item)))
            .toList();
        activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return limit != null ? activities.take(limit).toList() : activities;
      }

      return [];
    } catch (e) {
      developer.log('❌ [BondLevelService] Error getting XP activities: $e');
      return [];
    }
  }

  /// Get bond level statistics
  Future<Map<String, dynamic>> getBondLevelStatistics() async {
    try {
      final currentLevel = await getCurrentLevel();
      final activities = await getXPActivities();

      if (activities.isEmpty) {
        return {
          'currentLevel': currentLevel.level,
          'currentXP': currentLevel.currentXP,
          'xpToNextLevel': currentLevel.xpToNextLevel,
          'totalXP': currentLevel.currentXP,
          'totalActivities': 0,
          'xpThisWeek': 0,
          'xpThisMonth': 0,
          'levelProgress': 0.0,
          'recentActivities': [],
        };
      }

      // Calculate statistics
      final totalXP = activities.map((a) => a.xpEarned).reduce((a, b) => a + b);
      final totalActivities = activities.length;

      // XP this week
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final xpThisWeek = activities
          .where((a) => a.createdAt.isAfter(weekAgo))
          .map((a) => a.xpEarned)
          .fold(0, (a, b) => a + b);

      // XP this month
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      final xpThisMonth = activities
          .where((a) => a.createdAt.isAfter(monthAgo))
          .map((a) => a.xpEarned)
          .fold(0, (a, b) => a + b);

      // Level progress
      final levelProgress = currentLevel.xpToNextLevel > 0
          ? (currentLevel.currentXP %
                  _getXPRequiredForLevel(currentLevel.level)) /
              _getXPRequiredForLevel(currentLevel.level)
          : 1.0;

      // Recent activities
      final recentActivities = activities
          .take(5)
          .map((activity) => {
                'id': activity.id,
                'activityType': activity.activityType,
                'description': activity.description,
                'xpEarned': activity.xpEarned,
                'createdAt': activity.createdAt.toIso8601String(),
              })
          .toList();

      return {
        'currentLevel': currentLevel.level,
        'currentXP': currentLevel.currentXP,
        'xpToNextLevel': currentLevel.xpToNextLevel,
        'totalXP': totalXP,
        'totalActivities': totalActivities,
        'xpThisWeek': xpThisWeek,
        'xpThisMonth': xpThisMonth,
        'levelProgress': levelProgress,
        'recentActivities': recentActivities,
      };
    } catch (e) {
      developer.log('❌ [BondLevelService] Error getting statistics: $e');
      return {
        'currentLevel': 1,
        'currentXP': 0,
        'xpToNextLevel': 100,
        'totalXP': 0,
        'totalActivities': 0,
        'xpThisWeek': 0,
        'xpThisMonth': 0,
        'levelProgress': 0.0,
        'recentActivities': [],
      };
    }
  }

  /// Add XP activity
  Future<void> _addXPActivity(XPActivity activity) async {
    try {
      final activities = await getXPActivities();
      activities.add(activity);

      await _hiveService.store(
          _boxName, _activitiesKey, activities.map((a) => a.toMap()).toList());
    } catch (e) {
      developer.log('❌ [BondLevelService] Error adding XP activity: $e');
    }
  }

  /// Calculate level from XP
  int _calculateLevel(int xp) {
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    if (xp < 2100) return 6;
    if (xp < 2800) return 7;
    if (xp < 3600) return 8;
    if (xp < 4500) return 9;
    if (xp < 5500) return 10;
    if (xp < 6600) return 11;
    if (xp < 7800) return 12;
    if (xp < 9100) return 13;
    if (xp < 10500) return 14;
    if (xp < 12000) return 15;
    if (xp < 13600) return 16;
    if (xp < 15300) return 17;
    if (xp < 17100) return 18;
    if (xp < 19000) return 19;
    if (xp < 21000) return 20;
    if (xp < 23100) return 21;
    if (xp < 25300) return 22;
    if (xp < 27600) return 23;
    if (xp < 30000) return 24;
    if (xp < 32500) return 25;
    if (xp < 35100) return 26;
    if (xp < 37800) return 27;
    if (xp < 40600) return 28;
    if (xp < 43500) return 29;
    if (xp < 46500) return 30;
    if (xp < 49600) return 31;
    if (xp < 52800) return 32;
    if (xp < 56100) return 33;
    if (xp < 59500) return 34;
    if (xp < 63000) return 35;
    if (xp < 66600) return 36;
    if (xp < 70300) return 37;
    if (xp < 74100) return 38;
    if (xp < 78000) return 39;
    if (xp < 82000) return 40;
    if (xp < 86100) return 41;
    if (xp < 90300) return 42;
    if (xp < 94600) return 43;
    if (xp < 99000) return 44;
    if (xp < 103500) return 45;
    if (xp < 108100) return 46;
    if (xp < 112800) return 47;
    if (xp < 117600) return 48;
    if (xp < 122500) return 49;
    if (xp < 127500) return 50;

    // For levels beyond 50, use a formula
    return 50 + ((xp - 127500) / 5000).floor();
  }

  /// Calculate XP required for a specific level
  int _getXPRequiredForLevel(int level) {
    if (level <= 1) return 100;
    if (level <= 2) return 200;
    if (level <= 3) return 300;
    if (level <= 4) return 400;
    if (level <= 5) return 500;
    if (level <= 10) return 1000;
    if (level <= 20) return 2000;
    if (level <= 30) return 3000;
    if (level <= 40) return 4000;
    if (level <= 50) return 5000;
    return 5000; // For levels beyond 50
  }

  /// Calculate XP to next level
  int _calculateXPToNextLevel(int currentLevel) {
    return _getXPRequiredForLevel(currentLevel + 1) -
        _getXPRequiredForLevel(currentLevel);
  }

  /// Get level title
  String _getLevelTitle(int level) {
    if (level <= 5) return 'New Couple';
    if (level <= 10) return 'Growing Together';
    if (level <= 15) return 'Bonded Hearts';
    if (level <= 20) return 'Love Birds';
    if (level <= 25) return 'Soul Mates';
    if (level <= 30) return 'Perfect Match';
    if (level <= 35) return 'Eternal Love';
    if (level <= 40) return 'Legendary Couple';
    if (level <= 45) return 'Mythical Bond';
    if (level <= 50) return 'Divine Union';
    return 'Transcendent Love';
  }

  /// Get level description
  String _getLevelDescription(int level) {
    if (level <= 5) return 'Just starting your beautiful journey together';
    if (level <= 10) return 'Learning about each other and growing closer';
    if (level <= 15) return 'Your bond is strengthening with each passing day';
    if (level <= 20) return 'You two are truly meant for each other';
    if (level <= 25) return 'Your love story is becoming legendary';
    if (level <= 30) return 'A perfect match in every way possible';
    if (level <= 35) return 'Your love transcends time and space';
    if (level <= 40) return 'A legendary couple that inspires others';
    if (level <= 45) return 'Your bond is mythical and extraordinary';
    if (level <= 50) return 'A divine union blessed by the universe';
    return 'Your love has transcended all boundaries';
  }

  /// Get level emoji
  String _getLevelEmoji(int level) {
    if (level <= 5) return '💕';
    if (level <= 10) return '💖';
    if (level <= 15) return '💗';
    if (level <= 20) return '💝';
    if (level <= 25) return '💘';
    if (level <= 30) return '💞';
    if (level <= 35) return '💟';
    if (level <= 40) return '❤️';
    if (level <= 45) return '🧡';
    if (level <= 50) return '💛';
    return '💚';
  }

  /// Get level color
  String _getLevelColor(int level) {
    if (level <= 5) return '#FF6B9D';
    if (level <= 10) return '#FF8E9B';
    if (level <= 15) return '#FFB1A7';
    if (level <= 20) return '#FFD4B3';
    if (level <= 25) return '#FFF7BF';
    if (level <= 30) return '#E8F5E8';
    if (level <= 35) return '#D1F2D1';
    if (level <= 40) return '#BAEFBA';
    if (level <= 45) return '#A3ECA3';
    if (level <= 50) return '#8CE98C';
    return '#75E675';
  }

  /// Get unlocked features for level
  List<String> _getUnlockedFeatures(int level) {
    final features = <String>[];

    if (level >= 2) features.add('Custom Profile Themes');
    if (level >= 5) features.add('Advanced Mood Tracking');
    if (level >= 8) features.add('Photo Collage Creation');
    if (level >= 10) features.add('Love Note Templates');
    if (level >= 12) features.add('Anniversary Reminders');
    if (level >= 15) features.add('Couple Challenges');
    if (level >= 18) features.add('Memory Timeline');
    if (level >= 20) features.add('Love Language Quiz');
    if (level >= 25) features.add('Relationship Insights');
    if (level >= 30) features.add('Premium Features');
    if (level >= 35) features.add('AI Love Assistant');
    if (level >= 40) features.add('Couple Goals Tracking');
    if (level >= 45) features.add('Relationship Analytics');
    if (level >= 50) features.add('Legacy Mode');

    return features;
  }

  /// Create default level
  BondLevel _createDefaultLevel() {
    return BondLevel(
      level: 1,
      currentXP: 0,
      xpToNextLevel: 100,
      title: 'New Couple',
      description: 'Just starting your beautiful journey together',
      emoji: '💕',
      color: '#FF6B9D',
      unlockedFeatures: [],
      achievedAt: DateTime.now(),
    );
  }

  /// Save level to Firebase
  Future<void> _saveLevelToFirebase(BondLevel level) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'bond_levels',
        documentId: 'current_level',
        data: level.toMap(),
      );
    } catch (e) {
      developer.log('❌ [BondLevelService] Error saving level to Firebase: $e');
    }
  }

  /// Save activity to Firebase
  Future<void> _saveActivityToFirebase(XPActivity activity) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'xp_activities',
        documentId: activity.id,
        data: activity.toMap(),
      );
    } catch (e) {
      developer.log('❌ [BondLevelService] Error saving activity to Firebase: $e');
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _levelKey);
      await _hiveService.delete(_boxName, _activitiesKey);
      developer.log('✅ [BondLevelService] All data cleared');
    } catch (e) {
      developer.log('❌ [BondLevelService] Error clearing data: $e');
    }
  }
}
