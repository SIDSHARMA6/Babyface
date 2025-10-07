import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/quiz_models.dart';
import '../../data/quiz_repository.dart';

/// Quiz repository provider
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository();
});

/// Current user ID provider (would come from auth in real app)
final currentUserIdProvider = Provider<String>((ref) {
  return 'user_123'; // TODO: Get from authentication
});

/// Quiz categories provider
final quizCategoriesProvider =
    FutureProvider<List<QuizCategoryModel>>((ref) async {
  final repository = ref.read(quizRepositoryProvider);
  return await repository.getAllCategories();
});

/// User progress provider
final userProgressProvider = FutureProvider<UserQuizProgress>((ref) async {
  final repository = ref.read(quizRepositoryProvider);
  final userId = ref.read(currentUserIdProvider);
  return await repository.getUserProgress(userId);
});

/// Quiz statistics provider
final quizStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(quizRepositoryProvider);
  final userId = ref.read(currentUserIdProvider);
  return await repository.getQuizStatistics(userId);
});

/// Active quiz session provider
final activeQuizSessionProvider =
    StateNotifierProvider<ActiveQuizSessionNotifier, AsyncValue<QuizSession?>>(
        (ref) {
  return ActiveQuizSessionNotifier(ref.read(quizRepositoryProvider));
});

