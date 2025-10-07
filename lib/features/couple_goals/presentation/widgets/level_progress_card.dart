import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../providers/couple_goals_providers.dart';

/// Level progress card showing current level and progress to next level
class LevelProgressCard extends ConsumerWidget {
  const LevelProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelProgressAsync = ref.watch(levelProgressProvider);

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
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20.w,
                ),
              ),
              SizedBox(width: AppTheme.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Couple Level',
                      style: BabyFont.titleMedium
                          .copyWith(color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Your relationship journey',
                      style: BabyFont.bodySmall
                          .copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.largeSpacing),
          levelProgressAsync.when(
            data: (progress) => _buildLevelContent(progress),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelContent(Map<String, dynamic> progress) {
    final currentLevel = progress['currentLevel'] as int;
    final currentPoints = progress['currentPoints'] as int;
    final pointsNeeded = progress['pointsNeeded'] as int;
    final progressPercentage = progress['progressPercentage'] as double;
    final isMaxLevel = progress['isMaxLevel'] as bool;

    return Column(
      children: [
        // Current level display
        Row(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryPink,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: AppTheme.mediumShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$currentLevel',
                    style: BabyFont.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: BabyFont.bold,
                    ),
                  ),
                  Text(
                    'LVL',
                    style: BabyFont.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 8.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppTheme.mediumSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLevelTitle(currentLevel),
                    style: BabyFont.titleMedium.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: BabyFont.semiBold,
                    ),
                  ),
                  Text(
                    '$currentPoints points earned',
                    style: BabyFont.bodySmall
                        .copyWith(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              _getLevelEmoji(currentLevel),
              style: TextStyle(fontSize: 24.sp),
            ),
          ],
        ),

        if (!isMaxLevel) ...[
          SizedBox(height: AppTheme.largeSpacing),

          // Progress to next level
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next Level Progress',
                    style: BabyFont.titleSmall
                        .copyWith(color: AppTheme.textPrimary),
                  ),
                  Text(
                    '${progressPercentage.toInt()}%',
                    style: BabyFont.titleSmall.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: BabyFont.semiBold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.smallSpacing),
              LinearProgressIndicator(
                value: progressPercentage / 100,
                backgroundColor: AppTheme.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                minHeight: 6.h,
              ),
              SizedBox(height: AppTheme.smallSpacing),
              Text(
                '$pointsNeeded more points to level ${currentLevel + 1}',
                style:
                    BabyFont.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ] else ...[
          SizedBox(height: AppTheme.mediumSpacing),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.1),
                  AppTheme.primaryPink.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              border: Border.all(
                color: Colors.purple.withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Colors.purple,
                  size: 20.w,
                ),
                SizedBox(width: AppTheme.smallSpacing),
                Expanded(
                  child: Text(
                    'Maximum level reached! You\'re relationship legends! 👑',
                    style: BabyFont.bodySmall.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: BabyFont.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getLevelTitle(int level) {
    if (level == 1) return 'New Couple';
    if (level <= 3) return 'Growing Together';
    if (level <= 5) return 'Strong Bond';
    if (level <= 8) return 'Deep Connection';
    if (level <= 12) return 'Perfect Match';
    if (level <= 15) return 'Soulmates';
    return 'Relationship Legends';
  }

  String _getLevelEmoji(int level) {
    if (level == 1) return '💝';
    if (level <= 3) return '💗';
    if (level <= 5) return '💖';
    if (level <= 8) return '💕';
    if (level <= 12) return '💞';
    if (level <= 15) return '💘';
    return '👑';
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
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
                    width: 120.w,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    height: 12.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.largeSpacing),
        Container(
          height: 6.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.borderLight,
            borderRadius: BorderRadius.circular(3.h),
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
            'Unable to load level progress',
            style: BabyFont.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
