import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:developer' as developer;
import 'hive_service.dart';

/// Analytics service for tracking user behavior and app performance
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final HiveService _hiveService = HiveService();
  static const String _boxName = 'analytics_box';
  static const String _analyticsKey = 'analytics_data';

  /// Get analytics service instance
  static AnalyticsService get instance => _instance;

  /// Track user event
  Future<void> trackEvent(
      String eventName, Map<String, dynamic> parameters) async {
    try {
      // Track locally with Hive
      await _hiveService.ensureBoxOpen(_boxName);
      final analyticsData = await _getAnalyticsData();

      analyticsData['events'] = analyticsData['events'] ?? [];
      analyticsData['events'].add({
        'eventName': eventName,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _hiveService.store(_boxName, _analyticsKey, analyticsData);

      // Track with Firebase Analytics
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: parameters,
      );

      developer.log('📊 [AnalyticsService] Event tracked: $eventName');
    } catch (e) {
      developer.log('❌ [AnalyticsService] Error tracking event: $e');
    }
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName) async {
    try {
      await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
      await trackEvent('screen_view', {'screen_name': screenName});
    } catch (e) {
      developer.log('❌ [AnalyticsService] Error tracking screen view: $e');
    }
  }

  /// Track user property
  Future<void> setUserProperty(String name, String value) async {
    try {
      await FirebaseAnalytics.instance
          .setUserProperty(name: name, value: value);
    } catch (e) {
      developer.log('❌ [AnalyticsService] Error setting user property: $e');
    }
  }

  /// Get analytics data
  Future<Map<String, dynamic>> getAnalyticsData() async {
    try {
      return await _getAnalyticsData();
    } catch (e) {
      developer.log('❌ [AnalyticsService] Error getting analytics data: $e');
      return _getDefaultAnalyticsData();
    }
  }

  /// Get analytics data from Hive
  Future<Map<String, dynamic>> _getAnalyticsData() async {
    await _hiveService.ensureBoxOpen(_boxName);
    final data = _hiveService.retrieve(_boxName, _analyticsKey);

    if (data != null) {
      return Map<String, dynamic>.from(data);
    }

    return _getDefaultAnalyticsData();
  }

  /// Get default analytics data
  Map<String, dynamic> _getDefaultAnalyticsData() {
    return {
      'totalUsers': 0,
      'activeSessions': 0,
      'totalGenerations': 0,
      'averageSessionDuration': 0,
      'dailyActiveUsers': 0,
      'weeklyRetention': 0.0,
      'featureUsageCount': 0,
      'shareRate': 0.0,
      'appLaunchTime': 0,
      'memoryUsage': 0,
      'frameRate': 0.0,
      'crashRate': 0.0,
      'recentEvents': [],
      'events': [],
    };
  }

  /// Update analytics metrics
  Future<void> updateMetrics(Map<String, dynamic> metrics) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final analyticsData = await _getAnalyticsData();

      analyticsData.addAll(metrics);
      analyticsData['lastUpdated'] = DateTime.now().toIso8601String();

      await _hiveService.store(_boxName, _analyticsKey, analyticsData);

      developer.log('📊 [AnalyticsService] Metrics updated');
    } catch (e) {
      developer.log('❌ [AnalyticsService] Error updating metrics: $e');
    }
  }

  /// Clear analytics data
  Future<void> clearAnalyticsData() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _analyticsKey);
      developer.log('📊 [AnalyticsService] Analytics data cleared');
    } catch (e) {
      developer.log('❌ [AnalyticsService] Error clearing analytics data: $e');
    }
  }
}
