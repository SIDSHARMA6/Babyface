import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/animated_heart';
import '../../../../shared/widgets/toast_service.dart';

/// Couple Goals Screen with relationship features
class CoupleGoalsScreen extends ConsumerStatefulWidget {
  const CoupleGoalsScreen({super.key});

  @override
  ConsumerState<CoupleGoalsScreen> createState() => _CoupleGoalsScreenState();
}

class _CoupleGoalsScreenState extends ConsumerState<CoupleGoalsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _heartController;
  late final AnimationController _progressController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();
    _heartController.repeat();
    _progressController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _heartController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Animated hearts background
          const Positioned.fill(
            child: AnimatedHearts(),
          ),
          // Main content
          RefreshIndicator(
            onRefresh: () async {
              // Refresh logic here
            },
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildRelationshipOverview(),
                  _buildLovePercentageCard(),
                  _buildInsightsSection(),
                  _buildAchievementsSection(),
                  _buildStatsSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
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
      actions: [
        IconButton(
          onPressed: _showRelationshipSettings,
          icon: Icon(
            Icons.settings,
            color: AppTheme.primaryPink,
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipOverview() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16.w),
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
            Text(
              'Welcome Back! 👋',
              style: BabyFont.headingL.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: BabyFont.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Ready to explore your relationship journey?',
              style: BabyFont.bodyL.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLovePercentageCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPink.withValues(alpha: 0.8),
              AppTheme.primaryBlue.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: AppTheme.mediumShadow,
        ),
        child: Column(
          children: [
            Text(
              'Your Compatibility',
              style: BabyFont.headingM.copyWith(
                color: Colors.white,
                fontWeight: BabyFont.bold,
              ),
            ),
            SizedBox(height: 24.h),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final animatedPercentage = 85.0 * _progressAnimation.value;
                return Column(
                  children: [
                    Text(
                      '${animatedPercentage.toInt()}%',
                      style: BabyFont.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: BabyFont.extraBold,
                        fontSize: 48.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: 200.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16.h),
            Text(
              _getLoveMessage(85.0),
              style: BabyFont.bodyL.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16.w),
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
              'Relationship Insights',
              style: BabyFont.headingS.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: BabyFont.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ..._getSampleInsights()
                .map((insight) => _buildInsightCard(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(CoupleInsight insight) {
    final trendColor = insight.trend == 'up'
        ? AppTheme.success
        : insight.trend == 'down'
            ? AppTheme.error
            : AppTheme.textSecondary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: trendColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: BabyFont.bodyM.copyWith(
                    fontWeight: BabyFont.semiBold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  insight.description,
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${insight.value}%',
                style: BabyFont.headingS.copyWith(
                  color: trendColor,
                  fontWeight: BabyFont.bold,
                ),
              ),
              Icon(
                insight.trend == 'up'
                    ? Icons.trending_up
                    : insight.trend == 'down'
                        ? Icons.trending_down
                        : Icons.trending_flat,
                color: trendColor,
                size: 16.w,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements',
                  style: BabyFont.headingS.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: BabyFont.bold,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '5/10',
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
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildAchievementCard(_getSampleAchievements()[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? AppTheme.primaryPink.withValues(alpha: 0.1)
            : AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: achievement.isUnlocked
              ? AppTheme.primaryPink.withValues(alpha: 0.3)
              : AppTheme.borderLight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(
              fontSize: 32.sp,
              color: achievement.isUnlocked
                  ? AppTheme.primaryPink
                  : AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            achievement.title,
            style: BabyFont.bodyS.copyWith(
              fontWeight: BabyFont.semiBold,
              color: achievement.isUnlocked
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16.w),
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
              'Your Stats',
              style: BabyFont.headingS.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: BabyFont.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('🔥', '7', 'Day Streak'),
                ),
                Expanded(
                  child: _buildStatItem('🎯', '15', 'Quizzes'),
                ),
                Expanded(
                  child: _buildStatItem('👶', '3', 'Babies'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 24.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        Text(
          label,
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
              'Manage your notification preferences',
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
      leading: Icon(icon, color: AppTheme.primaryPink),
      title: Text(
        title,
        style: BabyFont.bodyLarge.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: BabyFont.medium,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: BabyFont.bodySmall.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
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

  List<CoupleInsight> _getSampleInsights() {
    return [
      CoupleInsight(
        title: 'Communication',
        value: 85,
        trend: 'up',
        description: 'Great communication patterns',
      ),
      CoupleInsight(
        title: 'Compatibility',
        value: 92,
        trend: 'up',
        description: 'Excellent compatibility score',
      ),
      CoupleInsight(
        title: 'Shared Interests',
        value: 78,
        trend: 'stable',
        description: 'Good shared interests',
      ),
    ];
  }

  List<Achievement> _getSampleAchievements() {
    return List.generate(
        10,
        (index) => Achievement(
              id: 'achievement_$index',
              title: 'Achievement ${index + 1}',
              description: 'Description for achievement ${index + 1}',
              icon: '🏆',
              isUnlocked: index < 5,
              unlockedAt: index < 5
                  ? DateTime.now().subtract(Duration(days: index))
                  : null,
            ));
  }
}

// Sample data classes
class CoupleInsight {
  final String title;
  final int value;
  final String trend;
  final String description;

  CoupleInsight({
    required this.title,
    required this.value,
    required this.trend,
    required this.description,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAt,
  });
}
