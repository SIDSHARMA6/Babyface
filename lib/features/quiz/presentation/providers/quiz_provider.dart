import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../../data/repositories/quiz_repository.dart';
import '../../domain/entities/quiz_entities.dart';

/// Enhanced Quiz provider for managing quiz state
class QuizProvider extends ChangeNotifier {
  int _currentLevel = 1;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _totalQuestions = 5; // 4 standard + 1 puzzle
  int _streak = 0;
  int _totalCorrect = 0;
  List<QuizQuestion> _currentQuestions = [];
  QuizCategory _selectedCategory = QuizCategory.babyPrediction;
  bool _isLoading = false;
  bool _isQuizComplete = false;
  bool _showExplanation = false;
  bool _isCorrectAnswer = false;
  final List<int> _userAnswers = [];
  final List<bool> _answerResults = [];
  String _motivationalMessage = '';
  String _personalizedFeedback = '';

  // Enhanced Getters
  int get currentLevel => _currentLevel;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  int get totalQuestions => _totalQuestions;
  int get streak => _streak;
  int get totalCorrect => _totalCorrect;
  List<QuizQuestion> get currentQuestions => _currentQuestions;
  QuizCategory get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isQuizComplete => _isQuizComplete;
  bool get showExplanation => _showExplanation;
  bool get isCorrectAnswer => _isCorrectAnswer;
  List<int> get userAnswers => _userAnswers;
  List<bool> get answerResults => _answerResults;
  String get motivationalMessage => _motivationalMessage;
  String get personalizedFeedback => _personalizedFeedback;

  QuizQuestion? get currentQuestion => _currentQuestions.isNotEmpty &&
          _currentQuestionIndex < _currentQuestions.length
      ? _currentQuestions[_currentQuestionIndex]
      : null;

  double get progress =>
      _totalQuestions > 0 ? _currentQuestionIndex / _totalQuestions : 0.0;

  bool get isPuzzleQuestion => currentQuestion?.type == QuestionType.puzzle;

  int get maxPossibleScore => _currentQuestions.fold(
      0, (sum, q) => sum + 10); // Default 10 points per question

  double get accuracyPercentage => _userAnswers.isNotEmpty
      ? (_totalCorrect / _userAnswers.length * 100)
      : 0.0;

  /// Start a new quiz for the selected category
  Future<void> startQuiz(QuizCategory category) async {
    _isLoading = true;
    notifyListeners();

    _selectedCategory = category;
    _currentLevel = 1;
    _currentQuestionIndex = 0;
    _score = 0;
    _streak = 0;
    _totalCorrect = 0;
    _isQuizComplete = false;
    _showExplanation = false;
    _userAnswers.clear();
    _answerResults.clear();

    try {
      // Load questions from repository
      final questions =
          QuizRepository.getQuestionsForLevel(category, _currentLevel);
      if (questions.isNotEmpty) {
        _currentQuestions = questions;
        _totalQuestions = _currentQuestions.length;
      } else {
        _currentQuestions = [];
        _totalQuestions = 0;
        developer.log(
            'No questions found for category: $category, level: $_currentLevel');
      }
    } catch (e) {
      developer.log('Error loading quiz questions: $e');
      _currentQuestions = [];
      _totalQuestions = 0;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Answer the current question with enhanced feedback
  Future<void> answerQuestion(int selectedAnswer) async {
    if (currentQuestion == null || _isQuizComplete) return;

    final question = currentQuestion!;
    _userAnswers.add(selectedAnswer);

    // Check if answer is correct
    final selectedOption = selectedAnswer < question.options.length
        ? question.options[selectedAnswer]
        : '';
    final isCorrect = selectedOption == question.correctAnswer;
    _answerResults.add(isCorrect);
    _isCorrectAnswer = isCorrect;

    if (isCorrect) {
      _score += 10; // Default 10 points per correct answer
      _totalCorrect++;
      _streak++;
    } else {
      _streak = 0; // Reset streak on wrong answer
    }

    // Show explanation
    _showExplanation = true;
    notifyListeners();

    // Wait for user to read explanation
    await Future.delayed(const Duration(seconds: 2));

    // Move to next question
    _showExplanation = false;
    _isCorrectAnswer = false;
    _currentQuestionIndex++;

    if (_currentQuestionIndex >= _currentQuestions.length) {
      await _completeQuiz();
    }

    notifyListeners();
  }

  /// Complete the current quiz with enhanced feedback
  Future<void> _completeQuiz() async {
    _isQuizComplete = true;

    // Generate motivational message
    _motivationalMessage =
        QuizRepository.getMotivationalMessage(_score, maxPossibleScore);

    // Generate personalized feedback
    _personalizedFeedback = QuizRepository.getPersonalizedFeedback(
      _selectedCategory,
      _score,
    );

    // Level up if score is high enough (70% correct)
    if (accuracyPercentage >= 70) {
      _currentLevel++;
    }

    notifyListeners();
  }

  /// Restart the current quiz
  void restartQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _streak = 0;
    _totalCorrect = 0;
    _isQuizComplete = false;
    _showExplanation = false;
    _userAnswers.clear();
    _answerResults.clear();
    notifyListeners();
  }

  /// Go to next level
  Future<void> nextLevel() async {
    _currentLevel++;
    await startQuiz(_selectedCategory);
  }

  /// Reset all quiz data
  void reset() {
    _currentLevel = 1;
    _currentQuestionIndex = 0;
    _score = 0;
    _streak = 0;
    _totalCorrect = 0;
    _totalQuestions = 5;
    _currentQuestions.clear();
    _selectedCategory = QuizCategory.babyPrediction;
    _isLoading = false;
    _isQuizComplete = false;
    _showExplanation = false;
    _userAnswers.clear();
    _answerResults.clear();
    _motivationalMessage = '';
    _personalizedFeedback = '';
    notifyListeners();
  }

  /// Skip current question (with penalty)
  void skipQuestion() {
    if (currentQuestion == null || _isQuizComplete) return;

    _userAnswers.add(-1); // -1 indicates skipped
    _answerResults.add(false);
    _streak = 0; // Reset streak on skip

    _currentQuestionIndex++;
    if (_currentQuestionIndex >= _currentQuestions.length) {
      _completeQuiz();
    }

    notifyListeners();
  }

  /// Use hint (reduces points but helps with answer)
  String? useHint() {
    if (currentQuestion == null) return null;

    final question = currentQuestion!;
    final correctIndex = question.options.indexOf(question.correctAnswer);
    final correctOption = correctIndex >= 0
        ? question.options[correctIndex]
        : question.correctAnswer;

    // Reduce points for using hint
    if (_score > 5) _score -= 5;

    return correctOption.isNotEmpty
        ? "Hint: The answer starts with '${correctOption[0]}'"
        : "Hint: Think about the most logical answer";
  }

  /// Get quiz statistics
  Map<String, dynamic> getQuizStats() {
    return {
      'level': _currentLevel,
      'score': _score,
      'maxScore': maxPossibleScore,
      'accuracy': accuracyPercentage,
      'streak': _streak,
      'totalCorrect': _totalCorrect,
      'totalQuestions': _userAnswers.length,
      'category': _selectedCategory.toString().split('.').last,
    };
  }
}
