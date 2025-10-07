import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../providers/couple_goals_providers.dart';
import '../../domain/models/couple_goals_models.dart';

/// Challenges section showing active mini challenges for couples
class ChallengesSection extends ConsumerWidget {
  const ChallengesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(activeChallengesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.task_alt_rounded,
              color: AppTheme.primaryPink,
              size: 24.w,
            ),
            SizedBox(width: AppTheme.smallSpacing),
            Text(
              'Active Challenges',
              style:
                  BabyFont.headlineSmall.copyWith(color: AppTheme.textPrimary),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _showAllChallenges(context, ref),
              child: Text(
                'View All',
                style:
                    BabyFont.titleSmall.copyWith(color: AppTheme.primaryPink),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.mediumSpacing),
        challengesAsync.when(
          data: (challenges) => challenges.isEmpty
              ? _buildEmptyState()
              : _buildChallengesList(challenges, ref),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(),
        ),
      ],
    );
  }

  Widget _buildChallengesList(List<MiniChallenge> challenges, WidgetRef ref) {
    return Column(
      children: challenges
          .take(3)
          .map((challenge) => _buildChallengeCard(challenge, ref))
          .toList(),
    );
  }

  Widget _buildChallengeCard(MiniChallenge challenge, WidgetRef ref) {
    final timeRemaining = challenge.timeRemaining;
    final isExpiringSoon = timeRemaining.inHours < 24;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
      padding: AppTheme.defaultCardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: isExpiringSoon
              ? Colors.orange.withValues(alpha: 0.3)
              : AppTheme.borderLight,
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
                  color: _getChallengeTypeColor(challenge.type)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    challenge.emoji,
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
                      challenge.title,
                      style: BabyFont.titleMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: BabyFont.semiBold,
                      ),
                    ),
                    Text(
                      challenge.type.name.toUpperCase(),
                      style: BabyFont.labelSmall.copyWith(
                        color: _getChallengeTypeColor(challenge.type),
                        fontWeight: BabyFont.medium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                ),
                child: Text(
                  '+${challenge.pointsReward}',
                  style: BabyFont.labelSmall.copyWith(
                    color: AppTheme.accentYellow,
                    fontWeight: BabyFont.semiBold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            challenge.description,
            style: BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: AppTheme.mediumSpacing),

          // Time remaining and action button
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: isExpiringSoon ? Colors.orange : AppTheme.textSecondary,
                size: 16.w,
              ),
              SizedBox(width: 4.w),
              Text(
                _formatTimeRemaining(timeRemaining),
                style: BabyFont.bodySmall.copyWith(
                  color:
                      isExpiringSoon ? Colors.orange : AppTheme.textSecondary,
                  fontWeight:
                      isExpiringSoon ? BabyFont.medium : BabyFont.regular,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _completeChallenge(challenge, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getChallengeTypeColor(challenge.type),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                  ),
                ),
                child: Text(
                  'Complete',
                  style: BabyFont.titleSmall.copyWith(color: Colors.white),
                ),
              ),
            ],
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
            Icons.celebration_rounded,
            size: 48.w,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            'All Caught Up!',
            style: BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            'You\'ve completed all your challenges! New ones will appear soon.',
            style: BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
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
            'Unable to Load Challenges',
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

  Color _getChallengeTypeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.daily:
        return AppTheme.accentYellow;
      case ChallengeType.weekly:
        return AppTheme.primaryBlue;
      case ChallengeType.quiz:
        return AppTheme.primaryPink;
      case ChallengeType.communication:
        return Colors.green;
      case ChallengeType.fun:
        return Colors.orange;
      case ChallengeType.romantic:
        return Colors.purple;
    }
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m left';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m left';
    } else {
      return 'Expires soon!';
    }
  }

  void _completeChallenge(MiniChallenge challenge, WidgetRef ref) {
    // Show completion dialog
    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        ),
        title: Row(
          children: [
            Text(challenge.emoji, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: AppTheme.smallSpacing),
            Expanded(
              child: Text(
                'Complete Challenge?',
                style:
                    BabyFont.titleLarge.copyWith(color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.title,
              style: BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
            ),
            SizedBox(height: AppTheme.smallSpacing),
            Text(
              'Did you complete this challenge?',
              style:
                  BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Not Yet',
              style:
                  BabyFont.titleSmall.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(challengeCompletionProvider.notifier)
                  .completeChallenge(challenge.id, note: 'Completed via app');

              // Show success message
              ScaffoldMessenger.of(ref.context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Challenge completed! +${challenge.pointsReward} points! 🎉',
                    style: BabyFont.bodyMedium.copyWith(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getChallengeTypeColor(challenge.type),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              ),
            ),
            child: Text(
              'Yes! 🎉',
              style: BabyFont.titleSmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllChallenges(BuildContext context, WidgetRef ref) {
    // Navigate to full challenges screen or show modal
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
                  Icon(Icons.task_alt_rounded, color: AppTheme.primaryPink),
                  SizedBox(width: AppTheme.smallSpacing),
                  Text(
                    'All Challenges',
                    style: BabyFont.headlineSmall
                        .copyWith(color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final challengesAsync = ref.watch(activeChallengesProvider);

                  return challengesAsync.when(
                    data: (challenges) => ListView.builder(
                      padding: AppTheme.cardPadding(context),
                      itemCount: challenges.length,
                      itemBuilder: (context, index) =>
                          _buildChallengeCard(challenges[index], ref),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text(
                        'Unable to load challenges',
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
