import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/responsive_widgets.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/responsive_button.dart';
import '../../../../shared/widgets/toast_service.dart';

import '../../domain/models/social_challenge.dart';
import '../../data/social_challenges_service.dart';

/// Challenge participation modal with theme integration
/// Follows universal theme, responsive design, and ANR prevention
class ChallengeParticipationModal extends StatefulWidget {
  final SocialChallenge challenge;
  final String userId;
  final VoidCallback? onParticipate;

  const ChallengeParticipationModal({
    super.key,
    required this.challenge,
    required this.userId,
    this.onParticipate,
  });

  @override
  State<ChallengeParticipationModal> createState() =>
      _ChallengeParticipationModalState();
}

class _ChallengeParticipationModalState
    extends State<ChallengeParticipationModal> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _captionController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasUserParticipated = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppTheme.defaultCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppTheme.defaultCurve,
    ));

    _slideController.forward();
    _fadeController.forward();
    _checkUserParticipation();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _checkUserParticipation() async {
    try {
      final hasParticipated = await SocialChallengesService.hasUserParticipated(
        widget.challenge.id,
        widget.userId,
      );

      if (mounted) {
        setState(() {
          _hasUserParticipated = hasParticipated;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
          child: SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildModalContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalContent() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.largeRadius),
        ),
        boxShadow: AppTheme.strongShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildChallengeInfo(),
                  SizedBox(height: AppTheme.largeSpacing),
                  _buildParticipationSection(),
                  SizedBox(height: AppTheme.extraLargeSpacing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40.w,
      height: 4.h,
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.borderLight,
        borderRadius: BorderRadius.circular(2.h),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: ResponsiveUtils.padding(context),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              gradient: _getChallengeGradient(),
              shape: BoxShape.circle,
              boxShadow: AppTheme.mediumShadow,
            ),
            child: Icon(
              _getChallengeIcon(),
              color: Colors.white,
              size: 24.w,
            ),
          ),
          SizedBox(width: AppTheme.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.challenge.title,
                  style: BabyFont.headlineSmall.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _getTimeRemaining(),
                  style: BabyFont.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _closeModal,
            icon: Icon(
              Icons.close_rounded,
              color: AppTheme.textSecondary,
              size: 24.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeInfo() {
    return Container(
      margin: ResponsiveUtils.padding(context),
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Challenge Details',
            style: BabyFont.titleMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: BabyFont.semiBold,
            ),
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            widget.challenge.description,
            style: BabyFont.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          _buildChallengeStats(),
          if (widget.challenge.hashtags.isNotEmpty) ...[
            SizedBox(height: AppTheme.mediumSpacing),
            _buildHashtags(),
          ],
        ],
      ),
    );
  }

  Widget _buildChallengeStats() {
    return ResponsiveWidget(
      phone: _buildPhoneStats(),
      tablet: _buildTabletStats(),
    );
  }

  Widget _buildPhoneStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.people_rounded,
            '${widget.challenge.participantCount}',
            'Participants',
            AppTheme.primaryBlue,
          ),
        ),
        SizedBox(width: AppTheme.mediumSpacing),
        Expanded(
          child: _buildStatCard(
            Icons.star_rounded,
            '${widget.challenge.rewardPoints}',
            'Points',
            AppTheme.accentYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          Icons.people_rounded,
          '${widget.challenge.participantCount}',
          'Participants',
          AppTheme.primaryBlue,
        ),
        _buildStatCard(
          Icons.star_rounded,
          '${widget.challenge.rewardPoints}',
          'Points',
          AppTheme.accentYellow,
        ),
        _buildStatCard(
          Icons.timer_rounded,
          _getTimeRemaining(),
          'Remaining',
          AppTheme.primaryPink,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTheme.mediumSpacing),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 4.h),
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
    );
  }

  Widget _buildHashtags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hashtags',
          style: BabyFont.titleSmall.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: widget.challenge.hashtags.map((hashtag) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                border: Border.all(
                  color: AppTheme.primaryPink.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '#$hashtag',
                style: BabyFont.labelMedium.copyWith(
                  color: AppTheme.primaryPink,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildParticipationSection() {
    if (_hasUserParticipated) {
      return _buildAlreadyParticipated();
    }

    if (!widget.challenge.isOngoing) {
      return _buildChallengeNotActive();
    }

    return _buildParticipationForm();
  }

  Widget _buildAlreadyParticipated() {
    return Container(
      margin: ResponsiveUtils.padding(context),
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 60.w,
            color: AppTheme.success,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            'Already Participated!',
            style: BabyFont.titleLarge.copyWith(
              color: AppTheme.success,
              fontWeight: BabyFont.semiBold,
            ),
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            'You\'ve already joined this challenge. Check your submissions in the "My Challenges" tab.',
            style: BabyFont.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeNotActive() {
    return Container(
      margin: ResponsiveUtils.padding(context),
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            widget.challenge.isUpcoming
                ? Icons.schedule_rounded
                : Icons.event_busy_rounded,
            size: 60.w,
            color: AppTheme.warning,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            widget.challenge.isUpcoming
                ? 'Challenge Not Started'
                : 'Challenge Ended',
            style: BabyFont.titleLarge.copyWith(
              color: AppTheme.warning,
              fontWeight: BabyFont.semiBold,
            ),
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            widget.challenge.isUpcoming
                ? 'This challenge will start ${_getTimeRemaining()}. Come back then to participate!'
                : 'This challenge has ended. Stay tuned for new challenges!',
            style: BabyFont.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipationForm() {
    return Container(
      margin: ResponsiveUtils.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join the Challenge',
            style: BabyFont.titleLarge.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: BabyFont.semiBold,
            ),
          ),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            'Share your participation with a caption and earn ${widget.challenge.rewardPoints} points!',
            style: BabyFont.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: AppTheme.largeSpacing),
          _buildCaptionInput(),
          SizedBox(height: AppTheme.largeSpacing),
          _buildParticipateButton(),
        ],
      ),
    );
  }

  Widget _buildCaptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caption (Optional)',
          style: BabyFont.titleSmall.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
            border: Border.all(color: AppTheme.borderLight),
            boxShadow: AppTheme.softShadow,
          ),
          child: TextField(
            controller: _captionController,
            maxLines: 3,
            maxLength: 200,
            style: BabyFont.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Share your thoughts about this challenge...',
              hintStyle: BabyFont.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppTheme.mediumSpacing),
              counterStyle: BabyFont.labelSmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipateButton() {
    return ResponsiveButton(
      text: _isSubmitting ? 'Joining...' : 'Join Challenge',
      icon: _isSubmitting ? null : Icons.emoji_events_rounded,
      type: ButtonType.primary,
      size: ButtonSize.large,
      width: double.infinity,
      isLoading: _isSubmitting,
      onPressed: _isSubmitting ? null : _participateInChallenge,
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

  String _getTimeRemaining() {
    if (widget.challenge.isUpcoming) {
      final duration = widget.challenge.timeUntilStart;
      return _formatDuration(duration);
    } else if (widget.challenge.isOngoing) {
      final duration = widget.challenge.timeRemaining;
      return _formatDuration(duration);
    } else {
      return 'Ended';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Soon';
    }
  }

  Future<void> _participateInChallenge() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      HapticFeedback.lightImpact();

      await SocialChallengesService.participateInChallenge(
        challengeId: widget.challenge.id,
        userId: widget.userId,
        caption: _captionController.text.trim(),
      );

      if (mounted) {
        ToastService.showCelebration(
          context,
          'Successfully joined the challenge! 🎉 You earned ${widget.challenge.rewardPoints} points!',
        );

        widget.onParticipate?.call();
        _closeModal();
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(
          context,
          'Failed to join challenge. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _closeModal() {
    _slideController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