/// Quiz session state notifier
class ActiveQuizSessionNotifier
    extends StateNotifier<AsyncValue<QuizSession?>> {
  final QuizRepository _repository;

  ActiveQuizSessionNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadActiveSession();
  }

  Future<void> _loadActiveSession() async {
    try {
      final session =
          await _repository.getActiveSession('user_123'); // TODO: Get from auth
      state = AsyncValue.data(session);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> startQuizSession({
    required String categoryId,
    required String levelId,
  }) async {
    try {
      state = const AsyncValue.loading();
      final session = await _repository.startQuizSession(
        categoryId: categoryId,
        levelId: levelId,
        userId: 'user_123', // TODO: Get from auth
      );
      state = AsyncValue.data(session);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSession(QuizSession session) async {
    try {
      await _repository.updateQuizSession(session);
      state = AsyncValue.data(session);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> completeSession(QuizSession session, int finalScore) async {
    try {
      await _repository.completeQuizSession(
        session: session,
        userId: 'user_123', // TODO: Get from auth
        finalScore: finalScore,
      );
      state = const AsyncValue.data(null); // No active session after completion
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSession() {
    state = const AsyncValue.data(null);
  }
}

/// Quiz game state provider for current gameplay
final quizGameStateProvider =
    StateNotifierProvider.family<QuizGameStateNotifier, QuizGameState, String>(
        (ref, levelId) {
  return QuizGameStateNotifier(levelId, ref.read(quizRepositoryProvider));
});

/// Quiz game state model
class QuizGameState {
  final QuizLevel? level;
  final int currentQuestionIndex;
  final List<int> userAnswers;
  final int score;
  final bool isCompleted;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> puzzleState;

  const QuizGameState({
    this.level,
    this.currentQuestionIndex = 0,
    this.userAnswers = const [],
    this.score = 0,
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
    this.puzzleState = const {},
  });

  QuizGameState copyWith({
    QuizLevel? level,
    int? currentQuestionIndex,
    List<int>? userAnswers,
    int? score,
    bool? isCompleted,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? puzzleState,
  }) {
    return QuizGameState(
      level: level ?? this.level,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      puzzleState: puzzleState ?? this.puzzleState,
    );
  }

  QuizQuestion? get currentQuestion => level?.questions[currentQuestionIndex];
  bool get canProceedToNext => currentQuestionIndex < 4; // 0-4 for 5 questions
  bool get isLastQuestion => currentQuestionIndex == 4;
  double get progressPercentage => ((currentQuestionIndex + 1) / 5) * 100;
}

/// Quiz game state notifier
class QuizGameStateNotifier extends StateNotifier<QuizGameState> {
  final String levelId;
  final QuizRepository _repository;

  QuizGameStateNotifier(this.levelId, this._repository)
      : super(const QuizGameState(isLoading: true)) {
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    try {
      // Extract category ID from level ID (assuming format: categoryId_level_X)
      final categoryId = levelId.split('_level_')[0];
      final level =
          await _repository.getCategoryById(categoryId).then((category) {
        return category?.levels.firstWhere((l) => l.id == levelId);
      });

      if (level != null) {
        state = state.copyWith(
          level: level,
          isLoading: false,
          userAnswers: List.filled(5, -1), // Initialize with -1 (no answer)
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Level not found',
        );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  void selectAnswer(int answerIndex) {
    if (state.level == null || state.isCompleted) return;

    final newAnswers = List<int>.from(state.userAnswers);
    newAnswers[state.currentQuestionIndex] = answerIndex;

    // Check if answer is correct
    final currentQuestion = state.currentQuestion;
    final isCorrect = currentQuestion?.correctAnswerIndex == answerIndex;
    final newScore = isCorrect ? state.score + 1 : state.score;

    state = state.copyWith(
      userAnswers: newAnswers,
      score: newScore,
    );
  }

  void nextQuestion() {
    if (state.canProceedToNext) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    } else {
      // Quiz completed
      state = state.copyWith(isCompleted: true);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  void updatePuzzleState(Map<String, dynamic> puzzleData) {
    state = state.copyWith(
      puzzleState: {...state.puzzleState, ...puzzleData},
    );
  }

  void resetQuiz() {
    if (state.level != null) {
      state = QuizGameState(
        level: state.level,
        userAnswers: List.filled(5, -1),
      );
    }
  }

  bool isPuzzleCompleted() {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion?.type != QuestionType.puzzle &&
        currentQuestion?.type != QuestionType.matching &&
        currentQuestion?.type != QuestionType.dragDrop) {
      return false;
    }

    // Check puzzle completion based on type
    switch (currentQuestion!.type) {
      case QuestionType.matching:
        final matches = state.puzzleState['matches'] as List<int>?;
        return matches != null &&
            matches.length == currentQuestion.options.length;

      case QuestionType.dragDrop:
        final order = state.puzzleState['order'] as List<int>?;
        return order != null && order.length == currentQuestion.options.length;

      case QuestionType.puzzle:
        final completed = state.puzzleState['completed'] as bool?;
        return completed == true;

      default:
        return false;
    }
  }

  int calculatePuzzleScore() {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion?.puzzleData == null) return 0;

    switch (currentQuestion!.type) {
      case QuestionType.matching:
        final userMatches = state.puzzleState['matches'] as List<int>?;
        final correctMatches =
            currentQuestion.puzzleData!['correctMatches'] as List<int>;
        if (userMatches == null) return 0;

        int correctCount = 0;
        for (int i = 0;
            i < userMatches.length && i < correctMatches.length;
            i++) {
          if (userMatches[i] == correctMatches[i]) correctCount++;
        }
        return correctCount == correctMatches.length ? 1 : 0;

      case QuestionType.dragDrop:
        final userOrder = state.puzzleState['order'] as List<int>?;
        final correctOrder =
            currentQuestion.puzzleData!['correctOrder'] as List<int>;
        if (userOrder == null) return 0;

        return userOrder.toString() == correctOrder.toString() ? 1 : 0;

      case QuestionType.puzzle:
        final completed = state.puzzleState['completed'] as bool?;
        return completed == true ? 1 : 0;

      default:
        return 0;
    }
  }
}

/// Leaderboard provider
final leaderboardProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(quizRepositoryProvider);
  return await repository.getLeaderboard();
});

/// Category progress provider
final categoryProgressProvider =
    FutureProvider.family<QuizCategoryModel?, String>((ref, categoryId) async {
  final repository = ref.read(quizRepositoryProvider);
  return await repository.getCategoryById(categoryId);
});
