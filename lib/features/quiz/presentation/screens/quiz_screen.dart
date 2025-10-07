import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/animated_heart';
import '../../../../shared/widgets/toast_service.dart';
import '../widgets/quiz_category_widgets.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../domain/entities/quiz_entities.dart';

/// Comprehensive Quiz Screen with all 5 quiz categories
/// Following master plan requirements with emotional connections
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _heartController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _floatingAnimation;
  late PageController _carouselController;

  List<Quiz> quizzes = [];
  int _currentCarouselIndex = 0;
  int _totalScore = 0;
  int _completedQuizzes = 0;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadQuizData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _heartAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _carouselController = PageController(viewportFraction: 0.85);

    _animationController.forward();
    _heartController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heartController.dispose();
    _floatingController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  void _loadQuizData() {
    setState(() {
      quizzes = QuizRepository.getAllQuizzes();
      _totalScore =
          quizzes.fold(0, (sum, quiz) => sum + quiz.completedLevels * 10);
      _completedQuizzes =
          quizzes.where((quiz) => quiz.completedLevels > 0).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Stack(
        children: [
          // Animated hearts background
          const Positioned.fill(
            child: AnimatedHearts(),
          ),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Enhanced App Bar
                  _buildAppBar(),

                  // Quiz Stats Section
                  _buildQuizStatsSection(),

                  // Category Filter
                  _buildCategoryFilter(),

                  // Enhanced Carousel with 3 Cards
                  SliverToBoxAdapter(
                    child: _buildEnhancedCarousel(context),
                  ),

                  // Enhanced Baby Prediction Widget (Pink Theme)
                  SliverToBoxAdapter(
                    child: _buildEnhancedBabyPrediction(context),
                  ),

                  // Quiz Category Widgets
                  SliverList(
                    delegate: SliverChildListDelegate([
                      // 1. Love Language - Horizontal Scroll Cards
                      if (quizzes.length > 2)
                        _buildQuizSection(
                          context,
                          "Love Language Discovery 💕",
                          LoveLanguageWidget(
                            quiz: quizzes.firstWhere(
                              (q) => q.category == QuizCategory.loveLanguage,
                              orElse: () => quizzes[2],
                            ),
                          ),
                        ),

                      // 2. Future Home - Grid Cards
                      if (quizzes.length > 3)
                        _buildQuizSection(
                          context,
                          "Future Home Planning 🏠",
                          FutureHomeWidget(
                            quiz: quizzes.firstWhere(
                              (q) => q.category == QuizCategory.futureHome,
                              orElse: () => quizzes[3],
                            ),
                          ),
                        ),

                      // 3. Parenting Style - Expansion Tiles
                      if (quizzes.length > 4)
                        _buildQuizSection(
                          context,
                          "Parenting Style 👨‍👩‍👧‍👦",
                          ParentingStyleWidget(
                            quiz: quizzes.firstWhere(
                              (q) => q.category == QuizCategory.parentingStyle,
                              orElse: () => quizzes[4],
                            ),
                          ),
                        ),

                      // 4. Relationship Milestones - Timeline
                      if (quizzes.length > 5)
                        _buildQuizSection(
                          context,
                          "Relationship Milestones 💍",
                          RelationshipMilestonesWidget(
                            quiz: quizzes.firstWhere(
                              (q) =>
                                  q.category ==
                                  QuizCategory.relationshipMilestones,
                              orElse: () => quizzes[5],
                            ),
                          ),
                        ),

                      // 5. Couple Puzzles - Staggered Grid
                      if (quizzes.length > 6)
                        _buildQuizSection(
                          context,
                          "Couple Puzzles 🧩",
                          CouplePuzzlesWidget(
                            quiz: quizzes.firstWhere(
                              (q) => q.category == QuizCategory.couplePuzzles,
                              orElse: () => quizzes[6],
                            ),
                          ),
                        ),

                      // 6. Role Play Scenarios - Carousel Cards
                      if (quizzes.length > 7)
                        _buildQuizSection(
                          context,
                          "Role Play Scenarios 🎭",
                          RolePlayScenariosWidget(
                            quiz: quizzes.firstWhere(
                              (q) =>
                                  q.category == QuizCategory.rolePlayScenarios,
                              orElse: () => quizzes[7],
                            ),
                          ),
                        ),

                      // 7. Future Predictions - Floating Action Cards
                      if (quizzes.length > 8)
                        _buildQuizSection(
                          context,
                          "Future Predictions 🔮",
                          FuturePredictionsWidget(
                            quiz: quizzes.firstWhere(
                              (q) =>
                                  q.category == QuizCategory.futurePredictions,
                              orElse: () => quizzes[8],
                            ),
                          ),
                        ),

                      // 8. Anniversary Memories - Photo Grid
                      if (quizzes.length > 9)
                        _buildQuizSection(
                          context,
                          "Anniversary Memories 📸",
                          AnniversaryMemoriesWidget(
                            quiz: quizzes.firstWhere(
                              (q) =>
                                  q.category ==
                                  QuizCategory.anniversaryMemories,
                              orElse: () => quizzes[9],
                            ),
                          ),
                        ),

                      // 9. Couple Compatibility - Progress Rings (Alternative Style)
                      if (quizzes.length > 1)
                        _buildQuizSection(
                          context,
                          "Compatibility Test 💖",
                          CompatibilityTestWidget(
                            quiz: quizzes.firstWhere(
                              (q) =>
                                  q.category ==
                                  QuizCategory.coupleCompatibility,
                              orElse: () => quizzes[1],
                            ),
                          ),
                        ),

                      // 10. Dream Wedding - Elegant Cards (if available)
                      if (quizzes.length > 10)
                        _buildQuizSection(
                          context,
                          "Dream Wedding 💒",
                          DreamWeddingWidget(
                            quiz: quizzes.length > 10
                                ? quizzes[10]
                                : quizzes.last,
                          ),
                        ),

                      // Bottom spacing
                      SizedBox(height: context.responsivePadding.top * 2),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPink,
                AppTheme.primaryBlue,
                AppTheme.accentYellow,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quiz Arena 🎮',
                            style: BabyFont.headingL.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Discover your love story together! 💕',
                            style: BabyFont.bodyM.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.quiz_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizStatsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _heartAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heartAnimation.value,
                        child: Icon(
                          Icons.quiz_rounded,
                          color: AppTheme.primaryPink,
                          size: 28,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Quiz Journey 🎯',
                          style: BabyFont.headingM.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Keep exploring your love story!',
                          style: BabyFont.bodyS.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Score',
                      '$_totalScore',
                      Icons.star,
                      AppTheme.primaryPink,
                      '⭐',
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      '$_completedQuizzes',
                      Icons.check_circle,
                      AppTheme.primaryBlue,
                      '✅',
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      'Available',
                      '${quizzes.length}',
                      Icons.quiz,
                      AppTheme.accentYellow,
                      '🎮',
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

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, String emoji) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 4),
          Icon(icon, color: color, size: 16),
          SizedBox(height: 8),
          Text(
            value,
            style: BabyFont.headingM.copyWith(
              fontSize: 18,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: BabyFont.bodyS.copyWith(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Love', 'Future', 'Parenting', 'Relationship'];

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Category 🔍',
              style: BabyFont.headingS.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      HapticFeedback.lightImpact();
                      ToastService.showInfo(
                          context, 'Filtered by $category! 🔍');
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryPink : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryPink
                              : AppTheme.borderColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isSelected
                                    ? AppTheme.primaryPink
                                    : Colors.black)
                                .withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        category,
                        style: BabyFont.bodyM.copyWith(
                          color:
                              isSelected ? Colors.white : AppTheme.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCarousel(BuildContext context) {
    if (quizzes.isEmpty) return const SizedBox.shrink();

    final carouselQuizzes = quizzes.take(3).toList();

    return Container(
      height: 220,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: PageView.builder(
        controller: _carouselController,
        onPageChanged: (index) {
          setState(() {
            _currentCarouselIndex = index;
          });
        },
        itemCount: carouselQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = carouselQuizzes[index];
          final isActive = index == _currentCarouselIndex;

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
                      color:
                          _getQuizColor(quiz.category).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background Icon
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Text(
                        quiz.icon,
                        style: TextStyle(
                          fontSize: 80,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            quiz.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            quiz.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${quiz.completedLevels}/${quiz.totalLevels} levels completed',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
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
    );
  }

  Widget _buildEnhancedBabyPrediction(BuildContext context) {
    if (quizzes.isEmpty) return const SizedBox.shrink();

    final babyQuiz = quizzes.firstWhere(
      (q) => q.category == QuizCategory.babyPrediction,
      orElse: () => quizzes.first,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Baby Prediction',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Enhanced Baby Prediction Card
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF6B9D), // Pink
                  Color(0xFFFFB5C5), // Light Pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned(
                  right: -20,
                  top: -20,
                  child: AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 5 * _floatingAnimation.value),
                        child: Text(
                          '🍼',
                          style: TextStyle(
                            fontSize: 100,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Baby Prediction Quiz',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Predict your future baby\'s features and personality',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${babyQuiz.completedLevels}/${babyQuiz.totalLevels} levels completed',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tap Area
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _navigateToQuiz(context, babyQuiz),
                      child: Container(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Level Grid
          SizedBox(
            height: 90,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: babyQuiz.levels.length,
              itemBuilder: (context, index) {
                final level = babyQuiz.levels[index];
                return GestureDetector(
                  onTap: level.isUnlocked
                      ? () => _navigateToLevel(context, babyQuiz, level)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: level.isUnlocked
                          ? const Color(0xFFFF6B9D)
                          : Colors.grey.withValues(alpha: 0.3),
                      boxShadow: level.isUnlocked
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF6B9D)
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🍼',
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                level.isUnlocked ? Colors.white : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'L${level.levelNumber}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color:
                                level.isUnlocked ? Colors.white : Colors.grey,
                          ),
                        ),
                        if (!level.isUnlocked)
                          Icon(
                            Icons.lock,
                            size: 10,
                            color: Colors.grey,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getQuizGradient(QuizCategory category) {
    switch (category) {
      case QuizCategory.babyPrediction:
        return const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFFB5C5)],
        );
      case QuizCategory.coupleCompatibility:
        return const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        );
      case QuizCategory.loveLanguage:
        return const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        );
    }
  }

  Color _getQuizColor(QuizCategory category) {
    switch (category) {
      case QuizCategory.babyPrediction:
        return const Color(0xFFFF6B9D);
      case QuizCategory.coupleCompatibility:
        return const Color(0xFF667eea);
      case QuizCategory.loveLanguage:
        return const Color(0xFFf093fb);
      default:
        return const Color(0xFF4facfe);
    }
  }

  void _navigateToQuiz(BuildContext context, Quiz quiz) {
    HapticFeedback.lightImpact();
    ToastService.showBabyMessage(context, 'Starting ${quiz.title}! 🎮');
    if (quiz.levels.isNotEmpty && quiz.levels.first.isUnlocked) {
      _navigateToLevel(context, quiz, quiz.levels.first);
    } else {
      ToastService.showWarning(context, 'Complete previous levels first! 🔒');
    }
  }

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    HapticFeedback.mediumImpact();
    ToastService.showCelebration(
        context, 'Level ${level.levelNumber} unlocked! 🌟');
    context.go('/main/quiz-game');
  }

  Widget _buildQuizSection(BuildContext context, String title, Widget child) {
    return Padding(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: context.responsiveFont(20),
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: context.responsiveMargin.top),
          child,
          SizedBox(height: context.responsivePadding.top),
        ],
      ),
    );
  }
}

// Removed PlayerToggleSwitch for cleaner UI
