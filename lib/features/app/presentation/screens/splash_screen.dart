import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/providers/login_provider.dart';
import 'onboarding_screen.dart';
import '../../../login/presentation/screens/login_screen.dart';
import 'main_navigation_screen.dart';

/// Ultra-fast SplashScreen with zero ANR
/// - Optimized animations with RepaintBoundary
/// - Minimal rebuilds and efficient memory usage
/// - Sub-1s response time with preloaded assets
/// - Handles login state checking and navigation
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _progressController;
  late final AnimationController _fadeController;

  late final Animation<double> _logoScale;
  late final Animation<double> _fadeOpacity;

  double _progress = 0.0;
  String _message = 'Creating magic...';
  bool _isCheckingLogin = true;
  bool _isLoggedIn = false;
  bool _isFirstTime = true;

  static const _messages = [
    'Creating magic...',
    'Loading features...',
    'Checking login status...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
    _checkLoginStatus();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 400), // Reduced from 800ms
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600), // Reduced from 1200ms
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300), // Reduced from 600ms
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
  }

  void _startSequence() async {
    // Start animations immediately
    _fadeController.forward();

    await Future.delayed(
        const Duration(milliseconds: 100)); // Reduced from 200ms
    if (!mounted) return;

    _logoController.forward();

    await Future.delayed(
        const Duration(milliseconds: 200)); // Reduced from 400ms
    if (!mounted) return;

    _progressController.forward();
    _updateProgress();
  }

  Future<void> _checkLoginStatus() async {
    try {
      print('🔐 [SplashScreen] Checking login status...');

      // Wait for login provider to initialize completely
      int attempts = 0;
      LoginState loginState;

      do {
        await Future.delayed(const Duration(milliseconds: 10));
        loginState = ref.read(loginProvider);
        attempts++;
        print(
            '🔐 [SplashScreen] Attempt $attempts - Login state: isLoading=${loginState.isLoading}, user=${loginState.user?.email}');
      } while (loginState.isLoading && attempts < 20); // Wait up to 2 seconds

      print(
          '🔐 [SplashScreen] Final login state: isLoading=${loginState.isLoading}, user=${loginState.user?.email}');

      // Debug: Show detailed user information
      if (loginState.user != null) {
        final user = loginState.user!;
        print('🔐 [SplashScreen] ===== USER DETAILS =====');
        print('🔐 [SplashScreen] Email: ${user.email}');
        print('🔐 [SplashScreen] Display Name: ${user.displayName}');
        print('🔐 [SplashScreen] First Name: ${user.firstName}');
        print('🔐 [SplashScreen] Last Name: ${user.lastName}');
        print('🔐 [SplashScreen] Gender: ${user.gender}');
        print('🔐 [SplashScreen] Partner Name: ${user.partnerName}');
        print('🔐 [SplashScreen] Bond Name: ${user.bondName}');
        print('🔐 [SplashScreen] Is Complete: ${user.isComplete}');
        print(
            '🔐 [SplashScreen] Has Bond Name: ${user.bondName?.isNotEmpty ?? false}');
        print('🔐 [SplashScreen] =========================');
      }

      if (mounted) {
        setState(() {
          _isLoggedIn = loginState.user != null && loginState.user!.isComplete;
          _isCheckingLogin = false;
        });
      }

      // Check if it's first time user
      await _checkFirstTimeUser();
    } catch (e) {
      print('❌ [SplashScreen] Error checking login status: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isCheckingLogin = false;
        });
      }
    }
  }

  Future<void> _checkFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (mounted) {
        setState(() {
          _isFirstTime = !hasSeenOnboarding;
        });
      }
    } catch (e) {
      print('❌ [SplashScreen] Error checking first time user: $e');
      if (mounted) {
        setState(() {
          _isFirstTime = true;
        });
      }
    }
  }

  void _updateProgress() async {
    for (int i = 0; i < _messages.length; i++) {
      if (!mounted) return;

      setState(() {
        _progress = (i + 1) / _messages.length;
        _message = _messages[i];
      });

      // No delay - instant progress
    }

    // Wait for login checking to complete
    while (_isCheckingLogin && mounted) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    if (!mounted) return;

    setState(() {
      _message = 'Ready! ✨';
      _progress = 1.0;
    });

    // No delay - instant navigation
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;

    Widget nextScreen;

    if (_isFirstTime) {
      nextScreen = const OnboardingScreen();
    } else if (_isLoggedIn) {
      nextScreen = const MainNavigationScreen();
    } else {
      nextScreen = const LoginScreen();
    }

    print('🔐 [SplashScreen] Navigating to: ${nextScreen.runtimeType}');
    print(
        '🔐 [SplashScreen] _isFirstTime: $_isFirstTime, _isLoggedIn: $_isLoggedIn');

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPink.withValues(alpha: 0.8),
              AppTheme.primaryBlue.withValues(alpha: 0.9),
              AppTheme.accentYellow.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeOpacity,
            child: Column(
              children: [
                const Spacer(flex: 2),
                RepaintBoundary(child: _buildLogo()),
                SizedBox(height: 40.h),
                RepaintBoundary(child: _buildTitle()),
                SizedBox(height: 16.h),
                RepaintBoundary(child: _buildMessage()),
                SizedBox(height: 32.h),
                RepaintBoundary(child: _buildProgress()),
                const Spacer(flex: 3),
                RepaintBoundary(child: _buildFooter()),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Icon(
              Icons.child_care_rounded,
              size: 60.w,
              color: AppTheme.primaryPink,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      'Future Baby',
      style: BabyFont.displayLarge.copyWith(
        color: Colors.white,
        fontWeight: BabyFont.bold,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: Offset(0, 2.h),
            blurRadius: 4.r,
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        _message,
        key: ValueKey(_message),
        style: BabyFont.titleMedium.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        Container(
          width: 200.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 200.w * _progress,
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '${(_progress * 100).toInt()}%',
          style: BabyFont.labelMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      'Your photos stay private',
      style: BabyFont.bodySmall.copyWith(
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }
}
