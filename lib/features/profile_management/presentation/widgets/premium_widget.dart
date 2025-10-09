import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Optimized premium upgrade widget
class PremiumWidget extends StatelessWidget {
  const PremiumWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accentYellow.withValues(alpha: 0.1),
              AppTheme.primaryPink.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentYellow.withValues(alpha: 0.1),
              blurRadius: 15.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 16.h),
            _buildFeatures(),
            SizedBox(height: 16.h),
            _buildUpgradeButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.star_rounded,
          color: AppTheme.accentYellow,
          size: 28.w,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upgrade to Premium ⭐',
                style: BabyFont.headingM.copyWith(
                  color: AppTheme.accentYellow,
                  fontWeight: BabyFont.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Unlock all features and unlimited baby generation!',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Row(
      children: [
        Expanded(child: _buildFeatureCard('Unlimited Babies', '👶')),
        SizedBox(width: 12.w),
        Expanded(child: _buildFeatureCard('Advanced AI', '🤖')),
        SizedBox(width: 12.w),
        Expanded(child: _buildFeatureCard('Priority Support', '🆘')),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String emoji) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentYellow.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(height: 4.h),
          Text(
            title,
            style: BabyFont.bodyS.copyWith(
              fontSize: 8.sp,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleUpgrade(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentYellow,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Upgrade Now',
          style: BabyFont.bodyM.copyWith(
            fontWeight: BabyFont.bold,
          ),
        ),
      ),
    );
  }

  void _handleUpgrade(BuildContext context) {
    HapticFeedback.lightImpact();
    ToastService.showCelebration(
      context,
      'Premium upgrade coming soon! ⭐',
    );
  }
}

