import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/responsive_widgets.dart';
import '../../domain/models/quiz_item.dart';
import '../../domain/models/quiz_type.dart';

/// Quiz result screen with celebration animations and sharing options
class QuizResultScreen extends StatefulWidget {
  final QuizItem quiz;
  final String result;
  final int score;
  final Duration timeSpent;
  final VoidCallback onRetake;
  final VoidCallback onBackToQuizzes;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.result,
    required this.score,
    required this.timeSpent,
    required this.onRetake,
    required this.onBackToQuizzes,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _contentController;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _celebrationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Results',
          style: BabyFont.headlineMedium.copyWith(color: AppTheme.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ResponsivePadding(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCelebrationHeader(),
                    SizedBox(height: AppTheme.largeSpacing),
                    _buildScoreCard(),
                    SizedBox(height: AppTheme.largeSpacing),
                    _buildResultCard(),
                    SizedBox(height: AppTheme.largeSpacing),
                    _buildStatsCard(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
            SizedBox(height: AppTheme.largeSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationHeader() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _celebrationAnimation.value,
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.quiz.color,
                  widget.quiz.color.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.quiz.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.celebration_rounded,
              size: 60.w,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value.clamp(0.0, 1.0),
            child: Container(
              padding: AppTheme.cardPadding(context),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.quiz.color.withValues(alpha: 0.1),
                    widget.quiz.color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                border: Border.all(
                  color: widget.quiz.color.withValues(alpha: 0.2),
                  width: 2.w,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Quiz Complete!',
                    style: BabyFont.displaySmall.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTheme.mediumSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreItem('Score', '${widget.score}', Icons.star),
                      _buildScoreItem(
                          'Time', _formatTime(widget.timeSpent), Icons.timer),
                      _buildScoreItem(
                          'Rank', _getPerformanceRank(), Icons.emoji_events),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: widget.quiz.color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: widget.quiz.color,
            size: 24.w,
          ),
        ),
        SizedBox(height: AppTheme.smallSpacing),
        Text(
          value,
          style: BabyFont.titleLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
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

  Widget _buildResultCard() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value.clamp(0.0, 1.0),
            child: Container(
              padding: AppTheme.cardPadding(context),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.quiz.icon,
                        color: widget.quiz.color,
                        size: 24.w,
                      ),
                      SizedBox(width: AppTheme.smallSpacing),
                      Text(
                        widget.quiz.title,
                        style: BabyFont.headlineSmall.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.largeSpacing),
                  Text(
                    widget.result,
                    style: BabyFont.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 70 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value.clamp(0.0, 1.0),
            child: Container(
              padding: AppTheme.cardPadding(context),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz Statistics',
                    style: BabyFont.titleLarge.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.mediumSpacing),
                  _buildStatRow(
                      'Questions Answered', '${widget.quiz.questionsCount}'),
                  _buildStatRow(
                      'Difficulty Level', widget.quiz.difficulty.displayName),
                  _buildStatRow('Category', widget.quiz.type.category),
                  _buildStatRow(
                      'Max Possible Score', '${widget.quiz.maxScore}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: BabyFont.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: BabyFont.titleSmall.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onBackToQuizzes,
                icon: Icon(Icons.arrow_back, size: 18.w),
                label: Text('Back to Quizzes'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.quiz.color),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppTheme.mediumSpacing),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onRetake,
                icon: Icon(Icons.refresh, size: 18.w),
                label: Text('Retake Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.quiz.color,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.mediumSpacing),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareResult,
            icon: Icon(Icons.share, size: 18.w),
            label: Text('Share Result'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String _getPerformanceRank() {
    final percentage = (widget.score / widget.quiz.maxScore * 100);
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    return 'D';
  }

  void _shareResult() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing feature coming soon!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }
}
