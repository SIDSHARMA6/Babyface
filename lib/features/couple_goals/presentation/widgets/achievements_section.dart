import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../providers/couple_goals_providers.dart';
import '../../domain/models/couple_goals_models.dart';

/// Achievements section showing recent achievements and badges
class AchievementsSection extends ConsumerWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(recentAchievementsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: AppTheme.accentYellow,
              size: 24.w,
            ),
            SizedBox(width: AppTheme.smallSpacing),
            Text(
              'Recent Achievements',
              style:
                  BabyFont.headlineSmall.copyWith(color: AppTheme.textPrimary),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _showAllAchievements(context, ref),
              child: Text(
                'View All',
                style:
                    BabyFont.titleSmall.copyWith(color: AppTheme.accentYellow),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.mediumSpacing),
        achievementsAsync.when(
          data: (achievements) => achievements.isEmpty
              ? _buildEmptyState()
              : _buildAchievementsList(achievements),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(),
        ),
      ],
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements) {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) =>
            _buildAchievementCard(achievements[index]),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      width: 200.w,
      margin: EdgeInsets.only(right: AppTheme.mediumSpacing),
      padding: AppTheme.defaultCardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: achievement.isRare
              ? [
                  Colors.purple.withValues(alpha: 0.1),
                  AppTheme.accentYellow.withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                  AppTheme.primaryPink.withValues(alpha: 0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: achievement.isRare
              ? Colors.purple.withValues(alpha: 0.3)
              : AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: achievement.isRare ? 2.w : 1.w,
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
                  color: _getAchievementColor(achievement.type)
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.emoji,
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ),
              ),
              const Spacer(),
              if (achievement.isRare)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  ),
                  child: Text(
                    'RARE',
                    style: BabyFont.labelSmall.copyWith(
                      color: Colors.purple,
                      fontWeight: BabyFont.bold,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            achievement.title,
            style: BabyFont.titleSmall.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: BabyFont.semiBold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            achievement.description,
            style: BabyFont.bodySmall.copyWith(color: AppTheme.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppTheme.accentYellow,
                size: 14.w,
              ),
              SizedBox(width: 4.w),
              Text(
                '+${achievement.pointsAwarded}',
                style: BabyFont.labelSmall.copyWith(
                  color: AppTheme.accentYellow,
                  fontWeight: BabyFont.semiBold,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(achievement.unlockedAt),
                style:
                    BabyFont.labelSmall.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120.h,
      padding: AppTheme.defaultCardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 32.w,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: AppTheme.smallSpacing),
            Text(
              'No Achievements Yet',
              style: BabyFont.titleSmall.copyWith(color: AppTheme.textPrimary),
            ),
            Text(
              'Complete quizzes to earn badges!',
              style: BabyFont.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => _buildLoadingCard(),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: 200.w,
      margin: EdgeInsets.only(right: AppTheme.mediumSpacing),
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
              const Spacer(),
              Container(
                width: 30.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Container(
            height: 14.h,
            width: 120.w,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            height: 12.h,
            width: 160.w,
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
      height: 120.h,
      padding: AppTheme.defaultCardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 32.w,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: AppTheme.smallSpacing),
            Text(
              'Unable to Load Achievements',
              style: BabyFont.titleSmall.copyWith(color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAchievementColor(AchievementType type) {
    switch (type) {
      case AchievementType.firstQuiz:
        return AppTheme.primaryBlue;
      case AchievementType.perfectScore:
        return AppTheme.accentYellow;
      case AchievementType.streakMaster:
        return Colors.orange;
      case AchievementType.loveExpert:
        return AppTheme.primaryPink;
      case AchievementType.puzzleMaster:
        return Colors.purple;
      case AchievementType.communicator:
        return Colors.green;
      case AchievementType.goalSetter:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showAllAchievements(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.largeRadius),
            topRight: Radius.circular(AppTheme.largeRadius),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
            Padding(
              padding: AppTheme.cardPadding(context),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_rounded,
                      color: AppTheme.accentYellow),
                  SizedBox(width: AppTheme.smallSpacing),
                  Text(
                    'All Achievements',
                    style: BabyFont.headlineSmall
                        .copyWith(color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final coupleGoalsAsync = ref.watch(coupleGoalsDataProvider);

                  return coupleGoalsAsync.when(
                    data: (data) => data.achievements.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events_outlined,
                                  size: 64.w,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(height: AppTheme.mediumSpacing),
                                Text(
                                  'No Achievements Yet',
                                  style: BabyFont.titleLarge
                                      .copyWith(color: AppTheme.textPrimary),
                                ),
                                Text(
                                  'Complete quizzes and challenges to earn badges!',
                                  style: BabyFont.bodyMedium
                                      .copyWith(color: AppTheme.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: AppTheme.cardPadding(context),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppTheme.mediumSpacing,
                              mainAxisSpacing: AppTheme.mediumSpacing,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: data.achievements.length,
                            itemBuilder: (context, index) =>
                                _buildAchievementCard(data.achievements[index]),
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text(
                        'Unable to load achievements',
                        style: BabyFont.bodyMedium
                            .copyWith(color: AppTheme.textSecondary),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
