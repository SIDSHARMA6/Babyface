import 'package:flutter/material.dart';

/// Carousel item model for romantic dashboard slider
class CarouselItem {
  final String title;
  final String subtitle;
  final String? value; // e.g., latest baby name, count, date
  final IconData? icon;
  final List<Color> gradientColors;
  final String emoji;
  final String description;
  final LinearGradient backgroundGradient;

  const CarouselItem({
    required this.title,
    required this.subtitle,
    this.value,
    this.icon,
    required this.gradientColors,
    required this.emoji,
    required this.description,
    required this.backgroundGradient,
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
  }) {
    return [
      CarouselItem(
        title: "Your Little Miracle 💕",
        subtitle: "You generated $babyCount beautiful names",
        value: latestBabyName ?? "No names yet",
        icon: Icons.child_care,
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
      ),
      CarouselItem(
        title: "Cherished Memories 🌸",
        subtitle: "$memoryCount moments captured",
        value: "In our hearts forever",
        icon: Icons.photo_library,
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
      ),
      CarouselItem(
        title: "Our Special Day ❤️",
        subtitle: anniversaryDate ?? "Set your anniversary",
        value: "Forever and always",
        icon: Icons.favorite,
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
      ),
      CarouselItem(
        title: "Caring for You 🌷",
        subtitle: "Next: ${periodDate ?? 'Set your cycle'}",
        value: "Your wellbeing matters",
        icon: Icons.calendar_today,
        gradientColors: const [
          Color(0xFFE6E6FA), // Lilac
          Color(0xFFFF6B81), // Pink
        ],
        emoji: "📅",
        description: "Love means taking care of each other",
        backgroundGradient: const LinearGradient(
          colors: [Color(0xFFE6E6FA), Color(0xFFFF6B81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];
  }
}
