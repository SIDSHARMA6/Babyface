import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/loading_animation.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../../../shared/widgets/responsive_button.dart';
import '../../domain/models/social_challenge.dart';
import '../../data/social_challenges_service.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenge_participation_modal.dart';

/// Social challenges screen with theme standardization
/// Follows universal theme, responsive design, and ANR prevention
class SocialChallengesScreen extends StatefulWidget {
  final String userId;

  const SocialChallengesScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SocialChallengesScreen> createState() => _SocialChallengesScreenState();
}

class _SocialChallengesScreenState extends State<SocialChallengesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _headerAnimationController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: AppTheme.defaultCurve,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: AppTheme.defaultCurve,
    ));

    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            _buildSliverTabBar(),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildActiveChallenges(),
            _buildTrendingChallenges(),
            _buildMyParticipations(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.surfaceLight,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerAnimationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _headerSlideAnimation.value),
              child: Opacity(
                opacity: _headerFadeAnimation.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryPink.withValues(alpha: 0.1),
                        AppTheme.primaryBlue.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: ResponsiveUtils.padding(context),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryPink,
                                  AppTheme.primaryBlue
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.mediumShadow,
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              size: 40.w,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: AppTheme.mediumSpacing),
                          Text(
                            'Social Challenges',
                            style: BabyFont.displaySmall.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppTheme.smallSpacing),
                          Text(
                            'Join fun challenges, earn rewards, and connect with the community!',
                            style: BabyFont.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryPink,
          indicatorWeight: 3.h,
          labelColor: AppTheme.primaryPink,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: BabyFont.titleSmall.copyWith(
            fontWeight: BabyFont.semiBold,
          ),
          unselectedLabelStyle: BabyFont.titleSmall,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Trending'),
            Tab(text: 'My Challenges'),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChallenges() {
    return StreamBuilder<List<SocialChallenge>>(
      stream: SocialChallengesService.getActiveChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState('Failed to load challenges');
        }

        final challenges = snapshot.data ?? [];

        if (challenges.isEmpty) {
          return _buildEmptyState(
            'No Active Challenges',
            'Check back soon for exciting new challenges!',
            Icons.emoji_events_outlined,
          );
        }

        return _buildChallengesList(challenges);
      },
    );
  }

  Widget _buildTrendingChallenges() {
    return FutureBuilder<List<SocialChallenge>>(
      future: SocialChallengesService.getTrendingChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState('Failed to load trending challenges');
        }

        final challenges = snapshot.data ?? [];

        if (challenges.isEmpty) {
          return _buildEmptyState(
            'No Trending Challenges',
            'Be the first to start a trend!',
            Icons.trending_up_rounded,
          );
        }

        return _buildChallengesList(challenges);
      },
    );
  }

  Widget _buildMyParticipations() {
    return StreamBuilder<List<ChallengeParticipation>>(
      stream: SocialChallengesService.getUserParticipations(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState('Failed to load your participations');
        }

        final participations = snapshot.data ?? [];

        if (participations.isEmpty) {
          return _buildEmptyState(
            'No Participations Yet',
            'Join a challenge to see your submissions here!',
            Icons.person_outline_rounded,
          );
        }

        return _buildParticipationsList(participations);
      },
    );
  }

  Widget _buildChallengesList(List<SocialChallenge> challenges) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: ResponsiveUtils.padding(context),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return ChallengeCard(
          challenge: challenge,
          onTap: () => _showChallengeDetails(challenge),
          onParticipate: () => _participateInChallenge(challenge),
        );
      },
    );
  }

  Widget _buildParticipationsList(List<ChallengeParticipation> participations) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: ResponsiveUtils.padding(context),
      itemCount: participations.length,
      itemBuilder: (context, index) {
        final participation = participations[index];
        return _buildParticipationCard(participation);
      },
    );
  }

  Widget _buildParticipationCard(ChallengeParticipation participation) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.borderLight),
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
                  color: participation.isVerified
                      ? AppTheme.success.withValues(alpha: 0.1)
                      : AppTheme.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  participation.isVerified
                      ? Icons.verified_rounded
                      : Icons.pending_rounded,
                  color: participation.isVerified
                      ? AppTheme.success
                      : AppTheme.warning,
                  size: 20.w,
                ),
              ),
              SizedBox(width: AppTheme.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Challenge Participation',
                      style: BabyFont.titleMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Submitted ${_formatDate(participation.participatedAt)}',
                      style: BabyFont.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${participation.pointsEarned} pts',
                style: BabyFont.titleSmall.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: BabyFont.semiBold,
                ),
              ),
            ],
          ),
          if (participation.caption.isNotEmpty) ...[
            SizedBox(height: AppTheme.mediumSpacing),
            Text(
              participation.caption,
              style: BabyFont.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ],
          SizedBox(height: AppTheme.mediumSpacing),
          Row(
            children: [
              _buildStatChip(
                Icons.favorite_rounded,
                '${participation.likesCount}',
                AppTheme.error,
              ),
              SizedBox(width: AppTheme.smallSpacing),
              _buildStatChip(
                Icons.share_rounded,
                '${participation.sharesCount}',
                AppTheme.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: color),
          SizedBox(width: 4.w),
          Text(
            value,
            style: BabyFont.labelSmall.copyWith(
              color: color,
              fontWeight: BabyFont.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: LoadingAnimation(
        size: 60.w,
        color: AppTheme.primaryPink,
        text: 'Loading challenges...',
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.padding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60.w,
              color: AppTheme.error,
            ),
            SizedBox(height: AppTheme.mediumSpacing),
            Text(
              'Oops! Something went wrong',
              style: BabyFont.titleLarge.copyWith(
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.smallSpacing),
            Text(
              message,
              style: BabyFont.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.largeSpacing),
            ResponsiveButton(
              text: 'Try Again',
              icon: Icons.refresh_rounded,
              onPressed: () => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.padding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40.w,
                color: AppTheme.primaryPink,
              ),
            ),
            SizedBox(height: AppTheme.largeSpacing),
            Text(
              title,
              style: BabyFont.titleLarge.copyWith(
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.smallSpacing),
            Text(
              message,
              style: BabyFont.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showChallengeDetails(SocialChallenge challenge) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChallengeParticipationModal(
        challenge: challenge,
        userId: widget.userId,
        onParticipate: () => _participateInChallenge(challenge),
      ),
    );
  }

  void _participateInChallenge(SocialChallenge challenge) {
    HapticFeedback.lightImpact();

    // Show participation modal or navigate to participation screen
    ToastService.showBabyMessage(
      context,
      'Challenge participation coming soon! 🎉',
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Custom sliver tab bar delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.surfaceLight,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
