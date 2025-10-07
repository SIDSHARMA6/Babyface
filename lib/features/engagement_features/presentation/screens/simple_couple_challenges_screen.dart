import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class CoupleChallengesScreen extends StatefulWidget {
  const CoupleChallengesScreen({super.key});

  @override
  State<CoupleChallengesScreen> createState() => _CoupleChallengesScreenState();
}

class _CoupleChallengesScreenState extends State<CoupleChallengesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Challenge> _challenges = [];
  int _completedChallenges = 0;
  int _currentStreak = 0;

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

    _initializeChallenges();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeChallenges() {
    _challenges = [
      Challenge(
        id: '1',
        title: 'Cook Together 👨‍🍳',
        description: 'Prepare a meal together and enjoy it without phones',
        category: 'Daily',
        points: 10,
        isCompleted: false,
        difficulty: 'Easy',
      ),
      Challenge(
        id: '2',
        title: 'Love Letter 💌',
        description: 'Write each other a heartfelt love letter',
        category: 'Weekly',
        points: 25,
        isCompleted: true,
        difficulty: 'Medium',
      ),
      Challenge(
        id: '3',
        title: 'Dance Night 💃',
        description: 'Have a spontaneous dance party in your living room',
        category: 'Daily',
        points: 15,
        isCompleted: false,
        difficulty: 'Easy',
      ),
      Challenge(
        id: '4',
        title: 'Adventure Day 🚗',
        description: 'Go on a spontaneous road trip or explore a new place',
        category: 'Weekly',
        points: 50,
        isCompleted: false,
        difficulty: 'Hard',
      ),
      Challenge(
        id: '5',
        title: 'Gratitude Share 🙏',
        description: 'Share 3 things you appreciate about each other',
        category: 'Daily',
        points: 10,
        isCompleted: true,
        difficulty: 'Easy',
      ),
      Challenge(
        id: '6',
        title: 'Photo Challenge 📸',
        description: 'Take 10 creative couple photos together',
        category: 'Weekly',
        points: 30,
        isCompleted: false,
        difficulty: 'Medium',
      ),
    ];

    _completedChallenges = _challenges.where((c) => c.isCompleted).length;
    _currentStreak = 3; // Sample streak
  }

  void _completeChallenge(String challengeId) {
    setState(() {
      final index = _challenges.indexWhere((c) => c.id == challengeId);
      if (index != -1 && !_challenges[index].isCompleted) {
        _challenges[index] = _challenges[index].copyWith(isCompleted: true);
        _completedChallenges++;
        _currentStreak++;
      }
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(context, 'Challenge completed! Great job! 🎉');
  }

  void _resetChallenge(String challengeId) {
    setState(() {
      final index = _challenges.indexWhere((c) => c.id == challengeId);
      if (index != -1) {
        _challenges[index] = _challenges[index].copyWith(isCompleted: false);
        _completedChallenges--;
      }
    });

    HapticFeedback.lightImpact();
    ToastService.showInfo(context, 'Challenge reset! You can try again! 🔄');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Couple Challenges 💪',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Stats Section
            Container(
              margin: EdgeInsets.all(20.w),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('$_completedChallenges', 'Completed',
                      Icons.check_circle, AppTheme.primaryPink),
                  _buildStatItem('$_currentStreak', 'Streak',
                      Icons.local_fire_department, AppTheme.accentYellow),
                  _buildStatItem(
                      '${_challenges.fold(0, (sum, c) => sum + (c.isCompleted ? c.points : 0))}',
                      'Points',
                      Icons.stars,
                      AppTheme.primaryBlue),
                ],
              ),
            ),

            // Challenges List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _challenges.length,
                itemBuilder: (context, index) {
                  final challenge = _challenges[index];
                  return _buildChallengeCard(challenge);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.w),
        SizedBox(height: 8.h),
        Text(
          value,
          style: BabyFont.headingM.copyWith(
            color: color,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: challenge.isCompleted
                ? AppTheme.primaryPink.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
        border: challenge.isCompleted
            ? Border.all(
                color: AppTheme.primaryPink.withValues(alpha: 0.3), width: 1.w)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              if (challenge.isCompleted)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryPink,
                  size: 24.w,
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            challenge.description,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildCategoryChip(challenge.category),
              SizedBox(width: 8.w),
              _buildDifficultyChip(challenge.difficulty),
              const Spacer(),
              Text(
                '${challenge.points} pts',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (challenge.isCompleted) {
                  _resetChallenge(challenge.id);
                } else {
                  _completeChallenge(challenge.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: challenge.isCompleted
                    ? Colors.grey.withValues(alpha: 0.3)
                    : AppTheme.primaryPink,
                foregroundColor:
                    challenge.isCompleted ? Colors.grey : Colors.white,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                challenge.isCompleted ? 'Completed ✓' : 'Complete Challenge',
                style: BabyFont.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    Color color;
    switch (category) {
      case 'Daily':
        color = AppTheme.primaryBlue;
        break;
      case 'Weekly':
        color = AppTheme.accentYellow;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        category,
        style: BabyFont.bodyS.copyWith(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'Easy':
        color = Colors.green;
        break;
      case 'Medium':
        color = AppTheme.accentYellow;
        break;
      case 'Hard':
        color = AppTheme.primaryPink;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        difficulty,
        style: BabyFont.bodyS.copyWith(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int points;
  final bool isCompleted;
  final String difficulty;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.isCompleted,
    required this.difficulty,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? points,
    bool? isCompleted,
    String? difficulty,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
