import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/responsive_widgets.dart';
import '../../domain/models/quiz_models.dart';

/// Screen for playing a specific quiz level
class QuizLevelScreen extends ConsumerStatefulWidget {
  final QuizCategoryModel category;
  final QuizLevel level;

  const QuizLevelScreen({
    super.key,
    required this.category,
    required this.level,
  });

  @override
  ConsumerState<QuizLevelScreen> createState() => _QuizLevelScreenState();
}

class _QuizLevelScreenState extends ConsumerState<QuizLevelScreen> {
  int _currentQuestionIndex = 0;
  List<int> _userAnswers = [];
  int _score = 0;
  bool _isCompleted = false;
  bool _showExplanation = false;

  @override
  void initState() {
    super.initState();
    _userAnswers = List.filled(widget.level.questions.length, -1);
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(widget.category.colorValue);

    if (_isCompleted) {
      return _buildResultScreen(categoryColor);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.level.title} - Level ${widget.level.levelNumber}',
          style: BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppTheme.textPrimary),
          onPressed: () => _showExitDialog(),
        ),
      ),
      body: ResponsivePadding(
        child: Column(
          children: [
            _buildProgressBar(categoryColor),
            SizedBox(height: AppTheme.largeSpacing),
            Expanded(
              child: _showExplanation
                  ? _buildExplanationView(categoryColor)
                  : _buildQuestionView(categoryColor),
            ),
            _buildNavigationButtons(categoryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(Color categoryColor) {
    final progress =
        (_currentQuestionIndex + 1) / widget.level.questions.length;

    return Container(
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${widget.level.questions.length}',
                style:
                    BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: BabyFont.titleMedium.copyWith(
                  color: categoryColor,
                  fontWeight: BabyFont.semiBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: categoryColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            minHeight: 6.h,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(Color categoryColor) {
    final currentQuestion = widget.level.questions[_currentQuestionIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getQuestionTypeIcon(currentQuestion.type),
                        color: categoryColor,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(width: AppTheme.mediumSpacing),
                    Expanded(
                      child: Text(
                        _getQuestionTypeText(currentQuestion.type),
                        style:
                            BabyFont.titleSmall.copyWith(color: categoryColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.largeSpacing),
                Text(
                  currentQuestion.question,
                  style: BabyFont.headlineSmall
                      .copyWith(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.largeSpacing),
          if (currentQuestion.type == QuestionType.multipleChoice)
            _buildMultipleChoiceOptions(currentQuestion, categoryColor)
          else if (currentQuestion.type == QuestionType.puzzle)
            _buildPuzzleView(currentQuestion, categoryColor)
          else if (currentQuestion.type == QuestionType.matching)
            _buildMatchingView(currentQuestion, categoryColor)
          else if (currentQuestion.type == QuestionType.dragDrop)
            _buildDragDropView(currentQuestion, categoryColor),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(
      QuizQuestion question, Color categoryColor) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = _userAnswers[_currentQuestionIndex] == index;

        return Container(
          margin: EdgeInsets.only(bottom: AppTheme.mediumSpacing),
          child: GestureDetector(
            onTap: () => _selectAnswer(index),
            child: AnimatedContainer(
              duration: AppTheme.fastAnimation,
              padding: AppTheme.cardPadding(context),
              decoration: BoxDecoration(
                color: isSelected
                    ? categoryColor.withValues(alpha: 0.1)
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                border: Border.all(
                  color: isSelected ? categoryColor : AppTheme.borderLight,
                  width: isSelected ? 2.w : 1.w,
                ),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: isSelected ? categoryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? categoryColor : AppTheme.borderLight,
                        width: 2.w,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16.w,
                          )
                        : null,
                  ),
                  SizedBox(width: AppTheme.mediumSpacing),
                  Expanded(
                    child: Text(
                      option,
                      style: BabyFont.bodyLarge.copyWith(
                        color:
                            isSelected ? categoryColor : AppTheme.textPrimary,
                        fontWeight:
                            isSelected ? BabyFont.semiBold : BabyFont.regular,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPuzzleView(QuizQuestion question, Color categoryColor) {
    // Simplified puzzle view - in a real app, this would be more interactive
    return Container(
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.extension_rounded,
            size: 60.w,
            color: categoryColor,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            'Interactive Puzzle',
            style: BabyFont.titleLarge.copyWith(color: AppTheme.textPrimary),
          ),
          Text(
            'Tap the correct answer below',
            style: BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: AppTheme.largeSpacing),
          // For now, show as multiple choice
          _buildMultipleChoiceOptions(question, categoryColor),
        ],
      ),
    );
  }

  Widget _buildMatchingView(QuizQuestion question, Color categoryColor) {
    return Container(
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.compare_arrows_rounded,
            size: 60.w,
            color: categoryColor,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            'Matching Game',
            style: BabyFont.titleLarge.copyWith(color: AppTheme.textPrimary),
          ),
          Text(
            'Match the items correctly',
            style: BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: AppTheme.largeSpacing),
          // For now, show as multiple choice
          _buildMultipleChoiceOptions(question, categoryColor),
        ],
      ),
    );
  }

  Widget _buildDragDropView(QuizQuestion question, Color categoryColor) {
    return Container(
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.drag_indicator_rounded,
            size: 60.w,
            color: categoryColor,
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            'Drag & Drop',
            style: BabyFont.titleLarge.copyWith(color: AppTheme.textPrimary),
          ),
          Text(
            'Arrange in the correct order',
            style: BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          SizedBox(height: AppTheme.largeSpacing),
          // For now, show as multiple choice
          _buildMultipleChoiceOptions(question, categoryColor),
        ],
      ),
    );
  }

  Widget _buildExplanationView(Color categoryColor) {
    final currentQuestion = widget.level.questions[_currentQuestionIndex];
    final isCorrect = _userAnswers[_currentQuestionIndex] ==
        currentQuestion.correctAnswerIndex;

    return Container(
      padding: AppTheme.cardPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check_rounded : Icons.close_rounded,
              color: isCorrect ? Colors.green : Colors.red,
              size: 40.w,
            ),
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          Text(
            isCorrect ? 'Correct! 🎉' : 'Not quite right 😊',
            style: BabyFont.displaySmall.copyWith(
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(height: AppTheme.mediumSpacing),
          if (currentQuestion.explanation != null) ...[
            Text(
              'Explanation:',
              style: BabyFont.titleMedium.copyWith(color: AppTheme.textPrimary),
            ),
            SizedBox(height: AppTheme.smallSpacing),
            Text(
              currentQuestion.explanation!,
              style:
                  BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: AppTheme.largeSpacing),
          Text(
            'Correct Answer: ${currentQuestion.options[currentQuestion.correctAnswerIndex]}',
            style: BabyFont.titleSmall.copyWith(color: Colors.green),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(Color categoryColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0 && !_showExplanation)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: BorderSide(color: categoryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: BabyFont.titleMedium.copyWith(color: categoryColor),
                ),
              ),
            ),
          if (_currentQuestionIndex > 0 && !_showExplanation)
            SizedBox(width: AppTheme.mediumSpacing),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextAction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryColor,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                ),
              ),
              child: Text(
                _getNextButtonText(),
                style: BabyFont.titleMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(Color categoryColor) {
    final isPerfectScore = _score == widget.level.questions.length;
    final passed = _score >= widget.level.requiredScore;

    return Scaffold(
      body: ResponsivePadding(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: passed
                        ? [categoryColor, categoryColor.withValues(alpha: 0.7)]
                        : [Colors.orange, Colors.orange.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.mediumShadow,
                ),
                child: Icon(
                  passed ? Icons.celebration_rounded : Icons.refresh_rounded,
                  size: 60.w,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppTheme.largeSpacing),
              Text(
                isPerfectScore
                    ? 'Perfect Score! 🌟'
                    : passed
                        ? 'Level Complete! 🎉'
                        : 'Try Again! 💪',
                style:
                    BabyFont.displaySmall.copyWith(color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.mediumSpacing),
              Text(
                'Score: $_score/${widget.level.questions.length}',
                style: BabyFont.titleLarge.copyWith(
                  color: categoryColor,
                  fontWeight: BabyFont.bold,
                ),
              ),
              SizedBox(height: AppTheme.smallSpacing),
              Text(
                passed
                    ? 'Great job! You\'ve unlocked the next level.'
                    : 'You need ${widget.level.requiredScore} correct answers to pass.',
                style:
                    BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.extraLargeSpacing),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: categoryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.mediumRadius),
                        ),
                      ),
                      child: Text(
                        'Back to Levels',
                        style:
                            BabyFont.titleMedium.copyWith(color: categoryColor),
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.mediumSpacing),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _retakeQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.mediumRadius),
                        ),
                      ),
                      child: Text(
                        passed ? 'Play Again' : 'Retry',
                        style:
                            BabyFont.titleMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getQuestionTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Icons.quiz_rounded;
      case QuestionType.puzzle:
        return Icons.extension_rounded;
      case QuestionType.dragDrop:
        return Icons.drag_indicator_rounded;
      case QuestionType.matching:
        return Icons.compare_arrows_rounded;
      case QuestionType.emoji:
        return Icons.emoji_emotions_rounded;
    }
  }

  String _getQuestionTypeText(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.puzzle:
        return 'Puzzle Challenge';
      case QuestionType.dragDrop:
        return 'Drag & Drop';
      case QuestionType.matching:
        return 'Matching Game';
      case QuestionType.emoji:
        return 'Emoji Quiz';
    }
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  bool _canProceed() {
    if (_showExplanation) return true;
    return _userAnswers[_currentQuestionIndex] != -1;
  }

  String _getNextButtonText() {
    if (_showExplanation) {
      if (_currentQuestionIndex == widget.level.questions.length - 1) {
        return 'Finish';
      }
      return 'Next Question';
    }
    return 'Submit Answer';
  }

  void _nextAction() {
    if (_showExplanation) {
      if (_currentQuestionIndex == widget.level.questions.length - 1) {
        _completeQuiz();
      } else {
        _nextQuestion();
      }
    } else {
      _submitAnswer();
    }
  }

  void _submitAnswer() {
    final currentQuestion = widget.level.questions[_currentQuestionIndex];
    final isCorrect = _userAnswers[_currentQuestionIndex] ==
        currentQuestion.correctAnswerIndex;

    if (isCorrect) {
      _score++;
    }

    setState(() {
      _showExplanation = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _showExplanation = false;
    });
  }

  void _previousQuestion() {
    setState(() {
      _currentQuestionIndex--;
      _showExplanation = false;
    });
  }

  void _completeQuiz() {
    setState(() {
      _isCompleted = true;
    });
  }

  void _retakeQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _userAnswers = List.filled(widget.level.questions.length, -1);
      _score = 0;
      _isCompleted = false;
      _showExplanation = false;
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Exit Quiz?',
          style: BabyFont.titleLarge.copyWith(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?',
          style: BabyFont.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style:
                  BabyFont.titleSmall.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Exit',
              style: BabyFont.titleSmall.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
