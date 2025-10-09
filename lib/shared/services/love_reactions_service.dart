import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';
import 'gesture_recognition_service.dart';

/// Love reactions service
class LoveReactionsService {
  static final LoveReactionsService _instance =
      LoveReactionsService._internal();
  factory LoveReactionsService() => _instance;
  LoveReactionsService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  final GestureRecognitionService _gestureService = GestureRecognitionService();
  static const String _boxName = 'love_reactions_box';
  static const String _reactionsKey = 'love_reactions';

  /// Get love reactions service instance
  static LoveReactionsService get instance => _instance;

  /// Add love reaction
  Future<bool> addLoveReaction(LoveReaction reaction) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final reactions = await getAllReactions();
      reactions.add(reaction);

      await _hiveService.store(
          _boxName, _reactionsKey, reactions.map((r) => r.toMap()).toList());

      // Sync to Firebase
      await _saveReactionToFirebase(reaction);

      developer.log('✅ [LoveReactionsService] Reaction added: ${reaction.id}');
      return true;
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error adding reaction: $e');
      return false;
    }
  }

  /// Create reaction from gesture points
  Future<LoveReaction> createReactionFromGesture(
    List<GesturePoint> gesturePoints,
    String userId,
    String partnerId, {
    String? message,
  }) async {
    try {
      // Recognize gesture
      final reactionType = _gestureService.recognizeGesture(gesturePoints);

      // Create reaction
      final reaction = LoveReaction(
        id: 'reaction_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        partnerId: partnerId,
        type: reactionType,
        gesturePoints: gesturePoints,
        message: message,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return reaction;
    } catch (e) {
      developer.log(
          '❌ [LoveReactionsService] Error creating reaction from gesture: $e');
      return LoveReaction(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        partnerId: partnerId,
        type: ReactionType.custom,
        gesturePoints: gesturePoints,
        message: message,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Get all reactions
  Future<List<LoveReaction>> getAllReactions() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _reactionsKey);

      if (data != null) {
        return (data as List)
            .map(
                (item) => LoveReaction.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error getting reactions: $e');
      return [];
    }
  }

  /// Get reactions by user
  Future<List<LoveReaction>> getReactionsByUser(String userId) async {
    try {
      final reactions = await getAllReactions();
      return reactions.where((reaction) => reaction.userId == userId).toList();
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error getting reactions by user: $e');
      return [];
    }
  }

  /// Get reactions by partner
  Future<List<LoveReaction>> getReactionsByPartner(String partnerId) async {
    try {
      final reactions = await getAllReactions();
      return reactions
          .where((reaction) => reaction.partnerId == partnerId)
          .toList();
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error getting reactions by partner: $e');
      return [];
    }
  }

  /// Get reactions by type
  Future<List<LoveReaction>> getReactionsByType(ReactionType type) async {
    try {
      final reactions = await getAllReactions();
      return reactions.where((reaction) => reaction.type == type).toList();
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error getting reactions by type: $e');
      return [];
    }
  }

  /// Get recent reactions
  Future<List<LoveReaction>> getRecentReactions({int limit = 10}) async {
    try {
      final reactions = await getAllReactions();
      reactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reactions.take(limit).toList();
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error getting recent reactions: $e');
      return [];
    }
  }

  /// Get reactions by date range
  Future<List<LoveReaction>> getReactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final reactions = await getAllReactions();
      return reactions.where((reaction) {
        return reaction.createdAt.isAfter(startDate) &&
            reaction.createdAt.isBefore(endDate);
      }).toList();
    } catch (e) {
      developer.log(
          '❌ [LoveReactionsService] Error getting reactions by date range: $e');
      return [];
    }
  }

  /// Update reaction
  Future<bool> updateReaction(LoveReaction reaction) async {
    try {
      final reactions = await getAllReactions();
      final index = reactions.indexWhere((r) => r.id == reaction.id);

      if (index != -1) {
        reactions[index] = reaction;
        await _hiveService.store(
            _boxName, _reactionsKey, reactions.map((r) => r.toMap()).toList());

        // Sync to Firebase
        await _updateReactionInFirebase(reaction);

        developer.log('✅ [LoveReactionsService] Reaction updated: ${reaction.id}');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error updating reaction: $e');
      return false;
    }
  }

  /// Delete reaction
  Future<bool> deleteReaction(String reactionId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final reactions = await getAllReactions();
      reactions.removeWhere((reaction) => reaction.id == reactionId);

      await _hiveService.store(
          _boxName, _reactionsKey, reactions.map((r) => r.toMap()).toList());

      // Sync to Firebase
      await _deleteReactionFromFirebase(reactionId);

      developer.log('✅ [LoveReactionsService] Reaction deleted: $reactionId');
      return true;
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error deleting reaction: $e');
      return false;
    }
  }

  /// Get reaction statistics
  Future<Map<String, dynamic>> getReactionStatistics() async {
    try {
      final reactions = await getAllReactions();

      if (reactions.isEmpty) {
        return {
          'totalReactions': 0,
          'reactionsByType': {},
          'recentReactions': [],
          'dailyBreakdown': {},
        };
      }

      // Calculate statistics
      final totalReactions = reactions.length;

      // Reactions by type
      final reactionsByType = <String, int>{};
      for (final reaction in reactions) {
        final typeName = reaction.type.name;
        reactionsByType[typeName] = (reactionsByType[typeName] ?? 0) + 1;
      }

      // Recent reactions (last 5)
      final recentReactions = reactions
          .take(5)
          .map((reaction) => {
                'id': reaction.id,
                'type': reaction.type.name,
                'createdAt': reaction.createdAt.toIso8601String(),
                'message': reaction.message,
              })
          .toList();

      // Daily breakdown
      final dailyBreakdown = <String, int>{};
      for (final reaction in reactions) {
        final dayKey =
            '${reaction.createdAt.year}-${reaction.createdAt.month.toString().padLeft(2, '0')}-${reaction.createdAt.day.toString().padLeft(2, '0')}';
        dailyBreakdown[dayKey] = (dailyBreakdown[dayKey] ?? 0) + 1;
      }

      return {
        'totalReactions': totalReactions,
        'reactionsByType': reactionsByType,
        'recentReactions': recentReactions,
        'dailyBreakdown': dailyBreakdown,
      };
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error getting statistics: $e');
      return {
        'totalReactions': 0,
        'reactionsByType': {},
        'recentReactions': [],
        'dailyBreakdown': {},
      };
    }
  }

  /// Save reaction to Firebase
  Future<void> _saveReactionToFirebase(LoveReaction reaction) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'love_reactions',
        documentId: reaction.id,
        data: reaction.toMap(),
      );
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error saving reaction to Firebase: $e');
    }
  }

  /// Update reaction in Firebase
  Future<void> _updateReactionInFirebase(LoveReaction reaction) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'love_reactions',
        documentId: reaction.id,
        data: reaction.toMap(),
      );
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error updating reaction in Firebase: $e');
    }
  }

  /// Delete reaction from Firebase
  Future<void> _deleteReactionFromFirebase(String reactionId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'love_reactions',
        documentId: reactionId,
      );
    } catch (e) {
      developer.log(
          '❌ [LoveReactionsService] Error deleting reaction from Firebase: $e');
    }
  }

  /// Clear all reactions
  Future<void> clearAllReactions() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _reactionsKey);
      developer.log('✅ [LoveReactionsService] All reactions cleared');
    } catch (e) {
      developer.log('❌ [LoveReactionsService] Error clearing reactions: $e');
    }
  }
}
