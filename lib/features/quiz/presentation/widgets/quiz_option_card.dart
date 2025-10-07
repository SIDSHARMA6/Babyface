import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';

/// Quiz option card with selection animation
class QuizOptionCard extends StatefulWidget {
  final String option;
  final int index;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const QuizOptionCard({
    super.key,
    required this.option,
    required this.index,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  State<QuizOptionCard> createState() => _QuizOptionCardState();
}

class _QuizOptionCardState extends State<QuizOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
              padding: AppTheme.cardPadding(context),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.color.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                border: Border.all(
                  color:
                      widget.isSelected ? widget.color : AppTheme.borderLight,
                  width: widget.isSelected ? 2.w : 1.w,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  _buildSelectionIndicator(),
                  SizedBox(width: AppTheme.mediumSpacing),
                  Expanded(
                    child: Text(
                      widget.option,
                      style: BabyFont.bodyLarge.copyWith(
                        color: widget.isSelected
                            ? widget.color
                            : AppTheme.textPrimary,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isSelected ? widget.color : Colors.transparent,
        border: Border.all(
          color: widget.isSelected ? widget.color : AppTheme.borderLight,
          width: 2.w,
        ),
      ),
      child: widget.isSelected
          ? Icon(
              Icons.check,
              color: Colors.white,
              size: 16.w,
            )
          : null,
    );
  }
}
