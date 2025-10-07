import 'package:cloud_firestore/cloud_firestore.dart';

/// Social challenge model for viral engagement
/// Follows theme standardization and Firebase integration
class SocialChallenge {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final ChallengeType type;
  final int participantCount;
  final int rewardPoints;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final List<String> hashtags;
  final ChallengeStatus status;

  const SocialChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.participantCount,
    required this.rewardPoints,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.metadata,
    required this.hashtags,
    required this.status,
  });

  factory SocialChallenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SocialChallenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      type: ChallengeType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ChallengeType.sharing,
      ),
      participantCount: data['participantCount'] ?? 0,
      rewardPoints: data['rewardPoints'] ?? 0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      hashtags: List<String>.from(data['hashtags'] ?? []),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ChallengeStatus.upcoming,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'participantCount': participantCount,
      'rewardPoints': rewardPoints,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'metadata': metadata,
      'hashtags': hashtags,
      'status': status.name,
    };
  }

  SocialChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    ChallengeType? type,
    int? participantCount,
    int? rewardPoints,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    Map<String, dynamic>? metadata,
    List<String>? hashtags,
    ChallengeStatus? status,
  }) {
    return SocialChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      participantCount: participantCount ?? this.participantCount,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      hashtags: hashtags ?? this.hashtags,
      status: status ?? this.status,
    );
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  Duration get timeRemaining =>
      isOngoing ? endDate.difference(DateTime.now()) : Duration.zero;
  Duration get timeUntilStart =>
      isUpcoming ? startDate.difference(DateTime.now()) : Duration.zero;
}

/// Challenge participation model
class ChallengeParticipation {
  final String id;
  final String challengeId;
  final String userId;
  final DateTime participatedAt;
  final String submissionUrl;
  final String caption;
  final int likesCount;
  final int sharesCount;
  final bool isVerified;
  final int pointsEarned;
  final Map<String, dynamic> metadata;

  const ChallengeParticipation({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.participatedAt,
    required this.submissionUrl,
    required this.caption,
    required this.likesCount,
    required this.sharesCount,
    required this.isVerified,
    required this.pointsEarned,
    required this.metadata,
  });

  factory ChallengeParticipation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChallengeParticipation(
      id: doc.id,
      challengeId: data['challengeId'] ?? '',
      userId: data['userId'] ?? '',
      participatedAt: (data['participatedAt'] as Timestamp).toDate(),
      submissionUrl: data['submissionUrl'] ?? '',
      caption: data['caption'] ?? '',
      likesCount: data['likesCount'] ?? 0,
      sharesCount: data['sharesCount'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      pointsEarned: data['pointsEarned'] ?? 0,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'participatedAt': Timestamp.fromDate(participatedAt),
      'submissionUrl': submissionUrl,
      'caption': caption,
      'likesCount': likesCount,
      'sharesCount': sharesCount,
      'isVerified': isVerified,
      'pointsEarned': pointsEarned,
      'metadata': metadata,
    };
  }
}

/// Challenge types
enum ChallengeType {
  sharing,
  babyPrediction,
  coupleGoals,
  quiz,
  referral,
  creative,
}

/// Challenge status
enum ChallengeStatus {
  upcoming,
  active,
  ended,
  cancelled,
}
