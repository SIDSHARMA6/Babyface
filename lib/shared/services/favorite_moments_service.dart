import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

/// Favorite moment model
class FavoriteMoment {
  final String id;
  final String title;
  final String description;
  final String? photoPath;
  final String? audioPath;
  final String momentType;
  final DateTime momentDate;
  final List<String> tags;
  final bool isShared;
  final int loveScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  FavoriteMoment({
    required this.id,
    required this.title,
    required this.description,
    this.photoPath,
    this.audioPath,
    required this.momentType,
    required this.momentDate,
    required this.tags,
    required this.isShared,
    required this.loveScore,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photoPath': photoPath,
      'audioPath': audioPath,
      'momentType': momentType,
      'momentDate': momentDate.toIso8601String(),
      'tags': tags,
      'isShared': isShared,
      'loveScore': loveScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FavoriteMoment.fromMap(Map<String, dynamic> map) {
    return FavoriteMoment(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photoPath: map['photoPath'],
      audioPath: map['audioPath'],
      momentType: map['momentType'] ?? '',
      momentDate:
          DateTime.parse(map['momentDate'] ?? DateTime.now().toIso8601String()),
      tags: List<String>.from(map['tags'] ?? []),
      isShared: map['isShared'] ?? false,
      loveScore: map['loveScore'] ?? 0,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  FavoriteMoment copyWith({
    String? id,
    String? title,
    String? description,
    String? photoPath,
    String? audioPath,
    String? momentType,
    DateTime? momentDate,
    List<String>? tags,
    bool? isShared,
    int? loveScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavoriteMoment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      audioPath: audioPath ?? this.audioPath,
      momentType: momentType ?? this.momentType,
      momentDate: momentDate ?? this.momentDate,
      tags: tags ?? this.tags,
      isShared: isShared ?? this.isShared,
      loveScore: loveScore ?? this.loveScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Favorite moments service
class FavoriteMomentsService {
  static final FavoriteMomentsService _instance =
      FavoriteMomentsService._internal();
  factory FavoriteMomentsService() => _instance;
  FavoriteMomentsService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'favorite_moments_box';
  static const String _momentsKey = 'favorite_moments';

  /// Get favorite moments service instance
  static FavoriteMomentsService get instance => _instance;

  /// Add favorite moment
  Future<bool> addFavoriteMoment(FavoriteMoment moment) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final moments = await getAllMoments();
      moments.add(moment);

      await _hiveService.store(
          _boxName, _momentsKey, moments.map((m) => m.toMap()).toList());

      // Sync to Firebase
      await _saveMomentToFirebase(moment);

      developer.log('✅ [FavoriteMomentsService] Moment added: ${moment.id}');
      return true;
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error adding moment: $e');
      return false;
    }
  }

  /// Get all favorite moments
  Future<List<FavoriteMoment>> getAllMoments() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _momentsKey);

      if (data != null) {
        return (data as List)
            .map((item) =>
                FavoriteMoment.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error getting moments: $e');
      return [];
    }
  }

  /// Get moments by type
  Future<List<FavoriteMoment>> getMomentsByType(String momentType) async {
    try {
      final moments = await getAllMoments();
      return moments
          .where((moment) => moment.momentType == momentType)
          .toList();
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error getting moments by type: $e');
      return [];
    }
  }

  /// Get moments by date range
  Future<List<FavoriteMoment>> getMomentsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final moments = await getAllMoments();
      return moments.where((moment) {
        return moment.momentDate.isAfter(startDate) &&
            moment.momentDate.isBefore(endDate);
      }).toList();
    } catch (e) {
      developer.log(
          '❌ [FavoriteMomentsService] Error getting moments by date range: $e');
      return [];
    }
  }

  /// Get recent moments
  Future<List<FavoriteMoment>> getRecentMoments({int limit = 10}) async {
    try {
      final moments = await getAllMoments();
      moments.sort((a, b) => b.momentDate.compareTo(a.momentDate));
      return moments.take(limit).toList();
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error getting recent moments: $e');
      return [];
    }
  }

  /// Get top moments by love score
  Future<List<FavoriteMoment>> getTopMomentsByLoveScore({int limit = 5}) async {
    try {
      final moments = await getAllMoments();
      moments.sort((a, b) => b.loveScore.compareTo(a.loveScore));
      return moments.take(limit).toList();
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error getting top moments: $e');
      return [];
    }
  }

  /// Update moment
  Future<bool> updateMoment(FavoriteMoment moment) async {
    try {
      final moments = await getAllMoments();
      final index = moments.indexWhere((m) => m.id == moment.id);

      if (index != -1) {
        moments[index] = moment;
        await _hiveService.store(
            _boxName, _momentsKey, moments.map((m) => m.toMap()).toList());

        // Sync to Firebase
        await _updateMomentInFirebase(moment);

        developer.log('✅ [FavoriteMomentsService] Moment updated: ${moment.id}');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error updating moment: $e');
      return false;
    }
  }

  /// Delete moment
  Future<bool> deleteMoment(String momentId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final moments = await getAllMoments();
      moments.removeWhere((moment) => moment.id == momentId);

      await _hiveService.store(
          _boxName, _momentsKey, moments.map((m) => m.toMap()).toList());

      // Sync to Firebase
      await _deleteMomentFromFirebase(momentId);

      developer.log('✅ [FavoriteMomentsService] Moment deleted: $momentId');
      return true;
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error deleting moment: $e');
      return false;
    }
  }

  /// Get favorite moments statistics
  Future<Map<String, dynamic>> getMomentsStatistics() async {
    try {
      final moments = await getAllMoments();

      if (moments.isEmpty) {
        return {
          'totalMoments': 0,
          'momentsByType': {},
          'averageLoveScore': 0.0,
          'topMomentType': '',
          'recentMoments': [],
          'monthlyBreakdown': {},
        };
      }

      // Calculate statistics
      final totalMoments = moments.length;
      final averageLoveScore =
          moments.map((m) => m.loveScore).reduce((a, b) => a + b) /
              moments.length;

      // Moments by type
      final momentsByType = <String, int>{};
      for (final moment in moments) {
        momentsByType[moment.momentType] =
            (momentsByType[moment.momentType] ?? 0) + 1;
      }

      // Top moment type
      final topMomentType = momentsByType.entries.isNotEmpty
          ? momentsByType.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : '';

      // Recent moments (last 5)
      final recentMoments = moments
          .take(5)
          .map((moment) => {
                'id': moment.id,
                'title': moment.title,
                'momentType': moment.momentType,
                'momentDate': moment.momentDate.toIso8601String(),
                'loveScore': moment.loveScore,
              })
          .toList();

      // Monthly breakdown
      final monthlyBreakdown = <String, int>{};
      for (final moment in moments) {
        final monthKey =
            '${moment.momentDate.year}-${moment.momentDate.month.toString().padLeft(2, '0')}';
        monthlyBreakdown[monthKey] = (monthlyBreakdown[monthKey] ?? 0) + 1;
      }

      return {
        'totalMoments': totalMoments,
        'momentsByType': momentsByType,
        'averageLoveScore': averageLoveScore,
        'topMomentType': topMomentType,
        'recentMoments': recentMoments,
        'monthlyBreakdown': monthlyBreakdown,
      };
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error getting statistics: $e');
      return {
        'totalMoments': 0,
        'momentsByType': {},
        'averageLoveScore': 0.0,
        'topMomentType': '',
        'recentMoments': [],
        'monthlyBreakdown': {},
      };
    }
  }

  /// Save moment to Firebase
  Future<void> _saveMomentToFirebase(FavoriteMoment moment) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'favorite_moments',
        documentId: moment.id,
        data: moment.toMap(),
      );
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error saving moment to Firebase: $e');
    }
  }

  /// Update moment in Firebase
  Future<void> _updateMomentInFirebase(FavoriteMoment moment) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'favorite_moments',
        documentId: moment.id,
        data: moment.toMap(),
      );
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error updating moment in Firebase: $e');
    }
  }

  /// Delete moment from Firebase
  Future<void> _deleteMomentFromFirebase(String momentId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'favorite_moments',
        documentId: momentId,
      );
    } catch (e) {
      developer.log(
          '❌ [FavoriteMomentsService] Error deleting moment from Firebase: $e');
    }
  }

  /// Clear all moments
  Future<void> clearAllMoments() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _momentsKey);
      developer.log('✅ [FavoriteMomentsService] All moments cleared');
    } catch (e) {
      developer.log('❌ [FavoriteMomentsService] Error clearing moments: $e');
    }
  }
}

