import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class LoveLanguageQuizScreen extends StatefulWidget {
  const LoveLanguageQuizScreen({super.key});

  @override
  State<LoveLanguageQuizScreen> createState() => _LoveLanguageQuizScreenState();
}

class _LoveLanguageQuizScreenState extends State<LoveLanguageQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentQuestionIndex = 0;
  Map<String, int> _scores = {
    'Words of Affirmation': 0,
    'Acts of Service': 0,
    'Receiving Gifts': 0,
    'Quality Time': 0,
    'Physical Touch': 0,
  };
  bool _quizCompleted = false;
  String? _primaryLoveLanguage;
  String? _secondaryLoveLanguage;

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'What makes you feel most loved?',
      options: [
        'Hearing "I love you" and compliments',
        'When they help with chores or tasks',
        'Receiving thoughtful gifts',
        'Spending quality time together',
        'Hugs, kisses, and physical affection',
      ],
      loveLanguages: [
        'Words of Affirmation',
        'Acts of Service',
        'Receiving Gifts',
        'Quality Time',
        'Physical Touch'
      ],
    ),
    QuizQuestion(
      question: 'What hurts you most in a relationship?',
      options: [
        'Harsh words or criticism',
        'Being taken for granted or ignored',
        'Forgetting special occasions',
        'Being too busy for each other',
        'Lack of physical intimacy',
      ],
      loveLanguages: [
        'Words of Affirmation',
        'Acts of Service',
        'Receiving Gifts',
        'Quality Time',
        'Physical Touch'
      ],
    ),
    QuizQuestion(
      question: 'How do you prefer to show love?',
      options: [
        'Telling them how much they mean to me',
        'Doing things to help and support them',
        'Buying or making gifts for them',
        'Planning special activities together',
        'Holding hands, cuddling, and being close',
      ],
      loveLanguages: [
        'Words of Affirmation',
        'Acts of Service',
        'Receiving Gifts',
        'Quality Time',
        'Physical Touch'
      ],
    ),
    QuizQuestion(
      question: 'What would make you feel most appreciated?',
      options: [
        'A heartfelt thank you note or message',
        'Having them take care of something for me',
        'A surprise gift or treat',
        'Their undivided attention and time',
        'A warm embrace or gentle touch',
      ],
      loveLanguages: [
        'Words of Affirmation',
        'Acts of Service',
        'Receiving Gifts',
        'Quality Time',
        'Physical Touch'
      ],
    ),
    QuizQuestion(
      question: 'What do you value most in a partner?',
      options: [
        'Their encouraging and supportive words',
        'Their helpful and considerate actions',
        'Their thoughtfulness in gift-giving',
        'Their willingness to spend time with me',
        'Their physical affection and closeness',
      ],
      loveLanguages: [
        'Words of Affirmation',
        'Acts of Service',
        'Receiving Gifts',
        'Quality Time',
        'Physical Touch'
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    if (_quizCompleted) return;

    final question = _questions[_currentQuestionIndex];
    final selectedLoveLanguage = question.loveLanguages[answerIndex];

    setState(() {
      _scores[selectedLoveLanguage] = _scores[selectedLoveLanguage]! + 1;
    });

    HapticFeedback.selectionClick();

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    // Find primary and secondary love languages
    final sortedScores = _scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _primaryLoveLanguage = sortedScores[0].key;
      _secondaryLoveLanguage = sortedScores[1].key;
      _quizCompleted = true;
    });

    HapticFeedback.mediumImpact();
    ToastService.showLove(
        context, 'Quiz completed! Discover your love language! 💕');
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _scores = {
        'Words of Affirmation': 0,
        'Acts of Service': 0,
        'Receiving Gifts': 0,
        'Quality Time': 0,
        'Physical Touch': 0,
      };
      _quizCompleted = false;
      _primaryLoveLanguage = null;
      _secondaryLoveLanguage = null;
    });
  }

  String _getLoveLanguageEmoji(String loveLanguage) {
    switch (loveLanguage) {
      case 'Words of Affirmation':
        return '💬';
      case 'Acts of Service':
        return '🤝';
      case 'Receiving Gifts':
        return '🎁';
      case 'Quality Time':
        return '⏰';
      case 'Physical Touch':
        return '🤗';
      default:
        return '💕';
    }
  }

  String _getLoveLanguageDescription(String loveLanguage) {
    switch (loveLanguage) {
      case 'Words of Affirmation':
        return 'You feel loved through verbal compliments, words of appreciation, and encouraging words.';
      case 'Acts of Service':
        return 'You feel loved when your partner does things for you, like helping with chores or running errands.';
      case 'Receiving Gifts':
        return 'You feel loved through thoughtful gifts, both big and small, that show you were thought of.';
      case 'Quality Time':
        return 'You feel loved through undivided attention, meaningful conversations, and shared activities.';
      case 'Physical Touch':
        return 'You feel loved through physical affection like hugs, kisses, holding hands, and cuddling.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Love Language Quiz 💝',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _quizCompleted ? _buildResults() : _buildQuiz(),
      ),
    );
  }

  Widget _buildQuiz() {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Progress Bar
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  blurRadius: 15.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: BabyFont.bodyM.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: BabyFont.bodyM.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
                  minHeight: 8.h,
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Question
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  blurRadius: 15.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  question.question,
                  style: BabyFont.headingM.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                ...question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return _buildAnswerOption(option, index);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(String option, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ElevatedButton(
        onPressed: () => _selectAnswer(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimary,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: AppTheme.primaryPink.withValues(alpha: 0.3),
              width: 1.w,
            ),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                option,
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Results Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  blurRadius: 15.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  color: AppTheme.primaryPink,
                  size: 60.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Your Love Language Results',
                  style: BabyFont.headingM.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 20.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Discover how you give and receive love!',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Primary Love Language
          _buildLoveLanguageCard(
            _primaryLoveLanguage!,
            'Primary Love Language',
            true,
          ),

          SizedBox(height: 16.h),

          // Secondary Love Language
          _buildLoveLanguageCard(
            _secondaryLoveLanguage!,
            'Secondary Love Language',
            false,
          ),

          SizedBox(height: 20.h),

          // Restart Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _restartQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Take Quiz Again',
                style: BabyFont.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoveLanguageCard(
      String loveLanguage, String title, bool isPrimary) {
    final emoji = _getLoveLanguageEmoji(loveLanguage);
    final description = _getLoveLanguageDescription(loveLanguage);
    final color = isPrimary ? AppTheme.primaryPink : AppTheme.primaryBlue;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: 32.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      loveLanguage,
                      style: BabyFont.headingM.copyWith(
                        color: color,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            description,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final List<String> loveLanguages;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.loveLanguages,
  });
}
