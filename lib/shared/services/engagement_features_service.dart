import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'hive_service.dart';
import 'firebase_service.dart';

/// Engagement feature model
class EngagementFeature {
  final String id;
  final String name;
  final String description;
  final String category;
  final EngagementType type;
  final int priority;
  final bool isEnabled;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime updatedAt;

  EngagementFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.type,
    required this.priority,
    required this.isEnabled,
    this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'type': type.name,
      'priority': priority,
      'isEnabled': isEnabled,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EngagementFeature.fromMap(Map<String, dynamic> map) {
    return EngagementFeature(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      type: EngagementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EngagementType.general,
      ),
      priority: map['priority'] ?? 0,
      isEnabled: map['isEnabled'] ?? false,
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  EngagementFeature copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    EngagementType? type,
    int? priority,
    bool? isEnabled,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EngagementFeature(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isEnabled: isEnabled ?? this.isEnabled,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Engagement type enum
enum EngagementType {
  daily,
  weekly,
  monthly,
  special,
  seasonal,
  general,
}

/// Engagement suggestion model
class EngagementSuggestion {
  final String id;
  final String title;
  final String description;
  final String category;
  final EngagementType type;
  final int difficulty;
  final int estimatedTime;
  final List<String> tags;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  EngagementSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.difficulty,
    required this.estimatedTime,
    required this.tags,
    this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type.name,
      'difficulty': difficulty,
      'estimatedTime': estimatedTime,
      'tags': tags,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EngagementSuggestion.fromMap(Map<String, dynamic> map) {
    return EngagementSuggestion(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      type: EngagementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EngagementType.general,
      ),
      difficulty: map['difficulty'] ?? 1,
      estimatedTime: map['estimatedTime'] ?? 30,
      tags: List<String>.from(map['tags'] ?? []),
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Engagement features service
class EngagementFeaturesService {
  static final EngagementFeaturesService _instance =
      EngagementFeaturesService._internal();
  factory EngagementFeaturesService() => _instance;
  EngagementFeaturesService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'engagement_features_box';
  static const String _featuresKey = 'engagement_features';
  static const String _suggestionsKey = 'engagement_suggestions';

  final List<VoidCallback> _listeners = [];
  Timer? _syncTimer;

  /// Get engagement features service instance
  static EngagementFeaturesService get instance => _instance;

  /// Initialize service
  void initialize() {
    _loadDefaultFeatures();
    _loadDefaultSuggestions();
    _startSyncTimer();
  }

  /// Add listener
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        developer.log('❌ [EngagementFeaturesService] Error notifying listener: $e');
      }
    }
  }

  /// Load default features
  void _loadDefaultFeatures() {
    final defaultFeatures = [
      EngagementFeature(
        id: 'daily_check_in',
        name: 'Daily Check-in',
        description: 'Share your daily mood and thoughts',
        category: 'Communication',
        type: EngagementType.daily,
        priority: 10,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EngagementFeature(
        id: 'love_note_reminder',
        name: 'Love Note Reminder',
        description: 'Get reminded to send love notes',
        category: 'Communication',
        type: EngagementType.daily,
        priority: 9,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EngagementFeature(
        id: 'photo_sharing',
        name: 'Photo Sharing',
        description: 'Share photos and create memories',
        category: 'Memories',
        type: EngagementType.daily,
        priority: 8,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EngagementFeature(
        id: 'weekly_recap',
        name: 'Weekly Recap',
        description: 'Review your week together',
        category: 'Reflection',
        type: EngagementType.weekly,
        priority: 7,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EngagementFeature(
        id: 'anniversary_tracker',
        name: 'Anniversary Tracker',
        description: 'Track special dates and anniversaries',
        category: 'Memories',
        type: EngagementType.monthly,
        priority: 6,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EngagementFeature(
        id: 'mood_insights',
        name: 'Mood Insights',
        description: 'Get AI-powered mood analysis',
        category: 'Analytics',
        type: EngagementType.weekly,
        priority: 5,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EngagementFeature(
        id: 'gesture_reactions',
        name: 'Gesture Reactions',
        description: 'Express love through drawing',
        category: 'Fun',
        type: EngagementType.daily,
        priority: 4,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EngagementFeature(
        id: 'shared_journal',
        name: 'Shared Journal',
        description: 'Write together in real-time',
        category: 'Communication',
        type: EngagementType.daily,
        priority: 3,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EngagementFeature(
        id: 'zodiac_compatibility',
        name: 'Zodiac Compatibility',
        description: 'Discover astrological insights',
        category: 'Fun',
        type: EngagementType.monthly,
        priority: 2,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EngagementFeature(
        id: 'bond_level_tracking',
        name: 'Bond Level Tracking',
        description: 'Track relationship progress',
        category: 'Progress',
        type: EngagementType.daily,
        priority: 1,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _saveFeatures(defaultFeatures);
  }

  /// Load default suggestions
  void _loadDefaultSuggestions() {
    final defaultSuggestions = [
      EngagementSuggestion(
        id: 'morning_affirmation',
        title: 'Morning Affirmation',
        description:
            'Start your day with a positive affirmation for your partner',
        category: 'Communication',
        type: EngagementType.daily,
        difficulty: 1,
        estimatedTime: 5,
        tags: ['morning', 'affirmation', 'positive'],
        createdAt: DateTime.now(),
      ),
      EngagementSuggestion(
        id: 'gratitude_sharing',
        title: 'Gratitude Sharing',
        description:
            'Share three things you\'re grateful for about your partner',
        category: 'Communication',
        type: EngagementType.daily,
        difficulty: 2,
        estimatedTime: 10,
        tags: ['gratitude', 'appreciation', 'positive'],
        createdAt: DateTime.now(),
      ),
      EngagementSuggestion(
        id: 'photo_memory',
        title: 'Photo Memory',
        description: 'Share a photo from a special moment and tell the story',
        category: 'Memories',
        type: EngagementType.daily,
        difficulty: 2,
        estimatedTime: 15,
        tags: ['photo', 'memory', 'story'],
        createdAt: DateTime.now(),
      ),
      EngagementSuggestion(
        id: 'love_language_quiz',
        title: 'Love Language Quiz',
        description: 'Take a love language quiz together and discuss results',
        category: 'Communication',
        type: EngagementType.weekly,
        difficulty: 3,
        estimatedTime: 30,
        tags: ['quiz', 'love language', 'communication'],
        createdAt: DateTime.now(),
      ),
      EngagementSuggestion(
        id: 'future_planning',
        title: 'Future Planning',
        description: 'Plan a future date or activity together',
        category: 'Planning',
        type: EngagementType.weekly,
        difficulty: 3,
        estimatedTime: 45,
        tags: ['planning', 'future', 'date'],
        createdAt: DateTime.now(),
      ),
      EngagementSuggestion(
        id: 'bucket_list',
        title: 'Bucket List',
        description: 'Add items to your couple bucket list',
        category: 'Planning',
        type: EngagementType.monthly,
        difficulty: 2,
        estimatedTime: 20,
        tags: ['bucket list', 'goals', 'dreams'],
        createdAt: DateTime.now(),
      ),
      EngagementSuggestion(
        id: 'mood_reflection',
        title: 'Mood Reflection',
        description: 'Reflect on your mood patterns and discuss together',
        category: 'Reflection',
        type: EngagementType.weekly,
        difficulty: 4,
        estimatedTime: 25,
        tags: ['mood', 'reflection', 'analysis'],
        createdAt: DateTime.now(),
      ),
      EngagementSuggestion(
        id: 'gesture_drawing',
        title: 'Gesture Drawing',
        description: 'Draw love gestures and send to your partner',
        category: 'Fun',
        type: EngagementType.daily,
        difficulty: 1,
        estimatedTime: 10,
        tags: ['drawing', 'gesture', 'fun'],
        createdAt: DateTime.now(),
      ),
      EngagementSuggestion(
        id: 'theme_customization',
        title: 'Theme Customization',
        description: 'Customize your app theme together',
        category: 'Customization',
        type: EngagementType.monthly,
        difficulty: 2,
        estimatedTime: 15,
        tags: ['theme', 'customization', 'personalization'],
        createdAt: DateTime.now(),
      ),
      EngagementSuggestion(
        id: 'achievement_celebration',
        title: 'Achievement Celebration',
        description: 'Celebrate your relationship achievements',
        category: 'Celebration',
        type: EngagementType.special,
        difficulty: 1,
        estimatedTime: 20,
        tags: ['achievement', 'celebration', 'milestone'],
        createdAt: DateTime.now(),
      ),
    ];

    _saveSuggestions(defaultSuggestions);
  }

  /// Get all features
  Future<List<EngagementFeature>> getAllFeatures() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _featuresKey);

      if (data != null) {
        return (data as List)
            .map((item) =>
                EngagementFeature.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [EngagementFeaturesService] Error getting features: $e');
      return [];
    }
  }

  /// Get enabled features
  Future<List<EngagementFeature>> getEnabledFeatures() async {
    try {
      final features = await getAllFeatures();
      return features.where((feature) => feature.isEnabled).toList();
    } catch (e) {
      developer.log('❌ [EngagementFeaturesService] Error getting enabled features: $e');
      return [];
    }
  }

  /// Get features by category
  Future<List<EngagementFeature>> getFeaturesByCategory(String category) async {
    try {
      final features = await getAllFeatures();
      return features.where((feature) => feature.category == category).toList();
    } catch (e) {
      developer.log(
          '❌ [EngagementFeaturesService] Error getting features by category: $e');
      return [];
    }
  }

  /// Get features by type
  Future<List<EngagementFeature>> getFeaturesByType(EngagementType type) async {
    try {
      final features = await getAllFeatures();
      return features.where((feature) => feature.type == type).toList();
    } catch (e) {
      developer.log('❌ [EngagementFeaturesService] Error getting features by type: $e');
      return [];
    }
  }

  /// Update feature
  Future<bool> updateFeature(EngagementFeature feature) async {
    try {
      final features = await getAllFeatures();
      final index = features.indexWhere((f) => f.id == feature.id);

      if (index != -1) {
        features[index] = feature;
        await _saveFeatures(features);

        // Sync to Firebase
        await _saveFeatureToFirebase(feature);

        // Notify listeners
        _notifyListeners();

        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [EngagementFeaturesService] Error updating feature: $e');
      return false;
    }
  }

  /// Enable/disable feature
  Future<bool> toggleFeature(String featureId) async {
    try {
      final features = await getAllFeatures();
      final index = features.indexWhere((f) => f.id == featureId);

      if (index != -1) {
        features[index] = features[index].copyWith(
          isEnabled: !features[index].isEnabled,
          updatedAt: DateTime.now(),
        );

        await _saveFeatures(features);

        // Sync to Firebase
        await _saveFeatureToFirebase(features[index]);

        // Notify listeners
        _notifyListeners();

        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [EngagementFeaturesService] Error toggling feature: $e');
      return false;
    }
  }

  /// Get all suggestions
  Future<List<EngagementSuggestion>> getAllSuggestions() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _suggestionsKey);

      if (data != null) {
        return (data as List)
            .map((item) =>
                EngagementSuggestion.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [EngagementFeaturesService] Error getting suggestions: $e');
      return [];
    }
  }

  /// Get suggestions by category
  Future<List<EngagementSuggestion>> getSuggestionsByCategory(
      String category) async {
    try {
      final suggestions = await getAllSuggestions();
      return suggestions
          .where((suggestion) => suggestion.category == category)
          .toList();
    } catch (e) {
      developer.log(
          '❌ [EngagementFeaturesService] Error getting suggestions by category: $e');
      return [];
    }
  }

  /// Get suggestions by type
  Future<List<EngagementSuggestion>> getSuggestionsByType(
      EngagementType type) async {
    try {
      final suggestions = await getAllSuggestions();
      return suggestions
          .where((suggestion) => suggestion.type == type)
          .toList();
    } catch (e) {
      developer.log(
          '❌ [EngagementFeaturesService] Error getting suggestions by type: $e');
      return [];
    }
  }

  /// Get random suggestion
  Future<EngagementSuggestion?> getRandomSuggestion() async {
    try {
      final suggestions = await getAllSuggestions();
      if (suggestions.isNotEmpty) {
        final random =
            DateTime.now().millisecondsSinceEpoch % suggestions.length;
        return suggestions[random];
      }
      return null;
    } catch (e) {
      developer.log(
          '❌ [EngagementFeaturesService] Error getting random suggestion: $e');
      return null;
    }
  }

  /// Get personalized suggestions
  Future<List<EngagementSuggestion>> getPersonalizedSuggestions({
    String? category,
    EngagementType? type,
    int? maxDifficulty,
    int? maxTime,
  }) async {
    try {
      final suggestions = await getAllSuggestions();
      var filtered = suggestions;

      if (category != null) {
        filtered = filtered.where((s) => s.category == category).toList();
      }

      if (type != null) {
        filtered = filtered.where((s) => s.type == type).toList();
      }

      if (maxDifficulty != null) {
        filtered =
            filtered.where((s) => s.difficulty <= maxDifficulty).toList();
      }

      if (maxTime != null) {
        filtered = filtered.where((s) => s.estimatedTime <= maxTime).toList();
      }

      return filtered;
    } catch (e) {
      developer.log(
          '❌ [EngagementFeaturesService] Error getting personalized suggestions: $e');
      return [];
    }
  }

  /// Save features
  Future<void> _saveFeatures(List<EngagementFeature> features) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.store(
          _boxName, _featuresKey, features.map((f) => f.toMap()).toList());
    } catch (e) {
      developer.log('❌ [EngagementFeaturesService] Error saving features: $e');
    }
  }

  /// Save suggestions
  Future<void> _saveSuggestions(List<EngagementSuggestion> suggestions) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.store(_boxName, _suggestionsKey,
          suggestions.map((s) => s.toMap()).toList());
    } catch (e) {
      developer.log('❌ [EngagementFeaturesService] Error saving suggestions: $e');
    }
  }

  /// Start sync timer
  void _startSyncTimer() {
    _syncTimer = Timer.periodic(Duration(minutes: 10), (timer) {
      _syncFeatures();
    });
  }

  /// Sync features with Firebase
  Future<void> _syncFeatures() async {
    try {
      final features = await getAllFeatures();
      for (final feature in features) {
        await _saveFeatureToFirebase(feature);
      }
    } catch (e) {
      developer.log('❌ [EngagementFeaturesService] Error syncing features: $e');
    }
  }

  /// Save feature to Firebase
  Future<void> _saveFeatureToFirebase(EngagementFeature feature) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'engagement_features',
        documentId: feature.id,
        data: feature.toMap(),
      );
    } catch (e) {
      developer.log(
          '❌ [EngagementFeaturesService] Error saving feature to Firebase: $e');
    }
  }

  /// Get engagement statistics
  Future<Map<String, dynamic>> getEngagementStatistics() async {
    try {
      final features = await getAllFeatures();
      final suggestions = await getAllSuggestions();

      final enabledFeatures = features.where((f) => f.isEnabled).length;
      final totalFeatures = features.length;
      final totalSuggestions = suggestions.length;

      final categories = features.map((f) => f.category).toSet().toList();
      final types = features.map((f) => f.type).toSet().toList();

      return {
        'enabledFeatures': enabledFeatures,
        'totalFeatures': totalFeatures,
        'totalSuggestions': totalSuggestions,
        'categories': categories,
        'types': types,
        'engagementRate': enabledFeatures / totalFeatures,
      };
    } catch (e) {
      developer.log(
          '❌ [EngagementFeaturesService] Error getting engagement statistics: $e');
      return {};
    }
  }

  /// Dispose service
  void dispose() {
    _syncTimer?.cancel();
    _listeners.clear();
  }
}
