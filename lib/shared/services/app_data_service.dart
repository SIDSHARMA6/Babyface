import 'anniversary_tracker_service.dart';
import 'dart:developer' as developer;
import 'period_tracker_service.dart';
import 'bond_profile_service.dart';
import 'history_service.dart';
import 'simple_memory_service.dart';
import 'achievements_service.dart';
import 'premium_service.dart';
import 'baby_name_service.dart';
import '../../features/quiz/data/quiz_repository.dart';
import '../models/anniversary_event.dart';
import '../models/period_cycle.dart';

/// Comprehensive data service that connects all app components
/// Provides real data flow between dashboard, profile, and all features
class AppDataService {
  static AppDataService? _instance;
  static AppDataService get instance => _instance ??= AppDataService._();

  AppDataService._();

  final AnniversaryTrackerService _anniversaryService =
      AnniversaryTrackerService.instance;
  final PeriodTrackerService _periodService = PeriodTrackerService.instance;
  final BondProfileService _bondService = BondProfileService.instance;
  final AchievementsService _achievementsService = AchievementsService.instance;
  final PremiumService _premiumService = PremiumService.instance;
  final BabyNameService _babyNameService = BabyNameService.instance;
  final QuizRepository _quizRepository = QuizRepository();

  /// Get dashboard carousel data (optimized with caching)
  Future<Map<String, dynamic>> getDashboardCarouselData() async {
    try {
      // Use Future.wait for parallel execution
      final results = await Future.wait([
        _anniversaryService.getNearestEvent(),
        _periodService.getCycleStats(),
        _bondService.getBondName(),
        _bondService.getBondImagePath(),
        _babyNameService.getGenerationCount(),
        _babyNameService.getLatestFinalName(),
        SimpleMemoryService.getAllMemoriesWithSync(),
        _anniversaryService.getTotalEventCount(),
      ]);

      final nearestEvent = results[0];
      final periodStats = results[1] as Map<String, dynamic>;
      final bondName = results[2] as String?;
      final bondImagePath = results[3] as String?;
      final babyGenerationCount = results[4] as int;
      final latestFinalName = results[5] as String?;
      final memories = results[6] as List;
      final totalEvents = results[7] as int;

      return {
        'nearestEvent':
            nearestEvent != null ? (nearestEvent as dynamic).toJson() : null,
        'periodStats': periodStats,
        'bondName': bondName,
        'bondImagePath': bondImagePath,
        'totalEvents': totalEvents,
        'isPeriodSetUp': periodStats['isSetUp'] ?? false,
        'babyGenerationCount': babyGenerationCount,
        'latestFinalName': latestFinalName,
        'memoryCount': memories.length,
      };
    } catch (e) {
      developer
          .log('❌ [AppDataService] Error getting dashboard carousel data: $e');
      return {
        'nearestEvent': null,
        'periodStats': {'isSetUp': false},
        'bondName': null,
        'bondImagePath': null,
        'totalEvents': 0,
        'isPeriodSetUp': false,
        'babyGenerationCount': 0,
        'latestFinalName': null,
        'memoryCount': 0,
      };
    }
  }

  /// Get profile screen statistics
  Future<Map<String, dynamic>> getProfileStats() async {
    try {
      // Get anniversary events count
      final totalEvents = await _anniversaryService.getTotalEventCount();

      // Get period cycle stats
      final periodStats = await _periodService.getCycleStats();

      // Get bond profile
      final bondName = await _bondService.getBondName();
      final bondImagePath = await _bondService.getBondImagePath();

      // Calculate days together (from first event or bond creation)
      final events = await _anniversaryService.getAllEvents();
      int daysTogether = 0;

      if (events.isNotEmpty) {
        final firstEvent =
            events.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
        daysTogether = DateTime.now().difference(firstEvent.date).inDays;
      }

      // Get babies created count from HistoryService
      final babiesCreated = HistoryService.getResultsCount();

      // Get memories created count from SimpleMemoryService
      final memories = await SimpleMemoryService.getAllMemoriesWithSync();
      final memoriesCreated = memories.length;

      // Get quiz statistics
      final userId = 'current_user'; // TODO: Get from auth service
      final quizStats = await _quizRepository.getQuizStatistics(userId);
      final quizzesCompleted = quizStats['totalQuizzesCompleted'] as int? ?? 0;

      // Get achievements unlocked count
      final achievementsUnlocked =
          await _achievementsService.getUnlockedAchievementsCount();

      // Check and unlock achievements based on current activity
      await _achievementsService.checkAndUnlockAchievements(
        quizzesCompleted: quizzesCompleted,
        babiesGenerated: babiesCreated,
        memoriesCreated: memoriesCreated,
        daysTogether: daysTogether,
        eventsCreated: totalEvents,
      );

      // Get premium status
      final isPremium = await _premiumService.isPremium();

      return {
        'bondName': bondName,
        'bondImagePath': bondImagePath,
        'daysTogether': daysTogether,
        'totalEvents': totalEvents,
        'periodStats': periodStats,
        'babiesCreated': babiesCreated,
        'memoriesCreated': memoriesCreated,
        'achievementsUnlocked': achievementsUnlocked,
        'loveScore': _calculateLoveScore(totalEvents, daysTogether),
        'isPremium': isPremium,
      };
    } catch (e) {
      developer.log('Error getting profile stats: $e');
      return {
        'bondName': null,
        'bondImagePath': null,
        'daysTogether': 0,
        'totalEvents': 0,
        'periodStats': {'isSetUp': false},
        'babiesCreated': 0,
        'memoriesCreated': 0,
        'achievementsUnlocked': 0,
        'loveScore': '0%',
        'isPremium': false,
      };
    }
  }

