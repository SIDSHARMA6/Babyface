import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';

/// Love connector widget between male and female avatars
class LoveConnectorWidget extends StatelessWidget {
  final Animation<double>? pulseAnimation;

  const LoveConnectorWidget({
    super.key,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (pulseAnimation != null)
          AnimatedBuilder(
            animation: pulseAnimation!,
            builder: (context, child) {
              return Transform.scale(
                scale: pulseAnimation!.value,
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
          )
        else
          Container(
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
}
