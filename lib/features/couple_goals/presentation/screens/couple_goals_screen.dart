import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/animated_heart';
import '../../../../shared/widgets/toast_service.dart';
import '../providers/couple_goals_provider.dart';

/// Comprehensive Couples Screen with all relationship features
/// Following master plan requirements with emotional connections
/// - Love percentage and relationship insights
/// - Achievement system and milestones
/// - Couple challenges and goals
/// - Memory journal and anniversary tracker
/// - Optimized performance and smooth animations
class CoupleGoalsScreen extends StatefulWidget {
  const CoupleGoalsScreen({super.key});

  @override
  State<CoupleGoalsScreen> createState() => _CoupleGoalsScreenState();
}

class _CoupleGoalsScreenState extends State<CoupleGoalsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _heartController;
  late final AnimationController _progressController;
  late final AnimationController _floatingController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _heartAnimation;
  late final Animation<double> _progressAnimation;
  late final Animation<double> _floatingAnimation;

  // Couple data
  final int _relationshipDays = 365;
  final int _anniversaries = 3;
  final int _memoriesCreated = 12;
  final int _challengesCompleted = 8;
  final double _loveScore = 92.5;
  final String _relationshipStatus = 'Soulmates';

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _heartAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _heartController.repeat(reverse: true);
    _progressController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _heartController.dispose();
    _progressController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoupleGoalsProvider(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // Animated hearts background
            const Positioned.fill(
              child: AnimatedHearts(),
            ),
            // Main content
            Consumer<CoupleGoalsProvider>(
              builder: (context, provider, child) {
                return RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildRelationshipOverview(),
                        _buildLovePercentageCard(provider),
                        _buildRelationshipStats(),
                        _buildCoupleFeatures(),
                        _buildInsightsSection(provider),
                        _buildAchievementsSection(provider),
                        _buildStatsSection(provider),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Our Love Story 💕',
        style: BabyFont.displayMedium.copyWith(
          color: AppTheme.primaryPink,
          fontWeight: BabyFont.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _showRelationshipSettings,
          icon: Icon(
            Icons.settings_rounded,
            color: AppTheme.primaryPink,
            size: 24.w,
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipOverview() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPink.withValues(alpha: 0.1),
                AppTheme.primaryBlue.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                blurRadius: 15.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatingAnimation.value * 5.h),
                        child: AnimatedBuilder(
                          animation: _heartAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _heartAnimation.value,
                              child: Icon(
                                Icons.favorite_rounded,
                                color: AppTheme.primaryPink,
                                size: 28.w,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Relationship Journey 💖',
                          style: BabyFont.headingM.copyWith(
                            color: AppTheme.primaryPink,
                            fontWeight: BabyFont.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Building beautiful memories together',
                          style: BabyFont.bodyS.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      'Days Together',
                      '$_relationshipDays',
                      Icons.calendar_today,
                      AppTheme.primaryPink,
                      '📅',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildOverviewCard(
                      'Anniversaries',
                      '$_anniversaries',
                      Icons.celebration,
                      AppTheme.primaryBlue,
                      '🎉',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildOverviewCard(
                      'Love Score',
                      '${_loveScore.toInt()}%',
                      Icons.favorite,
                      AppTheme.accentYellow,
                      '💕',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
      String label, String value, IconData icon, Color color, String emoji) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 4.h),
          Icon(icon, color: color, size: 14.w),
          SizedBox(height: 6.h),
          Text(
            value,
            style: BabyFont.headingS.copyWith(
              fontSize: 14.sp,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: BabyFont.bodyS.copyWith(
              fontSize: 8.sp,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Memories',
                '$_memoriesCreated',
                Icons.photo_library,
                AppTheme.primaryPink,
                '📸',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Challenges',
                '$_challengesCompleted',
                Icons.fitness_center,
                AppTheme.primaryBlue,
                '💪',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Status',
                _relationshipStatus,
                Icons.favorite,
                AppTheme.accentYellow,
                '💖',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, String emoji) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(height: 4.h),
          Icon(icon, color: color, size: 16.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: BabyFont.headingM.copyWith(
              fontSize: 16.sp,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: BabyFont.bodyS.copyWith(
              fontSize: 10.sp,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCoupleFeatures() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Couple Features 💕',
              style: BabyFont.headingM.copyWith(
                fontSize: 20.sp,
                color: AppTheme.textPrimary,
                fontWeight: BabyFont.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Strengthen your bond with these amazing features',
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 15.h),
            _buildFeatureGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {
        'title': 'Memory Journal',
        'icon': Icons.book,
        'color': AppTheme.primaryPink,
        'emoji': '📖',
        'action': () =>
            ToastService.showLove(context, 'Opening Memory Journal! 📖'),
      },
      {
        'title': 'Anniversary Tracker',
        'icon': Icons.calendar_today,
        'color': AppTheme.primaryBlue,
        'emoji': '💍',
        'action': () =>
            ToastService.showCelebration(context, 'Anniversary Tracker! 💍'),
      },
      {
        'title': 'Couple Challenges',
        'icon': Icons.fitness_center,
        'color': AppTheme.accentYellow,
        'emoji': '💪',
        'action': () =>
            ToastService.showBabyMessage(context, 'Couple Challenges! 💪'),
      },
      {
        'title': 'Love Language Quiz',
        'icon': Icons.psychology,
        'color': AppTheme.primaryPink,
        'emoji': '💝',
        'action': () =>
            ToastService.showLove(context, 'Love Language Quiz! 💝'),
      },
      {
        'title': 'Future Planning',
        'icon': Icons.rocket_launch,
        'color': AppTheme.primaryBlue,
        'emoji': '🚀',
        'action': () => ToastService.showInfo(context, 'Future Planning! 🚀'),
      },
      {
        'title': 'Bucket List',
        'icon': Icons.checklist,
        'color': AppTheme.accentYellow,
        'emoji': '✅',
        'action': () => ToastService.showCelebration(context, 'Bucket List! ✅'),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          feature['title'] as String,
          feature['icon'] as IconData,
          feature['color'] as Color,
          feature['emoji'] as String,
          feature['action'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color,
      String emoji, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 15.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Column(
                children: [
                  Text(
                    emoji,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  SizedBox(height: 4.h),
                  Icon(
                    icon,
                    color: color,
                    size: 20.w,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: BabyFont.bodyM.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLovePercentageCard(CoupleGoalsProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.primaryBlue.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartAnimation.value,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.primaryPink,
                      size: 32.w,
                    ),
                  );
                },
              ),
              SizedBox(width: 12.w),
              Text(
                'Love Compatibility',
                style: BabyFont.headlineMedium.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: BabyFont.bold,
                ),
              ),
              SizedBox(width: 12.w),
              AnimatedBuilder(
                animation: _heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartAnimation.value,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.primaryPink,
                      size: 32.w,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 24.h),
          if (provider.isLoading)
            CircularProgressIndicator(
              color: AppTheme.primaryPink,
              strokeWidth: 3.w,
            )
          else
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final animatedPercentage =
                    provider.lovePercentage * _progressAnimation.value;
                return Column(
                  children: [
                    Text(
                      '${animatedPercentage.toInt()}%',
                      style: BabyFont.displayLarge.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: BabyFont.extraBold,
                        fontSize: 48.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: 200.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPink.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: animatedPercentage / 100,
                          backgroundColor: Colors.transparent,
                          valueColor:
                              AlwaysStoppedAnimation(AppTheme.primaryPink),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          SizedBox(height: 16.h),
          Text(
            _getLoveMessage(provider.lovePercentage),
            style: BabyFont.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(CoupleGoalsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relationship Insights',
          style: BabyFont.headlineSmall.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: BabyFont.bold,
          ),
        ),
        SizedBox(height: 16.h),
        ...provider.insights.map((insight) => _buildInsightCard(insight)),
      ],
    );
  }

  Widget _buildInsightCard(CoupleInsight insight) {
    final trendColor = insight.trend == 'up'
        ? AppTheme.success
        : insight.trend == 'down'
            ? AppTheme.error
            : AppTheme.textSecondary;

    final trendIcon = insight.trend == 'up'
        ? Icons.trending_up_rounded
        : insight.trend == 'down'
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
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
                SizedBox(height: 4.h),
                Text(
                  insight.description,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${insight.value.toInt()}%',
                    style: BabyFont.titleLarge.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: BabyFont.bold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    trendIcon,
                    color: trendColor,
                    size: 20.w,
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Container(
                width: 60.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.r),
                  child: LinearProgressIndicator(
                    value: insight.value / 100,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(CoupleGoalsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: BabyFont.headlineSmall.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: BabyFont.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.accentYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${provider.unlockedAchievements.length}/${provider.achievements.length}',
                style: BabyFont.labelMedium.copyWith(
                  color: AppTheme.accentYellow,
                  fontWeight: BabyFont.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.2,
          ),
          itemCount: provider.achievements.length,
          itemBuilder: (context, index) {
            return _buildAchievementCard(provider.achievements[index]);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? Colors.white
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: achievement.isUnlocked
              ? AppTheme.accentYellow.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: achievement.isUnlocked ? AppTheme.softShadow : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(fontSize: 32.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            achievement.title,
            style: BabyFont.titleSmall.copyWith(
              color: achievement.isUnlocked
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary,
              fontWeight: BabyFont.semiBold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Flexible(
            child: Text(
              achievement.description,
              style: BabyFont.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(CoupleGoalsProvider provider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Journey Together',
            style: BabyFont.headlineSmall.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: BabyFont.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                  child: _buildStatItem(
                      '🔥', '${provider.streakDays}', 'Day Streak')),
              Expanded(
                  child: _buildStatItem(
                      '🎯', '${provider.totalQuizzesTaken}', 'Quizzes')),
              Expanded(
                  child: _buildStatItem(
                      '👶', '${provider.babiesGenerated}', 'Babies')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 24.sp)),
        SizedBox(height: 8.h),
        Text(
          value,
          style: BabyFont.headlineSmall.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: BabyFont.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getLoveMessage(double percentage) {
    if (percentage >= 90) return "You're absolutely perfect together! 💕";
    if (percentage >= 80) return "Amazing compatibility! You're soulmates! ✨";
    if (percentage >= 70) {
      return "Great match! You complement each other well! 💖";
    }
    if (percentage >= 60) {
      return "Good compatibility! Keep growing together! 💝";
    }
    if (percentage >= 50) return "Nice connection! There's potential here! 💗";
    return "Every relationship is a journey. Keep exploring! 💙";
  }

  void _showRelationshipSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Relationship Settings 💕',
              style: BabyFont.headingM.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: BabyFont.bold,
              ),
            ),
            SizedBox(height: 20.h),
            _buildSettingOption(
              'Edit Profile',
              'Update your relationship details',
              Icons.person,
              () {
                Navigator.pop(context);
                ToastService.showInfo(
                    context, 'Profile editing coming soon! 👤');
              },
            ),
            _buildSettingOption(
              'Privacy Settings',
              'Control your relationship visibility',
              Icons.privacy_tip,
              () {
                Navigator.pop(context);
                ToastService.showInfo(
                    context, 'Privacy settings coming soon! 🔒');
              },
            ),
            _buildSettingOption(
              'Notifications',
              'Manage your relationship reminders',
              Icons.notifications,
              () {
                Navigator.pop(context);
                ToastService.showInfo(
                    context, 'Notification settings coming soon! 🔔');
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppTheme.primaryPink.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppTheme.primaryPink, size: 20.w),
      ),
      title: Text(
        title,
        style: BabyFont.bodyM.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: BabyFont.bodyS.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppTheme.textSecondary,
        size: 16.w,
      ),
      onTap: onTap,
    );
  }
}
