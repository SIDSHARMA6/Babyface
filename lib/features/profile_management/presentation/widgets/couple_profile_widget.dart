import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Optimized couple profile widget
class CoupleProfileWidget extends StatelessWidget {
  const CoupleProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
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
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            _buildAvatars(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Couple Profile 💕',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Upload photos of both partners',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatars(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAvatarPlaceholder(context, 'Partner 1', AppTheme.primaryBlue, Icons.person_rounded),
              _buildHeartIcon(),
              _buildAvatarPlaceholder(context, 'Partner 2', AppTheme.primaryPink, Icons.person_rounded),
            ],
    );
  }

  Widget _buildHeartIcon() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPink, AppTheme.primaryBlue],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.favorite_rounded,
        color: Colors.white,
        size: 20.w,
      ),
    );
  }

  Widget _buildAvatarPlaceholder(BuildContext context, String label, Color color, IconData icon) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ToastService.showInfo(context, 'Photo upload coming soon! 📸');
          },
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.w),
            ),
            child: Icon(
              icon,
              size: 32.w,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: BabyFont.labelMedium.copyWith(
            color: color,
            fontWeight: BabyFont.semiBold,
          ),
        ),
      ],
    );
  }
}

