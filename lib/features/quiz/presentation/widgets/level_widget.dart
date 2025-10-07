import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/loading_animation.dart';

/// LevelWidget - Displays 4 questions + puzzle
/// Animated progression, difficulty scaling
class LevelWidget extends StatefulWidget {
  final int currentLevel;
  final int currentQuestionIndex;
  final int totalQuestions;
  final int score;
  final bool isPuzzleQuestion;
  final VoidCallback? onLevelUp;

  const LevelWidget({
    super.key,
    required this.currentLevel,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.score,
    this.isPuzzleQuestion = false,
    this.onLevelUp,
  });

  @override
  State<LevelWidget> createState() => _LevelWidgetState();
}

class _LevelWidgetState extends State<LevelWidget>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _levelUpController;
  late final Animation<double> _progressAnimation;
  late final Animation<double> _levelUpAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _levelUpController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );

    _levelUpAnimation = CurvedAnimation(
      parent: _levelUpController,
      curve: Curves.elasticOut,
    );

    _progressController.forward();
  }

  @override
  void didUpdateWidget(LevelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger level up animation
    if (oldWidget.currentLevel != widget.currentLevel) {
      _levelUpController.forward().then((_) {
        HapticFeedback.mediumImpact();
        widget.onLevelUp?.call();
      });
    }

    // Update progress animation
    if (oldWidget.currentQuestionIndex != widget.currentQuestionIndex) {
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _levelUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.primaryBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: widget.isPuzzleQuestion
              ? AppTheme.accentYellow
              : AppTheme.primaryPink.withValues(alpha: 0.3),
          width: 2.w,
        ),
      ),
      child: Column(
        children: [
          // Level header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLevelBadge(),
              _buildScoreDisplay(),
            ],
          ),

          SizedBox(height: 16.h),

          // Progress indicators
          _buildProgressIndicators(),

          SizedBox(height: 12.h),

          // Question type indicator
          if (widget.isPuzzleQuestion) _buildPuzzleIndicator(),

          // Level up animation overlay
          if (_levelUpController.isAnimating)
            AnimatedBuilder(
              animation: _levelUpAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _levelUpAnimation.value,
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 32.w,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Level Up!',
                          style: BabyFont.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: BabyFont.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
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
            Icons.emoji_events_rounded,
            color: Colors.white,
            size: 16.w,
          ),
          SizedBox(width: 4.w),
          Text(
            'Level ${widget.currentLevel}',
            style: BabyFont.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: BabyFont.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppTheme.accentYellow.withValues(alpha: 0.5),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: AppTheme.accentYellow,
            size: 16.w,
          ),
          SizedBox(width: 4.w),
          Text(
            '${widget.score} pts',
            style: BabyFont.labelMedium.copyWith(
              color: AppTheme.accentYellow,
              fontWeight: BabyFont.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Column(
      children: [
        // Question progress text
        Text(
          'Question ${widget.currentQuestionIndex + 1} of ${widget.totalQuestions}',
          style: BabyFont.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: BabyFont.medium,
          ),
        ),

        SizedBox(height: 8.h),

        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.totalQuestions, (index) {
            return AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final isCompleted = index < widget.currentQuestionIndex;
                final isCurrent = index == widget.currentQuestionIndex;
                final isPuzzle = index ==
                    widget.totalQuestions - 1; // Last question is puzzle

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: isPuzzle ? 16.w : 12.w,
                  height: isPuzzle ? 16.w : 12.w,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.success
                        : isCurrent
                            ? AppTheme.primaryPink
                            : AppTheme.borderColor,
                    shape: isPuzzle ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: isPuzzle ? BorderRadius.circular(4.r) : null,
                    border: isCurrent
                        ? Border.all(
                            color: AppTheme.primaryPink,
                            width: 2.w,
                          )
                        : null,
                  ),
                  child: isPuzzle && (isCompleted || isCurrent)
                      ? Icon(
                          Icons.extension_rounded,
                          color: Colors.white,
                          size: 10.w,
                        )
                      : null,
                );
              },
            );
          }),
        ),

        SizedBox(height: 12.h),

        // Progress bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            final progress = widget.totalQuestions > 0
                ? (widget.currentQuestionIndex / widget.totalQuestions) *
                    _progressAnimation.value
                : 0.0;

            return Container(
              width: double.infinity,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    widget.isPuzzleQuestion
                        ? AppTheme.accentYellow
                        : AppTheme.primaryPink,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPuzzleIndicator() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.accentYellow.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimation(
            size: 20.w,
            color: AppTheme.accentYellow,
            type: LoadingType.bouncing,
          ),
          SizedBox(width: 8.w),
          Text(
            'Puzzle Challenge!',
            style: BabyFont.titleSmall.copyWith(
              color: AppTheme.accentYellow,
              fontWeight: BabyFont.bold,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.extension_rounded,
            color: AppTheme.accentYellow,
            size: 20.w,
          ),
        ],
      ),
    );
  }
}
