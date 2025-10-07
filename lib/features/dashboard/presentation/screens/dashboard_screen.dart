import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../../../shared/widgets/animated_heart';
import '../../../engagement_features/presentation/screens/real_baby_name_generator_screen.dart';
import '../../../engagement_features/presentation/screens/real_growth_memory_timeline_screen.dart';
import '../../../engagement_features/presentation/screens/real_couple_challenges_bucket_list_screen.dart';
import '../../../engagement_features/presentation/screens/real_anniversary_event_tracker_screen.dart';
import '../../../engagement_features/presentation/screens/simple_love_language_quiz_screen.dart';
import '../../../engagement_features/presentation/screens/simple_future_planning_screen.dart';
import '../../../engagement_features/presentation/screens/simple_couple_bucket_list_screen.dart';
import '../../../premium_features/presentation/screens/premium_screen.dart';
import '../../../baby_generation/presentation/screens/ai_baby_result_screen.dart';
import '../../../../shared/services/ai_baby_generation_service.dart';
import 'dart:io';

/// Perfect Dashboard Screen with all features integrated
/// Following master plan requirements with emotional connections
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _heartController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  // Dashboard data
  final int _babiesGenerated = 12;
  final int _memoriesCreated = 8;
  final int _goalsCompleted = 5;
  final int _loveStreak = 7;
  final double _lovePercentage = 87.5;

  // Photo upload states
  File? _malePhoto;
  File? _femalePhoto;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _heartAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _heartController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heartController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Stack(
        children: [
          // Animated hearts background
          const Positioned.fill(
            child: AnimatedHearts(),
          ),
          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      _buildAppBar(),
                      _buildWelcomeSection(),
                      _buildLoveStreakCard(),
                      _buildBabyGenerationCard(),
                      _buildEngagementFeatures(),
                      _buildPremiumFeatures(),
                      _buildDailyInspiration(),
                      SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.scaffoldBackground,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPink,
                AppTheme.primaryBlue,
                AppTheme.accentYellow,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30.r),
              bottomRight: Radius.circular(30.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back! 👋',
                            style: BabyFont.headingL.copyWith(
                              color: Colors.white,
                              fontSize: 22.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Ready to create magic together? ✨💕',
                            style: BabyFont.bodyM.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _heartAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heartAnimation.value,
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: AppTheme.primaryPink,
                            size: 20.w,
                          ),
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
                          'Your Love Journey 💕',
                          style: BabyFont.headingM.copyWith(
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Creating beautiful memories together',
                          style: BabyFont.bodyS.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Text(
                              'Love Compatibility: ',
                              style: BabyFont.bodyS.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 10.sp,
                              ),
                            ),
                            Text(
                              '${_lovePercentage.toInt()}%',
                              style: BabyFont.bodyS.copyWith(
                                color: AppTheme.primaryPink,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Babies',
                      '$_babiesGenerated',
                      Icons.child_care,
                      AppTheme.primaryPink,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      'Memories',
                      '$_memoriesCreated',
                      Icons.photo_library,
                      AppTheme.primaryBlue,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      'Goals',
                      '$_goalsCompleted',
                      Icons.flag,
                      AppTheme.accentYellow,
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

  Widget _buildLoveStreakCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Love Streak 🔥',
                      style: BabyFont.headingM.copyWith(
                        fontSize: 18.sp,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$_loveStreak days of love!',
                      style: BabyFont.bodyL.copyWith(
                        fontSize: 16.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Keep the romance alive! 💖',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 2 * _floatingAnimation.value),
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryPink, AppTheme.primaryBlue],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$_loveStreak',
                          style: BabyFont.headingL.copyWith(
                            color: Colors.white,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16.w),
          SizedBox(height: 6.h),
          Text(
            value,
            style: BabyFont.headingM.copyWith(
              fontSize: 16.sp,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: BabyFont.bodyS.copyWith(
              fontSize: 9.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBabyGenerationCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                blurRadius: 25.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with love theme
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
                          size: 28.w,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Create Your Future Baby',
                    style: BabyFont.headingM.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
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
                          size: 28.w,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Upload your photos and watch the magic happen ✨',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),

              // Beautiful circular avatars
              Row(
                children: [
                  Expanded(
                    child: _buildBeautifulAvatar(
                      'Male 👨',
                      _malePhoto,
                      AppTheme.primaryBlue,
                      () => _selectPhoto(true),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildLoveConnector(),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildBeautifulAvatar(
                      'Female 👩',
                      _femalePhoto,
                      AppTheme.primaryPink,
                      () => _selectPhoto(false),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canGenerateBaby() ? _generateBaby : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canGenerateBaby()
                        ? AppTheme.primaryPink
                        : Colors.grey.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: _canGenerateBaby() ? 8 : 0,
                    shadowColor: AppTheme.primaryPink.withValues(alpha: 0.3),
                  ),
                  child: _isGenerating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Creating Magic...',
                              style: BabyFont.bodyM.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 20.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Generate Our Baby 👶',
                              style: BabyFont.bodyM.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeautifulAvatar(
      String label, File? photo, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Outer glow ring - responsive sizing
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: // Main avatar circle
                  Container(
                width: 85.w,
                height: 85.w,
                decoration: BoxDecoration(
                  color: photo != null
                      ? Colors.white
                      : color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: photo != null ? color : color.withValues(alpha: 0.3),
                    width: 2.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: photo != null
                    ? ClipOval(
                        child: Image.file(
                          photo,
                          fit: BoxFit.cover,
                          width: 85.w,
                          height: 85.w,
                        ),
                      )
                    : Icon(
                        Icons.add_photo_alternate,
                        color: color.withValues(alpha: 0.6),
                        size: 35.w,
                      ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: BabyFont.bodyM.copyWith(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoveConnector() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 45.w,
                height: 45.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPink, AppTheme.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withValues(alpha: 0.3),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 6.h),
        Text(
          'Love',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.primaryPink,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  bool _canGenerateBaby() {
    return _malePhoto != null && _femalePhoto != null && !_isGenerating;
  }

  void _selectPhoto(bool isMale) async {
    HapticFeedback.lightImpact();

    try {
      // Show photo selection dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select ${isMale ? 'Male' : 'Female'} Photo',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Choose a clear frontal photo for best AI results',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _simulatePhotoSelection(isMale, 'camera');
              },
              child: Text('Camera 📷'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _simulatePhotoSelection(isMale, 'gallery');
              },
              child: Text('Gallery 🖼️'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _simulatePhotoSelection(isMale, 'demo');
              },
              child: Text('Demo Photo ✨'),
            ),
          ],
        ),
      );
    } catch (e) {
      ToastService.showError(
          context, 'Failed to select photo: ${e.toString()}');
    }
  }

  void _simulatePhotoSelection(bool isMale, String source) {
    // Create a temporary file for demonstration
    final tempFile = File('/tmp/demo_${isMale ? 'male' : 'female'}_photo.jpg');

    setState(() {
      if (isMale) {
        _malePhoto = tempFile;
      } else {
        _femalePhoto = tempFile;
      }
    });

    String message =
        '${isMale ? 'Male' : 'Female'} photo selected from $source! 📸✨';
    if (source == 'demo') {
      message =
          'Demo ${isMale ? 'male' : 'female'} photo loaded! Ready for AI generation! 🎯✨';
    }

    ToastService.showBabyMessage(context, message);
  }

  void _generateBaby() async {
    if (!_canGenerateBaby()) return;

    setState(() {
      _isGenerating = true;
    });

    HapticFeedback.mediumImpact();
    ToastService.showBabyMessage(
        context, 'Generating your Indian baby face with AI! 🇮🇳🧬✨');

    try {
      // Generate AI baby with Indian characteristics
      final result = await AIBabyGenerationService.generateBabyFace(
        malePhoto: _malePhoto!,
        femalePhoto: _femalePhoto!,
        maleName: 'Male Parent', // You can get this from user input
        femaleName: 'Female Parent', // You can get this from user input
      );

      setState(() {
        _isGenerating = false;
      });

      if (!mounted) return;

      if (result.success) {
        ToastService.showCelebration(
            context, 'Your beautiful Indian baby is ready! 🇮🇳👶💕');

        // Navigate to AI baby result screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIBabyResultScreen(
              result: result,
              maleName: 'Male Parent',
              femaleName: 'Female Parent',
            ),
          ),
        );
      } else {
        ToastService.showError(
            context, 'Failed to generate baby: ${result.errorMessage}');
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (!mounted) return;
      ToastService.showError(context, 'Error generating baby: ${e.toString()}');
    }
  }

  Widget _buildEngagementFeatures() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Love & Engagement Features 💕',
              style: BabyFont.headingM.copyWith(
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Strengthen your bond with these amazing features',
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 12.sp,
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
        'title': 'Baby Names',
        'icon': Icons.baby_changing_station,
        'color': AppTheme.primaryBlue,
        'action': () =>
            _navigateToFeature(const BabyNameGeneratorScreen(), 'Baby Names'),
        'emoji': '👶'
      },
      {
        'title': 'Memory Journal',
        'icon': Icons.book,
        'color': AppTheme.accentYellow,
        'action': () => _navigateToFeature(
            const GrowthMemoryTimelineScreen(), 'Memory Journal'),
        'emoji': '📖'
      },
      {
        'title': 'Couple Challenges',
        'icon': Icons.fitness_center,
        'color': AppTheme.primaryPink,
        'action': () => _navigateToFeature(
            const CoupleChallengesBucketListScreen(), 'Couple Challenges'),
        'emoji': '💪'
      },
      {
        'title': 'Growth Timeline',
        'icon': Icons.timeline,
        'color': AppTheme.primaryBlue,
        'action': () => _navigateToFeature(
            const GrowthMemoryTimelineScreen(), 'Growth Timeline'),
        'emoji': '📈'
      },
      {
        'title': 'Anniversary Tracker',
        'icon': Icons.calendar_today,
        'color': AppTheme.accentYellow,
        'action': () => _navigateToFeature(
            const AnniversaryEventTrackerScreen(), 'Anniversary Tracker'),
        'emoji': '💍'
      },
      {
        'title': 'Love Language Quiz',
        'icon': Icons.psychology,
        'color': AppTheme.primaryPink,
        'action': () => _navigateToFeature(
            const LoveLanguageQuizScreen(), 'Love Language Quiz'),
        'emoji': '💝'
      },
      {
        'title': 'Future Planning',
        'icon': Icons.rocket_launch,
        'color': AppTheme.primaryBlue,
        'action': () =>
            _navigateToFeature(const FuturePlanningScreen(), 'Future Planning'),
        'emoji': '🚀'
      },
      {
        'title': 'Bucket List',
        'icon': Icons.checklist,
        'color': AppTheme.accentYellow,
        'action': () =>
            _navigateToFeature(const CoupleBucketListScreen(), 'Bucket List'),
        'emoji': '✅'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.0,
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
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    emoji,
                    style: TextStyle(fontSize: 20.sp),
                  ),
                  SizedBox(height: 4.h),
                  Icon(
                    icon,
                    color: color,
                    size: 18.w,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: BabyFont.bodyM.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeatures() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium Features ⭐',
              style: BabyFont.headingM.copyWith(
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Unlock unlimited possibilities',
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 15.h),
            GestureDetector(
              onTap: () => _navigateToFeature(const PremiumScreen(), 'Premium'),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentYellow,
                      AppTheme.accentYellow.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentYellow.withValues(alpha: 0.3),
                      blurRadius: 15.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 22.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Go Premium! 🌟',
                            style: BabyFont.headingM.copyWith(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'HD images, unlimited generations & more!',
                            style: BabyFont.bodyS.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18.w,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyInspiration() {
    final inspirations = [
      "Love is not about how much you say 'I love you', but how much you prove that it's true. 💕",
      "The best thing to hold onto in life is each other. 🤗",
      "A successful marriage requires falling in love many times, always with the same person. 💍",
      "In all the world, there is no heart for me like yours. 💖",
      "The greatest thing you'll ever learn is just to love and be loved in return. ✨",
    ];

    final randomInspiration =
        inspirations[DateTime.now().day % inspirations.length];

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPink.withValues(alpha: 0.1),
                AppTheme.primaryBlue.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.primaryPink,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Daily Love Inspiration',
                    style: BabyFont.headingM.copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.primaryPink,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                randomInspiration,
                style: BabyFont.bodyM.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFeature(Widget screen, String featureName) {
    HapticFeedback.lightImpact();
    ToastService.showLove(context, 'Opening $featureName! 💕');
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
