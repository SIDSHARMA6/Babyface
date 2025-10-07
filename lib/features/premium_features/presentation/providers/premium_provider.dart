import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/premium_subscription_entity.dart';
import '../../domain/usecases/subscribe_premium_usecase.dart';
import '../../domain/usecases/get_subscription_usecase.dart';

/// Premium state
class PremiumState {
  final PremiumSubscriptionEntity? subscription;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubscribed;

  const PremiumState({
    this.subscription,
    this.isLoading = false,
    this.errorMessage,
    this.isSubscribed = false,
  });

  PremiumState copyWith({
    PremiumSubscriptionEntity? subscription,
    bool? isLoading,
    String? errorMessage,
    bool? isSubscribed,
  }) {
    return PremiumState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }
}

/// Premium notifier
class PremiumNotifier extends StateNotifier<PremiumState> {
  final SubscribePremiumUsecase _subscribeUsecase;
  final GetSubscriptionUsecase _getSubscriptionUsecase;

  PremiumNotifier(
    this._subscribeUsecase,
    this._getSubscriptionUsecase,
  ) : super(const PremiumState()) {
    loadSubscription();
  }

  /// Subscribe to premium
  Future<void> subscribe(PremiumSubscriptionRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final subscription = await _subscribeUsecase.execute(request);

      state = state.copyWith(
        subscription: subscription,
        isLoading: false,
        isSubscribed: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load current subscription
  Future<void> loadSubscription() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final subscription = await _getSubscriptionUsecase.execute();

      state = state.copyWith(
        subscription: subscription,
        isLoading: false,
        isSubscribed: subscription?.isActive ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // In a real implementation, this would call a cancel subscription use case
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isLoading: false,
        isSubscribed: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Check if user has access to a premium feature
  bool hasAccessToFeature(PremiumFeature feature) {
    final subscription = state.subscription;
    if (subscription == null || !subscription.isActive) {
      return false;
    }
    return subscription.features.contains(feature);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for subscribe premium use case
final subscribePremiumUsecaseProvider =
    Provider<SubscribePremiumUsecase>((ref) {
  throw UnimplementedError('SubscribePremiumUsecase must be provided');
});

/// Provider for get subscription use case
final getSubscriptionUsecaseProvider = Provider<GetSubscriptionUsecase>((ref) {
  throw UnimplementedError('GetSubscriptionUsecase must be provided');
});

/// Provider for premium notifier
final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final subscribeUsecase = ref.watch(subscribePremiumUsecaseProvider);
  final getUsecase = ref.watch(getSubscriptionUsecaseProvider);

  return PremiumNotifier(subscribeUsecase, getUsecase);
});
