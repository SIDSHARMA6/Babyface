import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/loading_animation.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../domain/models/social_challenge.dart';
import '../../data/social_challenges_service.dart';

/// Social feed widget displaying community content
/// Follows theme standardization and ANR prevention
class SocialFeedWidget extends StatefulWidget {
  final String userId;
  final String? challengeId;
  final bool showOnlyUserContent;

  const SocialFeedWidget({
    super.key,
    required this.userId,
    this.challengeId,
    this.showOnlyUserContent = false,
  });

  @override
  State<SocialFeedWidget> createState() => _SocialFeedWidgetState();
}

class _SocialFeedWidgetState extends State<SocialFeedWidget>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  List<ChallengeParticipation> _participations = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadParticipations();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreParticipations();
      }
    }
  }

  Future<void> _loadParticipations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentPage = 0;
    });

    try {
      // In a real implementation, this would be a paginated Firebase query
      final participations = await _fetchParticipations(0, _pageSize);

      if (mounted) {
        setState(() {
          _participations = participations;
          _hasMore = participations.length == _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ToastService.showError(context, 'Failed to load feed');
      }
    }
  }

  Future<void> _loadMoreParticipations() async {
    if (!mounted || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newParticipations = await _fetchParticipations(
        _currentPage + 1,
        _pageSize,
      );

      if (mounted) {
        setState(() {
          _participations.addAll(newParticipations);
          _currentPage++;
          _hasMore = newParticipations.length == _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<ChallengeParticipation>> _fetchParticipations(
    int page,
    int pageSize,
  ) async {
    // Simulate API call with delay to prevent ANR
    await Future.delayed(const Duration(milliseconds: 500));

    // In real implementation, this would fetch from Firebase
    // For now, return sample data
    return List.generate(pageSize, (index) {
      final participationIndex = (page * pageSize) + index;
      return ChallengeParticipation(
        id: 'participation_$participationIndex',
        challengeId: widget.challengeId ?? 'sample_challenge',
        userId: 'user_$participationIndex',
        participatedAt:
            DateTime.now().subtract(Duration(hours: participationIndex)),
        submissionUrl: 'https://example.com/image_$participationIndex.jpg',
        caption: _getSampleCaption(participationIndex),
        likesCount: (participationIndex * 3) % 50,
        sharesCount: (participationIndex * 2) % 20,
        isVerified: participationIndex % 3 == 0,
        pointsEarned: 10 + (participationIndex % 5) * 5,
        metadata: {'sampleData': true},
      );
    });
  }

  String _getSampleCaption(int index) {
    final captions = [
      'So excited to share our future baby prediction! 👶✨',
      'This challenge was so much fun! Can\'t wait for more! 🎉',
      'Amazing results from the baby face generator! 💕',
      'Loving this community and all the cute predictions! 🌟',
      'Our future little one looks adorable! 😍',
    ];
    return captions[index % captions.length];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading && _participations.isEmpty) {
      return _buildLoadingState();
    }

    if (_participations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadParticipations,
      color: AppTheme.primaryPink,
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: ResponsiveUtils.padding(context),
        itemCount: _participations.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _participations.length) {
            return _buildLoadingIndicator();
          }

          final participation = _participations[index];
          return _buildParticipationCard(participation, index);
        },
      ),
    );
  }

  Widget _buildParticipationCard(
      ChallengeParticipation participation, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParticipationHeader(participation),
          _buildParticipationContent(participation),
          _buildParticipationActions(participation),
        ],
      ),
    );
  }

  Widget _buildParticipationHeader(ChallengeParticipation participation) {
    return Padding(
      padding: AppTheme.cardPadding(context),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryPink, AppTheme.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 20.w,
            ),
          ),
          SizedBox(width: AppTheme.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'User ${participation.userId.split('_').last}',
                      style: BabyFont.titleSmall.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: BabyFont.semiBold,
                      ),
                    ),
                    if (participation.isVerified) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.verified_rounded,
                        size: 16.w,
                        color: AppTheme.success,
                      ),
                    ],
                  ],
                ),
                Text(
                  _formatTimeAgo(participation.participatedAt),
                  style: BabyFont.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            ),
            child: Text(
              '+${participation.pointsEarned} pts',
              style: BabyFont.labelSmall.copyWith(
                color: AppTheme.accentYellow,
                fontWeight: BabyFont.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipationContent(ChallengeParticipation participation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (participation.caption.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.mediumSpacing),
            child: Text(
              participation.caption,
              style: BabyFont.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(height: AppTheme.smallSpacing),
        ],
        if (participation.submissionUrl.isNotEmpty)
          Container(
            width: double.infinity,
            height: 200.h,
            margin: EdgeInsets.symmetric(horizontal: AppTheme.mediumSpacing),
            decoration: BoxDecoration(
              color: AppTheme.borderLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.child_care_rounded,
                        size: 40.w,
                        color: AppTheme.primaryPink,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Baby Prediction',
                        style: BabyFont.titleSmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildParticipationActions(ChallengeParticipation participation) {
    return Container(
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.borderLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.largeRadius),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            Icons.favorite_rounded,
            '${participation.likesCount}',
            AppTheme.error,
            () => _likeParticipation(participation),
          ),
          SizedBox(width: AppTheme.largeSpacing),
          _buildActionButton(
            Icons.share_rounded,
            '${participation.sharesCount}',
            AppTheme.primaryBlue,
            () => _shareParticipation(participation),
          ),
          const Spacer(),
          Text(
            '${participation.pointsEarned} points earned',
            style: BabyFont.labelSmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String count,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.w, color: color),
          SizedBox(width: 4.w),
          Text(
            count,
            style: BabyFont.labelMedium.copyWith(
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
        text: 'Loading community feed...',
      ),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.people_outline_rounded,
                size: 40.w,
                color: AppTheme.primaryPink,
              ),
            ),
            SizedBox(height: AppTheme.largeSpacing),
            Text(
              'No Community Posts Yet',
              style: BabyFont.titleLarge.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.smallSpacing),
            Text(
              'Be the first to share your baby prediction and start the conversation!',
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

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(AppTheme.mediumSpacing),
      child: Center(
        child: LoadingAnimation(
          size: 30.w,
          color: AppTheme.primaryPink,
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  Future<void> _likeParticipation(ChallengeParticipation participation) async {
    try {
      HapticFeedback.lightImpact();

      await SocialChallengesService.likeParticipation(participation.id);

      // Update local state
      setState(() {
        final index =
            _participations.indexWhere((p) => p.id == participation.id);
        if (index != -1) {
          _participations[index] = ChallengeParticipation(
            id: participation.id,
            challengeId: participation.challengeId,
            userId: participation.userId,
            participatedAt: participation.participatedAt,
            submissionUrl: participation.submissionUrl,
            caption: participation.caption,
            likesCount: participation.likesCount + 1,
            sharesCount: participation.sharesCount,
            isVerified: participation.isVerified,
            pointsEarned: participation.pointsEarned,
            metadata: participation.metadata,
          );
        }
      });

      if (mounted) {
        ToastService.showLove(context, 'Liked! 💕');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Failed to like post');
      }
    }
  }

  Future<void> _shareParticipation(ChallengeParticipation participation) async {
    try {
      HapticFeedback.lightImpact();

      await SocialChallengesService.shareParticipation(participation.id);

      // Update local state
      setState(() {
        final index =
            _participations.indexWhere((p) => p.id == participation.id);
        if (index != -1) {
          _participations[index] = ChallengeParticipation(
            id: participation.id,
            challengeId: participation.challengeId,
            userId: participation.userId,
            participatedAt: participation.participatedAt,
            submissionUrl: participation.submissionUrl,
            caption: participation.caption,
            likesCount: participation.likesCount,
            sharesCount: participation.sharesCount + 1,
            isVerified: participation.isVerified,
            pointsEarned: participation.pointsEarned,
            metadata: participation.metadata,
          );
        }
      });

      if (mounted) {
        ToastService.showSuccess(context, 'Shared! 🎉');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Failed to share post');
      }
    }
  }
}
