import 'package:flutter/material.dart';

/// Carousel item model for romantic dashboard slider
class CarouselItem {
  final String title;
  final String subtitle;
  final String? value; // e.g., latest baby name, count, date
  final IconData? icon;
  final String? iconText; // Text to show instead of icon (like count)
  final Color? iconTextColor; // Special color for the count text
  final List<Color> gradientColors;
  final String emoji;
  final String description;
  final LinearGradient backgroundGradient;
  final VoidCallback? onTap; // Navigation callback
  final String? navigationRoute; // Route identifier for navigation

  const CarouselItem({
    required this.title,
    required this.subtitle,
    this.value,
    this.icon,
    this.iconText,
    this.iconTextColor,
    required this.gradientColors,
    required this.emoji,
    required this.description,
    required this.backgroundGradient,
    this.onTap,
    this.navigationRoute,
  });
}

/// Carousel data provider
class CarouselDataProvider {
  static List<CarouselItem> getCarouselItems({
    required int babyCount,
    required String? latestBabyName,
    required int memoryCount,
    required String? anniversaryDate,
    required String? periodDate,
    required Map<String, dynamic> periodStats,
    required Map<String, dynamic>? nearestEvent,
    VoidCallback? onBabyGeneratorTap,
    VoidCallback? onMemoryJournalTap,
    VoidCallback? onAnniversaryTrackerTap,
    VoidCallback? onPeriodTrackerTap,
  }) {
    return [
      CarouselItem(
        title: latestBabyName != null
            ? "Our Little $latestBabyName 💕"
            : "Our Little Miracle 💕",
        subtitle: "You generated $babyCount beautiful names",
        value: latestBabyName ?? "No names yet",
        icon: null, // Remove icon
        iconText: babyCount.toString(), // Show count instead
        iconTextColor: const Color(0xFFFF6B81), // Baby pink color
        gradientColors: const [
          Color(0xFFFF6B81), // Baby Pink
          Color(0xFFFF8FA3), // Coral
        ],
        emoji: "👶",
        description: "Every name is a dream come true",
        backgroundGradient: const LinearGradient(
          colors: [Color(0xFFFF6B81), Color(0xFFFF8FA3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: onBabyGeneratorTap,
        navigationRoute: 'baby_generator',
      ),
      CarouselItem(
        title: "Cherished Memories 🌸",
        subtitle: "$memoryCount moments captured",
        value: "In our hearts forever",
        icon: null, // Remove icon
        iconText: memoryCount.toString(), // Show count instead
        iconTextColor:
            const Color(0xFFFF6B81), // Baby pink color (same as 1st slide)
        gradientColors: const [
          Color(0xFFCDB4DB), // Lavender
          Color(0xFFFFB3BA), // Soft Rose
        ],
        emoji: "🖼️",
        description: "Every memory tells our love story",
        backgroundGradient: const LinearGradient(
          colors: [Color(0xFFCDB4DB), Color(0xFFFFB3BA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: onMemoryJournalTap,
        navigationRoute: 'memory_journal',
      ),
      CarouselItem(
        title: nearestEvent != null && nearestEvent['title'] != null
            ? "${nearestEvent['title']} ❤️"
            : "Our Special Day ❤️",
        subtitle: anniversaryDate ?? "Set your anniversary",
        value: nearestEvent != null && nearestEvent['title'] != null
            ? nearestEvent['title']
            : "Forever and always",
        icon: null, // Remove icon
        iconText: anniversaryDate != null
            ? anniversaryDate.split(' ')[0] // Show just the day number
            : "?", // Show ? if no date
        iconTextColor: const Color(0xFFFF6B81), // Romantic red color
        gradientColors: const [
          Color(0xFFFF6B81), // Romantic Red
          Color(0xFFFFB3BA), // Soft Pink
        ],
        emoji: "💍",
        description: "The day our hearts became one",
        backgroundGradient: const LinearGradient(
          colors: [Color(0xFFFF6B81), Color(0xFFFFB3BA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: onAnniversaryTrackerTap,
        navigationRoute: 'anniversary_tracker',
      ),
      CarouselItem(
        title: periodStats['isSetUp'] == true
            ? "${periodStats['pregnancyProbability']} Pregnancy 🌷"
            : "Caring for You 🌷",
        subtitle: periodStats['isSetUp'] == true
            ? "Day ${periodStats['currentDay']} - ${periodStats['phase']}"
            : "Set your cycle",
        value: periodStats['isSetUp'] == true
            ? periodStats['dailyDialogue'] ?? "Your body is amazing 💖"
            : "Your wellbeing matters",
        icon: null, // Remove icon
        iconText: periodStats['isSetUp'] == true
            ? periodStats['currentDay'].toString() // Show day count
            : "?", // Show ? if not set up
        iconTextColor:
            const Color(0xFFFF6B81), // Baby pink color (same as 1st slide)
        gradientColors: const [
          Color(0xFFE6E6FA), // Lilac
          Color(0xFFFF6B81), // Pink
        ],
        emoji: "📅",
        description: periodStats['isSetUp'] == true
            ? "Fertility: ${periodStats['pregnancyProbability']}"
            : "Love means taking care of each other",
        backgroundGradient: const LinearGradient(
          colors: [Color(0xFFE6E6FA), Color(0xFFFF6B81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: onPeriodTrackerTap,
        navigationRoute: 'period_tracker',
      ),
    ];
  }
}