/// Moment type extensions
extension MomentTypeExtension on String {
  String get emoji {
    switch (toLowerCase()) {
      case 'anniversary':
        return '🎉';
      case 'date':
        return '💕';
      case 'vacation':
        return '✈️';
      case 'surprise':
        return '🎁';
      case 'achievement':
        return '🏆';
      case 'milestone':
        return '🎯';
      case 'memory':
        return '💝';
      case 'adventure':
        return '🗺️';
      case 'celebration':
        return '🎊';
      case 'romantic':
        return '🌹';
      default:
        return '⭐';
    }
  }

  String get displayName {
    switch (toLowerCase()) {
      case 'anniversary':
        return 'Anniversary';
      case 'date':
        return 'Date';
      case 'vacation':
        return 'Vacation';
      case 'surprise':
        return 'Surprise';
      case 'achievement':
        return 'Achievement';
      case 'milestone':
        return 'Milestone';
      case 'memory':
        return 'Memory';
      case 'adventure':
        return 'Adventure';
      case 'celebration':
        return 'Celebration';
      case 'romantic':
        return 'Romantic';
      default:
        return 'Special Moment';
    }
  }

  String get color {
    switch (toLowerCase()) {
      case 'anniversary':
        return '#FF6B9D';
      case 'date':
        return '#FF8E9B';
      case 'vacation':
        return '#4ECDC4';
      case 'surprise':
        return '#FFD700';
      case 'achievement':
        return '#9B59B6';
      case 'milestone':
        return '#27AE60';
      case 'memory':
        return '#E67E22';
      case 'adventure':
        return '#3498DB';
      case 'celebration':
        return '#E74C3C';
      case 'romantic':
        return '#E91E63';
      default:
        return '#6B9D';
    }
  }
}
