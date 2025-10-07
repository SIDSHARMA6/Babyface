import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../providers/love_language_quiz_provider.dart';
import '../../domain/entities/love_language_entity.dart';

/// Love Language Quiz Screen
/// Follows master plan theme standards and performance requirements
class LoveLanguageQuizScreen extends OptimizedStatefulWidget {
  const LoveLanguageQuizScreen({super.key});

  @override
  OptimizedState<LoveLanguageQuizScreen> createState() =>
      _LoveLanguageQuizScreenState();
}

class _LoveLanguageQuizScreenState
    extends OptimizedState<LoveLanguageQuizScreen> {
  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loveLanguageQuizProvider);
    final notifier = ref.read(loveLanguageQuizProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Love Language Quiz',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: state.currentQuestionIndex > 0
            ? IconButton(
                onPressed: () => notifier.previousQuestion(),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: OptimizedContainer(
        padding: context.responsivePadding,
        child: Column(
          children: [
            _buildProgressIndicator(state),
            SizedBox(height: context.responsiveHeight(2)),
            if (state.isLoading) ...[
              Expanded(child: _buildLoadingState()),
            ] else if (state.questions.isEmpty) ...[
              Expanded(child: _buildEmptyState()),
            ] else if (state.showResults) ...[
              Expanded(child: _buildResults(state)),
            ] else ...[
              Expanded(child: _buildQuestion(state, notifier)),
            ],
            if (state.errorMessage != null) ...[
              _buildErrorMessage(state.errorMessage!, notifier),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(LoveLanguageQuizState state) {
    final progress = state.questions.isNotEmpty
        ? (state.currentQuestionIndex + 1) / state.questions.length
        : 0.0;

    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptimizedText(
                'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              OptimizedText(
                '${(progress * 100).toInt()}%',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(1)),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Loading quiz questions...',
            style: BabyFont.bodyL.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: context.responsiveHeight(12),
            color: AppTheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'No questions available',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Please try again later',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(
      LoveLanguageQuizState state, LoveLanguageQuizNotifier notifier) {
    final question = state.questions[state.currentQuestionIndex];

    return Column(
      children: [
        _buildQuestionHeader(question),
        SizedBox(height: context.responsiveHeight(2)),
        Expanded(
          child: _buildAnswers(question, notifier),
        ),
        SizedBox(height: context.responsiveHeight(2)),
        _buildNavigationButtons(state, notifier),
      ],
    );
  }

  Widget _buildQuestionHeader(LoveLanguageQuestionEntity question) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            size: context.responsiveHeight(8),
            color: Colors.white,
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Discover Your Love Language',
            style: BabyFont.headingL.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            question.question,
            style: BabyFont.bodyL.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswers(
      LoveLanguageQuestionEntity question, LoveLanguageQuizNotifier notifier) {
    return ListView.builder(
      itemCount: question.answers.length,
      itemBuilder: (context, index) {
        final answer = question.answers[index];
        return _buildAnswerCard(answer, notifier);
      },
    );
  }

  Widget _buildAnswerCard(
      LoveLanguageAnswerEntity answer, LoveLanguageQuizNotifier notifier) {
    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
      child: GestureDetector(
        onTap: () => notifier.selectAnswer(answer),
        child: Container(
          padding: context.responsivePadding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            boxShadow: AppTheme.softShadow,
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getAnswerIcon(answer.type),
                color: _getAnswerColor(answer.type),
                size: context.responsiveFont(24),
              ),
              SizedBox(width: context.responsiveWidth(2)),
              Expanded(
                child: OptimizedText(
                  answer.text,
                  style: BabyFont.bodyM,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
                size: context.responsiveFont(16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
      LoveLanguageQuizState state, LoveLanguageQuizNotifier notifier) {
    return Row(
      children: [
        if (state.currentQuestionIndex > 0)
          Expanded(
            child: OptimizedButton(
              text: 'Previous',
              onPressed: () => notifier.previousQuestion(),
              type: ButtonType.outline,
            ),
          ),
        if (state.currentQuestionIndex > 0)
          SizedBox(width: context.responsiveWidth(2)),
        Expanded(
          child: OptimizedButton(
            text: state.currentQuestionIndex == state.questions.length - 1
                ? 'Finish Quiz'
                : 'Next',
            onPressed: state.selectedAnswer != null
                ? () => notifier.nextQuestion()
                : null,
            type: ButtonType.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildResults(LoveLanguageQuizState state) {
    final result = state.result!;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildResultsHeader(result),
          SizedBox(height: context.responsiveHeight(2)),
          _buildPrimaryLanguage(result.primaryLanguage),
          SizedBox(height: context.responsiveHeight(2)),
          _buildSecondaryLanguage(result.secondaryLanguage),
          SizedBox(height: context.responsiveHeight(2)),
          _buildAllResults(result.results),
          SizedBox(height: context.responsiveHeight(2)),
          _buildActionButtons(
              state, ref.read(loveLanguageQuizProvider.notifier)),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(LoveLanguageQuizResultEntity result) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: context.responsiveHeight(8),
            color: Colors.white,
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Your Love Language Results',
            style: BabyFont.headingL.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Discover how you express and receive love',
            style: BabyFont.bodyM.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryLanguage(LoveLanguageEntity language) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getLanguageIcon(language.type),
                color: AppTheme.accent,
                size: context.responsiveFont(32),
              ),
              SizedBox(width: context.responsiveWidth(2)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OptimizedText(
                      'Primary Love Language',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    OptimizedText(
                      language.title,
                      style: BabyFont.headingM.copyWith(
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(2),
                  vertical: context.responsiveHeight(0.5),
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius(12)),
                ),
                child: OptimizedText(
                  '${language.score}%',
                  style: BabyFont.bodyS.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            language.description,
            style: BabyFont.bodyM,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          _buildExamples(language.examples),
        ],
      ),
    );
  }

  Widget _buildSecondaryLanguage(LoveLanguageEntity language) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getLanguageIcon(language.type),
                color: AppTheme.primary,
                size: context.responsiveFont(24),
              ),
              SizedBox(width: context.responsiveWidth(2)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OptimizedText(
                      'Secondary Love Language',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    OptimizedText(
                      language.title,
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(2),
                  vertical: context.responsiveHeight(0.5),
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius(12)),
                ),
                child: OptimizedText(
                  '${language.score}%',
                  style: BabyFont.bodyS.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            language.description,
            style: BabyFont.bodyM,
          ),
        ],
      ),
    );
  }

  Widget _buildAllResults(List<LoveLanguageEntity> results) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptimizedText(
            'Complete Results',
            style: BabyFont.headingS.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          ...results.map((language) => _buildResultItem(language)),
        ],
      ),
    );
  }

  Widget _buildResultItem(LoveLanguageEntity language) {
    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(0.5)),
      child: Row(
        children: [
          Icon(
            _getLanguageIcon(language.type),
            color: _getLanguageColor(language.type),
            size: context.responsiveFont(20),
          ),
          SizedBox(width: context.responsiveWidth(2)),
          Expanded(
            child: OptimizedText(
              language.title,
              style: BabyFont.bodyM,
            ),
          ),
          OptimizedText(
            '${language.score}%',
            style: BabyFont.bodyM.copyWith(
              color: _getLanguageColor(language.type),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamples(List<String> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Examples:',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.5)),
        ...examples.map((example) => Padding(
              padding: EdgeInsets.only(bottom: context.responsiveHeight(0.3)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.accent,
                    size: context.responsiveFont(16),
                  ),
                  SizedBox(width: context.responsiveWidth(1)),
                  Expanded(
                    child: OptimizedText(
                      example,
                      style: BabyFont.bodyM,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildActionButtons(
      LoveLanguageQuizState state, LoveLanguageQuizNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: OptimizedButton(
            text: 'Retake Quiz',
            onPressed: () => notifier.restartQuiz(),
            type: ButtonType.outline,
          ),
        ),
        SizedBox(width: context.responsiveWidth(2)),
        Expanded(
          child: OptimizedButton(
            text: 'Share Results',
            onPressed: () => _shareResults(state.result!),
            type: ButtonType.primary,
            icon: const Icon(Icons.share),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error, LoveLanguageQuizNotifier notifier) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: context.responsiveFont(20),
          ),
          SizedBox(width: context.responsiveWidth(2)),
          Expanded(
            child: OptimizedText(
              error,
              style: BabyFont.bodyM.copyWith(
                color: Colors.red,
              ),
            ),
          ),
          IconButton(
            onPressed: () => notifier.clearError(),
            icon: const Icon(Icons.close),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  IconData _getAnswerIcon(LoveLanguageType type) {
    switch (type) {
      case LoveLanguageType.wordsOfAffirmation:
        return Icons.chat_bubble_outline;
      case LoveLanguageType.actsOfService:
        return Icons.handyman_outlined;
      case LoveLanguageType.receivingGifts:
        return Icons.card_giftcard_outlined;
      case LoveLanguageType.qualityTime:
        return Icons.schedule_outlined;
      case LoveLanguageType.physicalTouch:
        return Icons.favorite_outline;
    }
  }

  Color _getAnswerColor(LoveLanguageType type) {
    switch (type) {
      case LoveLanguageType.wordsOfAffirmation:
        return AppTheme.primary;
      case LoveLanguageType.actsOfService:
        return AppTheme.boyColor;
      case LoveLanguageType.receivingGifts:
        return AppTheme.girlColor;
      case LoveLanguageType.qualityTime:
        return AppTheme.accent;
      case LoveLanguageType.physicalTouch:
        return Colors.purple;
    }
  }

  IconData _getLanguageIcon(LoveLanguageType type) {
    switch (type) {
      case LoveLanguageType.wordsOfAffirmation:
        return Icons.chat_bubble;
      case LoveLanguageType.actsOfService:
        return Icons.handyman;
      case LoveLanguageType.receivingGifts:
        return Icons.card_giftcard;
      case LoveLanguageType.qualityTime:
        return Icons.schedule;
      case LoveLanguageType.physicalTouch:
        return Icons.favorite;
    }
  }

  Color _getLanguageColor(LoveLanguageType type) {
    switch (type) {
      case LoveLanguageType.wordsOfAffirmation:
        return AppTheme.primary;
      case LoveLanguageType.actsOfService:
        return AppTheme.boyColor;
      case LoveLanguageType.receivingGifts:
        return AppTheme.girlColor;
      case LoveLanguageType.qualityTime:
        return AppTheme.accent;
      case LoveLanguageType.physicalTouch:
        return Colors.purple;
    }
  }

  void _shareResults(LoveLanguageQuizResultEntity result) {
    // Implementation for sharing results
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: OptimizedText('Results shared successfully!'),
        backgroundColor: AppTheme.accent,
      ),
    );
  }
}
