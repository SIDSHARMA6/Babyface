import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../domain/models/quiz_item.dart';
import '../../domain/models/quiz_type.dart';

/// Industry-level quiz card widget with animations, accessibility,
/// and premium indicators following Flutter best practices
class QuizCard extends StatefulWidget {
  final QuizItem quiz;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showStats;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.isSelected,
    required this.onTap,
    this.showStats = true,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                boxShadow: [
                  BoxShadow(
                    color: widget.quiz.color.withValues(alpha: 0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
                border: Border.all(
                  color: widget.isSelected
                      ? widget.quiz.color
                      : Colors.transparent,
                  width: 2.w,
                ),
              ),
              child: _buildCardContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: AppTheme.cardPadding(context),
      child: Row(
        children: [
          _buildIconSection(),
          SizedBox(width: AppTheme.mediumSpacing),
          Expanded(child: _buildContentSection()),
          _buildTrailingSection(),
        ],
      ),
    );
  }

  Widget _buildIconSection() {
    return Stack(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: widget.quiz.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
            border: Border.all(
              color: widget.quiz.color.withValues(alpha: 0.2),
              width: 1.w,
            ),
          ),
          child: Icon(
            widget.quiz.icon,
            color: widget.quiz.color,
            size: 30.w,
          ),
        ),
        if (widget.quiz.isPremium)
          Positioned(
            top: -2.h,
            right: -2.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.accentYellow,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: 12.w,
              ),
            ),
          ),
        if (widget.quiz.isTrending)
          Positioned(
            bottom: -2.h,
            right: -2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'HOT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.quiz.title,
                style: BabyFont.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppTheme.smallSpacing),
            _buildDifficultyBadge(),
          ],
        ),
        SizedBox(height: AppTheme.smallSpacing),
        Text(
          widget.quiz.description,
          style: BabyFont.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.showStats) ...[
          SizedBox(height: AppTheme.smallSpacing),
          _buildStatsRow(),
        ],
      ],
    );
  }

  Widget _buildDifficultyBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: widget.quiz.difficultyColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        border: Border.all(
          color: widget.quiz.difficultyColor.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Text(
        widget.quiz.difficulty.displayName,
        style: BabyFont.labelSmall.copyWith(
          color: widget.quiz.difficultyColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem(
          Icons.quiz_rounded,
          '${widget.quiz.questionsCount}Q',
          AppTheme.textSecondary,
        ),
        SizedBox(width: AppTheme.mediumSpacing),
        _buildStatItem(
          Icons.access_time_rounded,
          widget.quiz.estimatedTimeString,
          AppTheme.textSecondary,
        ),
        SizedBox(width: AppTheme.mediumSpacing),
        _buildStatItem(
          Icons.star_rounded,
          '${widget.quiz.maxScore}pts',
          AppTheme.accentYellow,
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.w,
          color: color,
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: BabyFont.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: widget.isSelected ? widget.quiz.color : AppTheme.textSecondary,
          size: 16.w,
        ),
        if (widget.quiz.isNew) ...[
          SizedBox(height: AppTheme.smallSpacing),
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
