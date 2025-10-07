import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/loading_animation.dart';

/// BabyGenerationButton - Trigger AI generation
/// Only enabled when both avatars validated, shows friendly loading animation
class BabyGenerationButton extends StatefulWidget {
  final bool canGenerate;
  final bool isGenerating;
  final VoidCallback? onPressed;
  final String? errorMessage;

  const BabyGenerationButton({
    super.key,
    required this.canGenerate,
    required this.isGenerating,
    this.onPressed,
    this.errorMessage,
  });

  @override
  State<BabyGenerationButton> createState() => _BabyGenerationButtonState();
}

class _BabyGenerationButtonState extends State<BabyGenerationButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.canGenerate &&
        !widget.isGenerating &&
        widget.onPressed != null) {
      HapticFeedback.mediumImpact();
      widget.onPressed!();
    } else if (!widget.canGenerate) {
      HapticFeedback.lightImpact();
      _showRequirementMessage();
    }
  }

  void _showRequirementMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Please upload both parent photos with clear faces to generate your baby! 👶',
                style: BabyFont.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: widget.canGenerate && !widget.isGenerating
                    ? (_) => _animationController.forward()
                    : null,
                onTapUp: widget.canGenerate && !widget.isGenerating
                    ? (_) {
                        _animationController.reverse();
                        _handleTap();
                      }
                    : null,
                onTapCancel: () => _animationController.reverse(),
                onTap: widget.canGenerate && !widget.isGenerating
                    ? null
                    : _handleTap,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  decoration: BoxDecoration(
                    gradient: widget.canGenerate && !widget.isGenerating
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryPink,
                              AppTheme.primaryBlue,
                              AppTheme.accentYellow,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: widget.canGenerate && !widget.isGenerating
                        ? null
                        : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: widget.canGenerate && !widget.isGenerating
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryPink
                                  .withValues(alpha: _glowAnimation.value),
                              blurRadius: 15.r,
                              offset: Offset(0, 5.h),
                              spreadRadius: 2.r,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isGenerating) ...[
                        LoadingAnimation(
                          size: 24.w,
                          color: Colors.white,
                          type: LoadingType.hearts,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Creating Magic...',
                          style: BabyFont.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: BabyFont.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 24.w,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          widget.canGenerate
                              ? 'Generate Baby Face'
                              : 'Upload Photos First',
                          style: BabyFont.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: BabyFont.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Error message display
        if (widget.errorMessage != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.error.withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.error,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.errorMessage!,
                    style: BabyFont.bodySmall.copyWith(
                      color: AppTheme.error,
                      fontWeight: BabyFont.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Helpful tips when not ready
        if (!widget.canGenerate && !widget.isGenerating) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentYellow.withValues(alpha: 0.1),
                  AppTheme.primaryPink.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 20.sp)),
                    SizedBox(width: 8.w),
                    Text(
                      'Quick Tips:',
                      style: BabyFont.titleSmall.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: BabyFont.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                _buildTip('📸', 'Use clear, well-lit photos'),
                _buildTip('👤', 'Ensure faces are clearly visible'),
                _buildTip('💕', 'Both parents needed for best results'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: BabyFont.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
