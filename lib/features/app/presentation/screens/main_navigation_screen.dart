import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

import '../../../../core/navigation/navigation_provider.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';
import '../../../couple_goals/presentation/screens/couple_goals_screen.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../profile_management/presentation/screens/profile_screen.dart';

/// Main navigation screen with bottom navigation bar
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _iconAnimationController;
  late List<AnimationController> _tabAnimationControllers;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const QuizScreen(),
    const CoupleGoalsScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.history_rounded),
      activeIcon: Icon(Icons.history),
      label: 'History',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.quiz_rounded),
      activeIcon: Icon(Icons.quiz),
      label: 'Quiz',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.favorite_outline_rounded),
      activeIcon: Icon(Icons.favorite_rounded),
      label: 'Goals',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize animation controllers for super smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200), // Super fast response
      vsync: this,
    );

    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150), // Even faster icon response
      vsync: this,
    );

    // Individual animation controllers for each tab
    _tabAnimationControllers = List.generate(
      _screens.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 100), // Ultra fast tap response
        vsync: this,
      ),
    );

    // Start with first tab selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tabAnimationControllers[0].forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _iconAnimationController.dispose();
    for (var controller in _tabAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(), // Cute bouncy physics
        onPageChanged: (index) {
          _onPageChanged(index);
        },
        children: _screens
            .map(
              (screen) => AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final animationValue =
                      _animationController.value.clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: 0.95 + (0.05 * animationValue),
                    child: Opacity(
                      opacity: (0.7 + (0.3 * animationValue.clamp(0.0, 1.0)))
                          .clamp(0.0, 1.0),
                      child: screen,
                    ),
                  );
                },
              ),
            )
            .toList(),
      ),
      bottomNavigationBar: _buildCuteBottomNavBar(),
    );
  }

  Widget _buildCuteBottomNavBar() {
    return Container(
      height: 75.h + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 20.r,
            offset: Offset(0, -5.h),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_navItems.length, (index) {
            return _buildNavItem(index);
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    return Consumer(
      builder: (context, ref, child) {
        final navigationState = ref.watch(navigationProvider);
        final navigationNotifier = ref.read(navigationProvider.notifier);
        final isSelected = navigationState.currentIndex == index;
        final item = _navItems[index];
        final isQuizTab = index == 2; // Quiz tab gets special treatment

        return GestureDetector(
          onTap: () => _onTabTapped(index, navigationNotifier),
          onTapDown: (_) => _onTabTapDown(index),
          onTapUp: (_) => _onTabTapUp(index),
          onTapCancel: () => _onTabTapUp(index),
          child: AnimatedBuilder(
            animation: _tabAnimationControllers[index],
            builder: (context, child) {
              final animationValue =
                  _tabAnimationControllers[index].value.clamp(0.0, 1.0);
              final scale = 0.85 + (0.15 * animationValue);

              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16.w : 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isQuizTab
                            ? AppTheme.primaryPink
                            : AppTheme.primaryPink.withValues(alpha: 0.1))
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(isQuizTab ? 25.r : 20.r),
                    border: isSelected && !isQuizTab
                        ? Border.all(
                            color: AppTheme.primaryPink.withValues(alpha: 0.2),
                            width: 1.w,
                          )
                        : null,
                    boxShadow: isSelected && isQuizTab
                        ? [
                            BoxShadow(
                              color:
                                  AppTheme.primaryPink.withValues(alpha: 0.3),
                              blurRadius: 12.r,
                              offset: Offset(0, 4.h),
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.elasticOut,
                          child: Icon(
                            _getIconData(index, isSelected),
                            color: isSelected
                                ? (isQuizTab
                                    ? Colors.white
                                    : AppTheme.primaryPink)
                                : AppTheme.textSecondary,
                            size: isSelected ? (isQuizTab ? 26.w : 24.w) : 20.w,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Flexible(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: isSelected
                                ? (isQuizTab
                                    ? Colors.white
                                    : AppTheme.primaryPink)
                                : AppTheme.textSecondary,
                            fontSize: isSelected ? 11.sp : 9.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            fontFamily: 'BabyFont',
                          ),
                          child: Text(
                            item.label ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (isSelected && !isQuizTab)
                        Container(
                          margin: EdgeInsets.only(top: 1.h),
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _onTabTapped(int index, NavigationNotifier navigationNotifier) {
    final currentIndex = ref.read(navigationProvider).currentIndex;
    
    if (currentIndex == index) {
      return; // Prevent unnecessary animations
    }

    // Immediate haptic feedback for super responsive feel
    HapticFeedback.lightImpact();

    // Reset previous tab animation
    _tabAnimationControllers[currentIndex].reverse();

    // Animate new tab
    _tabAnimationControllers[index].forward();

    // Update state immediately for instant visual feedback
    navigationNotifier.setCurrentIndex(index);

    // Start page transition animation
    _animationController.reset();
    _animationController.forward();

    // Smooth page transition with cute curve
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250), // Super fast transition
      curve: Curves.easeOutCubic, // Smooth deceleration
    );
  }

  void _onTabTapDown(int index) {
    // Immediate visual feedback on tap down
    _tabAnimationControllers[index].reverse();
    HapticFeedback.selectionClick(); // Subtle feedback
  }

  void _onTabTapUp(int index) {
    // Return to normal state
    final navigationState = ref.read(navigationProvider);
    if (navigationState.currentIndex == index) {
      _tabAnimationControllers[index].forward();
    }
  }

  void _onPageChanged(int index) {
    final navigationNotifier = ref.read(navigationProvider.notifier);
    final navigationState = ref.read(navigationProvider);

    if (navigationState.currentIndex != index) {
      // Reset previous tab animation
      _tabAnimationControllers[navigationState.currentIndex].reverse();

      // Animate new tab
      _tabAnimationControllers[index].forward();

      navigationNotifier.setCurrentIndex(index);

      // Gentle haptic feedback for page swipe
      HapticFeedback.selectionClick();
    }

    // Always animate page transition
    _animationController.reset();
    _animationController.forward();
  }

  IconData _getIconData(int index, bool isSelected) {
    switch (index) {
      case 0: // Home
        return isSelected ? Icons.home : Icons.home_rounded;
      case 1: // History
        return isSelected ? Icons.history : Icons.history_rounded;
      case 2: // Quiz
        return isSelected ? Icons.quiz : Icons.quiz_rounded;
      case 3: // Goals
        return isSelected
            ? Icons.favorite_rounded
            : Icons.favorite_outline_rounded;
      case 4: // Profile
        return isSelected ? Icons.person_rounded : Icons.person_outline_rounded;
      default:
        return Icons.home_rounded;
    }
  }
}
