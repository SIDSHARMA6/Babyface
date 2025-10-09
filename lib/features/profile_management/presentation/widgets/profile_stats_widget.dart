import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';

/// Optimized profile statistics widget
class ProfileStatsWidget extends StatelessWidget {
  const ProfileStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Achievements', '8', Icons.emoji_events, AppTheme.accentYellow, '🏆')),
          SizedBox(width: 12.w),
          Expanded(child: _buildStatCard('Love Score', '95%', Icons.favorite, AppTheme.primaryPink, '💕')),
          SizedBox(width: 12.w),
          Expanded(child: _buildStatCard('Status', 'Free', Icons.star, AppTheme.primaryBlue, '⭐')),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, String emoji) {
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
          Text(emoji, style: TextStyle(fontSize: 20.sp)),
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
}

