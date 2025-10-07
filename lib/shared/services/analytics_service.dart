import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../features/analytics/domain/entities/analytics_event_entity.dart';

/// Analytics service for user tracking
/// Follows master plan analytics standards
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late FirebaseAnalytics _firebaseAnalytics;
  late FirebaseCrashlytics _crashlytics;
  bool _isInitialized = false;

  /// Initialize analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _firebaseAnalytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable analytics collection
      await _firebaseAnalytics.setAnalyticsCollectionEnabled(true);

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize analytics: $e');
      }
    }
  }

  /// Track screen view
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
        parameters: parameters,
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track user action
  Future<void> trackUserAction({
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'user_action',
        parameters: {
          'action': action,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track business event
  Future<void> trackBusinessEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track performance metric
  Future<void> trackPerformanceMetric({
    required String metricName,
    required double value,
    String? unit,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'performance_metric',
        parameters: {
          'metric_name': metricName,
          'value': value,
          if (unit != null) 'unit': unit,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track error
  Future<void> trackError({
    required String error,
    String? stackTrace,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'error_occurred',
        parameters: {
          'error': error,
          if (stackTrace != null) 'stack_trace': stackTrace,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track engagement event
  Future<void> trackEngagementEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'engagement_event',
        parameters: {
          'event_name': eventName,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track baby generation event
  Future<void> trackBabyGeneration({
    required String generationType,
    required int processingTime,
    required bool success,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'baby_generation',
        parameters: {
          'generation_type': generationType,
          'processing_time': processingTime,
          'success': success,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track quiz completion
  Future<void> trackQuizCompletion({
    required String quizType,
    required int score,
    required int totalQuestions,
    required Duration completionTime,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'quiz_completion',
        parameters: {
          'quiz_type': quizType,
          'score': score,
          'total_questions': totalQuestions,
          'completion_time': completionTime.inSeconds,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track premium subscription
  Future<void> trackPremiumSubscription({
    required String subscriptionType,
    required double price,
    required String currency,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'premium_subscription',
        parameters: {
          'subscription_type': subscriptionType,
          'price': price,
          'currency': currency,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track social sharing
  Future<void> trackSocialSharing({
    required String platform,
    required String contentType,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'social_sharing',
        parameters: {
          'platform': platform,
          'content_type': contentType,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Set user properties
  Future<void> setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.setUserId(id: userId);

      if (properties != null) {
        for (final entry in properties.entries) {
          await _firebaseAnalytics.setUserProperty(
            name: entry.key,
            value: entry.value.toString(),
          );
        }
      }
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track app lifecycle events
  Future<void> trackAppLifecycleEvent({
    required String event,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'app_lifecycle',
        parameters: {
          'event': event,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track feature usage
  Future<void> trackFeatureUsage({
    required String featureName,
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'feature_usage',
        parameters: {
          'feature_name': featureName,
          'action': action,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track user journey
  Future<void> trackUserJourney({
    required String step,
    required String journey,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'user_journey',
        parameters: {
          'step': step,
          'journey': journey,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track conversion event
  Future<void> trackConversion({
    required String conversionType,
    required double value,
    String? currency,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: 'conversion',
        parameters: {
          'conversion_type': conversionType,
          'value': value,
          if (currency != null) 'currency': currency,
          ...?parameters,
        },
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Track custom event
  Future<void> trackCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _firebaseAnalytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      await _crashlytics.recordError(e, null);
    }
  }

  /// Get analytics instance
  FirebaseAnalytics get analytics => _firebaseAnalytics;

  /// Get crashlytics instance
  FirebaseCrashlytics get crashlytics => _crashlytics;
}

/// Analytics service provider for Riverpod
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
