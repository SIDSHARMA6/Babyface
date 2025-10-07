import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/loading_animation.dart';
import '../providers/dashboard_provider.dart';

/// BabyAvatarWidget - Display generated baby image
/// Animated reveal, percentage matching, option to save/share
class BabyAvatarWidget extends StatefulWidget {
  final BabyResult? babyResult;
  final bool isGenerating;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onRegenerate;

  const BabyAvatarWidget({
    super.key,
    this.babyResult,
    required this.isGenerating,
    this.onSave,
    this.onShare,
    this.onRegenerate,
  });

  @override
  State<BabyAvatarWidget> createState() => _BabyAvatarWidgetState();
}

class _BabyAvatarWidgetState extends State<BabyAvatarWidget>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _revealController;
  late final AnimationController _sparkleController;

  late final Animation<double> _pulseAnimation;

  late final Animation<double> _sparkleAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.elasticOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    // Start pulse animation for placeholder
    if (widget.babyResult == null && !widget.isGenerating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BabyAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger reveal animation when baby is generated
    if (oldWidget.babyResult == null && widget.babyResult != null) {
      _pulseController.stop();
      _revealController.forward();
      _sparkleController.forward();
      HapticFeedback.mediumImpact();
    }

    // Start pulse for placeholder
    if (widget.babyResult == null && !widget.isGenerating) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _revealController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main baby avatar container
        Stack(
          alignment: Alignment.center,
          children: [
            // Main avatar circle
            AnimatedBuilder(
              animation:
                  widget.babyResult != null ? _scaleAnimation : _pulseAnimation,
              builder: (context, child) {
                final scale = widget.babyResult != null
                    ? _scaleAnimation.value
                    : _pulseAnimation.value;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 140.w,
                    height: 140.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.babyResult != null
                          ? LinearGradient(
                              colors: [
                                AppTheme.accentYellow,
                                AppTheme.primaryPink,
                                AppTheme.primaryBlue,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      border: Border.all(
                        color: AppTheme.accentYellow,
                        width: 4.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentYellow.withValues(alpha: 0.4),
                          blurRadius: 15.r,
                          offset: Offset(0, 5.h),
                          spreadRadius: 2.r,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildAvatarContent(),
                    ),
                  ),
                );
              },
            ),

            // Sparkle effects for generated baby
            if (widget.babyResult != null)
              AnimatedBuilder(
                animation: _sparkleAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _sparkleAnimation.value,
                    child: _buildSparkleEffects(),
                  );
                },
              ),

            // Loading overlay
            if (widget.isGenerating)
              Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimation(
                        size: 40.w,
                        color: Colors.white,
                        type: LoadingType.hearts,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Creating...',
                        style: BabyFont.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: BabyFont.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: 16.h),

        // Baby info and actions
        if (widget.babyResult != null) ...[
          _buildBabyInfo(),
          SizedBox(height: 16.h),
          _buildActionButtons(),
        ] else if (!widget.isGenerating) ...[
          _buildPlaceholderText(),
        ],
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (widget.babyResult?.babyImagePath != null) {
      return Image.file(
        File(widget.babyResult!.babyImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderContent();
        },
      );
    } else {
      return _buildPlaceholderContent();
    }
  }

  Widget _buildPlaceholderContent() {
    return Container(
      color: AppTheme.accentYellow.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care_rounded,
            size: 50.w,
            color: AppTheme.accentYellow,
          ),
          SizedBox(height: 8.h),
          Text(
            'Future Baby',
            style: BabyFont.labelMedium.copyWith(
              color: AppTheme.accentYellow,
              fontWeight: BabyFont.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkleEffects() {
    return SizedBox(
      width: 200.w,
      height: 200.w,
      child: Stack(
        children: List.generate(8, (index) {
          final angle = (index * 45.0) * (3.14159 / 180);
          final radius = 80.w;
          final x = radius *
              0.8 *
              (1 + 0.2 * _sparkleAnimation.value) *
              (index.isEven ? 1 : -1) *
              (angle < 3.14159 ? 1 : -1);
          final y = radius *
              0.8 *
              (1 + 0.2 * _sparkleAnimation.value) *
              (index % 3 == 0 ? 1 : -1) *
              (angle > 1.57 && angle < 4.71 ? 1 : -1);

          return Positioned(
            left: 100.w + x,
            top: 100.w + y,
            child: Transform.rotate(
              angle: _sparkleAnimation.value * 2 * 3.14159,
              child: Icon(
                index.isEven ? Icons.star : Icons.favorite,
                color: [
                  AppTheme.accentYellow,
                  AppTheme.primaryPink,
                  AppTheme.primaryBlue,
                ][index % 3],
                size: (12 + (index % 3) * 4).w,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBabyInfo() {
    final babyResult = widget.babyResult!;
    final totalMatch =
        babyResult.maleMatchPercentage + babyResult.femaleMatchPercentage;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.primaryBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.accentYellow.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('🎉', style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 8.w),
              Text(
                'Your Future Baby!',
                style: BabyFont.titleMedium.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: BabyFont.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMatchInfo(
                'Dad Match',
                babyResult.maleMatchPercentage,
                AppTheme.primaryBlue,
                Icons.person,
              ),
              Container(
                width: 1.w,
                height: 40.h,
                color: AppTheme.borderColor,
              ),
              _buildMatchInfo(
                'Mom Match',
                babyResult.femaleMatchPercentage,
                AppTheme.primaryPink,
                Icons.person_outline,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.accentYellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Overall Match: $totalMatch%',
              style: BabyFont.labelMedium.copyWith(
                color: AppTheme.accentYellow,
                fontWeight: BabyFont.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfo(
      String label, int percentage, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.w),
        SizedBox(height: 4.h),
        Text(
          '$percentage%',
          style: BabyFont.titleSmall.copyWith(
            color: color,
            fontWeight: BabyFont.bold,
          ),
        ),
        Text(
          label,
          style: BabyFont.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.save_alt_rounded,
          label: 'Save',
          color: AppTheme.primaryBlue,
          onTap: widget.onSave,
        ),
        _buildActionButton(
          icon: Icons.share_rounded,
          label: 'Share',
          color: AppTheme.primaryPink,
          onTap: widget.onShare,
        ),
        _buildActionButton(
          icon: Icons.refresh_rounded,
          label: 'Retry',
          color: AppTheme.accentYellow,
          onTap: widget.onRegenerate,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20.w),
            SizedBox(height: 4.h),
            Text(
              label,
              style: BabyFont.labelSmall.copyWith(
                color: color,
                fontWeight: BabyFont.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderText() {
    return Column(
      children: [
        Text(
          'Your Future Baby',
          style: BabyFont.titleLarge.copyWith(
            color: AppTheme.accentYellow,
            fontWeight: BabyFont.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Upload both parent photos to see the magic! ✨',
          style: BabyFont.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
