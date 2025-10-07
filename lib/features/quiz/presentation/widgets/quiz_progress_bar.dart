import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';

/// Animated progress bar for quiz progression
class QuizProgressBar extends StatefulWidget {
  final int currentQuestion;
  final int totalQuestions;
  final double progress;
  final Color color;

  const QuizProgressBar({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.progress,
    required this.color,
  });

  @override
  State<QuizProgressBar> createState() => _QuizProgressBarState();
}

class _QuizProgressBarState extends State<QuizProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(QuizProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${widget.currentQuestion}',
              style: BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
            ),
            Text(
              '${widget.currentQuestion}/${widget.totalQuestions}',
              style:
                  BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
        SizedBox(height: AppTheme.mediumSpacing),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
              minHeight: 8.h,
            );
          },
        ),
      ],
    );
  }
}
