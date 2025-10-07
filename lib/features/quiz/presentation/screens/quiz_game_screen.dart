import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../domain/entities/quiz_entities.dart';

class QuizGameScreen extends StatefulWidget {
  final Quiz quiz;
  final QuizLevel level;

  const QuizGameScreen({
    super.key,
    required this.quiz,
    required this.level,
  });

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int currentQuestionIndex = 0;
  PlayerType currentPlayer = PlayerType.boy;
  Map<String, String> boyAnswers = {};
  Map<String, String> girlAnswers = {};
  bool showingPuzzle = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.level.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _animationController.reset();
        _animationController.forward();
      });
    } else if (!showingPuzzle) {
      setState(() {
        showingPuzzle = true;
        _animationController.reset();
        _animationController.forward();
      });
    } else {
      _completeLevel();
    }
  }

  void _completeLevel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius(20)),
        ),
        title: Text(
          '🎉 Level Complete!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: context.responsiveFont(20),
              ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You\'ve completed ${widget.level.title}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: context.responsiveFont(14),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsivePadding.top),
            Text(
              widget.quiz.icon,
              style: TextStyle(fontSize: context.responsiveFont(48)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Continue',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: context.responsiveFont(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safety check for empty questions
    if (!showingPuzzle && widget.level.questions.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Quiz Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              SizedBox(height: 16),
              Text(
                'No questions available for this level',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = showingPuzzle
        ? widget.level.puzzle
        : (currentQuestionIndex < widget.level.questions.length
            ? widget.level.questions[currentQuestionIndex]
            : null);

    // Additional safety check
    if (currentQuestion == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Quiz Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              SizedBox(height: 16),
              Text(
                'Question not found',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.level.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: context.responsiveFont(18),
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: context.responsiveMargin,
            child: Center(
              child: Text(
                showingPuzzle
                    ? 'Puzzle'
                    : '${currentQuestionIndex + 1}/${widget.level.questions.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: context.responsiveFont(12),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: context.responsivePadding,
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: showingPuzzle
                    ? 1.0
                    : (currentQuestionIndex + 1) /
                        (widget.level.questions.length + 1),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
              SizedBox(height: context.responsivePadding.top),

              // Player indicator
              if (currentQuestion.targetPlayer != PlayerType.both)
                Container(
                  padding: context.responsivePadding / 2,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(context.responsiveRadius(25)),
                    color: currentQuestion.targetPlayer == PlayerType.boy
                        ? AppTheme.boyColor.withValues(alpha: 0.1)
                        : AppTheme.girlColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: currentQuestion.targetPlayer == PlayerType.boy
                          ? AppTheme.boyColor
                          : AppTheme.girlColor,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentQuestion.targetPlayer == PlayerType.boy
                            ? '👨'
                            : '👩',
                        style: TextStyle(fontSize: context.responsiveFont(20)),
                      ),
                      SizedBox(width: context.responsiveMargin.left / 2),
                      Text(
                        '${currentQuestion.targetPlayer == PlayerType.boy ? 'Boy' : 'Girl'} Turn',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color:
                                  currentQuestion.targetPlayer == PlayerType.boy
                                      ? AppTheme.boyColor
                                      : AppTheme.girlColor,
                              fontWeight: FontWeight.w600,
                              fontSize: context.responsiveFont(14),
                            ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: context.responsivePadding.top),

              // Question card
              Expanded(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(context.responsiveRadius(20)),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: context.responsivePadding,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(context.responsiveRadius(20)),
                        gradient: showingPuzzle
                            ? AppTheme.primaryGradient
                            : currentQuestion.targetPlayer == PlayerType.boy
                                ? AppTheme.secondaryGradient
                                : AppTheme.primaryGradient,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.quiz.icon,
                            style:
                                TextStyle(fontSize: context.responsiveFont(48)),
                          ),
                          SizedBox(height: context.responsivePadding.top),
                          Text(
                            currentQuestion.question,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.responsiveFont(20),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.responsivePadding.top * 1.5),

                          // Answer options
                          if (currentQuestion.type ==
                              QuestionType.multipleChoice)
                            ...currentQuestion.options.map(
                              (option) => Padding(
                                padding: EdgeInsets.only(
                                    bottom: context.responsiveMargin.bottom),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Store answer and move to next
                                      if (currentQuestion.targetPlayer ==
                                          PlayerType.boy) {
                                        boyAnswers[currentQuestion.id] = option;
                                      } else {
                                        girlAnswers[currentQuestion.id] =
                                            option;
                                      }
                                      _nextQuestion();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppTheme.primary,
                                      padding: context.responsivePadding / 1.5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            context.responsiveRadius(15)),
                                      ),
                                    ),
                                    child: Text(
                                      option,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontSize:
                                                context.responsiveFont(16),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Text input for open questions
                          if (currentQuestion.type == QuestionType.textInput)
                            Column(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Type your answer...',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: context.responsiveFont(14),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          context.responsiveRadius(15)),
                                      borderSide:
                                          const BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          context.responsiveRadius(15)),
                                      borderSide:
                                          const BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          context.responsiveRadius(15)),
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 2),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.responsiveFont(16),
                                  ),
                                  onSubmitted: (value) {
                                    if (value.isNotEmpty) {
                                      if (currentQuestion.targetPlayer ==
                                          PlayerType.boy) {
                                        boyAnswers[currentQuestion.id] = value;
                                      } else {
                                        girlAnswers[currentQuestion.id] = value;
                                      }
                                      _nextQuestion();
                                    }
                                  },
                                ),
                                SizedBox(height: context.responsivePadding.top),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _nextQuestion(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppTheme.primary,
                                      padding: context.responsivePadding / 1.5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            context.responsiveRadius(15)),
                                      ),
                                    ),
                                    child: Text(
                                      'Continue',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontSize:
                                                context.responsiveFont(16),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          // Puzzle interface
                          if (currentQuestion.type == QuestionType.puzzle)
                            Column(
                              children: [
                                Text(
                                  'Drag and arrange the items in your preferred order:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: context.responsiveFont(14),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: context.responsivePadding.top),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: currentQuestion.options
                                      .map(
                                        (option) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                                context.responsiveRadius(20)),
                                          ),
                                          child: Text(
                                            option,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppTheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: context
                                                      .responsiveFont(12),
                                                ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                SizedBox(height: context.responsivePadding.top),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _nextQuestion(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppTheme.primary,
                                      padding: context.responsivePadding / 1.5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            context.responsiveRadius(15)),
                                      ),
                                    ),
                                    child: Text(
                                      'Complete Puzzle',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontSize:
                                                context.responsiveFont(16),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
