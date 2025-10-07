import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../domain/entities/quiz_entities.dart';
// import '../screens/quiz_game_screen.dart';

// Enhanced Carousel with 3 Cards
class EnhancedQuizCarousel extends StatefulWidget {
  final List<Quiz> quizzes;
  final double height;

  const EnhancedQuizCarousel({
    super.key,
    required this.quizzes,
    required this.height,
  });

  @override
  State<EnhancedQuizCarousel> createState() => _EnhancedQuizCarouselState();
}

class _EnhancedQuizCarouselState extends State<EnhancedQuizCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quizzes.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.quizzes.length,
            itemBuilder: (context, index) {
              final quiz = widget.quizzes[index];
              final isActive = index == _currentIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: isActive ? 0 : 20,
                ),
                child: GestureDetector(
                  onTap: () => _navigateToQuiz(context, quiz),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: _getQuizGradient(quiz.category),
                      boxShadow: [
                        BoxShadow(
                          color: _getQuizColor(quiz.category)
                              .withValues(alpha: 0.3),
                          blurRadius: isActive ? 20 : 10,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Text(
                            quiz.icon,
                            style: TextStyle(
                              fontSize: 120,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                quiz.icon,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                quiz.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                quiz.description,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              // Progress indicator
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: quiz.progressPercentage / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${quiz.completedLevels}/${quiz.totalLevels} levels',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.quizzes.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentIndex == entry.key ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentIndex == entry.key
                    ? AppTheme.primaryPink
                    : Colors.grey.withValues(alpha: 0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  LinearGradient _getQuizGradient(QuizCategory category) {
    switch (category) {
      case QuizCategory.babyPrediction:
        return LinearGradient(
          colors: [
            AppTheme.primaryPink,
            AppTheme.primaryPink.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case QuizCategory.coupleCompatibility:
        return LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [
            AppTheme.accentYellow,
            AppTheme.accentYellow.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getQuizColor(QuizCategory category) {
    switch (category) {
      case QuizCategory.babyPrediction:
        return AppTheme.primaryPink;
      case QuizCategory.coupleCompatibility:
        return AppTheme.primaryBlue;
      default:
        return AppTheme.accentYellow;
    }
  }

  void _navigateToQuiz(BuildContext context, Quiz quiz) {
    if (quiz.levels.isNotEmpty) {
      context.go('/main/quiz-game');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// Enhanced Baby Prediction Widget with Pink Theme
class EnhancedBabyPredictionWidget extends StatelessWidget {
  final Quiz quiz;

  const EnhancedBabyPredictionWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink,
            AppTheme.primaryPink.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -40,
            top: -40,
            child: Text(
              '👶',
              style: TextStyle(
                fontSize: 150,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '👶',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Baby Prediction Quiz',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Discover your future baby\'s features',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Level cards
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: quiz.levels.length,
                    itemBuilder: (context, index) {
                      final level = quiz.levels[index];
                      return GestureDetector(
                        onTap: () {
                          context.go('/main/quiz-game');
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: level.isUnlocked
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!level.isUnlocked)
                                Icon(
                                  Icons.lock,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 24,
                                )
                              else
                                Text(
                                  '🎯',
                                  style: TextStyle(fontSize: 32),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                'Level ${level.levelNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                level.title,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Progress section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress: ${quiz.completedLevels}/${quiz.totalLevels}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: quiz.progressPercentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Start Quiz',
                        style: TextStyle(
                          color: AppTheme.primaryPink,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    if (level.isUnlocked) {
      context.go('/main/quiz-game');
    }
  }
}

// 1. Carousel Banner Widget
class QuizCarouselBanner extends StatefulWidget {
  final List<Quiz> featuredQuizzes;
  final double height;

  const QuizCarouselBanner({
    super.key,
    required this.featuredQuizzes,
    required this.height,
  });

  @override
  State<QuizCarouselBanner> createState() => _QuizCarouselBannerState();
}

class _QuizCarouselBannerState extends State<QuizCarouselBanner> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && widget.featuredQuizzes.isNotEmpty) {
        _currentIndex = (_currentIndex + 1) % widget.featuredQuizzes.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featuredQuizzes.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.featuredQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = widget.featuredQuizzes[index];
              return Container(
                margin: context.responsiveMargin,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius(20)),
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Text(
                        quiz.icon,
                        style: TextStyle(fontSize: context.responsiveFont(80)),
                      ),
                    ),
                    Padding(
                      padding: context.responsivePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            quiz.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.responsiveFont(22),
                                ),
                          ),
                          SizedBox(height: context.responsiveMargin.top / 2),
                          Text(
                            quiz.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: context.responsiveFont(14),
                                ),
                          ),
                          SizedBox(height: context.responsiveMargin.top),
                          LinearProgressIndicator(
                            value: quiz.progressPercentage / 100,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                          SizedBox(height: context.responsiveMargin.top / 2),
                          Text(
                            '${quiz.completedLevels}/${quiz.totalLevels} levels completed',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: context.responsiveFont(12),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.featuredQuizzes.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == entry.key ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == entry.key
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// 2. Card Grid Widget
class QuizCardGrid extends StatelessWidget {
  final Quiz quiz;

  const QuizCardGrid({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.cardHeight * 1.5,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: quiz.levels.length,
        itemBuilder: (context, index) {
          final level = quiz.levels[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
              gradient: level.isUnlocked
                  ? AppTheme.secondaryGradient
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    ),
              boxShadow: [
                BoxShadow(
                  color: (level.isUnlocked ? AppTheme.secondary : Colors.grey)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (!level.isUnlocked)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.lock, color: Colors.white, size: 16),
                  ),
                if (level.isCompleted)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child:
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quiz.icon,
                        style: TextStyle(fontSize: context.responsiveFont(24)),
                      ),
                      SizedBox(height: context.responsiveMargin.top / 2),
                      Text(
                        'Level ${level.levelNumber}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: context.responsiveFont(12),
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 3. List Tile Widget
class QuizListTile extends StatelessWidget {
  final Quiz quiz;

  const QuizListTile({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: Text(
            quiz.icon,
            style: TextStyle(fontSize: context.responsiveFont(20)),
          ),
        ),
        title: Text(
          quiz.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: context.responsiveFont(16),
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: context.responsiveFont(12),
                  ),
            ),
            SizedBox(height: context.responsiveMargin.top / 2),
            LinearProgressIndicator(
              value: quiz.progressPercentage / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ],
        ),
        trailing: Text(
          '${quiz.completedLevels}/${quiz.totalLevels}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: context.responsiveFont(12),
              ),
        ),
        children: quiz.levels.map((level) {
          return ListTile(
            dense: true,
            leading: Icon(
              level.isCompleted
                  ? Icons.check_circle
                  : level.isUnlocked
                      ? Icons.play_circle_outline
                      : Icons.lock,
              color: level.isCompleted
                  ? Colors.green
                  : level.isUnlocked
                      ? AppTheme.primary
                      : Colors.grey,
              size: context.responsiveFont(20),
            ),
            title: Text(
              level.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: context.responsiveFont(14),
                  ),
            ),
            subtitle: Text(
              level.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: context.responsiveFont(12),
                  ),
            ),
            onTap: level.isUnlocked
                ? () {
                    context.go('/main/quiz-game');
                  }
                : null,
          );
        }).toList(),
      ),
    );
  }
}

// 4. Horizontal Scroll Widget
class QuizHorizontalScroll extends StatelessWidget {
  final Quiz quiz;

  const QuizHorizontalScroll({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: quiz.levels.length,
        itemBuilder: (context, index) {
          final level = quiz.levels[index];
          return GestureDetector(
            onTap: level.isUnlocked
                ? () {
                    context.go('/main/quiz-game');
                  }
                : null,
            child: Container(
              width: context.screenWidth * 0.4,
              margin: EdgeInsets.only(right: context.responsiveMargin.right),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(context.responsiveRadius(20)),
                gradient: level.isUnlocked
                    ? LinearGradient(
                        colors: [
                          AppTheme.accent,
                          AppTheme.accent.withValues(alpha: 0.7)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: (level.isUnlocked ? AppTheme.accent : Colors.grey)
                        .withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: context.responsivePadding / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      quiz.icon,
                      style: TextStyle(fontSize: context.responsiveFont(32)),
                    ),
                    SizedBox(height: context.responsiveMargin.top / 2),
                    Text(
                      level.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: level.isUnlocked
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: context.responsiveFont(14),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.responsiveMargin.top / 4),
                    Text(
                      level.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: level.isUnlocked
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.grey.shade500,
                            fontSize: context.responsiveFont(10),
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 5. Masonry Layout Widget
class QuizMasonryLayout extends StatelessWidget {
  final Quiz quiz;

  const QuizMasonryLayout({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.cardHeight * 2,
      child: MasonryGridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        itemCount: quiz.levels.length,
        itemBuilder: (context, index) {
          final level = quiz.levels[index];
          final height = (index % 3 + 1) * 60.0; // Varying heights

          return Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
              color: level.isUnlocked ? AppTheme.primary : Colors.grey.shade300,
              boxShadow: [
                BoxShadow(
                  color: (level.isUnlocked ? AppTheme.primary : Colors.grey)
                      .withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    quiz.icon,
                    style: TextStyle(fontSize: context.responsiveFont(20)),
                  ),
                  if (height > 80)
                    Text(
                      'L${level.levelNumber}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: level.isUnlocked
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: context.responsiveFont(10),
                          ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 6. Accordion Widget
class QuizAccordion extends StatefulWidget {
  final Quiz quiz;

  const QuizAccordion({super.key, required this.quiz});

  @override
  State<QuizAccordion> createState() => _QuizAccordionState();
}

class _QuizAccordionState extends State<QuizAccordion> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.quiz.levels.asMap().entries.map((entry) {
        final index = entry.key;
        final level = entry.value;
        final isExpanded = expandedIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: context.responsiveMargin.bottom / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: level.isUnlocked
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                  child: Text(
                    widget.quiz.icon,
                    style: TextStyle(fontSize: context.responsiveFont(16)),
                  ),
                ),
                title: Text(
                  level.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: context.responsiveFont(14),
                      ),
                ),
                trailing: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.expand_more,
                    color: level.isUnlocked ? AppTheme.primary : Colors.grey,
                  ),
                ),
                onTap: level.isUnlocked
                    ? () {
                        setState(() {
                          expandedIndex = isExpanded ? null : index;
                        });
                      }
                    : null,
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: context.responsivePadding / 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: context.responsiveFont(12),
                            ),
                      ),
                      SizedBox(height: context.responsiveMargin.top / 2),
                      Row(
                        children: [
                          Icon(
                            Icons.quiz,
                            size: context.responsiveFont(16),
                            color: AppTheme.primary,
                          ),
                          SizedBox(width: context.responsiveMargin.left / 2),
                          Text(
                            '${level.questions.length} questions + 1 puzzle',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: context.responsiveFont(10),
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// 7. Carousel Cards Widget
class QuizCarouselCards extends StatelessWidget {
  final Quiz quiz;

  const QuizCarouselCards({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.cardHeight * 1.2,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.8),
        physics: const BouncingScrollPhysics(),
        itemCount: quiz.levels.length,
        itemBuilder: (context, index) {
          final level = quiz.levels[index];
          return Container(
            margin: EdgeInsets.symmetric(
                horizontal: context.responsiveMargin.left / 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.responsiveRadius(20)),
              gradient: level.isUnlocked
                  ? AppTheme.secondaryGradient
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    ),
              boxShadow: [
                BoxShadow(
                  color: (level.isUnlocked ? AppTheme.secondary : Colors.grey)
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -10,
                  child: Text(
                    quiz.icon,
                    style: TextStyle(
                      fontSize: context.responsiveFont(60),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                Padding(
                  padding: context.responsivePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        level.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: level.isUnlocked
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: context.responsiveFont(18),
                            ),
                      ),
                      SizedBox(height: context.responsiveMargin.top / 2),
                      Text(
                        level.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: level.isUnlocked
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.grey.shade500,
                              fontSize: context.responsiveFont(12),
                            ),
                      ),
                      SizedBox(height: context.responsiveMargin.top),
                      Row(
                        children: [
                          Icon(
                            level.isCompleted
                                ? Icons.check_circle
                                : level.isUnlocked
                                    ? Icons.play_circle_outline
                                    : Icons.lock,
                            color: level.isCompleted
                                ? Colors.white
                                : level.isUnlocked
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.grey.shade500,
                            size: context.responsiveFont(20),
                          ),
                          SizedBox(width: context.responsiveMargin.left / 2),
                          Text(
                            level.isCompleted
                                ? 'Completed'
                                : level.isUnlocked
                                    ? 'Start Level'
                                    : 'Locked',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: level.isUnlocked
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                  fontWeight: FontWeight.w600,
                                  fontSize: context.responsiveFont(12),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 8. Timeline Widget
class QuizTimeline extends StatelessWidget {
  final Quiz quiz;

  const QuizTimeline({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.cardHeight * 1.5,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: quiz.levels.length,
        itemBuilder: (context, index) {
          final level = quiz.levels[index];
          final isLast = index == quiz.levels.length - 1;

          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: level.isCompleted
                          ? Colors.green
                          : level.isUnlocked
                              ? AppTheme.primary
                              : Colors.grey.shade300,
                      boxShadow: [
                        BoxShadow(
                          color: (level.isCompleted
                                  ? Colors.green
                                  : level.isUnlocked
                                      ? AppTheme.primary
                                      : Colors.grey)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: level.isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: context.responsiveFont(24),
                            )
                          : level.isUnlocked
                              ? Text(
                                  quiz.icon,
                                  style: TextStyle(
                                      fontSize: context.responsiveFont(20)),
                                )
                              : Icon(
                                  Icons.lock,
                                  color: Colors.grey.shade600,
                                  size: context.responsiveFont(20),
                                ),
                    ),
                  ),
                  SizedBox(height: context.responsiveMargin.top / 2),
                  SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        Text(
                          level.title,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: context.responsiveFont(12),
                                  ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: context.responsiveMargin.top / 4),
                        Text(
                          'Level ${level.levelNumber}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontSize: context.responsiveFont(10),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Container(
                  width: 40,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 80),
                  color: level.isCompleted
                      ? Colors.green
                      : level.isUnlocked
                          ? AppTheme.primary
                          : Colors.grey.shade300,
                ),
            ],
          );
        },
      ),
    );
  }
}

// 9. Grid Tiles Widget
class QuizGridTiles extends StatelessWidget {
  final Quiz quiz;

  const QuizGridTiles({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.gridCrossAxisCount,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: quiz.levels.length,
      itemBuilder: (context, index) {
        final level = quiz.levels[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
            gradient: level.isUnlocked
                ? LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.8),
                      AppTheme.secondary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.shade400,
                      Colors.grey.shade500,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (!level.isUnlocked)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.lock, color: Colors.white, size: 20),
                ),
              if (level.isCompleted)
                const Positioned(
                  top: 8,
                  right: 8,
                  child:
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      quiz.icon,
                      style: TextStyle(fontSize: context.responsiveFont(32)),
                    ),
                    SizedBox(height: context.responsiveMargin.top / 2),
                    Text(
                      level.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: context.responsiveFont(14),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 10. Floating Action Widget
class QuizFloatingAction extends StatefulWidget {
  final Quiz quiz;

  const QuizFloatingAction({super.key, required this.quiz});

  @override
  State<QuizFloatingAction> createState() => _QuizFloatingActionState();
}

class _QuizFloatingActionState extends State<QuizFloatingAction>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.quiz.levels.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 500 + (index * 200)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();

    // Start animations with delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.cardHeight * 1.8,
      child: Stack(
        children: widget.quiz.levels.asMap().entries.map((entry) {
          final index = entry.key;
          final level = entry.value;

          // Calculate position for floating effect
          final double left = (index % 3) * (context.screenWidth * 0.25) + 20;
          final double top = (index ~/ 3) * 80.0 + 20;

          return Positioned(
            left: left,
            top: top,
            child: SlideTransition(
              position: _animations[index],
              child: GestureDetector(
                onTap: level.isUnlocked
                    ? () {
                        context.go('/main/quiz-game');
                      }
                    : null,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: level.isUnlocked
                        ? RadialGradient(
                            colors: [
                              AppTheme.accent,
                              AppTheme.accent.withValues(alpha: 0.7),
                            ],
                          )
                        : RadialGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade400,
                            ],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (level.isUnlocked ? AppTheme.accent : Colors.grey)
                                .withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.quiz.icon,
                              style: TextStyle(
                                  fontSize: context.responsiveFont(20)),
                            ),
                            Text(
                              '${level.levelNumber}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: level.isUnlocked
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.responsiveFont(10),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (!level.isUnlocked)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.lock,
                            color: Colors.grey.shade600,
                            size: 12,
                          ),
                        ),
                      if (level.isCompleted)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
