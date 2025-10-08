import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/providers/login_provider.dart';
import '../../../../shared/widgets/romantic_carousel.dart';
import '../../../../shared/models/carousel_item.dart';

/// Welcome section widget with user greeting and romantic carousel
class WelcomeSectionWidget extends ConsumerWidget {
  final int babiesGenerated;
  final int memoriesCreated;
  final double lovePercentage;
  final Animation<double> heartAnimation;

  const WelcomeSectionWidget({
    super.key,
    required this.babiesGenerated,
    required this.memoriesCreated,
    required this.lovePercentage,
    required this.heartAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final user = loginState.user;

    String greeting = 'Welcome Back! 👋';
    String subGreeting = 'Ready to create magic together? ✨💕';
    if (user != null) {
      if (user.bondName != null && user.bondName!.isNotEmpty) {
        greeting = 'Welcome, ${user.bondName}! 💕';
        subGreeting = 'Your love story continues here ✨';
      } else if (user.partnerName != null && user.partnerName!.isNotEmpty) {
        greeting = 'Hello, ${user.partnerName}! 💕';
        subGreeting = 'Ready to create magic together? ✨💕';
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.w),
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
                animation: heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: heartAnimation.value,
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
                      greeting,
                      style: BabyFont.headingL.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subGreeting,
                      style: BabyFont.bodyL.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 16.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          'Our Love Score: ',
                          style: BabyFont.bodyM.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${lovePercentage.toInt()}%',
                          style: BabyFont.bodyL.copyWith(
                            color: AppTheme.primaryPink,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildRomanticCarousel(user),
        ],
      ),
    );
  }

  Widget _buildRomanticCarousel(user) {
    // Get user data for carousel
    final babyCount = babiesGenerated;
    final latestBabyName = user?.bondName;
    final memoryCount = memoriesCreated;
    final anniversaryDate = user?.partnerName != null ? "25 Dec 2025" : null;
    final periodDate = "15 Oct 2025";

    final carouselItems = CarouselDataProvider.getCarouselItems(
      babyCount: babyCount,
      latestBabyName: latestBabyName,
      memoryCount: memoryCount,
      anniversaryDate: anniversaryDate,
      periodDate: periodDate,
    );

    return SizedBox(
      width: double.infinity,
      child: RomanticCarousel(
        items: carouselItems,
        height: 220,
      ),
    );
  }
}
