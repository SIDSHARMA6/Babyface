import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../providers/couple_goals_providers.dart';
import '../../domain/models/couple_goals_models.dart';

/// Insights section showing relationship insights based on quiz performance
class InsightsSection extends ConsumerWidget {
  const InsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(relationshipInsightsProvider(null));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_rounded,
              color: AppTheme.accentYellow,
              size: 24.w,
            ),
            SizedBox(width: AppTheme.smallSpacing),
            Text(
              'Relationship Insights',
              style:
                  BabyFont.headlineSmall.copyWith(color: AppTheme.textPrimary),
            ),
          ],
        ),
        SizedBox(height: AppTheme.mediumSpacing),
        insightsAsync.when(
          data: (insights) => insights.isEmpty
              ? _buildEmptyState()
              : _buildInsightsList(insights),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(),
        ),
      ],
    );
  }

  Widget _buildInsightsList(List<RelationshipInsight> insights) {
    return Column(
      children: insights
          .take(3)
          .map((insight) => _buildInsightCard(insight))
          .toList(),
    );
  }

  Widget _buildInsightCard(RelationshipInsight insight) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
      padding: AppTheme.defaultCardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: insight.isPositive
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: _getCategoryColor(insight.category)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    insight.emoji,
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: BabyFont.titleMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: BabyFont.semiBold,
                      ),
                    ),
                    Text(
                      insight.category.toUpperCase(),
                      style: BabyFont.labelSmall.copyWith(
                        color: _getCategoryColor(insight.category),
                        fontWeight: BabyFont.medium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getScoreColor(insight.score).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                ),
                child: Text(
                  '${insight.score.toInt()}%',
                  style: BabyFont.labelSmall.copyWith(
                    color: _getScoreColor(insight.score),
                    fontWeight: BabyFont.semiBold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            insight.description,
            style: BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: AppTheme.primaryBlue,
                  size: 16.w,
                ),
                SizedBox(width: AppTheme.smallSpacing),
                Expanded(
                  child: Text(
                    insight.recommendation,
                    style: BabyFont.bodySmall.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: BabyFont.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: AppTheme.defaultCardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.psychology_rounded,
            size: 48.w,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            'No Insights Yet',
            style: BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            'Complete more quizzes together to unlock personalized relationship insights!',
            style: BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to quiz screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              ),
            ),
            icon: Icon(Icons.quiz_rounded, color: Colors.white, size: 16.w),
            label: Text(
              'Take a Quiz',
              style: BabyFont.titleSmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(2, (index) => _buildLoadingCard()),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
      padding: AppTheme.defaultCardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppTheme.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius:
                            BorderRadius.circular(AppTheme.smallRadius),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      height: 12.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius:
                            BorderRadius.circular(AppTheme.smallRadius),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Container(
            height: 14.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            height: 14.h,
            width: 200.w,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: AppTheme.defaultCardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48.w,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            'Unable to Load Insights',
            style: BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            'Please try again later',
            style: BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'compatibility':
        return AppTheme.primaryPink;
      case 'communication':
        return AppTheme.primaryBlue;
      case 'fun':
        return AppTheme.accentYellow;
      case 'intimacy':
        return Colors.purple;
      case 'goals':
        return Colors.green;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return AppTheme.accentYellow;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
