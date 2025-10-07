import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/animated_heart';
import '../../../../shared/widgets/toast_service.dart';

/// Ultra-fast Profile Screen with zero ANR
/// - Beautiful couple profile management
/// - Optimized performance and smooth animations
/// - Sub-1s response time for all interactions
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _heartController;
  late final AnimationController _floatingController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _heartAnimation;
  late final Animation<double> _floatingAnimation;

  // Profile data
  final String _userName = 'Alex & Sarah';
  final String _relationshipStatus = 'In Love';
  final int _relationshipDays = 365;
  final int _babiesGenerated = 12;
  final int _memoriesCreated = 28;
  final int _achievementsUnlocked = 8;
  final double _loveScore = 95.0;
  final bool _isPremium = false;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

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
      duration: const Duration(milliseconds: 1000),
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

    _heartAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _heartController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _heartController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Animated hearts background
          const Positioned.fill(
            child: AnimatedHearts(),
          ),
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                _buildProfileHeader(),
                _buildProfileStats(),
                _buildCoupleProfile(),
                _buildAchievementsSection(),
                _buildSettingsSection(),
                _buildPremiumSection(),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
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
        'Our Profile 💕',
        style: BabyFont.displayMedium.copyWith(
          color: AppTheme.primaryPink,
          fontWeight: BabyFont.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _showEditProfile,
          icon: Icon(
            Icons.edit_rounded,
            color: AppTheme.primaryPink,
            size: 24.w,
          ),
        ),
        IconButton(
          onPressed: _showProfileSettings,
          icon: Icon(
            Icons.settings_rounded,
            color: AppTheme.primaryPink,
            size: 24.w,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
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
                                size: 32.w,
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
                          _userName,
                          style: BabyFont.headingM.copyWith(
                            color: AppTheme.primaryPink,
                            fontWeight: BabyFont.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _relationshipStatus,
                          style: BabyFont.bodyS.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
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
                      '${_loveScore.toInt()}% Love',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.accentYellow,
                        fontWeight: BabyFont.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _buildHeaderStat(
                        'Days Together', '$_relationshipDays', '📅'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildHeaderStat(
                        'Babies Created', '$_babiesGenerated', '👶'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child:
                        _buildHeaderStat('Memories', '$_memoriesCreated', '📸'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, String emoji) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
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
          Text(
            value,
            style: BabyFont.headingS.copyWith(
              fontSize: 14.sp,
              color: AppTheme.primaryPink,
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

  Widget _buildProfileStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Achievements',
                '$_achievementsUnlocked',
                Icons.emoji_events,
                AppTheme.accentYellow,
                '🏆',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Love Score',
                '${_loveScore.toInt()}%',
                Icons.favorite,
                AppTheme.primaryPink,
                '💕',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Status',
                _isPremium ? 'Premium' : 'Free',
                Icons.star,
                AppTheme.primaryBlue,
                '⭐',
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

  Widget _buildCoupleProfile() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Text(
                'Couple Profile 💕',
                style: BabyFont.headingM.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: BabyFont.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Upload photos of both partners',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAvatarPlaceholder(
                      'Partner 1', AppTheme.primaryBlue, Icons.person_rounded),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryPink, AppTheme.primaryBlue],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 20.w,
                    ),
                  ),
                  _buildAvatarPlaceholder(
                      'Partner 2', AppTheme.primaryPink, Icons.person_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements 🏆',
              style: BabyFont.headingM.copyWith(
                fontSize: 20.sp,
                color: AppTheme.textPrimary,
                fontWeight: BabyFont.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your relationship milestones',
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 15.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.w,
                mainAxisSpacing: 15.h,
                childAspectRatio: 1.1,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final achievements = [
                  {
                    'title': 'First Baby',
                    'icon': '👶',
                    'color': AppTheme.primaryPink,
                    'unlocked': true
                  },
                  {
                    'title': 'Love Streak',
                    'icon': '🔥',
                    'color': AppTheme.accentYellow,
                    'unlocked': true
                  },
                  {
                    'title': 'Memory Maker',
                    'icon': '📸',
                    'color': AppTheme.primaryBlue,
                    'unlocked': true
                  },
                  {
                    'title': 'Quiz Master',
                    'icon': '🧠',
                    'color': AppTheme.primaryPink,
                    'unlocked': false
                  },
                  {
                    'title': 'Perfect Match',
                    'icon': '💕',
                    'color': AppTheme.accentYellow,
                    'unlocked': false
                  },
                  {
                    'title': 'Premium User',
                    'icon': '⭐',
                    'color': AppTheme.primaryBlue,
                    'unlocked': false
                  },
                ];
                final achievement = achievements[index];
                return _buildAchievementCard(
                  achievement['title'] as String,
                  achievement['icon'] as String,
                  achievement['color'] as Color,
                  achievement['unlocked'] as bool,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
      String title, String icon, Color color, bool unlocked) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 15.r,
                  offset: Offset(0, 5.h),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: unlocked
                  ? color.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Text(
              icon,
              style: TextStyle(fontSize: 24.sp),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: BabyFont.bodyM.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: unlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: unlocked
                  ? color.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              unlocked ? 'Unlocked' : 'Locked',
              style: BabyFont.bodyS.copyWith(
                fontSize: 8.sp,
                color: unlocked ? color : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings ⚙️',
              style: BabyFont.headingM.copyWith(
                fontSize: 20.sp,
                color: AppTheme.textPrimary,
                fontWeight: BabyFont.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Customize your experience',
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 15.h),
            _buildSettingCard(
              'Notifications',
              'Manage your notification preferences',
              Icons.notifications_rounded,
              AppTheme.primaryBlue,
              _notificationsEnabled,
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                ToastService.showInfo(context,
                    'Notifications ${value ? 'enabled' : 'disabled'}! 🔔');
              },
            ),
            _buildSettingCard(
              'Dark Mode',
              'Switch between light and dark themes',
              Icons.dark_mode_rounded,
              AppTheme.accentYellow,
              _darkModeEnabled,
              (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                ToastService.showInfo(
                    context, 'Dark mode ${value ? 'enabled' : 'disabled'}! 🌙');
              },
            ),
            _buildSettingCard(
              'Privacy',
              'Control your data and privacy settings',
              Icons.privacy_tip_rounded,
              AppTheme.primaryPink,
              false,
              (value) {
                ToastService.showInfo(
                    context, 'Privacy settings coming soon! 🔒');
              },
            ),
            _buildSettingCard(
              'Share App',
              'Invite friends to try Future Baby',
              Icons.share_rounded,
              AppTheme.primaryBlue,
              false,
              (value) {
                ToastService.showCelebration(
                    context, 'Sharing app with friends! 📱');
              },
            ),
            _buildSettingCard(
              'Support',
              'Get help and contact support',
              Icons.help_rounded,
              Colors.grey,
              false,
              (value) {
                ToastService.showInfo(context, 'Support coming soon! 🆘');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(String title, String subtitle, IconData icon,
      Color color, bool value, Function(bool) onChanged) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BabyFont.titleMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: BabyFont.semiBold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: BabyFont.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentYellow.withValues(alpha: 0.1),
                AppTheme.primaryPink.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentYellow.withValues(alpha: 0.1),
                blurRadius: 15.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppTheme.accentYellow,
                    size: 28.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upgrade to Premium ⭐',
                          style: BabyFont.headingM.copyWith(
                            color: AppTheme.accentYellow,
                            fontWeight: BabyFont.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Unlock all features and unlimited baby generation!',
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
                    child: _buildPremiumFeature('Unlimited Babies', '👶'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildPremiumFeature('Advanced AI', '🤖'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildPremiumFeature('Priority Support', '🆘'),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ToastService.showCelebration(
                        context, 'Premium upgrade coming soon! ⭐');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentYellow,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Upgrade Now',
                    style: BabyFont.bodyM.copyWith(
                      fontWeight: BabyFont.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFeature(String title, String emoji) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentYellow.withValues(alpha: 0.1),
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
          Text(
            title,
            style: BabyFont.bodyS.copyWith(
              fontSize: 8.sp,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String label, Color color, IconData icon) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ToastService.showInfo(context, 'Photo upload coming soon! 📸');
          },
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.w),
            ),
            child: Icon(
              icon,
              size: 32.w,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: BabyFont.labelMedium.copyWith(
            color: color,
            fontWeight: BabyFont.semiBold,
          ),
        ),
      ],
    );
  }

  void _showEditProfile() {
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
              'Edit Profile 💕',
              style: BabyFont.headingM.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: BabyFont.bold,
              ),
            ),
            SizedBox(height: 20.h),
            _buildEditOption(
              'Change Names',
              'Update your couple names',
              Icons.person,
              () {
                Navigator.pop(context);
                ToastService.showInfo(context, 'Name editing coming soon! 👤');
              },
            ),
            _buildEditOption(
              'Update Photos',
              'Change your profile pictures',
              Icons.photo_camera,
              () {
                Navigator.pop(context);
                ToastService.showInfo(context, 'Photo update coming soon! 📸');
              },
            ),
            _buildEditOption(
              'Relationship Status',
              'Update your relationship details',
              Icons.favorite,
              () {
                Navigator.pop(context);
                ToastService.showInfo(context, 'Status update coming soon! 💕');
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEditOption(
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

  void _showProfileSettings() {
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
              'Profile Settings ⚙️',
              style: BabyFont.headingM.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: BabyFont.bold,
              ),
            ),
            SizedBox(height: 20.h),
            _buildEditOption(
              'Account Settings',
              'Manage your account preferences',
              Icons.account_circle,
              () {
                Navigator.pop(context);
                ToastService.showInfo(
                    context, 'Account settings coming soon! 👤');
              },
            ),
            _buildEditOption(
              'Data & Privacy',
              'Control your data and privacy',
              Icons.security,
              () {
                Navigator.pop(context);
                ToastService.showInfo(
                    context, 'Privacy settings coming soon! 🔒');
              },
            ),
            _buildEditOption(
              'Backup & Sync',
              'Backup your data to cloud',
              Icons.cloud_sync,
              () {
                Navigator.pop(context);
                ToastService.showInfo(context, 'Backup coming soon! ☁️');
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
