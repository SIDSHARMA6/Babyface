import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';

/// Optimized achievements widget with grid layout
class AchievementsWidget extends StatelessWidget {
  const AchievementsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 15.h),
          _buildAchievementsGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements 🏆',
          style: BabyFont.headingM.copyWith(
            fontSize: 20.sp,
            color: AppTheme.textPrimary,
            fontWeight: BabyFont.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Your relationship milestones',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid() {
    final achievements = _getAchievements();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 1.1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(
          achievement['title'] as String,
          achievement['icon'] as String,
          achievement['color'] as Color,
          achievement['unlocked'] as bool,
        );
      },
    );
  }

  List<Map<String, dynamic>> _getAchievements() {
    return [
      {
        'title': 'First Baby',
        'icon': '👶',
        'color': AppTheme.primaryPink,
        'unlocked': true
      },
      {
        'title': 'Love Streak',
        'icon': '🔥',
        'color': AppTheme.accentYellow,
        'unlocked': true
      },
      {
        'title': 'Memory Maker',
        'icon': '📸',
        'color': AppTheme.primaryBlue,
        'unlocked': true
      },
      {
        'title': 'Quiz Master',
        'icon': '🧠',
        'color': AppTheme.primaryPink,
        'unlocked': false
      },
      {
        'title': 'Perfect Match',
        'icon': '💕',
        'color': AppTheme.accentYellow,
        'unlocked': false
      },
      {
        'title': 'Premium User',
        'icon': '⭐',
        'color': AppTheme.primaryBlue,
        'unlocked': false
      },
    ];
  }

  Widget _buildAchievementCard(String title, String icon, Color color, bool unlocked) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 15.r,
                  offset: Offset(0, 5.h),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconContainer(icon, color, unlocked),
          SizedBox(height: 12.h),
          _buildTitle(title, unlocked),
          SizedBox(height: 4.h),
          _buildStatusBadge(color, unlocked),
        ],
      ),
    );
  }

  Widget _buildIconContainer(String icon, Color color, bool unlocked) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: unlocked
            ? color.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Text(icon, style: TextStyle(fontSize: 24.sp)),
    );
  }

  Widget _buildTitle(String title, bool unlocked) {
    return Text(
      title,
      style: BabyFont.bodyM.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: unlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStatusBadge(Color color, bool unlocked) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: unlocked
            ? color.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        unlocked ? 'Unlocked' : 'Locked',
        style: BabyFont.bodyS.copyWith(
          fontSize: 8.sp,
          color: unlocked ? color : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

