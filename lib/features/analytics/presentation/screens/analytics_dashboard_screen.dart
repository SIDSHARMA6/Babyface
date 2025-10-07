import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../providers/analytics_provider.dart';
import '../../domain/entities/analytics_event_entity.dart';

/// Analytics Dashboard Screen
/// Follows master plan theme standards and performance requirements
class AnalyticsDashboardScreen extends OptimizedStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  OptimizedState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends OptimizedState<AnalyticsDashboardScreen> {
  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Analytics Dashboard',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => notifier.refreshAnalytics(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: OptimizedContainer(
        padding: context.responsivePadding,
        child: Column(
          children: [
            if (state.isLoading) ...[
              Expanded(child: _buildLoadingState()),
            ] else ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildOverviewCards(state),
                      SizedBox(height: context.responsiveHeight(3)),
                      _buildEngagementMetrics(state),
                      SizedBox(height: context.responsiveHeight(3)),
                      _buildPerformanceMetrics(state),
                      SizedBox(height: context.responsiveHeight(3)),
                      _buildRecentEvents(state),
                    ],
                  ),
                ),
              ),
            ],
            if (state.errorMessage != null) ...[
              _buildErrorMessage(state.errorMessage!, notifier),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Loading analytics...',
            style: BabyFont.bodyL.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(AnalyticsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Overview',
          style: BabyFont.headingS,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Total Users',
                '${state.totalUsers}',
                Icons.people,
                AppTheme.primary,
              ),
            ),
            SizedBox(width: context.responsiveWidth(2)),
            Expanded(
              child: _buildOverviewCard(
                'Active Sessions',
                '${state.activeSessions}',
                Icons.timeline,
                AppTheme.accent,
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(2)),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Generations',
                '${state.totalGenerations}',
                Icons.child_care,
                AppTheme.boyColor,
              ),
            ),
            SizedBox(width: context.responsiveWidth(2)),
            Expanded(
              child: _buildOverviewCard(
                'Avg Session',
                '${state.averageSessionDuration.inMinutes}m',
                Icons.access_time,
                AppTheme.girlColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: context.responsiveFont(32),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            value,
            style: BabyFont.headingL.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.responsiveHeight(0.5)),
          OptimizedText(
            title,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementMetrics(AnalyticsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'User Engagement',
          style: BabyFont.headingS,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        Container(
          padding: context.responsivePadding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              _buildEngagementRow('Daily Active Users',
                  '${state.dailyActiveUsers}', AppTheme.primary),
              SizedBox(height: context.responsiveHeight(1)),
              _buildEngagementRow('Weekly Retention',
                  '${state.weeklyRetention}%', AppTheme.accent),
              SizedBox(height: context.responsiveHeight(1)),
              _buildEngagementRow('Feature Usage', '${state.featureUsageCount}',
                  AppTheme.boyColor),
              SizedBox(height: context.responsiveHeight(1)),
              _buildEngagementRow(
                  'Share Rate', '${state.shareRate}%', AppTheme.girlColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementRow(String label, String value, Color color) {
    return Row(
      children: [
        Expanded(
          child: OptimizedText(
            label,
            style: BabyFont.bodyM,
          ),
        ),
        OptimizedText(
          value,
          style: BabyFont.bodyM.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics(AnalyticsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Performance Metrics',
          style: BabyFont.headingS,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        Container(
          padding: context.responsivePadding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              _buildPerformanceRow('App Launch Time',
                  '${state.appLaunchTime}ms', AppTheme.primary),
              SizedBox(height: context.responsiveHeight(1)),
              _buildPerformanceRow(
                  'Memory Usage', '${state.memoryUsage}MB', AppTheme.accent),
              SizedBox(height: context.responsiveHeight(1)),
              _buildPerformanceRow(
                  'Frame Rate', '${state.frameRate}fps', AppTheme.boyColor),
              SizedBox(height: context.responsiveHeight(1)),
              _buildPerformanceRow(
                  'Crash Rate', '${state.crashRate}%', AppTheme.girlColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(String label, String value, Color color) {
    return Row(
      children: [
        Expanded(
          child: OptimizedText(
            label,
            style: BabyFont.bodyM,
          ),
        ),
        OptimizedText(
          value,
          style: BabyFont.bodyM.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEvents(AnalyticsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Recent Events',
          style: BabyFont.headingS,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        Container(
          padding: context.responsivePadding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: state.recentEvents
                .take(5)
                .map((event) => _buildEventItem(event))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(AnalyticsEventEntity event) {
    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
      padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(0.5)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.responsiveWidth(1)),
            decoration: BoxDecoration(
              color:
                  _getEventCategoryColor(event.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
            ),
            child: Icon(
              _getEventCategoryIcon(event.category),
              color: _getEventCategoryColor(event.category),
              size: context.responsiveFont(16),
            ),
          ),
          SizedBox(width: context.responsiveWidth(2)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OptimizedText(
                  event.eventName,
                  style: BabyFont.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                OptimizedText(
                  _formatEventTime(event.timestamp),
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          OptimizedText(
            _getEventCategoryLabel(event.category),
            style: BabyFont.bodyS.copyWith(
              color: _getEventCategoryColor(event.category),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error, AnalyticsNotifier notifier) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: context.responsiveFont(20),
          ),
          SizedBox(width: context.responsiveWidth(2)),
          Expanded(
            child: OptimizedText(
              error,
              style: BabyFont.bodyM.copyWith(
                color: Colors.red,
              ),
            ),
          ),
          IconButton(
            onPressed: () => notifier.clearError(),
            icon: const Icon(Icons.close),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Color _getEventCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.userAction:
        return AppTheme.primary;
      case EventCategory.screenView:
        return AppTheme.accent;
      case EventCategory.performance:
        return AppTheme.boyColor;
      case EventCategory.error:
        return Colors.red;
      case EventCategory.business:
        return AppTheme.girlColor;
      case EventCategory.engagement:
        return Colors.purple;
    }
  }

  IconData _getEventCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.userAction:
        return Icons.touch_app;
      case EventCategory.screenView:
        return Icons.visibility;
      case EventCategory.performance:
        return Icons.speed;
      case EventCategory.error:
        return Icons.error;
      case EventCategory.business:
        return Icons.business;
      case EventCategory.engagement:
        return Icons.favorite;
    }
  }

  String _getEventCategoryLabel(EventCategory category) {
    switch (category) {
      case EventCategory.userAction:
        return 'Action';
      case EventCategory.screenView:
        return 'Screen';
      case EventCategory.performance:
        return 'Performance';
      case EventCategory.error:
        return 'Error';
      case EventCategory.business:
        return 'Business';
      case EventCategory.engagement:
        return 'Engagement';
    }
  }

  String _formatEventTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
