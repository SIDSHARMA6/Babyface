import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';

/// Daily inspiration widget with love quotes
class DailyInspirationWidget extends StatelessWidget {
  const DailyInspirationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final inspirations = [
      "Love is not about how much you say 'I love you', but how much you prove that it's true. 💕",
      "The best thing to hold onto in life is each other. 🤗",
      "A successful marriage requires falling in love many times, always with the same person. 💍",
      "In all the world, there is no heart for me like yours. 💖",
      "The greatest thing you'll ever learn is just to love and be loved in return. ✨",
    ];

    final randomInspiration =
        inspirations[DateTime.now().day % inspirations.length];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
    );
  }
}
