import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';

/// ScoreWidget - Shows current score & leaderboard
/// Fun, visual feedback for each correct answer
class ScoreWidget extends StatefulWidget {
  final int currentScore;
  final int maxScore;
  final int streak;
  final bool isCorrectAnswer;
  final VoidCallback? onScoreUpdate;

  const ScoreWidget({
    super.key,
    required this.currentScore,
    required this.maxScore,
    this.streak = 0,
    this.isCorrectAnswer = false,
    this.onScoreUpdate,
  });

  @override
  State<ScoreWidget> createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<ScoreWidget>
    with TickerProviderStateMixin {
  late final AnimationController _scoreController;
  late final AnimationController _streakController;
  late final AnimationController _celebrationController;

  late final Animation<double> _scoreAnimation;
  late final Animation<double> _streakAnimation;
  late final Animation<double> _celebrationAnimation;
  late final Animation<Offset> _floatingAnimation;

  int _displayScore = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _displayScore = widget.currentScore;
  }

  void _initAnimations() {
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _streakController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.elasticOut,
    );

    _streakAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _streakController, curve: Curves.easeInOut),
    );

    _celebrationAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeOut,
    );

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(ScoreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate score increase
    if (oldWidget.currentScore != widget.currentScore) {
      _animateScoreIncrease(oldWidget.currentScore, widget.currentScore);
    }

    // Animate streak
    if (oldWidget.streak != widget.streak && widget.streak > 0) {
      _streakController.forward().then((_) {
        _streakController.reverse();
      });
    }

    // Celebrate correct answer
    if (widget.isCorrectAnswer && !oldWidget.isCorrectAnswer) {
      _celebrateCorrectAnswer();
    }
  }

  void _animateScoreIncrease(int oldScore, int newScore) {
    HapticFeedback.lightImpact();

    _scoreController.forward().then((_) {
      _scoreController.reverse();
    });

    // Animate score counting
    final scoreDiff = newScore - oldScore;
    if (scoreDiff > 0) {
      _animateScoreCounting(oldScore, newScore, scoreDiff);
    }
  }

  void _animateScoreCounting(int startScore, int endScore, int diff) {
    const duration = Duration(milliseconds: 500);
    const steps = 20;
    final stepValue = diff / steps;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(
          Duration(milliseconds: (duration.inMilliseconds * i / steps).round()),
          () {
        if (mounted) {
          setState(() {
            _displayScore = (startScore + (stepValue * i)).round();
            if (i == steps) _displayScore = endScore;
          });
        }
      });
    }
  }

  void _celebrateCorrectAnswer() {
    HapticFeedback.mediumImpact();
    _celebrationController.forward().then((_) {
      _celebrationController.reset();
    });
    widget.onScoreUpdate?.call();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _streakController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentYellow.withValues(alpha: 0.1),
            AppTheme.primaryPink.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.accentYellow.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Main score display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScoreDisplay(),
                  _buildStreakDisplay(),
                ],
              ),

              SizedBox(height: 12.h),

              // Score progress bar
              _buildScoreProgress(),

              SizedBox(height: 8.h),

              // Achievement indicators
              _buildAchievementIndicators(),
            ],
          ),

          // Floating celebration effects
          if (_celebrationController.isAnimating) ..._buildCelebrationEffects(),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_scoreAnimation.value * 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score',
                style: BabyFont.labelMedium.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: BabyFont.medium,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    '$_displayScore',
                    style: BabyFont.displaySmall.copyWith(
                      color: AppTheme.accentYellow,
                      fontWeight: BabyFont.extraBold,
                      fontSize: 28.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.star_rounded,
                    color: AppTheme.accentYellow,
                    size: 20.w,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakDisplay() {
    if (widget.streak <= 0) return const SizedBox();

    return AnimatedBuilder(
      animation: _streakAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _streakAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryPink, AppTheme.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.3),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 16.w,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${widget.streak}',
                  style: BabyFont.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: BabyFont.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreProgress() {
    final progress =
        widget.maxScore > 0 ? _displayScore / widget.maxScore : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: BabyFont.labelSmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '${(_displayScore / widget.maxScore * 100).toInt()}%',
              style: BabyFont.labelSmall.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: BabyFont.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: 6.h,
          decoration: BoxDecoration(
            color: AppTheme.accentYellow.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                LinearGradient(
                  colors: [AppTheme.accentYellow, AppTheme.primaryPink],
                ).colors.first,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementIndicators() {
    final achievements = <String>[];

    if (widget.streak >= 3) achievements.add('🔥 Hot Streak!');
    if (_displayScore >= widget.maxScore * 0.8) {
      achievements.add('⭐ High Score!');
    }
    if (widget.streak >= 5) achievements.add('💎 Perfect Run!');

    if (achievements.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8.w,
      children: achievements.map((achievement) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.success.withValues(alpha: 0.3),
              width: 1.w,
            ),
          ),
          child: Text(
            achievement,
            style: BabyFont.labelSmall.copyWith(
              color: AppTheme.success,
              fontWeight: BabyFont.medium,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildCelebrationEffects() {
    return List.generate(5, (index) {
      final angle = (index * 72.0) * (3.14159 / 180); // 72 degrees apart
      final radius = 40.w;

      return AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Positioned(
            left: 100.w +
                (radius * (1 + _celebrationAnimation.value)) *
                    (index.isEven ? 1 : -1) *
                    (angle < 3.14159 ? 1 : -1),
            top: 50.h +
                (radius * (1 + _celebrationAnimation.value)) *
                    (index % 3 == 0 ? 1 : -1) *
                    _floatingAnimation.value.dy,
            child: Opacity(
              opacity: 1.0 - _celebrationAnimation.value,
              child: Transform.rotate(
                angle: _celebrationAnimation.value * 2 * 3.14159,
                child: Text(
                  ['+10', '🎉', '⭐', '💕', '🔥'][index],
                  style: TextStyle(
                    fontSize: (16 + index * 2).sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
