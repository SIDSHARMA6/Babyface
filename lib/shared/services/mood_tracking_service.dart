import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

/// Mood entry model
class MoodEntry {
  final String id;
  final String userId;
  final String partnerId;
  final MoodType mood;
  final int intensity; // 1-10 scale
  final String? note;
  final List<String> emotions; // Additional emotions
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.mood,
    required this.intensity,
    this.note,
    required this.emotions,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'mood': mood.name,
      'intensity': intensity,
      'note': note,
      'emotions': emotions,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      mood: MoodType.values.firstWhere(
        (e) => e.name == map['mood'],
        orElse: () => MoodType.happy,
      ),
      intensity: map['intensity'] ?? 5,
      note: map['note'],
      emotions: List<String>.from(map['emotions'] ?? []),
      photoPath: map['photoPath'],
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  MoodEntry copyWith({
    String? id,
    String? userId,
    String? partnerId,
    MoodType? mood,
    int? intensity,
    String? note,
    List<String>? emotions,
    String? photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      emotions: emotions ?? this.emotions,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Mood types
enum MoodType {
  happy,
  excited,
  content,
  calm,
  neutral,
  tired,
  stressed,
  sad,
  angry,
  anxious,
  loved,
  grateful,
  playful,
  romantic,
  nostalgic,
}

/// Mood tracking service
class MoodTrackingService {
  static final MoodTrackingService _instance = MoodTrackingService._internal();
  factory MoodTrackingService() => _instance;
  MoodTrackingService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'mood_tracking_box';
  static const String _entriesKey = 'mood_entries';

  /// Get mood tracking service instance
  static MoodTrackingService get instance => _instance;

  /// Add mood entry
  Future<bool> addMoodEntry(MoodEntry entry) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final entries = await getAllMoodEntries();
      entries.add(entry);

      await _hiveService.store(
          _boxName, _entriesKey, entries.map((e) => e.toMap()).toList());

      // Sync to Firebase
      await _saveToFirebase(entry);

      developer.log('✅ [MoodTrackingService] Mood entry added: ${entry.mood.name}');
      return true;
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error adding mood entry: $e');
      return false;
    }
  }

  /// Get all mood entries
  Future<List<MoodEntry>> getAllMoodEntries() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _entriesKey);

      if (data != null) {
        return (data as List)
            .map((item) => MoodEntry.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error getting mood entries: $e');
      return [];
    }
  }

