import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../providers/couple_goals_providers.dart';

/// Daily progress card showing today's activities and streak
class DailyProgressCard extends ConsumerWidget {
  const DailyProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyProgressAsync = ref.watch(dailyProgressProvider);

    return Container(
      padding: AppTheme.cardPadding(context),
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
                  color: AppTheme.accentYellow.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.today_rounded,
                  color: AppTheme.accentYellow,
                  size: 20.w,
                ),
              ),
              SizedBox(width: AppTheme.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Progress',
                      style: BabyFont.titleMedium
                          .copyWith(color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Keep the momentum going!',
                      style: BabyFont.bodySmall
                          .copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.largeSpacing),
          dailyProgressAsync.when(
            data: (progress) => Column(
              children: [
                _buildProgressItem(
                  'Challenges Completed',
                  '${progress['challengesCompleted']}',
                  Icons.task_alt_rounded,
                  AppTheme.primaryPink,
                ),
                SizedBox(height: AppTheme.mediumSpacing),
                _buildProgressItem(
                  'Quizzes Completed',
                  '${progress['quizzesCompleted']}',
                  Icons.quiz_rounded,
                  AppTheme.primaryBlue,
                ),
                SizedBox(height: AppTheme.mediumSpacing),
                _buildStreakIndicator(progress['streakDays'] as int),
              ],
            ),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16.w),
        ),
        SizedBox(width: AppTheme.mediumSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: BabyFont.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: BabyFont.semiBold,
                ),
              ),
              Text(
                title,
                style:
                    BabyFont.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakIndicator(int streakDays) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.red.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: Colors.orange,
            size: 24.w,
          ),
          SizedBox(width: AppTheme.smallSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays Day Streak! 🔥',
                  style: BabyFont.titleSmall.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: BabyFont.semiBold,
                  ),
                ),
                Text(
                  'You\'re on fire! Keep it up!',
                  style: BabyFont.bodySmall
                      .copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildLoadingItem(),
        SizedBox(height: AppTheme.mediumSpacing),
        _buildLoadingItem(),
        SizedBox(height: AppTheme.mediumSpacing),
        _buildLoadingItem(),
      ],
    );
  }

  Widget _buildLoadingItem() {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
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
                width: 60.w,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                height: 12.h,
                width: 100.w,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.textSecondary,
            size: 32.w,
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            'Unable to load progress',
            style: BabyFont.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
