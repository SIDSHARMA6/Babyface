import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../providers/couple_goals_providers.dart';
import 'dart:math' as math;

/// Animated love percentage meter with heart animations
class LovePercentageMeter extends ConsumerStatefulWidget {
  const LovePercentageMeter({super.key});

  @override
  ConsumerState<LovePercentageMeter> createState() =>
      _LovePercentageMeterState();
}

class _LovePercentageMeterState extends ConsumerState<LovePercentageMeter>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final lovePercentageState = ref.watch(lovePercentageProvider);

        return Container(
          padding: AppTheme.cardPadding(context),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPink.withValues(alpha: 0.1),
                AppTheme.primaryBlue.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            boxShadow: AppTheme.mediumShadow,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.primaryPink,
                    size: 24.w,
                  ),
                  SizedBox(width: AppTheme.smallSpacing),
                  Text(
                    'Love Score',
                    style: BabyFont.titleLarge
                        .copyWith(color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(lovePercentageState.currentPercentage)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                    child: Text(
                      lovePercentageState.status,
                      style: BabyFont.labelMedium.copyWith(
                        color: _getStatusColor(
                            lovePercentageState.currentPercentage),
                        fontWeight: BabyFont.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.largeSpacing),

              // Animated Love Meter
              Stack(
                alignment: Alignment.center,
                children: [
                  // Sparkle effects
                  AnimatedBuilder(
                    animation: _sparkleAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(200.w, 200.w),
                        painter: SparklePainter(
                          animation: _sparkleAnimation.value,
                          percentage: lovePercentageState.currentPercentage,
                        ),
                      );
                    },
                  ),

                  // Main circular progress
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: lovePercentageState.isAnimating
                            ? 1.0
                            : _pulseAnimation.value,
                        child: SizedBox(
                          width: 180.w,
                          height: 180.w,
                          child: CircularProgressIndicator(
                            value: lovePercentageState.currentPercentage / 100,
                            strokeWidth: 12.w,
                            backgroundColor: AppTheme.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(
                                  lovePercentageState.currentPercentage),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lovePercentageState.emoji,
                        style: TextStyle(fontSize: 40.sp),
                      ),
                      SizedBox(height: AppTheme.smallSpacing),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          '${lovePercentageState.currentPercentage.toInt()}%',
                          key: ValueKey(
                              lovePercentageState.currentPercentage.toInt()),
                          style: BabyFont.displayMedium.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: BabyFont.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: AppTheme.largeSpacing),

              // Progress description
              Text(
                _getProgressDescription(lovePercentageState.currentPercentage),
                style:
                    BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppTheme.mediumSpacing),

              // Action button
              if (lovePercentageState.currentPercentage < 100)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showImprovementTips(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.mediumRadius),
                      ),
                    ),
                    icon: Icon(Icons.tips_and_updates_rounded,
                        color: Colors.white, size: 20.w),
                    label: Text(
                      'Improve Love Score',
                      style: BabyFont.titleMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 90) return Colors.purple;
    if (percentage >= 75) return AppTheme.primaryPink;
    if (percentage >= 50) return AppTheme.primaryBlue;
    if (percentage >= 25) return AppTheme.accentYellow;
    return Colors.orange;
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 90) return Colors.purple;
    if (percentage >= 75) return AppTheme.primaryPink;
    if (percentage >= 50) return AppTheme.primaryBlue;
    if (percentage >= 25) return AppTheme.accentYellow;
    return Colors.orange;
  }

  String _getProgressDescription(double percentage) {
    if (percentage >= 90) {
      return 'You two are absolutely perfect together! Your bond is unbreakable! 👑💕';
    } else if (percentage >= 75) {
      return 'Your love is strong and beautiful! Keep nurturing your amazing relationship! 🌟💖';
    } else if (percentage >= 50) {
      return 'Your relationship is growing beautifully! You\'re on the right path! 🌸💗';
    } else if (percentage >= 25) {
      return 'You\'re building something special together! Keep exploring and learning! 🌱💓';
    } else {
      return 'Every great love story starts somewhere! Take more quizzes to grow closer! 💝';
    }
  }

  void _showImprovementTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.largeRadius),
            topRight: Radius.circular(AppTheme.largeRadius),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
            Padding(
              padding: AppTheme.cardPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded,
                          color: AppTheme.primaryPink),
                      SizedBox(width: AppTheme.smallSpacing),
                      Text(
                        'Improve Your Love Score',
                        style: BabyFont.headlineSmall
                            .copyWith(color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.largeSpacing),
                  _buildTip(
                      'Complete more quizzes together',
                      'Each quiz helps you understand each other better',
                      Icons.quiz_rounded),
                  _buildTip(
                      'Try different quiz categories',
                      'Explore Baby Games, Couple Games, and more!',
                      Icons.category_rounded),
                  _buildTip(
                      'Complete daily challenges',
                      'Small actions make a big difference in your bond',
                      Icons.task_alt_rounded),
                  _buildTip(
                      'Share your results',
                      'Celebrate your progress and milestones together',
                      Icons.share_rounded),
                  SizedBox(height: AppTheme.largeSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPink,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.mediumRadius),
                        ),
                      ),
                      child: Text(
                        'Let\'s Do This! 💕',
                        style:
                            BabyFont.titleMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String title, String description, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryPink, size: 20.w),
          ),
          SizedBox(width: AppTheme.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      BabyFont.titleSmall.copyWith(color: AppTheme.textPrimary),
                ),
                Text(
                  description,
                  style: BabyFont.bodySmall
                      .copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for sparkle effects around the love meter
class SparklePainter extends CustomPainter {
  final double animation;
  final double percentage;

  SparklePainter({required this.animation, required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    if (percentage < 25) return; // Only show sparkles for higher love scores

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw sparkles at different positions
    for (int i = 0; i < 8; i++) {
      final angle = (animation + (i * math.pi / 4)) % (2 * math.pi);
      final sparkleRadius = radius + 20 + (math.sin(animation * 3 + i) * 10);

      final x = center.dx + math.cos(angle) * sparkleRadius;
      final y = center.dy + math.sin(angle) * sparkleRadius;

      final sparkleSize = 3 + (math.sin(animation * 4 + i) * 2);

      // Draw star-like sparkle
      _drawStar(canvas, Offset(x, y), sparkleSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - (math.pi / 2);
      final outerRadius = size;
      final innerRadius = size * 0.4;

      if (i == 0) {
        path.moveTo(
          center.dx + math.cos(angle) * outerRadius,
          center.dy + math.sin(angle) * outerRadius,
        );
      } else {
        path.lineTo(
          center.dx + math.cos(angle) * outerRadius,
          center.dy + math.sin(angle) * outerRadius,
        );
      }

      final innerAngle = angle + (math.pi / 5);
      path.lineTo(
        center.dx + math.cos(innerAngle) * innerRadius,
        center.dy + math.sin(innerAngle) * innerRadius,
      );
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
