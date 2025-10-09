import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

// App screens
import '../../features/app/presentation/screens/splash_screen.dart';
import '../../features/app/presentation/screens/onboarding_screen.dart';
import '../../features/app/presentation/screens/main_navigation_screen.dart';
import '../../features/app/presentation/screens/settings_screen.dart';

// Dashboard screens
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

// Baby Generation screens
import '../../features/baby_generation/presentation/screens/baby_generation_screen.dart';

// Couple Goals screens
import '../../features/couple_goals/presentation/screens/couple_goals_screen.dart';
import '../../features/couple_goals/presentation/screens/baby_detail_screen.dart';
import '../../shared/models/baby_result.dart';

// Engagement Features screens
import '../../features/engagement_features/presentation/screens/baby_name_generator_screen.dart';
import '../../features/engagement_features/presentation/screens/memory_journal_screen.dart';
import '../../features/engagement_features/presentation/screens/add_memory_screen.dart';
import '../../features/engagement_features/presentation/screens/journey_preview_screen.dart';
import '../../features/engagement_features/presentation/screens/memory_journey_preview_screen.dart';
import '../../features/engagement_features/presentation/screens/couple_challenges_screen.dart';
import '../../features/engagement_features/presentation/screens/growth_timeline_screen.dart';
import '../../features/engagement_features/presentation/screens/anniversary_tracker_screen.dart';
import '../../features/engagement_features/presentation/screens/love_language_quiz_screen.dart';
import '../../features/engagement_features/presentation/screens/future_planning_screen.dart';
import '../../features/engagement_features/presentation/screens/couple_bucket_list_screen.dart';

// Quiz screens
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/quiz/presentation/screens/quiz_category_screen.dart';
import '../../features/quiz/presentation/screens/quiz_level_screen.dart';
import '../../features/quiz/presentation/screens/quiz_game_screen.dart';
import '../../features/quiz/domain/entities/quiz_entities.dart' as entities;
import '../../features/quiz/domain/models/quiz_models.dart' as models;

// Premium Features screens
import '../../features/premium_features/presentation/screens/premium_screen.dart';

// Profile Management screens
import '../../features/profile_management/presentation/screens/profile_screen.dart';

// History screens
import '../../features/history/presentation/screens/history_screen.dart';

// Social Sharing screens
import '../../features/social_sharing/presentation/screens/social_challenges_screen.dart';

// Analytics screens
import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';

// Login screens
import '../../features/login/presentation/screens/login_screen.dart';

// Period Tracker screens
import '../../features/period_tracker/presentation/screens/period_tracker_screen.dart';

// Additional Engagement Features screens
import '../../features/engagement_features/presentation/screens/debug_memory_screen.dart';
import '../../features/engagement_features/presentation/screens/memory_detail_screen.dart';
import '../../features/engagement_features/presentation/screens/real_baby_name_generator_screen.dart'
    as real_screens;
import '../../features/engagement_features/presentation/screens/real_couple_challenges_bucket_list_screen.dart';
import '../../features/engagement_features/presentation/screens/real_growth_memory_timeline_screen.dart';

// Baby Generation additional screens
import '../../features/baby_generation/presentation/screens/ai_baby_result_screen.dart';

