import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/carousel_item.dart';
import '../../core/theme/baby_font.dart';
import '../../core/theme/app_theme.dart';

/// Romantic carousel slider for dashboard - Custom implementation
class RomanticCarousel extends StatefulWidget {
  final List<CarouselItem> items;
  final double height;

  const RomanticCarousel({
    super.key,
    required this.items,
    this.height = 200,
  });

  @override
  State<RomanticCarousel> createState() => _RomanticCarouselState();
}

class _RomanticCarouselState extends State<RomanticCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 0;
  bool _isAutoPlaying = true;

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
      final nextIndex = (_currentIndex + 1) % widget.items.length;
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
    return Column(
      children: [
        SizedBox(
          height: widget.height.h,
          width: double.infinity, // Match parent width
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _animationController.reset();
              _animationController.forward();
            },
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return _buildCarouselItem(widget.items[index], index);
            },
          ),
        ),
        SizedBox(height: 16.h),
        _buildDotsIndicator(),
      ],
    );
  }

  Widget _buildCarouselItem(CarouselItem item, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _currentIndex == index ? _scaleAnimation.value : 0.9,
          child: Opacity(
            opacity: _currentIndex == index ? _fadeAnimation.value : 0.7,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                gradient: item.backgroundGradient,
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w), // Reduced from 20.w
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.icon != null)
                        Icon(
                          item.icon,
                          color: Colors.white,
                          size: 35.w, // Reduced from 40.w
                        ),
                      SizedBox(height: 8.h), // Reduced from 10.h
                      Text(
                        item.title,
                        style: BabyFont.headingL.copyWith(
                          color: Colors.white,
                          fontSize: 22.sp, // Reduced from 24.sp
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h), // Reduced from 5.h
                      Text(
                        item.subtitle,
                        style: BabyFont.bodyL.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp, // Reduced from 16.sp
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (item.value != null) ...[
                        SizedBox(height: 4.h), // Reduced from 5.h
                        Text(
                          item.value!,
                          style: BabyFont.bodyM.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12.sp, // Reduced from 14.sp
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.items.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => _pageController.animateToPage(
            entry.key,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          child: Container(
            width: 10.w,
            height: 10.w,
            margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.primaryPink)
                  .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
            ),
          ),
        );
      }).toList(),
    );
  }
}
