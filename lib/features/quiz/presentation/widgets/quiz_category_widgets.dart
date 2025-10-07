import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/quiz_entities.dart';
// import '../screens/quiz_game_screen.dart';

// Standard height for all quiz widgets
const double _kQuizWidgetHeight = 180.0;

// 1. Love Language Widget - Horizontal Scroll Cards
class LoveLanguageWidget extends StatelessWidget {
  final Quiz quiz;

  const LoveLanguageWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kQuizWidgetHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: quiz.levels.length,
        itemBuilder: (context, index) {
          final level = quiz.levels[index];
          return GestureDetector(
            onTap: level.isUnlocked
                ? () => _navigateToLevel(context, quiz, level)
                : null,
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: level.isUnlocked
                      ? [const Color(0xFFf093fb), const Color(0xFFf5576c)]
                      : [Colors.grey.shade300, Colors.grey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (level.isUnlocked
                            ? const Color(0xFFf093fb)
                            : Colors.grey)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '💕',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      flex: 2,
                      child: Text(
                        level.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: level.isUnlocked
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (!level.isUnlocked)
                      Icon(Icons.lock, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    context.go('/main/quiz-game');
  }
}

// 2. Future Home Widget - Grid Cards
class FutureHomeWidget extends StatelessWidget {
  final Quiz quiz;

  const FutureHomeWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kQuizWidgetHeight,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: quiz.levels.length,
        itemBuilder: (context, index) {
          final level = quiz.levels[index];
          return GestureDetector(
            onTap: level.isUnlocked
                ? () => _navigateToLevel(context, quiz, level)
                : null,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: level.isUnlocked
                    ? const Color(0xFF4facfe)
                    : Colors.grey.withValues(alpha: 0.3),
                boxShadow: level.isUnlocked
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4facfe).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '🏠',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      'Level ${level.levelNumber}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: level.isUnlocked ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                  if (!level.isUnlocked)
                    const Icon(Icons.lock, size: 12, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    context.go('/main/quiz-game');
  }
}

// 3. Parenting Style Widget - Expansion Tiles
class ParentingStyleWidget extends StatelessWidget {
  final Quiz quiz;

  const ParentingStyleWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kQuizWidgetHeight,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ExpansionTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF667eea),
            child: Text('👶', style: TextStyle(fontSize: 20)),
          ),
          title: Text(
            quiz.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            '${quiz.completedLevels}/${quiz.totalLevels} completed',
            style: const TextStyle(fontSize: 12),
          ),
          children: quiz.levels.take(3).map((level) {
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
                        ? const Color(0xFF667eea)
                        : Colors.grey,
                size: 20,
              ),
              title: Text(
                level.title,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                level.description,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: level.isUnlocked
                  ? () => _navigateToLevel(context, quiz, level)
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    context.go('/main/quiz-game');
  }
}

// 4. Relationship Milestones Widget - Timeline Style
class RelationshipMilestonesWidget extends StatelessWidget {
  final Quiz quiz;

  const RelationshipMilestonesWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kQuizWidgetHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quiz.levels.length,
        itemBuilder: (context, index) {
          final level = quiz.levels[index];
          final isLast = index == quiz.levels.length - 1;

          return GestureDetector(
            onTap: level.isUnlocked
                ? () => _navigateToLevel(context, quiz, level)
                : null,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
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
                      child: Center(
                        child: level.isUnlocked
                            ? Text('💍', style: TextStyle(fontSize: 24))
                            : const Icon(Icons.lock, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        level.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              level.isUnlocked ? Colors.black87 : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Container(
                    width: 40,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 60),
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    context.go('/main/quiz-game');
  }
}

// 5. Couple Puzzles Widget - Staggered Grid
class CouplePuzzlesWidget extends StatelessWidget {
  final Quiz quiz;

  const CouplePuzzlesWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kQuizWidgetHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (quiz.levels.length / 2).ceil(),
        itemBuilder: (context, columnIndex) {
          final startIndex = columnIndex * 2;
          final endIndex = (startIndex + 2).clamp(0, quiz.levels.length);
          final columnLevels = quiz.levels.sublist(startIndex, endIndex);

          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: columnLevels.asMap().entries.map((entry) {
                final level = entry.value;
                final isFirst = entry.key == 0;

                return Expanded(
                  flex: isFirst ? 3 : 2,
                  child: GestureDetector(
                    onTap: level.isUnlocked
                        ? () => _navigateToLevel(context, quiz, level)
                        : null,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: level.isUnlocked
                            ? const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400
                                ],
                              ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                level.isUnlocked ? '🧩' : '🔒',
                                style: TextStyle(fontSize: isFirst ? 28 : 20),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                'L${level.levelNumber}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: level.isUnlocked
                                      ? Colors.white
                                      : Colors.grey,
                                ),
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
        },
      ),
    );
  }

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    context.go('/main/quiz-game');
  }
}

// 6. Role Play Scenarios Widget - Carousel Cards
class RolePlayScenariosWidget extends StatefulWidget {
  final Quiz quiz;

  const RolePlayScenariosWidget({super.key, required this.quiz});

  @override
  State<RolePlayScenariosWidget> createState() =>
      _RolePlayScenariosWidgetState();
}

class _RolePlayScenariosWidgetState extends State<RolePlayScenariosWidget> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kQuizWidgetHeight,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: widget.quiz.levels.length,
              itemBuilder: (context, index) {
                final level = widget.quiz.levels[index];
                final isActive = index == _currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: isActive ? 0 : 15,
                  ),
                  child: GestureDetector(
                    onTap: level.isUnlocked
                        ? () => _navigateToLevel(context, widget.quiz, level)
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: level.isUnlocked
                            ? const LinearGradient(
                                colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400
                                ],
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: (level.isUnlocked
                                    ? const Color(0xFFa8edea)
                                    : Colors.grey)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                level.isUnlocked ? '🎭' : '🔒',
                                style: TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Flexible(
                              flex: 2,
                              child: Text(
                                level.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: level.isUnlocked
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                level.description,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: level.isUnlocked
                                      ? Colors.black54
                                      : Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.quiz.levels.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentIndex ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index == _currentIndex
                      ? const Color(0xFFa8edea)
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    context.go('/main/quiz-game');
  }
}

// 7. Future Predictions Widget - Floating Action Cards
class FuturePredictionsWidget extends StatelessWidget {
  final Quiz quiz;

  const FuturePredictionsWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kQuizWidgetHeight,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Floating cards
          ...quiz.levels.take(5).indexed.map((entry) {
            final index = entry.$1;
            final level = entry.$2;

            final positions = [
              const Offset(20, 20),
              const Offset(120, 60),
              const Offset(220, 30),
              const Offset(80, 120),
              const Offset(180, 140),
            ];
            final position = positions[index % positions.length];

            return Positioned(
              left: position.dx,
              top: position.dy,
              child: GestureDetector(
                onTap: level.isUnlocked
                    ? () => _navigateToLevel(context, quiz, level)
                    : null,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: level.isUnlocked
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: level.isUnlocked
                        ? Text('🔮', style: TextStyle(fontSize: 20))
                        : const Icon(Icons.lock, color: Colors.grey, size: 16),
                  ),
                ),
              ),
            );
          }),
          // Title overlay
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Future Predictions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${quiz.completedLevels}/${quiz.totalLevels} completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    context.go('/main/quiz-game');
  }
}

// 8. Anniversary Memories Widget - Photo Grid Style
class AnniversaryMemoriesWidget extends StatelessWidget {
  final Quiz quiz;

  const AnniversaryMemoriesWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kQuizWidgetHeight,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: quiz.levels.length,
        itemBuilder: (context, index) {
          final level = quiz.levels[index];
          return GestureDetector(
            onTap: level.isUnlocked
                ? () => _navigateToLevel(context, quiz, level)
                : null,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: level.isUnlocked
                    ? const LinearGradient(
                        colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: (level.isUnlocked
                            ? const Color(0xFFffecd2)
                            : Colors.grey)
                        .withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Photo frame effect
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              level.isUnlocked ? '📸' : '🔒',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              'Memory ${level.levelNumber}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: level.isUnlocked
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Corner decoration
                  if (level.isCompleted)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
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

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    context.go('/main/quiz-game');
  }
}

// 9. Dream Wedding Widget - Elegant Cards
class DreamWeddingWidget extends StatelessWidget {
  final Quiz quiz;

  const DreamWeddingWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kQuizWidgetHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: quiz.levels.length,
        itemBuilder: (context, index) {
          final level = quiz.levels[index];
          return GestureDetector(
            onTap: level.isUnlocked
                ? () => _navigateToLevel(context, quiz, level)
                : null,
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: level.isUnlocked
                    ? const LinearGradient(
                        colors: [Color(0xFFffeaa7), Color(0xFFfab1a0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: (level.isUnlocked
                            ? const Color(0xFFffeaa7)
                            : Colors.grey)
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative pattern
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            level.isUnlocked ? '💒' : '🔒',
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          flex: 2,
                          child: Text(
                            level.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: level.isUnlocked
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          child: Text(
                            'Level ${level.levelNumber}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  level.isUnlocked ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ],
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

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    context.go('/main/quiz-game');
  }
}

// 10. Compatibility Test Widget - Progress Rings
class CompatibilityTestWidget extends StatelessWidget {
  final Quiz quiz;

  const CompatibilityTestWidget({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kQuizWidgetHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Compatibility Test',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: quiz.levels.take(4).map((level) {
                final progress = level.isCompleted
                    ? 1.0
                    : level.isUnlocked
                        ? 0.5
                        : 0.0;
                return GestureDetector(
                  onTap: level.isUnlocked
                      ? () => _navigateToLevel(context, quiz, level)
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 3,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                            Text(
                              level.isUnlocked ? '💝' : '🔒',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'L${level.levelNumber}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Text(
            '${quiz.completedLevels}/${quiz.totalLevels} tests completed',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLevel(BuildContext context, Quiz quiz, QuizLevel level) {
    context.go('/main/quiz-game');
  }
}
