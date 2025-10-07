import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';

/// Leaderboard section widget showing top quiz performers
/// with rankings, scores, and achievements
class LeaderboardSection extends StatefulWidget {
  const LeaderboardSection({super.key});

  @override
  State<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<LeaderboardSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _itemAnimations;

  final List<LeaderboardEntry> _leaderboardData = [
    LeaderboardEntry(
      rank: 1,
      name: 'Quiz Master',
      score: 2850,
      completedQuizzes: 8,
      avatar: '👑',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 2,
      name: 'Baby Expert',
      score: 2340,
      completedQuizzes: 7,
      avatar: '🌟',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 3,
      name: 'Future Parent',
      score: 1890,
      completedQuizzes: 6,
      avatar: '🎯',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 999,
      name: 'You',
      score: 0,
      completedQuizzes: 0,
      avatar: '👤',
      isCurrentUser: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _itemAnimations = List.generate(
      _leaderboardData.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          0.6 + (index * 0.1),
          curve: Curves.easeOutBack,
        ),
      )),
    );

    // Start animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        SizedBox(height: AppTheme.mediumSpacing),
        _buildLeaderboardCard(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(
          Icons.emoji_events_rounded,
          color: AppTheme.accentYellow,
          size: 24.w,
        ),
        SizedBox(width: AppTheme.smallSpacing),
        Text(
          'Quiz Leaderboard',
          style: BabyFont.headlineSmall.copyWith(color: AppTheme.textPrimary),
        ),
        const Spacer(),
        TextButton(
          onPressed: _showFullLeaderboard,
          child: Text(
            'View All',
            style: BabyFont.labelMedium.copyWith(color: AppTheme.primaryPink),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard() {
    return Container(
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentYellow.withValues(alpha: 0.05),
            AppTheme.primaryPink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(
          color: AppTheme.accentYellow.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          _buildLeaderboardHeader(),
          SizedBox(height: AppTheme.mediumSpacing),
          ..._leaderboardData.asMap().entries.map((entry) {
            final index = entry.key;
            final leaderboardEntry = entry.value;
            return AnimatedBuilder(
              animation: _itemAnimations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    50 * (1 - _itemAnimations[index].value),
                    0,
                  ),
                  child: Opacity(
                    opacity: _itemAnimations[index].value.clamp(0.0, 1.0),
                    child: _buildLeaderboardItem(leaderboardEntry),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardHeader() {
    return Row(
      children: [
        Text(
          'Top Quiz Masters',
          style: BabyFont.titleLarge.copyWith(color: AppTheme.textPrimary),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.smallRadius),
          ),
          child: Text(
            'Weekly',
            style: BabyFont.labelSmall.copyWith(
              color: AppTheme.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.smallSpacing),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppTheme.primaryPink.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(
          color: entry.isCurrentUser
              ? AppTheme.primaryPink.withValues(alpha: 0.3)
              : AppTheme.borderLight,
          width: entry.isCurrentUser ? 2.w : 1.w,
        ),
        boxShadow: entry.rank <= 3
            ? [
                BoxShadow(
                  color: _getRankColor(entry.rank).withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          _buildRankBadge(entry.rank),
          SizedBox(width: AppTheme.mediumSpacing),
          _buildAvatar(entry.avatar, entry.rank),
          SizedBox(width: AppTheme.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.name,
                      style: BabyFont.titleSmall.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: entry.isCurrentUser
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.person,
                        size: 16.w,
                        color: AppTheme.primaryPink,
                      ),
                    ],
                  ],
                ),
                Text(
                  '${entry.completedQuizzes} quizzes completed',
                  style: BabyFont.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.score}',
                style: BabyFont.titleMedium.copyWith(
                  color: _getRankColor(entry.rank),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'points',
                style: BabyFont.labelSmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color rankColor = _getRankColor(rank);
    String rankText = rank <= 999 ? '#$rank' : '#999+';

    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: rankColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: rankColor.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          rank <= 3 ? '$rank' : rankText.substring(1),
          style: BabyFont.labelSmall.copyWith(
            color: rankColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String emoji, int rank) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: _getRankColor(rank).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppTheme.accentYellow; // Gold
      case 2:
        return Colors.grey[600]!; // Silver
      case 3:
        return Colors.brown[400]!; // Bronze
      default:
        return AppTheme.textSecondary;
    }
  }

  void _showFullLeaderboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.largeRadius),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
            Padding(
              padding: AppTheme.cardPadding(context),
              child: Row(
                children: [
                  Text(
                    'Full Leaderboard',
                    style: BabyFont.headlineSmall.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: AppTheme.cardPadding(context),
                itemCount: 20, // Show more entries
                itemBuilder: (context, index) {
                  // Generate mock data for demonstration
                  final entry = LeaderboardEntry(
                    rank: index + 1,
                    name: index == 19 ? 'You' : 'Player ${index + 1}',
                    score: 3000 - (index * 150),
                    completedQuizzes: 8 - (index ~/ 3),
                    avatar: index == 19
                        ? '👤'
                        : ['🌟', '🎯', '🚀', '💎', '🔥'][index % 5],
                    isCurrentUser: index == 19,
                  );
                  return _buildLeaderboardItem(entry);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Leaderboard entry model
class LeaderboardEntry {
  final int rank;
  final String name;
  final int score;
  final int completedQuizzes;
  final String avatar;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.completedQuizzes,
    required this.avatar,
    this.isCurrentUser = false,
  });
}
