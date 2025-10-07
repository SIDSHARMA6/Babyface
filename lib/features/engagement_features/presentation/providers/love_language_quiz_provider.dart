import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/love_language_entity.dart';
import '../../domain/usecases/get_love_language_questions_usecase.dart';
import '../../domain/usecases/calculate_love_language_results_usecase.dart';

/// Love language quiz state
class LoveLanguageQuizState {
  final List<LoveLanguageQuestionEntity> questions;
  final int currentQuestionIndex;
  final LoveLanguageAnswerEntity? selectedAnswer;
  final Map<String, String> answers;
  final LoveLanguageQuizResultEntity? result;
  final bool isLoading;
  final bool showResults;
  final String? errorMessage;

  const LoveLanguageQuizState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswer,
    this.answers = const {},
    this.result,
    this.isLoading = false,
    this.showResults = false,
    this.errorMessage,
  });

  LoveLanguageQuizState copyWith({
    List<LoveLanguageQuestionEntity>? questions,
    int? currentQuestionIndex,
    LoveLanguageAnswerEntity? selectedAnswer,
    Map<String, String>? answers,
    LoveLanguageQuizResultEntity? result,
    bool? isLoading,
    bool? showResults,
    String? errorMessage,
  }) {
    return LoveLanguageQuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      showResults: showResults ?? this.showResults,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Love language quiz notifier
class LoveLanguageQuizNotifier extends StateNotifier<LoveLanguageQuizState> {
  final GetLoveLanguageQuestionsUsecase _getQuestionsUsecase;
  final CalculateLoveLanguageResultsUsecase _calculateResultsUsecase;

  LoveLanguageQuizNotifier(
    this._getQuestionsUsecase,
    this._calculateResultsUsecase,
  ) : super(const LoveLanguageQuizState()) {
    loadQuestions();
  }

  /// Load quiz questions
  Future<void> loadQuestions() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final questions = await _getQuestionsUsecase.execute();

      state = state.copyWith(
        questions: questions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getCuteErrorMessage(e.toString()),
      );
    }
  }

  /// Select answer for current question
  void selectAnswer(LoveLanguageAnswerEntity answer) {
    final currentQuestion = state.questions[state.currentQuestionIndex];
    final updatedAnswers = Map<String, String>.from(state.answers);
    updatedAnswers[currentQuestion.id] = answer.id;

    state = state.copyWith(
      selectedAnswer: answer,
      answers: updatedAnswers,
    );
  }

  /// Move to next question
  void nextQuestion() {
    if (state.selectedAnswer == null) return;

    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        selectedAnswer: null,
      );
    } else {
      _finishQuiz();
    }
  }

  /// Move to previous question
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      final previousQuestion = state.questions[state.currentQuestionIndex - 1];
      final previousAnswerId = state.answers[previousQuestion.id];

      LoveLanguageAnswerEntity? previousAnswer;
      if (previousAnswerId != null) {
        previousAnswer = previousQuestion.answers.firstWhere(
          (answer) => answer.id == previousAnswerId,
        );
      }

      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
        selectedAnswer: previousAnswer,
      );
    }
  }

  /// Finish quiz and calculate results
  Future<void> _finishQuiz() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final request = LoveLanguageQuizRequest(
        userId: 'current_user', // In real app, get from auth
        answers: state.answers.entries.map((e) => {e.key: e.value}).toList(),
      );

      final result = await _calculateResultsUsecase.execute(request);

      state = state.copyWith(
        result: result,
        isLoading: false,
        showResults: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getCuteErrorMessage(e.toString()),
      );
    }
  }

  /// Restart quiz
  void restartQuiz() {
    state = const LoveLanguageQuizState();
    loadQuestions();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Get cute error message for users
  String _getCuteErrorMessage(String error) {
    if (error.contains('network') || error.contains('connection')) {
      return 'Oops! Our love connection got interrupted 💕 Try again in a moment!';
    } else if (error.contains('timeout')) {
      return 'Love takes time! ⏰ Please try again, sweetheart!';
    } else if (error.contains('server')) {
      return 'Our love server is taking a break 😴 Try again soon!';
    } else if (error.contains('permission')) {
      return 'We need your permission to share love 💖 Please check your settings!';
    } else {
      return 'Something went wrong, but our love is still strong! 💕 Try again!';
    }
  }
}

/// Provider for get love language questions use case
final getLoveLanguageQuestionsUsecaseProvider =
    Provider<GetLoveLanguageQuestionsUsecase>((ref) {
  throw UnimplementedError('GetLoveLanguageQuestionsUsecase must be provided');
});

/// Provider for calculate love language results use case
final calculateLoveLanguageResultsUsecaseProvider =
    Provider<CalculateLoveLanguageResultsUsecase>((ref) {
  throw UnimplementedError(
      'CalculateLoveLanguageResultsUsecase must be provided');
});

/// Provider for love language quiz notifier
final loveLanguageQuizProvider =
    StateNotifierProvider<LoveLanguageQuizNotifier, LoveLanguageQuizState>(
        (ref) {
  final getQuestionsUsecase =
      ref.watch(getLoveLanguageQuestionsUsecaseProvider);
  final calculateResultsUsecase =
      ref.watch(calculateLoveLanguageResultsUsecaseProvider);
  return LoveLanguageQuizNotifier(getQuestionsUsecase, calculateResultsUsecase);
});
