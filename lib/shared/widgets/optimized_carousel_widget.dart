import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/carousel_item.dart';
import '../providers/login_provider.dart';
import '../models/user.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/baby_font.dart';

/// Optimized carousel widget that fetches bond name and image from profile
/// - Minimal rebuilds with RepaintBoundary
/// - Connected to login provider for real data
/// - Smooth animations with proper disposal
class OptimizedCarouselWidget extends ConsumerStatefulWidget {
  final double height;
  final List<CarouselItem>? customItems;

  const OptimizedCarouselWidget({
    super.key,
    this.height = 200,
    this.customItems,
  });

  @override
  ConsumerState<OptimizedCarouselWidget> createState() =>
      _OptimizedCarouselWidgetState();
}

class _OptimizedCarouselWidgetState
    extends ConsumerState<OptimizedCarouselWidget>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _currentIndex = 0;
  final bool _isAutoPlaying = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (!mounted) return;

    Future.delayed(const Duration(seconds: 4), () {
      if (_isAutoPlaying && mounted) {
        _nextPage();
        _startAutoPlay();
      }
    });
  }

  void _nextPage() {
    if (_pageController.hasClients) {
      final nextIndex = (_currentIndex + 1) % _getCarouselItems().length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch login state for real user data
    final loginState = ref.watch(loginProvider);
    final user = loginState.user;

    final carouselItems = _getCarouselItems(user);

    if (carouselItems.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height.h,
          width: double.infinity,
          child: RepaintBoundary(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _animationController.reset();
                _animationController.forward();
              },
              itemCount: carouselItems.length,
              itemBuilder: (context, index) {
                return _buildCarouselItem(carouselItems[index], index, user);
              },
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _buildDotsIndicator(carouselItems.length),
      ],
    );
  }

  List<CarouselItem> _getCarouselItems([User? user]) {
    if (widget.customItems != null) {
      return widget.customItems!;
    }

    // Generate carousel items based on user data
    final bondName = user?.bondName ??
        (user?.partnerName != null
            ? '${user?.firstName ?? 'You'} & ${user!.partnerName}'
            : 'You & Your Partner');
    final daysTogether = user?.createdAt != null
        ? DateTime.now().difference(user!.createdAt).inDays
        : 0;

    return [
      CarouselItem(
        title: "Our Love Story 💕",
        subtitle: bondName,
        value: "$daysTogether days together",
        icon: Icons.favorite,
        gradientColors: const [
          Color(0xFFFF6B81), // Baby Pink
          Color(0xFFFF8FA3), // Coral
        ],
        emoji: "💕",
        description: "Every day is a new chapter in our story",
        backgroundGradient: const LinearGradient(
          colors: [Color(0xFFFF6B81), Color(0xFFFF8FA3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      CarouselItem(
        title: "Future Dreams 🌟",
        subtitle: "Our baby predictions",
        value: "12 names generated",
        icon: Icons.child_care,
        gradientColors: const [
          Color(0xFF6BCBFF), // Baby Blue
          Color(0xFF87CEEB), // Sky Blue
        ],
        emoji: "👶",
        description: "Dreaming of our little miracle",
        backgroundGradient: const LinearGradient(
          colors: [Color(0xFF6BCBFF), Color(0xFF87CEEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      CarouselItem(
        title: "Cherished Memories 📸",
        subtitle: "Moments we treasure",
        value: "28 memories saved",
        icon: Icons.photo_library,
        gradientColors: const [
          Color(0xFFCDB4DB), // Lavender
          Color(0xFFFFB3BA), // Soft Rose
        ],
        emoji: "🖼️",
        description: "Every memory tells our love story",
        backgroundGradient: const LinearGradient(
          colors: [Color(0xFFCDB4DB), Color(0xFFFFB3BA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];
  }

  Widget _buildCarouselItem(CarouselItem item, int index, User? user) {
    final isActive = index == _currentIndex;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isActive ? _scaleAnimation.value : 0.9,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: isActive ? 0 : 20.h,
            ),
            decoration: BoxDecoration(
              gradient: item.backgroundGradient,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: item.gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 15.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                children: [
                  // Background gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: item.backgroundGradient,
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with emoji and icon
                        Row(
                          children: [
                            Text(
                              item.emoji,
                              style: TextStyle(fontSize: 32.sp),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: BabyFont.headingS.copyWith(
                                      color: Colors.white,
                                      fontWeight: BabyFont.bold,
                                    ),
                                  ),
                                  Text(
                                    item.subtitle,
                                    style: BabyFont.bodyS.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (item.icon != null)
                              Icon(
                                item.icon,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 24.w,
                              ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Description
                        Text(
                          item.description,
                          style: BabyFont.bodyM.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 12.h),

                        // Value
                        if (item.value != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              item.value!,
                              style: BabyFont.bodyS.copyWith(
                                color: Colors.white,
                                fontWeight: BabyFont.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // User photo overlay (if available)
                  if (user?.photoUrl != null && index == 0)
                    Positioned(
                      top: 16.h,
                      right: 16.w,
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.w,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            user!.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20.w,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsIndicator(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: _currentIndex == index ? 24.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? AppTheme.primaryPink
                : AppTheme.primaryPink.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }
}
