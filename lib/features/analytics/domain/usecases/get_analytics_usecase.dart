import '../entities/analytics_event_entity.dart';

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
  /// Execute get analytics
  Future<AnalyticsData> execute() async {
    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 800));

    // Return sample analytics data for demo
    return AnalyticsData(
      totalUsers: 12543,
      activeSessions: 892,
      totalGenerations: 45678,
      averageSessionDuration: const Duration(minutes: 8, seconds: 32),
      dailyActiveUsers: 2341,
      weeklyRetention: 67.5,
      featureUsageCount: 123456,
      shareRate: 23.8,
      appLaunchTime: 1250,
      memoryUsage: 85,
      frameRate: 58.7,
      crashRate: 0.12,
      recentEvents: _generateSampleEvents(),
    );
  }

  /// Generate sample events for demo
  List<AnalyticsEventEntity> _generateSampleEvents() {
    final now = DateTime.now();
    return [
      AnalyticsEventEntity(
        id: '1',
        eventName: 'baby_generation_started',
        parameters: {'user_id': 'user_123', 'generation_type': 'standard'},
        userId: 'user_123',
        timestamp: now.subtract(const Duration(minutes: 5)),
        sessionId: 'session_456',
        screenName: 'BabyGenerationScreen',
        category: EventCategory.userAction,
      ),
      AnalyticsEventEntity(
        id: '2',
        eventName: 'screen_view',
        parameters: {'screen_name': 'PremiumScreen'},
        userId: 'user_456',
        timestamp: now.subtract(const Duration(minutes: 12)),
        sessionId: 'session_789',
        screenName: 'PremiumScreen',
        category: EventCategory.screenView,
      ),
      AnalyticsEventEntity(
        id: '3',
        eventName: 'performance_metric',
        parameters: {'metric': 'memory_usage', 'value': 95, 'unit': 'MB'},
        userId: 'user_789',
        timestamp: now.subtract(const Duration(minutes: 18)),
        sessionId: 'session_101',
        screenName: 'DashboardScreen',
        category: EventCategory.performance,
      ),
      AnalyticsEventEntity(
        id: '4',
        eventName: 'premium_subscription',
        parameters: {'plan': 'yearly', 'price': 79.99},
        userId: 'user_101',
        timestamp: now.subtract(const Duration(minutes: 25)),
        sessionId: 'session_202',
        screenName: 'PremiumScreen',
        category: EventCategory.business,
      ),
      AnalyticsEventEntity(
        id: '5',
        eventName: 'share_image',
        parameters: {'platform': 'instagram', 'image_id': 'img_123'},
        userId: 'user_202',
        timestamp: now.subtract(const Duration(minutes: 32)),
        sessionId: 'session_303',
        screenName: 'HistoryScreen',
        category: EventCategory.engagement,
      ),
    ];
  }
}
