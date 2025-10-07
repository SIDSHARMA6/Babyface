import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/analytics_event_entity.dart';
import '../../domain/usecases/get_analytics_usecase.dart';
import '../../domain/usecases/track_event_usecase.dart';

/// Analytics state
class AnalyticsState {
  final int totalUsers;
  final int activeSessions;
  final int totalGenerations;
  final Duration averageSessionDuration;
  final int dailyActiveUsers;
  final double weeklyRetention;
  final int featureUsageCount;
  final double shareRate;
  final int appLaunchTime;
  final int memoryUsage;
  final double frameRate;
  final double crashRate;
  final List<AnalyticsEventEntity> recentEvents;
  final bool isLoading;
  final String? errorMessage;

  const AnalyticsState({
    this.totalUsers = 0,
    this.activeSessions = 0,
    this.totalGenerations = 0,
    this.averageSessionDuration = Duration.zero,
    this.dailyActiveUsers = 0,
    this.weeklyRetention = 0.0,
    this.featureUsageCount = 0,
    this.shareRate = 0.0,
    this.appLaunchTime = 0,
    this.memoryUsage = 0,
    this.frameRate = 0.0,
    this.crashRate = 0.0,
    this.recentEvents = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    int? totalUsers,
    int? activeSessions,
    int? totalGenerations,
    Duration? averageSessionDuration,
    int? dailyActiveUsers,
    double? weeklyRetention,
    int? featureUsageCount,
    double? shareRate,
    int? appLaunchTime,
    int? memoryUsage,
    double? frameRate,
    double? crashRate,
    List<AnalyticsEventEntity>? recentEvents,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AnalyticsState(
      totalUsers: totalUsers ?? this.totalUsers,
      activeSessions: activeSessions ?? this.activeSessions,
      totalGenerations: totalGenerations ?? this.totalGenerations,
      averageSessionDuration:
          averageSessionDuration ?? this.averageSessionDuration,
      dailyActiveUsers: dailyActiveUsers ?? this.dailyActiveUsers,
      weeklyRetention: weeklyRetention ?? this.weeklyRetention,
      featureUsageCount: featureUsageCount ?? this.featureUsageCount,
      shareRate: shareRate ?? this.shareRate,
      appLaunchTime: appLaunchTime ?? this.appLaunchTime,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      frameRate: frameRate ?? this.frameRate,
      crashRate: crashRate ?? this.crashRate,
      recentEvents: recentEvents ?? this.recentEvents,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Analytics notifier
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final GetAnalyticsUsecase _getAnalyticsUsecase;
  final TrackEventUsecase _trackEventUsecase;

  AnalyticsNotifier(
    this._getAnalyticsUsecase,
    this._trackEventUsecase,
  ) : super(const AnalyticsState()) {
    loadAnalytics();
  }

  /// Load analytics data
  Future<void> loadAnalytics() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final analytics = await _getAnalyticsUsecase.execute();

      state = state.copyWith(
        totalUsers: analytics.totalUsers,
        activeSessions: analytics.activeSessions,
        totalGenerations: analytics.totalGenerations,
        averageSessionDuration: analytics.averageSessionDuration,
        dailyActiveUsers: analytics.dailyActiveUsers,
        weeklyRetention: analytics.weeklyRetention,
        featureUsageCount: analytics.featureUsageCount,
        shareRate: analytics.shareRate,
        appLaunchTime: analytics.appLaunchTime,
        memoryUsage: analytics.memoryUsage,
        frameRate: analytics.frameRate,
        crashRate: analytics.crashRate,
        recentEvents: analytics.recentEvents,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Track an event
  Future<void> trackEvent(String eventName, Map<String, dynamic> parameters,
      EventCategory category) async {
    try {
      await _trackEventUsecase.execute(eventName, parameters, category);
    } catch (e) {
      // Log error but don't update state for tracking failures
      // Failed to track event: $e
    }
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName) async {
    await trackEvent(
      'screen_view',
      {'screen_name': screenName},
      EventCategory.screenView,
    );
  }

  /// Track user action
  Future<void> trackUserAction(
      String action, Map<String, dynamic> parameters) async {
    await trackEvent(
      'user_action',
      {'action': action, ...parameters},
      EventCategory.userAction,
    );
  }

  /// Track performance metric
  Future<void> trackPerformance(
      String metricName, double value, String unit) async {
    await trackEvent(
      'performance_metric',
      {'metric_name': metricName, 'value': value, 'unit': unit},
      EventCategory.performance,
    );
  }

  /// Track error
  Future<void> trackError(String error, String? stackTrace) async {
    await trackEvent(
      'error',
      {'error': error, 'stack_trace': stackTrace},
      EventCategory.error,
    );
  }

  /// Track business event
  Future<void> trackBusinessEvent(
      String eventName, Map<String, dynamic> parameters) async {
    await trackEvent(eventName, parameters, EventCategory.business);
  }

  /// Refresh analytics
  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for get analytics use case
final getAnalyticsUsecaseProvider = Provider<GetAnalyticsUsecase>((ref) {
  throw UnimplementedError('GetAnalyticsUsecase must be provided');
});

/// Provider for track event use case
final trackEventUsecaseProvider = Provider<TrackEventUsecase>((ref) {
  throw UnimplementedError('TrackEventUsecase must be provided');
});

/// Provider for analytics notifier
final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final getUsecase = ref.watch(getAnalyticsUsecaseProvider);
  final trackUsecase = ref.watch(trackEventUsecaseProvider);

  return AnalyticsNotifier(getUsecase, trackUsecase);
});
