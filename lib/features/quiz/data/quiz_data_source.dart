import '../domain/models/quiz_models.dart';
import 'dart:math';

/// Quiz data source providing all quiz content
class QuizDataSource {
  static final QuizDataSource _instance = QuizDataSource._internal();
  factory QuizDataSource() => _instance;
  QuizDataSource._internal();

  /// Get all quiz categories with their levels and questions
  List<QuizCategoryModel> getAllQuizCategories() {
    return [
      _createBabyGameCategory(),
      _createCoupleGameCategory(),
      _createPartingGameCategory(),
      _createCouplesGoalsCategory(),
      _createKnowEachOtherCategory(),
    ];
  }

  /// Baby Game Category - Fun predictions & games for baby planning
  QuizCategoryModel _createBabyGameCategory() {
    return QuizCategoryModel(
      id: 'baby_game',
      category: QuizCategory.babyGame,
      title: 'Baby Game',
      description: 'Fun predictions & games for baby planning',
      iconPath: 'assets/icons/baby_game.png',
      colorValue: 0xFFFF6B81, // Pink
      levels: _createBabyGameLevels(),
      totalLevels: 5,
    );
  }

  List<QuizLevel> _createBabyGameLevels() {
    return [
      // Level 1 - Easy
      QuizLevel(
        id: 'baby_game_level_1',
        levelNumber: 1,
        title: 'Baby Basics',
        description: 'Learn the fundamentals of baby care',
        difficulty: DifficultyLevel.easy,
        isUnlocked: true, // First level is always unlocked
        questions: [
          QuizQuestion(
            id: 'bg_l1_q1',
            question: 'How many hours do newborns typically sleep per day?',
            options: ['8-10 hours', '14-17 hours', '20-22 hours', '6-8 hours'],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Newborns sleep 14-17 hours per day, waking every 2-3 hours to feed.',
          ),
          QuizQuestion(
            id: 'bg_l1_q2',
            question: 'At what age do babies typically start smiling socially?',
            options: ['1-2 weeks', '6-8 weeks', '3-4 months', '6 months'],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Babies usually start social smiling around 6-8 weeks old.',
          ),
          QuizQuestion(
            id: 'bg_l1_q3',
            question: 'What is the average weight of a newborn baby?',
            options: ['5-6 lbs', '7-8 lbs', '9-10 lbs', '4-5 lbs'],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation: 'The average newborn weighs between 7-8 pounds.',
          ),
          QuizQuestion(
            id: 'bg_l1_q4',
            question: 'How often should you feed a newborn?',
            options: [
              'Once a day',
              'Every 6 hours',
              'Every 2-3 hours',
              'Only when crying'
            ],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation:
                'Newborns need to be fed every 2-3 hours, including at night.',
          ),
          QuizQuestion(
            id: 'bg_l1_q5',
            question: 'Match the baby item with its purpose',
            options: ['Swaddle', 'Pacifier', 'Bib', 'Rattle'],
            correctAnswerIndex:
                0, // This is a puzzle, so we'll handle matching differently
            type: QuestionType.matching,
            explanation:
                'Each baby item serves a specific purpose for comfort and development.',
            puzzleData: {
              'items': ['Swaddle', 'Pacifier', 'Bib', 'Rattle'],
              'purposes': [
                'Keeps baby warm',
                'Soothes baby',
                'Protects clothes',
                'Stimulates senses'
              ],
              'correctMatches': [
                0,
                1,
                2,
                3
              ], // Each item matches its corresponding purpose
            },
          ),
        ],
        rewards: ['Baby Expert Badge', '50 points'],
      ),

      // Level 2 - Easy-Medium
      QuizLevel(
        id: 'baby_game_level_2',
        levelNumber: 2,
        title: 'Baby Development',
        description: 'Understanding baby milestones',
        difficulty: DifficultyLevel.easy,
        questions: [
          QuizQuestion(
            id: 'bg_l2_q1',
            question: 'When do babies typically start crawling?',
            options: [
              '4-6 months',
              '7-10 months',
              '11-12 months',
              '13-15 months'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation: 'Most babies start crawling between 7-10 months old.',
          ),
          QuizQuestion(
            id: 'bg_l2_q2',
            question:
                'What is the first solid food typically introduced to babies?',
            options: ['Fruits', 'Vegetables', 'Rice cereal', 'Meat'],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation:
                'Rice cereal is often the first solid food because it\'s easy to digest.',
          ),
          QuizQuestion(
            id: 'bg_l2_q3',
            question: 'At what age do babies typically say their first word?',
            options: ['6 months', '9-12 months', '15-18 months', '2 years'],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Most babies say their first recognizable word between 9-12 months.',
          ),
          QuizQuestion(
            id: 'bg_l2_q4',
            question:
                'How many teeth do babies typically have by their first birthday?',
            options: ['2-4 teeth', '6-8 teeth', '10-12 teeth', '16-20 teeth'],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation: 'Most babies have 6-8 teeth by their first birthday.',
          ),
          QuizQuestion(
            id: 'bg_l2_q5',
            question: 'Arrange the baby milestones in correct order',
            options: ['Rolling over', 'Sitting up', 'Crawling', 'Walking'],
            correctAnswerIndex: 0,
            type: QuestionType.dragDrop,
            explanation:
                'Baby milestones follow a predictable sequence of development.',
            puzzleData: {
              'items': ['Walking', 'Crawling', 'Rolling over', 'Sitting up'],
              'correctOrder': [
                2,
                3,
                1,
                0
              ], // Rolling over, Sitting up, Crawling, Walking
            },
          ),
        ],
        rewards: ['Development Expert Badge', '75 points'],
      ),

      // Level 3 - Medium
      QuizLevel(
        id: 'baby_game_level_3',
        levelNumber: 3,
        title: 'Baby Safety',
        description: 'Essential safety knowledge for parents',
        difficulty: DifficultyLevel.medium,
        questions: [
          QuizQuestion(
            id: 'bg_l3_q1',
            question: 'What is the safest sleep position for babies?',
            options: [
              'On their stomach',
              'On their back',
              'On their side',
              'Any position'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Babies should always sleep on their backs to reduce SIDS risk.',
          ),
          QuizQuestion(
            id: 'bg_l3_q2',
            question: 'At what temperature should you bathe a newborn?',
            options: ['95-100°F', '100-105°F', '98-100°F', '90-95°F'],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation:
                'Bath water should be 98-100°F (37-38°C) for newborn safety.',
          ),
          QuizQuestion(
            id: 'bg_l3_q3',
            question: 'When should you start baby-proofing your home?',
            options: [
              'Before baby arrives',
              'When baby starts crawling',
              'When baby starts walking',
              'After the first accident'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Start baby-proofing when your baby begins to crawl and explore.',
          ),
          QuizQuestion(
            id: 'bg_l3_q4',
            question: 'What should you never put in a baby\'s crib?',
            options: [
              'Fitted sheet',
              'Blankets and pillows',
              'Mattress',
              'Baby'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Blankets, pillows, and toys increase SIDS risk. Keep cribs bare.',
          ),
          QuizQuestion(
            id: 'bg_l3_q5',
            question: 'Identify the baby safety hazards in this room',
            options: ['Outlet', 'Sharp corner', 'Small object', 'All correct'],
            correctAnswerIndex: 3,
            type: QuestionType.puzzle,
            explanation:
                'Multiple hazards can exist in one room - always check thoroughly.',
            puzzleData: {
              'hazards': [
                'Uncovered outlet',
                'Sharp table corner',
                'Small toy on floor',
                'Loose cord'
              ],
              'safeItems': [
                'Soft rug',
                'Baby gate',
                'Outlet cover',
                'Corner guard'
              ],
              'correctHazards': [0, 1, 2, 3],
            },
          ),
        ],
        rewards: ['Safety Guardian Badge', '100 points'],
      ),

      // Level 4 - Medium-Hard
      QuizLevel(
        id: 'baby_game_level_4',
        levelNumber: 4,
        title: 'Baby Health',
        description: 'Understanding baby health and wellness',
        difficulty: DifficultyLevel.medium,
        questions: [
          QuizQuestion(
            id: 'bg_l4_q1',
            question: 'What is a normal temperature range for a baby?',
            options: ['96-98°F', '98.6-100.4°F', '100-102°F', '95-97°F'],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation: 'Normal baby temperature is 98.6-100.4°F (37-38°C).',
          ),
          QuizQuestion(
            id: 'bg_l4_q2',
            question: 'How many wet diapers should a newborn have per day?',
            options: ['2-3', '4-5', '6-8', '10-12'],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation:
                'A healthy newborn should have 6-8 wet diapers per day.',
          ),
          QuizQuestion(
            id: 'bg_l4_q3',
            question: 'When should you call a doctor for baby fever?',
            options: [
              'Any fever',
              'Fever over 100.4°F',
              'Fever over 102°F',
              'Only if baby is crying'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Call a doctor if baby under 3 months has fever over 100.4°F.',
          ),
          QuizQuestion(
            id: 'bg_l4_q4',
            question: 'What are signs of dehydration in babies?',
            options: [
              'Dry mouth only',
              'Fewer wet diapers',
              'Sunken fontanelle',
              'All of the above'
            ],
            correctAnswerIndex: 3,
            type: QuestionType.multipleChoice,
            explanation:
                'All these signs indicate dehydration and need medical attention.',
          ),
          QuizQuestion(
            id: 'bg_l4_q5',
            question: 'Match symptoms with appropriate actions',
            options: ['High fever', 'Rash', 'Vomiting', 'Difficulty breathing'],
            correctAnswerIndex: 0,
            type: QuestionType.matching,
            explanation:
                'Different symptoms require different levels of medical response.',
            puzzleData: {
              'symptoms': [
                'High fever',
                'Mild rash',
                'Persistent vomiting',
                'Difficulty breathing'
              ],
              'actions': [
                'Call doctor immediately',
                'Monitor and document',
                'Seek urgent care',
                'Call 911'
              ],
              'correctMatches': [0, 1, 2, 3],
            },
          ),
        ],
        rewards: ['Health Expert Badge', '125 points'],
      ),

      // Level 5 - Hard
      QuizLevel(
        id: 'baby_game_level_5',
        levelNumber: 5,
        title: 'Advanced Baby Care',
        description: 'Expert-level baby care knowledge',
        difficulty: DifficultyLevel.hard,
        questions: [
          QuizQuestion(
            id: 'bg_l5_q1',
            question:
                'What is the recommended duration for exclusive breastfeeding?',
            options: ['3 months', '6 months', '9 months', '12 months'],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'WHO recommends exclusive breastfeeding for the first 6 months.',
          ),
          QuizQuestion(
            id: 'bg_l5_q2',
            question: 'At what age can babies start drinking water?',
            options: ['Birth', '2 months', '6 months', '12 months'],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation:
                'Babies can start drinking small amounts of water at 6 months.',
          ),
          QuizQuestion(
            id: 'bg_l5_q3',
            question: 'What is the purple crying period?',
            options: [
              'A medical condition',
              'Normal crying phase',
              'Sign of illness',
              'Teething symptom'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Purple crying is a normal phase of increased crying in healthy babies.',
          ),
          QuizQuestion(
            id: 'bg_l5_q4',
            question: 'When do babies typically develop stranger anxiety?',
            options: [
              '2-4 months',
              '6-8 months',
              '10-12 months',
              '15-18 months'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Stranger anxiety typically develops around 6-8 months as babies form attachments.',
          ),
          QuizQuestion(
            id: 'bg_l5_q5',
            question: 'Create a daily routine for a 6-month-old baby',
            options: ['Wake up', 'Feeding', 'Playtime', 'Nap'],
            correctAnswerIndex: 0,
            type: QuestionType.dragDrop,
            explanation:
                'A structured routine helps babies feel secure and develop healthy habits.',
            puzzleData: {
              'activities': [
                'Nap time',
                'Feeding',
                'Wake up',
                'Playtime',
                'Bath time',
                'Bedtime'
              ],
              'timeSlots': [
                '7:00 AM',
                '8:00 AM',
                '10:00 AM',
                '12:00 PM',
                '6:00 PM',
                '8:00 PM'
              ],
              'correctOrder': [
                2,
                1,
                3,
                0,
                4,
                5
              ], // Wake up, Feeding, Playtime, Nap, Bath, Bedtime
            },
          ),
        ],
        rewards: ['Baby Care Master Badge', '150 points', 'Expert Certificate'],
      ),
    ];
  }

  /// Couple Game Category - Bonding & fun couple games
  QuizCategoryModel _createCoupleGameCategory() {
    return QuizCategoryModel(
      id: 'couple_game',
      category: QuizCategory.coupleGame,
      title: 'Couple Game',
      description: 'Bonding & fun couple games',
      iconPath: 'assets/icons/couple_game.png',
      colorValue: 0xFF6BCBFF, // Blue
      levels: _createCoupleGameLevels(),
      totalLevels: 3, // Reduced for demo
    );
  }

  List<QuizLevel> _createCoupleGameLevels() {
    return [
      QuizLevel(
        id: 'couple_game_level_1',
        levelNumber: 1,
        title: 'Getting to Know You',
        description: 'Basic questions about your partner',
        difficulty: DifficultyLevel.easy,
        isUnlocked: true,
        questions: [
          QuizQuestion(
            id: 'cg_l1_q1',
            question: 'What is your partner\'s favorite color?',
            options: ['Red', 'Blue', 'Green', 'Yellow'],
            correctAnswerIndex: 1, // This would be personalized
            type: QuestionType.multipleChoice,
            explanation:
                'Knowing your partner\'s preferences shows you pay attention to them.',
          ),
          QuizQuestion(
            id: 'cg_l1_q2',
            question: 'What is your partner\'s dream vacation destination?',
            options: ['Beach', 'Mountains', 'City', 'Countryside'],
            correctAnswerIndex: 0,
            type: QuestionType.multipleChoice,
            explanation:
                'Understanding their travel dreams helps plan future adventures together.',
          ),
          QuizQuestion(
            id: 'cg_l1_q3',
            question: 'What is your partner\'s favorite type of music?',
            options: ['Pop', 'Rock', 'Classical', 'Jazz'],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Music preferences can reveal personality traits and shared interests.',
          ),
          QuizQuestion(
            id: 'cg_l1_q4',
            question: 'What is your partner\'s biggest fear?',
            options: ['Heights', 'Spiders', 'Public speaking', 'Dark'],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation:
                'Knowing fears helps you be supportive and understanding.',
          ),
          QuizQuestion(
            id: 'cg_l1_q5',
            question: 'Match your partner\'s traits with examples',
            options: ['Funny', 'Caring', 'Adventurous', 'Smart'],
            correctAnswerIndex: 0,
            type: QuestionType.matching,
            explanation:
                'Recognizing your partner\'s positive traits strengthens your bond.',
            puzzleData: {
              'traits': ['Funny', 'Caring', 'Adventurous', 'Smart'],
              'examples': [
                'Makes you laugh',
                'Helps when sick',
                'Tries new things',
                'Solves problems'
              ],
              'correctMatches': [0, 1, 2, 3],
            },
          ),
        ],
        rewards: ['Couple Connection Badge', '50 points'],
      ),
      QuizLevel(
        id: 'couple_game_level_2',
        levelNumber: 2,
        title: 'Love Languages',
        description: 'Understanding how you both express love',
        difficulty: DifficultyLevel.easy,
        questions: [
          QuizQuestion(
            id: 'cg_l2_q1',
            question: 'How does your partner prefer to receive love?',
            options: [
              'Words of affirmation',
              'Physical touch',
              'Acts of service',
              'Quality time'
            ],
            correctAnswerIndex: 0,
            type: QuestionType.multipleChoice,
            explanation:
                'Understanding love languages improves relationship satisfaction.',
          ),
          QuizQuestion(
            id: 'cg_l2_q2',
            question: 'What makes your partner feel most appreciated?',
            options: [
              'Compliments',
              'Hugs',
              'Help with tasks',
              'Undivided attention'
            ],
            correctAnswerIndex: 3,
            type: QuestionType.multipleChoice,
            explanation: 'Appreciation is key to a strong relationship.',
          ),
          QuizQuestion(
            id: 'cg_l2_q3',
            question: 'How does your partner handle stress?',
            options: [
              'Talks it out',
              'Needs space',
              'Seeks comfort',
              'Stays busy'
            ],
            correctAnswerIndex: 0,
            type: QuestionType.multipleChoice,
            explanation:
                'Knowing stress responses helps you provide better support.',
          ),
          QuizQuestion(
            id: 'cg_l2_q4',
            question: 'What\'s your partner\'s ideal date night?',
            options: [
              'Romantic dinner',
              'Adventure activity',
              'Cozy home night',
              'Social gathering'
            ],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation: 'Shared preferences create stronger bonds.',
          ),
          QuizQuestion(
            id: 'cg_l2_q5',
            question:
                'Arrange these relationship priorities in your partner\'s order',
            options: ['Trust', 'Communication', 'Fun', 'Support'],
            correctAnswerIndex: 0,
            type: QuestionType.dragDrop,
            explanation:
                'Understanding priorities helps align your relationship goals.',
            puzzleData: {
              'items': ['Fun', 'Support', 'Trust', 'Communication'],
              'correctOrder': [
                2,
                3,
                0,
                1
              ], // Trust, Communication, Fun, Support
            },
          ),
        ],
        rewards: ['Love Expert Badge', '75 points'],
      ),
      QuizLevel(
        id: 'couple_game_level_3',
        levelNumber: 3,
        title: 'Future Dreams',
        description: 'Exploring your shared future together',
        difficulty: DifficultyLevel.medium,
        questions: [
          QuizQuestion(
            id: 'cg_l3_q1',
            question: 'Where does your partner see you living in 5 years?',
            options: [
              'Same city',
              'Different city',
              'Different country',
              'Wherever life takes us'
            ],
            correctAnswerIndex: 3,
            type: QuestionType.multipleChoice,
            explanation: 'Discussing future plans helps align your life goals.',
          ),
          QuizQuestion(
            id: 'cg_l3_q2',
            question: 'How many children does your partner ideally want?',
            options: ['1-2', '3-4', '5+', 'Undecided'],
            correctAnswerIndex: 0,
            type: QuestionType.multipleChoice,
            explanation: 'Family planning is crucial for couples to discuss.',
          ),
          QuizQuestion(
            id: 'cg_l3_q3',
            question: 'What\'s your partner\'s biggest life goal?',
            options: [
              'Career success',
              'Happy family',
              'Travel the world',
              'Make a difference'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Supporting each other\'s goals strengthens relationships.',
          ),
          QuizQuestion(
            id: 'cg_l3_q4',
            question: 'How does your partner define success?',
            options: [
              'Money and status',
              'Happiness and health',
              'Achievement and recognition',
              'Love and relationships'
            ],
            correctAnswerIndex: 3,
            type: QuestionType.multipleChoice,
            explanation:
                'Aligned definitions of success prevent future conflicts.',
          ),
          QuizQuestion(
            id: 'cg_l3_q5',
            question: 'Match life goals with importance to your partner',
            options: ['Career', 'Family', 'Health', 'Adventure'],
            correctAnswerIndex: 0,
            type: QuestionType.matching,
            explanation:
                'Understanding priorities helps you support each other better.',
            puzzleData: {
              'goals': ['Career', 'Family', 'Health', 'Adventure'],
              'importance': [
                'Important',
                'Most Important',
                'Very Important',
                'Somewhat Important'
              ],
              'correctMatches': [0, 1, 2, 3],
            },
          ),
        ],
        rewards: ['Future Planner Badge', '100 points'],
      ),
    ];
  }

  /// Parting Game Category - Compatibility/puzzle games
  QuizCategoryModel _createPartingGameCategory() {
    return QuizCategoryModel(
      id: 'parting_game',
      category: QuizCategory.partingGame,
      title: 'Parting Game',
      description: 'Compatibility & puzzle games',
      iconPath: 'assets/icons/parting_game.png',
      colorValue: 0xFFFFE066, // Yellow
      levels: _createPartingGameLevels(),
      totalLevels: 2, // Reduced for demo
    );
  }

  List<QuizLevel> _createPartingGameLevels() {
    return [
      QuizLevel(
        id: 'parting_game_level_1',
        levelNumber: 1,
        title: 'Compatibility Test',
        description: 'Test how well you match as partners',
        difficulty: DifficultyLevel.easy,
        isUnlocked: true,
        questions: [
          QuizQuestion(
            id: 'pg_l1_q1',
            question: 'How do you both handle disagreements?',
            options: [
              'Talk it out calmly',
              'Need time to cool down',
              'Avoid conflict',
              'Seek compromise quickly'
            ],
            correctAnswerIndex: 0,
            type: QuestionType.multipleChoice,
            explanation:
                'Healthy conflict resolution is key to relationship success.',
          ),
          QuizQuestion(
            id: 'pg_l1_q2',
            question: 'What\'s your shared approach to finances?',
            options: [
              'Joint everything',
              'Separate accounts',
              'Mix of both',
              'One person manages'
            ],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation:
                'Financial compatibility prevents many relationship issues.',
          ),
          QuizQuestion(
            id: 'pg_l1_q3',
            question: 'How do you both prefer to spend weekends?',
            options: [
              'Social activities',
              'Quiet at home',
              'Outdoor adventures',
              'Mix of activities'
            ],
            correctAnswerIndex: 3,
            type: QuestionType.multipleChoice,
            explanation:
                'Shared leisure preferences enhance relationship satisfaction.',
          ),
          QuizQuestion(
            id: 'pg_l1_q4',
            question: 'What\'s your communication style as a couple?',
            options: [
              'Very open',
              'Selective sharing',
              'Need encouragement',
              'Naturally expressive'
            ],
            correctAnswerIndex: 0,
            type: QuestionType.multipleChoice,
            explanation: 'Open communication builds trust and intimacy.',
          ),
          QuizQuestion(
            id: 'pg_l1_q5',
            question: 'Match relationship strengths with examples',
            options: ['Trust', 'Fun', 'Support', 'Growth'],
            correctAnswerIndex: 0,
            type: QuestionType.matching,
            explanation: 'Recognizing strengths helps build on them.',
            puzzleData: {
              'strengths': ['Trust', 'Fun', 'Support', 'Growth'],
              'examples': [
                'Share everything openly',
                'Laugh together daily',
                'Help during tough times',
                'Encourage each other\'s dreams'
              ],
              'correctMatches': [0, 1, 2, 3],
            },
          ),
        ],
        rewards: ['Compatibility Expert Badge', '60 points'],
      ),
      QuizLevel(
        id: 'parting_game_level_2',
        levelNumber: 2,
        title: 'Puzzle Challenge',
        description: 'Work together to solve relationship puzzles',
        difficulty: DifficultyLevel.medium,
        questions: [
          QuizQuestion(
            id: 'pg_l2_q1',
            question: 'What\'s the key to lasting relationships?',
            options: [
              'Perfect compatibility',
              'Constant communication',
              'Mutual respect and growth',
              'Never fighting'
            ],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation: 'Respect and growth together create lasting bonds.',
          ),
          QuizQuestion(
            id: 'pg_l2_q2',
            question: 'How do strong couples handle differences?',
            options: [
              'Ignore them',
              'Change each other',
              'Appreciate and adapt',
              'Argue until resolved'
            ],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation:
                'Differences can be strengths when handled with appreciation.',
          ),
          QuizQuestion(
            id: 'pg_l2_q3',
            question: 'What builds emotional intimacy?',
            options: [
              'Physical closeness only',
              'Shared experiences',
              'Vulnerability and trust',
              'Similar interests'
            ],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation: 'Emotional intimacy requires vulnerability and trust.',
          ),
          QuizQuestion(
            id: 'pg_l2_q4',
            question: 'How do you maintain romance over time?',
            options: [
              'Grand gestures',
              'Daily small acts',
              'Special occasions only',
              'Natural chemistry'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation: 'Consistent small acts of love maintain romance.',
          ),
          QuizQuestion(
            id: 'pg_l2_q5',
            question: 'Arrange relationship priorities for long-term success',
            options: ['Passion', 'Friendship', 'Commitment', 'Understanding'],
            correctAnswerIndex: 0,
            type: QuestionType.dragDrop,
            explanation:
                'All elements are important, but their balance matters.',
            puzzleData: {
              'items': ['Passion', 'Understanding', 'Commitment', 'Friendship'],
              'correctOrder': [
                2,
                1,
                3,
                0
              ], // Commitment, Understanding, Friendship, Passion
            },
          ),
        ],
        rewards: ['Relationship Guru Badge', '80 points'],
      ),
    ];
  }

  /// Couples Goals Category - Goal setting & interactive quizzes
  QuizCategoryModel _createCouplesGoalsCategory() {
    return QuizCategoryModel(
      id: 'couples_goals',
      category: QuizCategory.couplesGoals,
      title: 'Couples Goals',
      description: 'Goal setting & interactive quizzes',
      iconPath: 'assets/icons/couples_goals.png',
      colorValue: 0xFFFF9A9E, // Peach
      levels: _createCouplesGoalsLevels(),
      totalLevels: 2, // Reduced for demo
    );
  }

  List<QuizLevel> _createCouplesGoalsLevels() {
    return [
      QuizLevel(
        id: 'couples_goals_level_1',
        levelNumber: 1,
        title: 'Setting Shared Goals',
        description: 'Learn to set goals together as a couple',
        difficulty: DifficultyLevel.easy,
        isUnlocked: true,
        questions: [
          QuizQuestion(
            id: 'cgl_l1_q1',
            question: 'What\'s most important when setting couple goals?',
            options: [
              'Individual wants',
              'Shared vision',
              'Practical considerations',
              'Timeline flexibility'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Shared vision ensures both partners are working toward the same future.',
          ),
          QuizQuestion(
            id: 'cgl_l1_q2',
            question: 'How often should couples review their goals?',
            options: ['Monthly', 'Quarterly', 'Yearly', 'When problems arise'],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Regular quarterly reviews keep goals relevant and achievable.',
          ),
          QuizQuestion(
            id: 'cgl_l1_q3',
            question: 'What makes a relationship goal achievable?',
            options: [
              'Being specific',
              'Having deadlines',
              'Both partners committed',
              'All of the above'
            ],
            correctAnswerIndex: 3,
            type: QuestionType.multipleChoice,
            explanation:
                'Effective goals are specific, time-bound, and have mutual commitment.',
          ),
          QuizQuestion(
            id: 'cgl_l1_q4',
            question: 'How should couples handle conflicting goals?',
            options: [
              'Compromise equally',
              'Take turns prioritizing',
              'Find creative solutions',
              'Discuss and align'
            ],
            correctAnswerIndex: 3,
            type: QuestionType.multipleChoice,
            explanation:
                'Open discussion helps find alignment and creative solutions.',
          ),
          QuizQuestion(
            id: 'cgl_l1_q5',
            question: 'Match goal types with examples',
            options: ['Financial', 'Relationship', 'Health', 'Adventure'],
            correctAnswerIndex: 0,
            type: QuestionType.matching,
            explanation:
                'Different goal types require different approaches and timelines.',
            puzzleData: {
              'goalTypes': ['Financial', 'Relationship', 'Health', 'Adventure'],
              'examples': [
                'Save for house down payment',
                'Weekly date nights',
                'Exercise together 3x/week',
                'Visit 5 new countries'
              ],
              'correctMatches': [0, 1, 2, 3],
            },
          ),
        ],
        rewards: ['Goal Setter Badge', '50 points'],
      ),
      QuizLevel(
        id: 'couples_goals_level_2',
        levelNumber: 2,
        title: 'Achieving Together',
        description: 'Strategies for reaching your couple goals',
        difficulty: DifficultyLevel.medium,
        questions: [
          QuizQuestion(
            id: 'cgl_l2_q1',
            question:
                'What\'s the best way to stay motivated toward couple goals?',
            options: [
              'Celebrate small wins',
              'Focus on end result',
              'Compete with others',
              'Set bigger goals'
            ],
            correctAnswerIndex: 0,
            type: QuestionType.multipleChoice,
            explanation:
                'Celebrating progress maintains motivation and strengthens partnership.',
          ),
          QuizQuestion(
            id: 'cgl_l2_q2',
            question: 'How should couples handle setbacks in their goals?',
            options: [
              'Give up and try later',
              'Blame each other',
              'Reassess and adjust',
              'Push harder'
            ],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation:
                'Setbacks are opportunities to reassess and strengthen your approach.',
          ),
          QuizQuestion(
            id: 'cgl_l2_q3',
            question: 'What role does accountability play in couple goals?',
            options: [
              'Creates pressure',
              'Builds trust',
              'Causes conflict',
              'Isn\'t necessary'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation: 'Mutual accountability builds trust and commitment.',
          ),
          QuizQuestion(
            id: 'cgl_l2_q4',
            question:
                'How do successful couples balance individual and shared goals?',
            options: [
              'Only shared goals matter',
              'Support each other\'s individual goals too',
              'Keep them separate',
              'Individual goals come first'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Supporting individual growth strengthens the relationship.',
          ),
          QuizQuestion(
            id: 'cgl_l2_q5',
            question: 'Arrange goal achievement steps in order',
            options: ['Plan', 'Dream', 'Act', 'Review'],
            correctAnswerIndex: 0,
            type: QuestionType.dragDrop,
            explanation: 'Successful goal achievement follows a clear process.',
            puzzleData: {
              'items': ['Act', 'Review', 'Dream', 'Plan'],
              'correctOrder': [2, 3, 0, 1], // Dream, Plan, Act, Review
            },
          ),
        ],
        rewards: ['Achievement Master Badge', '75 points'],
      ),
    ];
  }

  /// Know Each Other Category - Emotional & fun Q&A
  QuizCategoryModel _createKnowEachOtherCategory() {
    return QuizCategoryModel(
      id: 'know_each_other',
      category: QuizCategory.knowEachOther,
      title: 'Know Each Other',
      description: 'Emotional & fun Q&A to know partner',
      iconPath: 'assets/icons/know_each_other.png',
      colorValue: 0xFFA8E6CF, // Green
      levels: _createKnowEachOtherLevels(),
      totalLevels: 2, // Reduced for demo
    );
  }

  List<QuizLevel> _createKnowEachOtherLevels() {
    return [
      QuizLevel(
        id: 'know_each_other_level_1',
        levelNumber: 1,
        title: 'Deep Questions',
        description: 'Get to know your partner on a deeper level',
        difficulty: DifficultyLevel.easy,
        isUnlocked: true,
        questions: [
          QuizQuestion(
            id: 'keo_l1_q1',
            question: 'What\'s your partner\'s biggest dream in life?',
            options: [
              'Career success',
              'Happy family',
              'Travel the world',
              'Make a difference'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Understanding dreams helps you support each other\'s aspirations.',
          ),
          QuizQuestion(
            id: 'keo_l1_q2',
            question: 'What makes your partner feel most loved?',
            options: [
              'Words of affirmation',
              'Quality time',
              'Physical touch',
              'Acts of service'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation:
                'Knowing love languages improves relationship satisfaction.',
          ),
          QuizQuestion(
            id: 'keo_l1_q3',
            question: 'What\'s your partner\'s greatest strength?',
            options: ['Kindness', 'Intelligence', 'Humor', 'Determination'],
            correctAnswerIndex: 0,
            type: QuestionType.multipleChoice,
            explanation:
                'Recognizing strengths builds appreciation and confidence.',
          ),
          QuizQuestion(
            id: 'keo_l1_q4',
            question:
                'What childhood memory is most important to your partner?',
            options: [
              'Family vacation',
              'Achievement moment',
              'Time with grandparents',
              'Learning something new'
            ],
            correctAnswerIndex: 2,
            type: QuestionType.multipleChoice,
            explanation: 'Childhood memories shape who we become as adults.',
          ),
          QuizQuestion(
            id: 'keo_l1_q5',
            question: 'Match your partner\'s values with their importance',
            options: ['Family', 'Honesty', 'Adventure', 'Security'],
            correctAnswerIndex: 0,
            type: QuestionType.matching,
            explanation:
                'Understanding values helps predict decisions and priorities.',
            puzzleData: {
              'values': ['Family', 'Honesty', 'Adventure', 'Security'],
              'importance': [
                'Most Important',
                'Very Important',
                'Important',
                'Somewhat Important'
              ],
              'correctMatches': [0, 1, 2, 3],
            },
          ),
        ],
        rewards: ['Deep Connection Badge', '60 points'],
      ),
      QuizLevel(
        id: 'know_each_other_level_2',
        levelNumber: 2,
        title: 'Fun Facts',
        description: 'Discover fun and quirky things about each other',
        difficulty: DifficultyLevel.easy,
        questions: [
          QuizQuestion(
            id: 'keo_l2_q1',
            question: 'What\'s your partner\'s secret talent?',
            options: ['Singing', 'Dancing', 'Cooking', 'Drawing'],
            correctAnswerIndex: 0,
            type: QuestionType.multipleChoice,
            explanation:
                'Hidden talents make relationships more interesting and fun.',
          ),
          QuizQuestion(
            id: 'keo_l2_q2',
            question: 'What\'s your partner\'s guilty pleasure?',
            options: [
              'Reality TV',
              'Junk food',
              'Romance novels',
              'Video games'
            ],
            correctAnswerIndex: 0,
            type: QuestionType.multipleChoice,
            explanation:
                'Guilty pleasures are part of what makes us human and relatable.',
          ),
          QuizQuestion(
            id: 'keo_l2_q3',
            question: 'What would your partner do with a free day?',
            options: [
              'Sleep in and relax',
              'Adventure outdoors',
              'Learn something new',
              'Spend time with loved ones'
            ],
            correctAnswerIndex: 3,
            type: QuestionType.multipleChoice,
            explanation:
                'How someone spends free time reveals their true priorities.',
          ),
          QuizQuestion(
            id: 'keo_l2_q4',
            question: 'What\'s your partner\'s biggest pet peeve?',
            options: [
              'Loud chewing',
              'Being late',
              'Messy spaces',
              'Interrupting'
            ],
            correctAnswerIndex: 1,
            type: QuestionType.multipleChoice,
            explanation: 'Knowing pet peeves helps avoid unnecessary friction.',
          ),
          QuizQuestion(
            id: 'keo_l2_q5',
            question: 'Arrange your partner\'s favorite activities in order',
            options: ['Reading', 'Exercising', 'Socializing', 'Creating'],
            correctAnswerIndex: 0,
            type: QuestionType.dragDrop,
            explanation:
                'Activity preferences reveal personality and interests.',
            puzzleData: {
              'items': ['Creating', 'Socializing', 'Reading', 'Exercising'],
              'correctOrder': [
                2,
                3,
                1,
                0
              ], // Reading, Exercising, Socializing, Creating
            },
          ),
        ],
        rewards: ['Fun Facts Expert Badge', '70 points'],
      ),
    ];
  }

  /// Get quiz category by ID
  QuizCategoryModel? getCategoryById(String categoryId) {
    try {
      return getAllQuizCategories()
          .firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Get quiz level by category and level ID
  QuizLevel? getLevelById(String categoryId, String levelId) {
    final category = getCategoryById(categoryId);
    if (category == null) return null;

    try {
      return category.levels.firstWhere((level) => level.id == levelId);
    } catch (e) {
      return null;
    }
  }

  /// Generate random questions for practice mode
  List<QuizQuestion> getRandomQuestions(QuizCategory category, int count) {
    final categoryModel =
        getAllQuizCategories().firstWhere((cat) => cat.category == category);

    final allQuestions = <QuizQuestion>[];
    for (final level in categoryModel.levels) {
      allQuestions.addAll(level.questions);
    }

    allQuestions.shuffle(Random());
    return allQuestions.take(count).toList();
  }
}
