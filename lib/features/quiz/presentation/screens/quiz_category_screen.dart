import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/responsive_widgets.dart';
import '../../domain/models/quiz_models.dart';
import 'quiz_level_screen.dart';

/// Screen showing levels for a specific quiz category
class QuizCategoryScreen extends ConsumerStatefulWidget {
  final QuizCategoryModel category;

  const QuizCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<QuizCategoryScreen> createState() => _QuizCategoryScreenState();
}

class _QuizCategoryScreenState extends ConsumerState<QuizCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(widget.category.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: BabyFont.headlineMedium.copyWith(color: AppTheme.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: categoryColor),
            onPressed: () => _showCategoryInfo(),
          ),
        ],
      ),
      body: ResponsivePadding(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryHeader(categoryColor),
              SizedBox(height: AppTheme.largeSpacing),
              _buildProgressOverview(categoryColor),
              SizedBox(height: AppTheme.largeSpacing),
              _buildLevelsList(categoryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(Color categoryColor) {
    return Container(
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.1),
            categoryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
            ),
            child: Icon(
              _getCategoryIcon(widget.category.category),
              color: categoryColor,
              size: 40.w,
            ),
          ),
          SizedBox(width: AppTheme.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.title,
                  style: BabyFont.displaySmall
                      .copyWith(color: AppTheme.textPrimary),
                ),
                SizedBox(height: AppTheme.smallSpacing),
                Text(
                  widget.category.description,
                  style: BabyFont.bodyMedium
                      .copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(Color categoryColor) {
    return Container(
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
                Icons.trending_up_rounded,
                color: categoryColor,
                size: 24.w,
              ),
              SizedBox(width: AppTheme.smallSpacing),
              Text(
                'Your Progress',
                style:
                    BabyFont.titleLarge.copyWith(color: AppTheme.textPrimary),
              ),
            ],
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Levels Completed',
                  '${widget.category.completedLevels}/${widget.category.totalLevels}',
                  Icons.check_circle_rounded,
                  categoryColor,
                ),
              ),
              SizedBox(width: AppTheme.mediumSpacing),
              Expanded(
                child: _buildProgressItem(
                  'Total Score',
                  '${widget.category.totalScore}',
                  Icons.star_rounded,
                  AppTheme.accentYellow,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Progress',
                    style: BabyFont.titleSmall
                        .copyWith(color: AppTheme.textPrimary),
                  ),
                  Text(
                    '${widget.category.progressPercentage.toInt()}%',
                    style: BabyFont.titleSmall.copyWith(
                      color: categoryColor,
                      fontWeight: BabyFont.semiBold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.smallSpacing),
              LinearProgressIndicator(
                value: widget.category.progressPercentage / 100,
                backgroundColor: categoryColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                minHeight: 6.h,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: AppTheme.smallSpacing),
          Text(
            value,
            style: BabyFont.titleMedium.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: BabyFont.semiBold,
            ),
          ),
          Text(
            title,
            style: BabyFont.labelSmall.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsList(Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Levels',
          style: BabyFont.headlineSmall.copyWith(color: AppTheme.textPrimary),
        ),
        SizedBox(height: AppTheme.mediumSpacing),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.category.levels.length,
          itemBuilder: (context, index) {
            final level = widget.category.levels[index];
            return _buildLevelCard(level, categoryColor, index);
          },
        ),
      ],
    );
  }

  Widget _buildLevelCard(QuizLevel level, Color categoryColor, int index) {
    final isUnlocked =
        level.isUnlocked || index == 0; // First level always unlocked
    final isCompleted = level.isCompleted;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
      child: GestureDetector(
        onTap: isUnlocked ? () => _openLevel(level) : null,
        child: AnimatedContainer(
          duration: AppTheme.fastAnimation,
          padding: AppTheme.cardPadding(context),
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppTheme.surfaceLight
                : AppTheme.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            border: Border.all(
              color: isCompleted
                  ? categoryColor
                  : isUnlocked
                      ? categoryColor.withValues(alpha: 0.2)
                      : AppTheme.borderLight,
              width: isCompleted ? 2.w : 1.w,
            ),
            boxShadow: isUnlocked ? AppTheme.softShadow : [],
          ),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? categoryColor
                      : isUnlocked
                          ? categoryColor.withValues(alpha: 0.1)
                          : AppTheme.borderLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : isUnlocked
                          ? Icons.play_arrow_rounded
                          : Icons.lock_rounded,
                  color: isCompleted
                      ? Colors.white
                      : isUnlocked
                          ? categoryColor
                          : AppTheme.textSecondary,
                  size: 30.w,
                ),
              ),
              SizedBox(width: AppTheme.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Level ${level.levelNumber}',
                          style: BabyFont.titleMedium.copyWith(
                            color: isUnlocked
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight: BabyFont.semiBold,
                          ),
                        ),
                        SizedBox(width: AppTheme.smallSpacing),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(level.difficulty)
                                .withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.smallRadius),
                          ),
                          child: Text(
                            _getDifficultyText(level.difficulty),
                            style: BabyFont.labelSmall.copyWith(
                              color: _getDifficultyColor(level.difficulty),
                              fontWeight: BabyFont.medium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      level.title,
                      style: BabyFont.titleSmall.copyWith(
                        color: isUnlocked
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      level.description,
                      style: BabyFont.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (isCompleted) ...[
                      SizedBox(height: AppTheme.smallSpacing),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppTheme.accentYellow,
                            size: 16.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Score: ${level.userScore}/${level.questions.length}',
                            style: BabyFont.labelSmall.copyWith(
                              color: AppTheme.accentYellow,
                              fontWeight: BabyFont.medium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isUnlocked)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textSecondary,
                  size: 16.w,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(QuizCategory category) {
    switch (category) {
      case QuizCategory.babyGame:
        return Icons.child_care_rounded;
      case QuizCategory.coupleGame:
        return Icons.favorite_rounded;
      case QuizCategory.partingGame:
        return Icons.extension_rounded;
      case QuizCategory.couplesGoals:
        return Icons.flag_rounded;
      case QuizCategory.knowEachOther:
        return Icons.psychology_rounded;
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
      case DifficultyLevel.expert:
        return Colors.purple;
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  void _openLevel(QuizLevel level) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizLevelScreen(
          category: widget.category,
          level: level,
        ),
      ),
    );
  }

  void _showCategoryInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCategoryInfoModal(),
    );
  }

  Widget _buildCategoryInfoModal() {
    final categoryColor = Color(widget.category.colorValue);

    return Container(
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
                    Icon(
                      _getCategoryIcon(widget.category.category),
                      color: categoryColor,
                      size: 24.w,
                    ),
                    SizedBox(width: AppTheme.smallSpacing),
                    Text(
                      'About ${widget.category.title}',
                      style: BabyFont.headlineSmall
                          .copyWith(color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.mediumSpacing),
                Text(
                  widget.category.description,
                  style: BabyFont.bodyMedium
                      .copyWith(color: AppTheme.textSecondary),
                ),
                SizedBox(height: AppTheme.largeSpacing),
                Text(
                  'How it works:',
                  style: BabyFont.titleMedium
                      .copyWith(color: AppTheme.textPrimary),
                ),
                SizedBox(height: AppTheme.smallSpacing),
                _buildInfoItem(
                    'Each level has 5 questions (4 multiple choice + 1 puzzle)'),
                _buildInfoItem('Get all 5 correct to unlock the next level'),
                _buildInfoItem('Difficulty increases with each level'),
                _buildInfoItem('Earn badges and points for completing levels'),
                SizedBox(height: AppTheme.largeSpacing),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.mediumRadius),
                      ),
                    ),
                    child: Text(
                      'Got it!',
                      style: BabyFont.titleMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.smallSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            margin: EdgeInsets.only(top: 8.h, right: 12.w),
            decoration: BoxDecoration(
              color: Color(widget.category.colorValue),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style:
                  BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
