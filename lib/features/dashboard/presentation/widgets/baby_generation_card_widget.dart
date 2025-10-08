import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';
import 'photo_avatar_widget.dart';
import 'love_connector_widget.dart';

/// Baby generation card widget with photo upload and generation functionality
class BabyGenerationCardWidget extends StatefulWidget {
  final File? malePhoto;
  final File? femalePhoto;
  final bool isGenerating;
  final Animation<double> heartAnimation;
  final VoidCallback onMalePhotoSelected;
  final VoidCallback onFemalePhotoSelected;
  final VoidCallback onGenerateBaby;

  const BabyGenerationCardWidget({
    super.key,
    required this.malePhoto,
    required this.femalePhoto,
    required this.isGenerating,
    required this.heartAnimation,
    required this.onMalePhotoSelected,
    required this.onFemalePhotoSelected,
    required this.onGenerateBaby,
  });

  @override
  State<BabyGenerationCardWidget> createState() =>
      _BabyGenerationCardWidgetState();
}

class _BabyGenerationCardWidgetState extends State<BabyGenerationCardWidget> {
  bool _canGenerateBaby() {
    return widget.malePhoto != null &&
        widget.femalePhoto != null &&
        !widget.isGenerating;
  }

  void _selectPhoto(bool isMale) async {
    HapticFeedback.lightImpact();

    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select ${isMale ? 'Male' : 'Female'} Photo',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Choose a clear frontal photo for best AI results',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isMale) {
                  widget.onMalePhotoSelected();
                } else {
                  widget.onFemalePhotoSelected();
                }
              },
              child: Text('Camera 📷'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isMale) {
                  widget.onMalePhotoSelected();
                } else {
                  widget.onFemalePhotoSelected();
                }
              },
              child: Text('Gallery 🖼️'),
            ),
          ],
        ),
      );
    } catch (e) {
      ToastService.showError(
          context, 'Failed to select photo: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 25.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with love theme
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: widget.heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.heartAnimation.value,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.primaryPink,
                      size: 28.w,
                    ),
                  );
                },
              ),
              SizedBox(width: 12.w),
              Text(
                'Create Your Future Baby',
                style: BabyFont.headingM.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12.w),
              AnimatedBuilder(
                animation: widget.heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.heartAnimation.value,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.primaryPink,
                      size: 28.w,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Upload your photos and watch the magic happen ✨',
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),

          // Beautiful circular avatars
          Row(
            children: [
              Expanded(
                child: PhotoAvatarWidget(
                  label: 'Male 👨',
                  photo: widget.malePhoto,
                  color: AppTheme.primaryBlue,
                  onTap: () => _selectPhoto(true),
                ),
              ),
              SizedBox(width: 8.w),
              const LoveConnectorWidget(),
              SizedBox(width: 8.w),
              Expanded(
                child: PhotoAvatarWidget(
                  label: 'Female 👩',
                  photo: widget.femalePhoto,
                  color: AppTheme.primaryPink,
                  onTap: () => _selectPhoto(false),
                ),
              ),
            ],
          ),

          SizedBox(height: 30.h),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canGenerateBaby() ? widget.onGenerateBaby : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canGenerateBaby()
                    ? AppTheme.primaryPink
                    : Colors.grey.withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                elevation: _canGenerateBaby() ? 8 : 0,
                shadowColor: AppTheme.primaryPink.withValues(alpha: 0.3),
              ),
              child: widget.isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Creating Magic...',
                          style: BabyFont.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 20.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Generate Our Baby 👶',
                          style: BabyFont.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