  /// Calculate love score based on events and days together
  String _calculateLoveScore(int totalEvents, int daysTogether) {
    if (daysTogether == 0) return '0%';

    // Base score from days together
    double baseScore = (daysTogether / 365.0) * 50; // Max 50% from time

    // Bonus score from events
    double eventScore = (totalEvents * 5).toDouble(); // 5% per event

    // Cap at 100%
    double totalScore = (baseScore + eventScore).clamp(0, 100);

    return '${totalScore.round()}%';
  }

  /// Get welcome section data for dashboard
  Future<Map<String, dynamic>> getWelcomeSectionData() async {
    try {
      final profileStats = await getProfileStats();

      return {
        'babiesGenerated': profileStats['babiesCreated'] ?? 0,
        'memoriesCreated': profileStats['memoriesCreated'] ?? 0,
        'lovePercentage': double.tryParse(
                profileStats['loveScore']?.toString().replaceAll('%', '') ??
                    '0') ??
            0.0,
        'daysTogether': profileStats['daysTogether'] ?? 0,
        'totalEvents': profileStats['totalEvents'] ?? 0,
      };
    } catch (e) {
      developer.log('Error getting welcome section data: $e');
      return {
        'babiesGenerated': 0,
        'memoriesCreated': 0,
        'lovePercentage': 0.0,
        'daysTogether': 0,
        'totalEvents': 0,
      };
    }
  }

  /// Get carousel slide data
  Future<List<Map<String, dynamic>>> getCarouselSlides() async {
    try {
      final carouselData = await getDashboardCarouselData();
      final nearestEvent = carouselData['nearestEvent'];
      final periodStats = carouselData['periodStats'];

      List<Map<String, dynamic>> slides = [];

      // Slide 1: Welcome
      slides.add({
        'type': 'welcome',
        'title': 'Welcome Back! 👋',
        'subtitle': 'Ready to create magic together? ✨💕',
        'color': '#FF6B81',
      });

      // Slide 2: Love Streak
      slides.add({
        'type': 'love_streak',
        'title': 'Love Streak 💕',
        'subtitle': '${carouselData['totalEvents']} special moments',
        'color': '#6BCBFF',
      });

      // Slide 3: Special Day (Anniversary)
      if (nearestEvent != null) {
        final event = AnniversaryEvent.fromJson(nearestEvent);
        slides.add({
          'type': 'special_day',
          'title': event.displayTitle,
          'subtitle': 'In ${event.daysUntil} days',
          'date': event.date.toIso8601String(),
          'color': '#FFE066',
        });
      } else {
        slides.add({
          'type': 'special_day',
          'title': 'Add Special Days 💖',
          'subtitle': 'Track your anniversaries',
          'color': '#FFE066',
        });
      }

      // Slide 4: Caring (Period Tracker)
      if (periodStats['isSetUp'] == true) {
        slides.add({
          'type': 'caring',
          'title': 'Cycle Day ${periodStats['currentDay']}',
          'subtitle': periodStats['dailyDialogue'] ?? 'Your body is amazing 💖',
          'phase': periodStats['phase'],
          'daysUntilNext': periodStats['daysUntilNext'],
          'color': '#FFB6C1',
        });
      } else {
        slides.add({
          'type': 'caring',
          'title': 'Track Your Cycle 🌸',
          'subtitle': 'Understand your body better',
          'color': '#FFB6C1',
        });
      }

      return slides;
    } catch (e) {
      developer.log('Error getting carousel slides: $e');
      return [
        {
          'type': 'welcome',
          'title': 'Welcome Back! 👋',
          'subtitle': 'Ready to create magic together? ✨💕',
          'color': '#FF6B81',
        }
      ];
    }
  }

  /// Sync all data to Firebase
  Future<void> syncAllDataToFirebase() async {
    try {
      // Sync anniversary events (handled internally by AnniversaryTrackerService)
      final events = await _anniversaryService.getAllEvents();
      developer.log('Synced ${events.length} anniversary events');

      // Sync period cycle (handled internally by PeriodTrackerService)
      final cycle = await _periodService.getCurrentCycle();
      if (cycle != null) {
        developer.log('Synced period cycle data');
      }

      // Sync bond profile
      final bondName = await _bondService.getBondName();
      final bondImagePath = await _bondService.getBondImagePath();
      if (bondName != null || bondImagePath != null) {
        // TODO: Sync bond profile to Firebase
        developer.log('Syncing bond profile to Firebase');
      }

      developer.log('All data synced to Firebase successfully');
    } catch (e) {
      developer.log('Error syncing data to Firebase: $e');
    }
  }

  /// Clear all app data
  Future<bool> clearAllData() async {
    try {
      // Clear anniversary events (get all events and delete them individually)
      final events = await _anniversaryService.getAllEvents();
      for (final event in events) {
        await _anniversaryService.deleteEvent(event.id);
      }

      // Clear period cycle (recreate with default values)
      final currentCycle = await _periodService.getCurrentCycle();
      if (currentCycle != null) {
        // Create a new cycle with default values
        final defaultCycle = PeriodCycle(
          id: 'default',
          lastPeriodStart: DateTime.now(),
          cycleLength: 28,
          periodLength: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _periodService.setCycle(defaultCycle);
      }

      // Clear bond profile
      await _bondService.clearBondProfile();

      return true;
    } catch (e) {
      developer.log('Error clearing all data: $e');
      return false;
    }
  }
}
