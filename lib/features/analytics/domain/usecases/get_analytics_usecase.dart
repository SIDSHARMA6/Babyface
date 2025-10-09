import '../entities/analytics_event_entity.dart';
import 'dart:developer' as developer;
import '../../../../shared/services/analytics_service.dart';

/// Analytics data class
class AnalyticsData {
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

  const AnalyticsData({
    required this.totalUsers,
    required this.activeSessions,
    required this.totalGenerations,
    required this.averageSessionDuration,
    required this.dailyActiveUsers,
    required this.weeklyRetention,
    required this.featureUsageCount,
    required this.shareRate,
    required this.appLaunchTime,
    required this.memoryUsage,
    required this.frameRate,
    required this.crashRate,
    required this.recentEvents,
  });
}

/// Get analytics use case
/// Follows master plan clean architecture
class GetAnalyticsUsecase {
  final AnalyticsService _analyticsService = AnalyticsService();

  /// Execute get analytics
  Future<AnalyticsData> execute() async {
    try {
      // Get real analytics data from AnalyticsService
      final analyticsData = await _analyticsService.getAnalyticsData();

      return AnalyticsData(
        totalUsers: analyticsData['totalUsers'] ?? 0,
        activeSessions: analyticsData['activeSessions'] ?? 0,
        totalGenerations: analyticsData['totalGenerations'] ?? 0,
        averageSessionDuration: Duration(
          milliseconds: analyticsData['averageSessionDuration'] ?? 0,
        ),
        dailyActiveUsers: analyticsData['dailyActiveUsers'] ?? 0,
        weeklyRetention: analyticsData['weeklyRetention'] ?? 0.0,
        featureUsageCount: analyticsData['featureUsageCount'] ?? 0,
        shareRate: analyticsData['shareRate'] ?? 0.0,
        appLaunchTime: analyticsData['appLaunchTime'] ?? 0,
        memoryUsage: analyticsData['memoryUsage'] ?? 0,
        frameRate: analyticsData['frameRate'] ?? 0.0,
        crashRate: analyticsData['crashRate'] ?? 0.0,
        recentEvents: _convertToAnalyticsEvents(
          analyticsData['recentEvents'] ?? [],
        ),
      );
    } catch (e) {
      developer.log('Error getting analytics: $e');
      // Return default values if analytics service fails
      return AnalyticsData(
        totalUsers: 0,
        activeSessions: 0,
        totalGenerations: 0,
        averageSessionDuration: Duration.zero,
        dailyActiveUsers: 0,
        weeklyRetention: 0.0,
        featureUsageCount: 0,
        shareRate: 0.0,
        appLaunchTime: 0,
        memoryUsage: 0,
        frameRate: 0.0,
        crashRate: 0.0,
        recentEvents: [],
      );
    }
  }

  /// Convert raw events to AnalyticsEventEntity
  List<AnalyticsEventEntity> _convertToAnalyticsEvents(
      List<dynamic> rawEvents) {
    return rawEvents
        .map((event) => AnalyticsEventEntity(
              id: event['id'] ?? '',
              eventName: event['eventName'] ?? '',
              parameters: Map<String, dynamic>.from(event['parameters'] ?? {}),
              userId: event['userId'] ?? '',
              timestamp:
                  DateTime.tryParse(event['timestamp'] ?? '') ?? DateTime.now(),
              category: EventCategory.values.firstWhere(
                (e) => e.name == event['category'],
                orElse: () => EventCategory.userAction,
              ),
            ))
        .toList();
  }
}