/// App router configuration
/// Follows master plan navigation standards
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Flow
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login Screen
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main Navigation (Tab-based)
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainNavigationScreen(),
        routes: [
          // Dashboard
          GoRoute(
            path: 'dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Baby Generation
          GoRoute(
            path: 'baby-generation',
            name: 'baby-generation',
            builder: (context, state) => const BabyGenerationScreen(),
          ),
          GoRoute(
            path: 'ai-baby-result',
            name: 'ai-baby-result',
            builder: (context, state) {
              final resultData = state.extra as Map<String, dynamic>?;
              if (resultData == null) {
                return const Scaffold(
                  body: Center(child: Text('Baby result data not found')),
                );
              }
              return AIBabyResultScreen(
                result: resultData['result'],
                maleName: resultData['maleName'] ?? 'Male Parent',
                femaleName: resultData['femaleName'] ?? 'Female Parent',
              );
            },
          ),

          // Couple Goals
          GoRoute(
            path: 'couple-goals',
            name: 'couple-goals',
            builder: (context, state) => const CoupleGoalsScreen(),
          ),
          GoRoute(
            path: 'baby-detail',
            name: 'baby-detail',
            builder: (context, state) {
              // For now, create a placeholder result
              // In a real app, you'd fetch the result by ID
              return BabyDetailScreen(
                result: BabyResult(
                  id: 'placeholder',
                  maleMatchPercentage: 50,
                  femaleMatchPercentage: 50,
                  createdAt: DateTime.now(),
                ),
              );
            },
          ),

          // Engagement Features
          GoRoute(
            path: 'baby-name-generator',
            name: 'baby-name-generator',
            builder: (context, state) => const BabyNameGeneratorScreen(),
          ),
          GoRoute(
            path: 'memory-journal',
            name: 'memory-journal',
            builder: (context, state) => const MemoryJournalScreen(),
          ),
          GoRoute(
            path: 'add-memory',
            name: 'add-memory',
            builder: (context, state) => const AddMemoryScreen(),
          ),
          GoRoute(
            path: 'memory-detail',
            name: 'memory-detail',
            builder: (context, state) {
              final memoryId = state.uri.queryParameters['id'];
              if (memoryId == null) {
                return const Scaffold(
                  body: Center(child: Text('Memory not found')),
                );
              }
              // TODO: Implement proper memory fetching by ID
              // For now, show a loading screen
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
          GoRoute(
            path: 'journey-preview',
            name: 'journey-preview',
            builder: (context, state) => const JourneyPreviewScreen(),
          ),
          GoRoute(
            path: 'memory-journey-preview',
            name: 'memory-journey-preview',
            builder: (context, state) => const MemoryJourneyPreviewScreen(),
          ),
          GoRoute(
            path: 'memory-journey-visualizer',
            name: 'memory-journey-visualizer',
            builder: (context, state) {
              // Get journey data from arguments
              final journeyData = state.extra as Map<String, dynamic>?;
              if (journeyData == null) {
                return const Scaffold(
                  body: Center(child: Text('Journey data not found')),
                );
              }
              // TODO: Implement proper journey data parsing
              // For now, show a loading screen
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
          GoRoute(
            path: 'couple-challenges',
            name: 'couple-challenges',
            builder: (context, state) => const CoupleChallengesScreen(),
          ),
          GoRoute(
            path: 'growth-timeline',
            name: 'growth-timeline',
            builder: (context, state) => const GrowthTimelineScreen(),
          ),
          GoRoute(
            path: 'anniversary-tracker',
            name: 'anniversary-tracker',
            builder: (context, state) => const AnniversaryTrackerScreen(),
          ),
          GoRoute(
            path: 'love-language-quiz',
            name: 'love-language-quiz',
            builder: (context, state) => const LoveLanguageQuizScreen(),
          ),
          GoRoute(
            path: 'future-planning',
            name: 'future-planning',
            builder: (context, state) => const FuturePlanningScreen(),
          ),
          GoRoute(
            path: 'couple-bucket-list',
            name: 'couple-bucket-list',
            builder: (context, state) => const CoupleBucketListScreen(),
          ),
          GoRoute(
            path: 'debug-memory',
            name: 'debug-memory',
            builder: (context, state) => const DebugMemoryScreen(),
          ),
          GoRoute(
            path: 'memory-detail',
            name: 'memory-detail',
            builder: (context, state) {
              final memoryId = state.uri.queryParameters['id'];
              if (memoryId == null) {
                return const Scaffold(
                  body: Center(child: Text('Memory ID not found')),
                );
              }
              // TODO: Fetch memory by ID and pass to MemoryDetailScreen
              return const Scaffold(
                body: Center(child: Text('Memory detail not implemented yet')),
              );
            },
          ),
          GoRoute(
            path: 'real-baby-name-generator',
            name: 'real-baby-name-generator',
            builder: (context, state) =>
                const real_screens.BabyNameGeneratorScreen(),
          ),
          GoRoute(
            path: 'real-couple-challenges-bucket-list',
            name: 'real-couple-challenges-bucket-list',
            builder: (context, state) =>
                const CoupleChallengesBucketListScreen(),
          ),
          GoRoute(
            path: 'real-growth-memory-timeline',
            name: 'real-growth-memory-timeline',
            builder: (context, state) => const GrowthMemoryTimelineScreen(),
          ),

          // Quiz System
          GoRoute(
            path: 'quiz',
            name: 'quiz',
            builder: (context, state) => const QuizScreen(),
          ),
          GoRoute(
            path: 'quiz-category',
            name: 'quiz-category',
            builder: (context, state) => QuizCategoryScreen(
              category: models.QuizCategoryModel(
                id: 'default',
                category: models.QuizCategory.babyGame,
                title: 'Default',
                description: 'Default category',
                iconPath: 'assets/icons/baby_game.png',
                colorValue: 0xFF667eea,
                levels: [],
                totalLevels: 0,
                completedLevels: 0,
                totalScore: 0,
              ),
            ),
          ),
          GoRoute(
            path: 'quiz-level',
            name: 'quiz-level',
            builder: (context, state) => QuizLevelScreen(
              category: models.QuizCategoryModel(
                id: 'default',
                category: models.QuizCategory.babyGame,
                title: 'Default',
                description: 'Default category',
                iconPath: 'assets/icons/baby_game.png',
                colorValue: 0xFF667eea,
                levels: [],
                totalLevels: 0,
                completedLevels: 0,
                totalScore: 0,
              ),
              level: models.QuizLevel(
                id: 'default',
                levelNumber: 1,
                title: 'Default Level',
                description: 'Default level',
                difficulty: models.DifficultyLevel.easy,
                questions: [],
                requiredScore: 5,
                rewards: [],
                isUnlocked: true,
              ),
            ),
          ),
          GoRoute(
            path: 'quiz-game',
            name: 'quiz-game',
            builder: (context, state) => QuizGameScreen(
              quiz: entities.Quiz(
                category: entities.QuizCategory.babyPrediction,
                title: 'Default Quiz',
                description: 'Default quiz',
                icon: '🎮',
                levels: [],
                totalLevels: 0,
                completedLevels: 0,
                progressPercentage: 0.0,
                isFeatured: false,
              ),
              level: entities.QuizLevel(
                levelNumber: 1,
                title: 'Default Level',
                description: 'Default level',
                questions: [],
                puzzle: entities.QuizQuestion(
                  id: 'default',
                  question: 'Default puzzle',
                  type: entities.QuestionType.multipleChoice,
                  targetPlayer: entities.PlayerType.both,
                  options: ['Option 1', 'Option 2'],
                  correctAnswer: 'Option 1',
                ),
                isUnlocked: true,
                isCompleted: false,
              ),
            ),
          ),

          // Profile Management
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Period Tracker
          GoRoute(
            path: 'period-tracker',
            name: 'period-tracker',
            builder: (context, state) => const PeriodTrackerScreen(),
          ),

          // History
          GoRoute(
            path: 'history',
            name: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),

          // Social Sharing
          GoRoute(
            path: 'social-challenges',
            name: 'social-challenges',
            builder: (context, state) => const SocialChallengesScreen(
              userId: 'default-user',
            ),
          ),

          // Premium Features
          GoRoute(
            path: 'premium',
            name: 'premium',
            builder: (context, state) => const PremiumScreen(),
          ),

          // Settings
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),

          // Analytics (Admin/Developer)
          GoRoute(
            path: 'analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsDashboardScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );

  static GoRouter get router => _router;
}

/// Error screen for navigation errors
class _ErrorScreen extends StatelessWidget {
  final Exception? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown error occurred',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/main'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
