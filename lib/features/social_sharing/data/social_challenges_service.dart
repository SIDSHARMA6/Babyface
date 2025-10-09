import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:firebase_analytics/firebase_analytics.dart';
import '../domain/models/social_challenge.dart';

/// Firebase-integrated social challenges service
/// Follows theme standardization and ANR prevention principles
class SocialChallengesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get active social challenges
  static Stream<List<SocialChallenge>> getActiveChallenges() {
    return _firestore
        .collection('social_challenges')
        .where('isActive', isEqualTo: true)
        .where('status', isEqualTo: 'active')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SocialChallenge.fromFirestore(doc))
            .toList());
  }

  /// Get upcoming challenges
  static Stream<List<SocialChallenge>> getUpcomingChallenges() {
    return _firestore
        .collection('social_challenges')
        .where('status', isEqualTo: 'upcoming')
        .orderBy('startDate')
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SocialChallenge.fromFirestore(doc))
            .toList());
  }

  /// Get challenge by ID
  static Future<SocialChallenge?> getChallengeById(String challengeId) async {
    try {
      final doc = await _firestore
          .collection('social_challenges')
          .doc(challengeId)
          .get();

      if (doc.exists) {
        return SocialChallenge.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      developer.log('Error getting challenge: $e');
      return null;
    }
  }

  /// Check if user has already participated in a challenge
  static Future<bool> hasUserParticipated(
      String challengeId, String userId) async {
    try {
      final existingParticipation = await _firestore
          .collection('challenge_participations')
          .where('challengeId', isEqualTo: challengeId)
          .where('userId', isEqualTo: userId)
          .get();

      return existingParticipation.docs.isNotEmpty;
    } catch (e) {
      developer.log('Error checking user participation: $e');
      return false;
    }
  }

  /// Participate in a challenge (simplified version for modal)
  static Future<bool> participateInChallenge({
    required String challengeId,
    required String userId,
    required String caption,
    String? submissionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check if user already participated
      final hasParticipated = await hasUserParticipated(challengeId, userId);
      if (hasParticipated) {
        return false; // Already participated
      }

      // Get challenge details for reward points
      final challenge = await getChallengeById(challengeId);
      if (challenge == null) return false;

      // Create participation record
      final participation = ChallengeParticipation(
        id: '',
        challengeId: challengeId,
        userId: userId,
        participatedAt: DateTime.now(),
        submissionUrl: submissionUrl ?? '',
        caption: caption,
        likesCount: 0,
        sharesCount: 0,
        isVerified: false,
        pointsEarned: challenge.rewardPoints,
        metadata: metadata ?? {},
      );

      await _firestore
          .collection('challenge_participations')
          .add(participation.toFirestore());

      // Update challenge participant count
      await _firestore.collection('social_challenges').doc(challengeId).update({
        'participantCount': FieldValue.increment(1),
      });

      // Award points to user
      await _firestore.collection('users').doc(userId).update({
        'totalPoints': FieldValue.increment(challenge.rewardPoints),
        'challengeParticipations': FieldValue.increment(1),
      });

      // Track analytics
      await _analytics.logEvent(
        name: 'challenge_participated',
        parameters: {
          'challenge_id': challengeId,
          'user_id': userId,
          'points_earned': challenge.rewardPoints,
        },
      );

      return true;
    } catch (e) {
      developer.log('Error participating in challenge: $e');
      return false;
    }
  }

  /// Participate in a challenge (full version with submission)
  static Future<bool> participateInChallengeWithSubmission({
    required String challengeId,
    required String userId,
    required String submissionUrl,
    required String caption,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check if user already participated
      final existingParticipation = await _firestore
          .collection('challenge_participations')
          .where('challengeId', isEqualTo: challengeId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingParticipation.docs.isNotEmpty) {
        return false; // Already participated
      }

      // Create participation record
      final participation = ChallengeParticipation(
        id: '',
        challengeId: challengeId,
        userId: userId,
        participatedAt: DateTime.now(),
        submissionUrl: submissionUrl,
        caption: caption,
        likesCount: 0,
        sharesCount: 0,
        isVerified: false,
        pointsEarned: 0,
        metadata: metadata ?? {},
      );

      await _firestore
          .collection('challenge_participations')
          .add(participation.toFirestore());

      // Update challenge participant count
      await _firestore.collection('social_challenges').doc(challengeId).update({
        'participantCount': FieldValue.increment(1),
      });

      // Track analytics
      await _analytics.logEvent(
        name: 'challenge_participated',
        parameters: {
          'challenge_id': challengeId,
          'user_id': userId,
        },
      );

      return true;
    } catch (e) {
      developer.log('Error participating in challenge: $e');
      return false;
    }
  }

  /// Get user's challenge participations
  static Stream<List<ChallengeParticipation>> getUserParticipations(
      String userId) {
    return _firestore
        .collection('challenge_participations')
        .where('userId', isEqualTo: userId)
        .orderBy('participatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChallengeParticipation.fromFirestore(doc))
            .toList());
  }

  /// Get challenge leaderboard
  static Future<List<Map<String, dynamic>>> getChallengeLeaderboard(
      String challengeId) async {
    try {
      final participations = await _firestore
          .collection('challenge_participations')
          .where('challengeId', isEqualTo: challengeId)
          .orderBy('pointsEarned', descending: true)
          .limit(10)
          .get();

      final leaderboard = <Map<String, dynamic>>[];

      for (final doc in participations.docs) {
        final participation = ChallengeParticipation.fromFirestore(doc);

        // Get user data
        final userDoc = await _firestore
            .collection('users')
            .doc(participation.userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          leaderboard.add({
            'participation': participation,
            'user': userData,
            'rank': leaderboard.length + 1,
          });
        }
      }

      return leaderboard;
    } catch (e) {
      developer.log('Error getting leaderboard: $e');
      return [];
    }
  }

  /// Like a challenge participation
  static Future<void> likeParticipation(String participationId) async {
    try {
      await _firestore
          .collection('challenge_participations')
          .doc(participationId)
          .update({
        'likesCount': FieldValue.increment(1),
      });
    } catch (e) {
      developer.log('Error liking participation: $e');
    }
  }

  /// Share a challenge participation
  static Future<void> shareParticipation(String participationId) async {
    try {
      await _firestore
          .collection('challenge_participations')
          .doc(participationId)
          .update({
        'sharesCount': FieldValue.increment(1),
      });
    } catch (e) {
      developer.log('Error sharing participation: $e');
    }
  }

  /// Create a new challenge (admin function)
  static Future<String?> createChallenge(SocialChallenge challenge) async {
    try {
      final docRef = await _firestore
          .collection('social_challenges')
          .add(challenge.toFirestore());

      return docRef.id;
    } catch (e) {
      developer.log('Error creating challenge: $e');
      return null;
    }
  }

  /// Get trending challenges based on participation
  static Future<List<SocialChallenge>> getTrendingChallenges() async {
    try {
      final snapshot = await _firestore
          .collection('social_challenges')
          .where('isActive', isEqualTo: true)
          .orderBy('participantCount', descending: true)
          .limit(5)
          .get();

      return snapshot.docs
          .map((doc) => SocialChallenge.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error getting trending challenges: $e');
      return [];
    }
  }

  /// Search challenges by hashtag
  static Future<List<SocialChallenge>> searchChallengesByHashtag(
      String hashtag) async {
    try {
      final snapshot = await _firestore
          .collection('social_challenges')
          .where('hashtags', arrayContains: hashtag)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => SocialChallenge.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error searching challenges: $e');
      return [];
    }
  }

  /// Get challenge statistics
  static Future<Map<String, dynamic>> getChallengeStats(
      String challengeId) async {
    try {
      final participations = await _firestore
          .collection('challenge_participations')
          .where('challengeId', isEqualTo: challengeId)
          .get();

      int totalLikes = 0;
      int totalShares = 0;
      int verifiedSubmissions = 0;

      for (final doc in participations.docs) {
        final data = doc.data();
        totalLikes += (data['likesCount'] as int? ?? 0);
        totalShares += (data['sharesCount'] as int? ?? 0);
        if (data['isVerified'] == true) {
          verifiedSubmissions++;
        }
      }

      return {
        'totalParticipants': participations.size,
        'totalLikes': totalLikes,
        'totalShares': totalShares,
        'verifiedSubmissions': verifiedSubmissions,
        'engagementRate': participations.size > 0
            ? (totalLikes + totalShares) / participations.size
            : 0.0,
      };
    } catch (e) {
      developer.log('Error getting challenge stats: $e');
      return {};
    }
  }
}
