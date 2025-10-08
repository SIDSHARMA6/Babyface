import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../../../shared/widgets/animated_heart.dart';
import '../../../../shared/providers/login_provider.dart';
import '../../../../shared/services/ai_baby_generation_service.dart';
import '../../../baby_generation/presentation/screens/ai_baby_result_screen.dart';
import '../widgets/welcome_section_widget.dart';
import '../widgets/love_streak_card_widget.dart';
import '../widgets/baby_generation_card_widget.dart';
import '../widgets/engagement_features_widget.dart';
import '../widgets/premium_features_widget.dart';
import '../widgets/daily_inspiration_widget.dart';
import 'dart:io';

/// Modular Dashboard Screen with clean architecture
/// All widgets are separated into individual classes for better maintainability
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _heartController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _scrollController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _scrollAnimation;

  // Dashboard data - will be loaded from providers
  final int _babiesGenerated = 0;
  final int _memoriesCreated = 0;
  final int _loveStreak = 0;
  final double _lovePercentage = 0.0;

  // Photo upload states
  File? _malePhoto;
  File? _femalePhoto;
  bool _isGenerating = false;

  // Scroll state
  double _scrollOffset = 0.0;
  bool _showBondName = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // Add smooth transition from login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playWelcomeAnimation();
    });
  }

  void _playWelcomeAnimation() {
    // Play a gentle welcome animation
    _animationController.reset();
    _animationController.forward();

    // Show welcome message if user just completed login
    final loginState = ref.read(loginProvider);
    if (loginState.user != null && loginState.user!.bondName != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ToastService.showCelebration(context,
              'Welcome to your love journey, ${loginState.user!.bondName}! 💕✨');
        }
      });
    }
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

    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

    _scrollAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scrollController,
      curve: Curves.easeOutCubic,
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Stack(
          children: [
            // Animated hearts background
            const Positioned.fill(
              child: AnimatedHearts(),
            ),
            // Floating bond name - Edge-to-edge immersive
            if (_showBondName)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _scrollAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -50 * (1 - _scrollAnimation.value)),
                      child: Opacity(
                        opacity: _scrollAnimation.value,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                              24.w,
                              MediaQuery.of(context).padding.top + 5.h,
                              24.w,
                              16.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryPink,
                                AppTheme.primaryBlue,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.primaryPink.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildProfileImageOrHeart(),
                              SizedBox(width: 48.w),
                              Text(
                                _getBondName(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Main content - Immersive (no SafeArea)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification is ScrollUpdateNotification) {
                        setState(() {
                          _scrollOffset = notification.metrics.pixels;
                          final shouldShowBondName = _scrollOffset > 100;
                          if (shouldShowBondName != _showBondName) {
                            _showBondName = shouldShowBondName;
                            if (_showBondName) {
                              _scrollController.forward();
                            } else {
                              _scrollController.reverse();
                            }
                          }
                        });
                      }
                      return false;
                    },
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final loginState = ref.watch(loginProvider);
    final user = loginState.user;

    String appBarGreeting = 'Welcome Back! 👋';
    String appBarSubGreeting = 'Ready to create magic together? ✨💕';
    if (user != null) {
      if (user.bondName != null && user.bondName!.isNotEmpty) {
        appBarGreeting = 'Hello, ${user.bondName}! 💕';
        appBarSubGreeting = 'Your love story awaits ✨';
      } else if (user.partnerName != null && user.partnerName!.isNotEmpty) {
        appBarGreeting = 'Hello, ${user.partnerName}! 💕';
        appBarSubGreeting = 'Ready to create magic together? ✨💕';
      }
    }

    final double topPadding = MediaQuery.of(context).padding.top;

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 120.h + topPadding,
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
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            0, // Start from the very top
            20.w,
            12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add space for status bar
              SizedBox(height: topPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appBarGreeting,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          appBarSubGreeting,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: WelcomeSectionWidget(
          babiesGenerated: _babiesGenerated,
          memoriesCreated: _memoriesCreated,
          lovePercentage: _lovePercentage,
          heartAnimation: _heartAnimation,
        ),
      ),
    );
  }

  Widget _buildLoveStreakCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: LoveStreakCardWidget(
          loveStreak: _loveStreak,
          floatingAnimation: _floatingAnimation,
        ),
      ),
    );
  }

  Widget _buildBabyGenerationCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: BabyGenerationCardWidget(
          malePhoto: _malePhoto,
          femalePhoto: _femalePhoto,
          isGenerating: _isGenerating,
          heartAnimation: _heartAnimation,
          onMalePhotoSelected: () => _selectPhoto(true),
          onFemalePhotoSelected: () => _selectPhoto(false),
          onGenerateBaby: _generateBaby,
        ),
      ),
    );
  }

  Widget _buildEngagementFeatures() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: const EngagementFeaturesWidget(),
      ),
    );
  }

  Widget _buildPremiumFeatures() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: const PremiumFeaturesWidget(),
      ),
    );
  }

  Widget _buildDailyInspiration() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: const DailyInspirationWidget(),
      ),
    );
  }

  String _getBondName() {
    final loginState = ref.read(loginProvider);
    final user = loginState.user;

    if (user != null && user.bondName != null && user.bondName!.isNotEmpty) {
      return user.bondName!;
    } else if (user != null &&
        user.partnerName != null &&
        user.partnerName!.isNotEmpty) {
      return 'Hello, ${user.partnerName}! 💕';
    } else {
      return 'Hello, Love! 💕';
    }
  }

  Widget _buildProfileImageOrHeart() {
    final loginState = ref.read(loginProvider);
    final user = loginState.user;

    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      return Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            user.photoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.favorite,
                color: Colors.white,
                size: 16.w,
              );
            },
          ),
        ),
      );
    } else {
      return Icon(
        Icons.favorite,
        color: Colors.white,
        size: 20.w,
      );
    }
  }

  void _selectPhoto(bool isMale) async {
    HapticFeedback.lightImpact();

    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select ${isMale ? 'Male' : 'Female'} Photo',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Choose a clear frontal photo for best AI results',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
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
          ],
        ),
      );
    } catch (e) {
      ToastService.showError(
          context, 'Failed to select photo: ${e.toString()}');
    }
  }

  void _simulatePhotoSelection(bool isMale, String source) {
    // This method is no longer needed as we removed demo functionality
    // Real photo selection should be implemented through image picker
  }

  void _generateBaby() async {
    if (_malePhoto == null || _femalePhoto == null || _isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    HapticFeedback.mediumImpact();
    ToastService.showBabyMessage(
        context, 'Generating your Indian baby face with AI! 🇮🇳🧬✨');

    try {
      final result = await AIBabyGenerationService.generateBabyFace(
        malePhoto: _malePhoto!,
        femalePhoto: _femalePhoto!,
        maleName: 'Male Parent',
        femaleName: 'Female Parent',
      );

      setState(() {
        _isGenerating = false;
      });

      if (!mounted) return;

      if (result.success) {
        ToastService.showCelebration(
            context, 'Your beautiful Indian baby is ready! 🇮🇳👶💕');

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
}
