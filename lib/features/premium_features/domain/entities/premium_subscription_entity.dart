import 'package:equatable/equatable.dart';

/// Premium subscription entity
/// Follows master plan clean architecture
class PremiumSubscriptionEntity extends Equatable {
  final String id;
  final String userId;
  final SubscriptionType type;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String currency;
  final List<PremiumFeature> features;
  final DateTime? trialEndDate;
  final bool isTrialActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PremiumSubscriptionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.currency,
    required this.features,
    this.trialEndDate,
    this.isTrialActive = false,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        status,
        startDate,
        endDate,
        price,
        currency,
        features,
        trialEndDate,
        isTrialActive,
        createdAt,
        updatedAt,
      ];

  PremiumSubscriptionEntity copyWith({
    String? id,
    String? userId,
    SubscriptionType? type,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? price,
    String? currency,
    List<PremiumFeature>? features,
    DateTime? trialEndDate,
    bool? isTrialActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PremiumSubscriptionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      features: features ?? this.features,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if subscription is active
  bool get isActive {
    return status == SubscriptionStatus.active &&
        endDate.isAfter(DateTime.now());
  }

  /// Check if subscription is in trial
  bool get isInTrial {
    return isTrialActive &&
        trialEndDate != null &&
        trialEndDate!.isAfter(DateTime.now());
  }

  /// Get days remaining
  int get daysRemaining {
    final now = DateTime.now();
    if (isInTrial && trialEndDate != null) {
      return trialEndDate!.difference(now).inDays;
    } else if (isActive) {
      return endDate.difference(now).inDays;
    }
    return 0;
  }
}

/// Subscription type enum
enum SubscriptionType {
  monthly,
  yearly,
  lifetime,
}

/// Subscription status enum
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending,
  trial,
}

/// Premium feature enum
enum PremiumFeature {
  hdImages,
  watermarkRemoval,
  unlimitedGenerations,
  priorityProcessing,
  advancedFilters,
  batchProcessing,
  cloudStorage,
  premiumSupport,
  earlyAccess,
  exclusiveContent,
}

/// Premium subscription request
class PremiumSubscriptionRequest extends Equatable {
  final SubscriptionType type;
  final String? promoCode;
  final bool startTrial;

  const PremiumSubscriptionRequest({
    required this.type,
    this.promoCode,
    this.startTrial = false,
  });

  @override
  List<Object?> get props => [type, promoCode, startTrial];
}
