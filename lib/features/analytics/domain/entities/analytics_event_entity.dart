import 'package:equatable/equatable.dart';

/// Analytics event entity
/// Follows master plan clean architecture
class AnalyticsEventEntity extends Equatable {
  final String id;
  final String eventName;
  final Map<String, dynamic> parameters;
  final String userId;
  final DateTime timestamp;
  final String? sessionId;
  final String? screenName;
  final EventCategory category;

  const AnalyticsEventEntity({
    required this.id,
    required this.eventName,
    required this.parameters,
    required this.userId,
    required this.timestamp,
    this.sessionId,
    this.screenName,
    required this.category,
  });

  @override
  List<Object?> get props => [
        id,
        eventName,
        parameters,
        userId,
        timestamp,
        sessionId,
        screenName,
        category,
      ];

  AnalyticsEventEntity copyWith({
    String? id,
    String? eventName,
    Map<String, dynamic>? parameters,
    String? userId,
    DateTime? timestamp,
    String? sessionId,
    String? screenName,
    EventCategory? category,
  }) {
    return AnalyticsEventEntity(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      parameters: parameters ?? this.parameters,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      screenName: screenName ?? this.screenName,
      category: category ?? this.category,
    );
  }
}

/// Event category enum
enum EventCategory {
  userAction,
  screenView,
  performance,
  error,
  business,
  engagement,
}

/// Analytics metrics entity
class AnalyticsMetricsEntity extends Equatable {
  final String id;
  final String metricName;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const AnalyticsMetricsEntity({
    required this.id,
    required this.metricName,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [id, metricName, value, unit, timestamp, metadata];
}

/// User engagement metrics
class UserEngagementMetrics extends Equatable {
  final String userId;
  final int sessionCount;
  final Duration totalSessionTime;
  final int screenViews;
  final int actionsPerformed;
  final DateTime lastActiveDate;
  final List<String> favoriteFeatures;
  final double engagementScore;

  const UserEngagementMetrics({
    required this.userId,
    required this.sessionCount,
    required this.totalSessionTime,
    required this.screenViews,
    required this.actionsPerformed,
    required this.lastActiveDate,
    required this.favoriteFeatures,
    required this.engagementScore,
  });

  @override
  List<Object?> get props => [
        userId,
        sessionCount,
        totalSessionTime,
        screenViews,
        actionsPerformed,
        lastActiveDate,
        favoriteFeatures,
        engagementScore,
      ];
}

/// Performance metrics
class PerformanceMetrics extends Equatable {
  final String screenName;
  final Duration loadTime;
  final int memoryUsage;
  final double frameRate;
  final int crashCount;
  final DateTime timestamp;

  const PerformanceMetrics({
    required this.screenName,
    required this.loadTime,
    required this.memoryUsage,
    required this.frameRate,
    required this.crashCount,
    required this.timestamp,
  });

  @override
  List<Object?> get props =>
      [screenName, loadTime, memoryUsage, frameRate, crashCount, timestamp];
}