  /// Get mood entries for a specific date
  Future<List<MoodEntry>> getMoodEntriesForDate(DateTime date) async {
    try {
      final entries = await getAllMoodEntries();
      return entries.where((entry) {
        final entryDate = DateTime(
            entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
        final targetDate = DateTime(date.year, date.month, date.day);
        return entryDate.isAtSameMomentAs(targetDate);
      }).toList();
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error getting mood entries for date: $e');
      return [];
    }
  }

  /// Get mood entries for date range
  Future<List<MoodEntry>> getMoodEntriesForRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final entries = await getAllMoodEntries();
      return entries.where((entry) {
        return entry.createdAt.isAfter(startDate) &&
            entry.createdAt.isBefore(endDate);
      }).toList();
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error getting mood entries for range: $e');
      return [];
    }
  }

  /// Get mood statistics
  Future<Map<String, dynamic>> getMoodStatistics() async {
    try {
      final entries = await getAllMoodEntries();

      if (entries.isEmpty) {
        return {
          'totalEntries': 0,
          'averageIntensity': 0.0,
          'mostCommonMood': 'neutral',
          'moodDistribution': {},
          'weeklyTrend': [],
          'monthlyTrend': [],
        };
      }

      // Calculate statistics
      final totalEntries = entries.length;
      final averageIntensity =
          entries.map((e) => e.intensity).reduce((a, b) => a + b) /
              totalEntries;

      // Most common mood
      final moodCounts = <MoodType, int>{};
      for (final entry in entries) {
        moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      }
      final mostCommonMood =
          moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      // Mood distribution
      final moodDistribution = <String, int>{};
      for (final entry in moodCounts.entries) {
        moodDistribution[entry.key.name] = entry.value;
      }

      // Weekly trend (last 7 days)
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final weeklyEntries =
          entries.where((e) => e.createdAt.isAfter(weekAgo)).toList();
      final weeklyTrend = <Map<String, dynamic>>[];

      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dayEntries = weeklyEntries.where((e) {
          final entryDate =
              DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
          final targetDate = DateTime(date.year, date.month, date.day);
          return entryDate.isAtSameMomentAs(targetDate);
        }).toList();

        weeklyTrend.add({
          'date': date.toIso8601String(),
          'count': dayEntries.length,
          'averageIntensity': dayEntries.isEmpty
              ? 0.0
              : dayEntries.map((e) => e.intensity).reduce((a, b) => a + b) /
                  dayEntries.length,
        });
      }

      // Monthly trend (last 30 days)
      final monthAgo = now.subtract(const Duration(days: 30));
      final monthlyEntries =
          entries.where((e) => e.createdAt.isAfter(monthAgo)).toList();
      final monthlyTrend = <Map<String, dynamic>>[];

      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final dayEntries = monthlyEntries.where((e) {
          final entryDate =
              DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
          final targetDate = DateTime(date.year, date.month, date.day);
          return entryDate.isAtSameMomentAs(targetDate);
        }).toList();

        monthlyTrend.add({
          'date': date.toIso8601String(),
          'count': dayEntries.length,
          'averageIntensity': dayEntries.isEmpty
              ? 0.0
              : dayEntries.map((e) => e.intensity).reduce((a, b) => a + b) /
                  dayEntries.length,
        });
      }

      return {
        'totalEntries': totalEntries,
        'averageIntensity': averageIntensity,
        'mostCommonMood': mostCommonMood.name,
        'moodDistribution': moodDistribution,
        'weeklyTrend': weeklyTrend,
        'monthlyTrend': monthlyTrend,
      };
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error getting mood statistics: $e');
      return {
        'totalEntries': 0,
        'averageIntensity': 0.0,
        'mostCommonMood': 'neutral',
        'moodDistribution': {},
        'weeklyTrend': [],
        'monthlyTrend': [],
      };
    }
  }

  /// Update mood entry
  Future<bool> updateMoodEntry(MoodEntry entry) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final entries = await getAllMoodEntries();
      final index = entries.indexWhere((e) => e.id == entry.id);

      if (index != -1) {
        entries[index] = entry;
        await _hiveService.store(
            _boxName, _entriesKey, entries.map((e) => e.toMap()).toList());

        // Sync to Firebase
        await _updateInFirebase(entry);

        developer.log('✅ [MoodTrackingService] Mood entry updated: ${entry.id}');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error updating mood entry: $e');
      return false;
    }
  }

  /// Delete mood entry
  Future<bool> deleteMoodEntry(String entryId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final entries = await getAllMoodEntries();
      entries.removeWhere((entry) => entry.id == entryId);

      await _hiveService.store(
          _boxName, _entriesKey, entries.map((e) => e.toMap()).toList());

      // Sync to Firebase
      await _deleteFromFirebase(entryId);

      developer.log('✅ [MoodTrackingService] Mood entry deleted: $entryId');
      return true;
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error deleting mood entry: $e');
      return false;
    }
  }

  /// Save entry to Firebase
  Future<void> _saveToFirebase(MoodEntry entry) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'mood_entries',
        documentId: entry.id,
        data: entry.toMap(),
      );
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error saving to Firebase: $e');
    }
  }

  /// Update entry in Firebase
  Future<void> _updateInFirebase(MoodEntry entry) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'mood_entries',
        documentId: entry.id,
        data: entry.toMap(),
      );
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error updating in Firebase: $e');
    }
  }

  /// Delete entry from Firebase
  Future<void> _deleteFromFirebase(String entryId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'mood_entries',
        documentId: entryId,
      );
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error deleting from Firebase: $e');
    }
  }

  /// Clear all mood entries
  Future<void> clearAllEntries() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _entriesKey);
      developer.log('✅ [MoodTrackingService] All mood entries cleared');
    } catch (e) {
      developer.log('❌ [MoodTrackingService] Error clearing entries: $e');
    }
  }
}

/// Mood type extensions
extension MoodTypeExtension on MoodType {
  String get emoji {
    switch (this) {
      case MoodType.happy:
        return '😊';
      case MoodType.excited:
        return '🤩';
      case MoodType.content:
        return '😌';
      case MoodType.calm:
        return '😌';
      case MoodType.neutral:
        return '😐';
      case MoodType.tired:
        return '😴';
      case MoodType.stressed:
        return '😰';
      case MoodType.sad:
        return '😢';
      case MoodType.angry:
        return '😠';
      case MoodType.anxious:
        return '😟';
      case MoodType.loved:
        return '🥰';
      case MoodType.grateful:
        return '🙏';
      case MoodType.playful:
        return '😜';
      case MoodType.romantic:
        return '😍';
      case MoodType.nostalgic:
        return '🥺';
    }
  }

  String get displayName {
    switch (this) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.excited:
        return 'Excited';
      case MoodType.content:
        return 'Content';
      case MoodType.calm:
        return 'Calm';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.tired:
        return 'Tired';
      case MoodType.stressed:
        return 'Stressed';
      case MoodType.sad:
        return 'Sad';
      case MoodType.angry:
        return 'Angry';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.loved:
        return 'Loved';
      case MoodType.grateful:
        return 'Grateful';
      case MoodType.playful:
        return 'Playful';
      case MoodType.romantic:
        return 'Romantic';
      case MoodType.nostalgic:
        return 'Nostalgic';
    }
  }

  String get color {
    switch (this) {
      case MoodType.happy:
        return '#FFD700';
      case MoodType.excited:
        return '#FF6B35';
      case MoodType.content:
        return '#4ECDC4';
      case MoodType.calm:
        return '#45B7D1';
      case MoodType.neutral:
        return '#95A5A6';
      case MoodType.tired:
        return '#7F8C8D';
      case MoodType.stressed:
        return '#E74C3C';
      case MoodType.sad:
        return '#3498DB';
      case MoodType.angry:
        return '#E74C3C';
      case MoodType.anxious:
        return '#F39C12';
      case MoodType.loved:
        return '#E91E63';
      case MoodType.grateful:
        return '#8E44AD';
      case MoodType.playful:
        return '#F1C40F';
      case MoodType.romantic:
        return '#E91E63';
      case MoodType.nostalgic:
        return '#9B59B6';
    }
  }
}
