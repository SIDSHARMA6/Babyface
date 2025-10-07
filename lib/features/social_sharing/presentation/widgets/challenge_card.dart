import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/baby_font.dart';

import '../../../../shared/widgets/responsive_button.dart';
import '../../domain/models/social_challenge.dart';

/// Theme-aware challenge card with ANR prevention
/// Follows universal theme, responsive design, and zero boilerplate principles
class ChallengeCard extends StatefulWidget {
  final SocialChallenge challenge;
  final VoidCallback? onTap;
  final VoidCallback? onParticipate;
  final bool isCompact;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.onParticipate,
    this.isCompact = false,
  });

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.defaultCurve,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(_slideAnimation.value, 0),
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              onTap: _handleTap,
              child: Container(
                margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: AppTheme.softShadow,
                ),
                child:
                    widget.isCompact ? _buildCompactCard() : _buildFullCard(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildContent(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildCompactCard() {
    return Padding(
      padding: AppTheme.cardPadding(context),
      child: Row(
        children: [
          _buildTypeIcon(),
          SizedBox(width: AppTheme.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.challenge.title,
                  style: BabyFont.titleMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${widget.challenge.participantCount} participants • ${widget.challenge.rewardPoints} pts',
                  style: BabyFont.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        gradient: _getChallengeGradient(),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.largeRadius),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.largeRadius),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: AppTheme.cardPadding(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeIcon(),
                SizedBox(width: AppTheme.mediumSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.challenge.title,
                        style: BabyFont.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: BabyFont.semiBold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getTimeRemaining(),
                        style: BabyFont.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: AppTheme.cardPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.challenge.description,
            style: BabyFont.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          _buildStats(),
          if (widget.challenge.hashtags.isNotEmpty) ...[
            SizedBox(height: AppTheme.smallSpacing),
            _buildHashtags(),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.borderLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.largeRadius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reward',
                  style: BabyFont.labelSmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  '${widget.challenge.rewardPoints} Points',
                  style: BabyFont.titleSmall.copyWith(
                    color: AppTheme.accentYellow,
                    fontWeight: BabyFont.semiBold,
                  ),
                ),
              ],
            ),
          ),
          ResponsiveButton(
            text: 'Join Challenge',
            icon: Icons.emoji_events_rounded,
            type: ButtonType.primary,
            size: ButtonSize.medium,
            onPressed: widget.onParticipate,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon() {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Icon(
        _getChallengeIcon(),
        color: Colors.white,
        size: 24.w,
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (color, text) = _getStatusInfo();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1.w,
        ),
      ),
      child: Text(
        text,
        style: BabyFont.labelSmall.copyWith(
          color: color,
          fontWeight: BabyFont.medium,
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _buildStatItem(
          Icons.people_rounded,
          '${widget.challenge.participantCount}',
          'Participants',
          AppTheme.primaryBlue,
        ),
        SizedBox(width: AppTheme.largeSpacing),
        _buildStatItem(
          Icons.star_rounded,
          '${widget.challenge.rewardPoints}',
          'Points',
          AppTheme.accentYellow,
        ),
      ],
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.w, color: color),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: BabyFont.titleSmall.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: BabyFont.semiBold,
              ),
            ),
            Text(
              label,
              style: BabyFont.labelSmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHashtags() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 4.h,
      children: widget.challenge.hashtags.take(3).map((hashtag) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 2.h,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.smallRadius),
          ),
          child: Text(
            '#$hashtag',
            style: BabyFont.labelSmall.copyWith(
              color: AppTheme.primaryPink,
            ),
          ),
        );
      }).toList(),
    );
  }

  LinearGradient _getChallengeGradient() {
    switch (widget.challenge.type) {
      case ChallengeType.sharing:
        return LinearGradient(
          colors: [AppTheme.primaryPink, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChallengeType.babyPrediction:
        return LinearGradient(
          colors: [AppTheme.accentYellow, AppTheme.softPeach],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChallengeType.coupleGoals:
        return LinearGradient(
          colors: [AppTheme.primaryPink, AppTheme.lavender],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChallengeType.quiz:
        return LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.mintGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChallengeType.referral:
        return LinearGradient(
          colors: [AppTheme.accentYellow, AppTheme.primaryPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChallengeType.creative:
        return LinearGradient(
          colors: [AppTheme.lavender, AppTheme.mintGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getChallengeIcon() {
    switch (widget.challenge.type) {
      case ChallengeType.sharing:
        return Icons.share_rounded;
      case ChallengeType.babyPrediction:
        return Icons.child_care_rounded;
      case ChallengeType.coupleGoals:
        return Icons.favorite_rounded;
      case ChallengeType.quiz:
        return Icons.quiz_rounded;
      case ChallengeType.referral:
        return Icons.people_rounded;
      case ChallengeType.creative:
        return Icons.palette_rounded;
    }
  }

  (Color, String) _getStatusInfo() {
    if (widget.challenge.isUpcoming) {
      return (AppTheme.warning, 'Upcoming');
    } else if (widget.challenge.isOngoing) {
      return (AppTheme.success, 'Active');
    } else if (widget.challenge.isExpired) {
      return (AppTheme.textSecondary, 'Ended');
    } else {
      return (AppTheme.primaryBlue, 'Available');
    }
  }

  String _getTimeRemaining() {
    if (widget.challenge.isUpcoming) {
      final duration = widget.challenge.timeUntilStart;
      return 'Starts in ${_formatDuration(duration)}';
    } else if (widget.challenge.isOngoing) {
      final duration = widget.challenge.timeRemaining;
      return 'Ends in ${_formatDuration(duration)}';
    } else {
      return 'Challenge ended';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Soon';
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }
}
