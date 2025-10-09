import 'package:equatable/equatable.dart';

/// Period Cycle Model
/// Represents a menstrual cycle with all phases and calculations
class PeriodCycle extends Equatable {
  final String id;
  final DateTime lastPeriodStart;
  final int cycleLength;
  final int periodLength;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PeriodCycle({
    required this.id,
    required this.lastPeriodStart,
    this.cycleLength = 28,
    this.periodLength = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create PeriodCycle from JSON
  factory PeriodCycle.fromJson(Map<String, dynamic> json) {
    return PeriodCycle(
      id: json['id'] as String,
      lastPeriodStart: DateTime.parse(json['lastPeriodStart'] as String),
      cycleLength: json['cycleLength'] as int? ?? 28,
      periodLength: json['periodLength'] as int? ?? 5,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert PeriodCycle to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lastPeriodStart': lastPeriodStart.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of PeriodCycle with updated fields
  PeriodCycle copyWith({
    String? id,
    DateTime? lastPeriodStart,
    int? cycleLength,
    int? periodLength,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PeriodCycle(
      id: id ?? this.id,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get current day in cycle with leap year and month length consideration
  int get currentDayInCycle {
    final now = DateTime.now();
    final daysSinceLastPeriod = now.difference(lastPeriodStart).inDays;

    // Handle leap year and month length variations
    int adjustedCycleLength = cycleLength;

    // Adjust for leap year if current year is leap year
    if (_isLeapYear(now.year)) {
      // Slight adjustment for leap year (optional)
      adjustedCycleLength = cycleLength;
    }

    // Calculate day in cycle with modulo to handle cycle completion
    int dayInCycle = (daysSinceLastPeriod % adjustedCycleLength) + 1;

    // Ensure day is within valid range (1 to cycleLength)
    if (dayInCycle < 1) dayInCycle = 1;
    if (dayInCycle > cycleLength) dayInCycle = cycleLength;

    return dayInCycle;
  }

  /// Check if a year is a leap year
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get days in a specific month considering leap year
  int _getDaysInMonth(int year, int month) {
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    if (month == 2 && _isLeapYear(year)) {
      return 29; // Leap year February
    }

    return daysInMonth[month - 1];
  }

  /// Get next period start date with month length consideration
  DateTime get nextPeriodStart {
    DateTime nextPeriod = lastPeriodStart.add(Duration(days: cycleLength));

    // Adjust for month boundaries if needed
    final currentMonthDays = _getDaysInMonth(nextPeriod.year, nextPeriod.month);
    if (nextPeriod.day > currentMonthDays) {
      // Move to next month if day exceeds month length
      nextPeriod = DateTime(nextPeriod.year, nextPeriod.month + 1, 1);
    }

    return nextPeriod;
  }

  /// Get current cycle phase
  CyclePhase get currentPhase {
    final day = currentDayInCycle;
    final ovulationDayInCycle =
        cycleLength - 14; // Ovulation typically 14 days before next period

    if (day <= periodLength) {
      return CyclePhase.menstrual;
    } else if (day < ovulationDayInCycle) {
      return CyclePhase.follicular;
    } else if (day == ovulationDayInCycle) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  /// Get ovulation day (typically 14 days before next period)
  DateTime get ovulationDay {
    return nextPeriodStart.subtract(Duration(days: 14));
  }

  /// Get fertile window start (5 days before ovulation)
  DateTime get fertileWindowStart {
    return ovulationDay.subtract(Duration(days: 5));
  }

  /// Get fertile window end (1 day after ovulation)
  DateTime get fertileWindowEnd {
    return ovulationDay.add(Duration(days: 1));
  }

  /// Get days until next period
  int get daysUntilNextPeriod {
    final now = DateTime.now();
    final nextPeriod = nextPeriodStart;
    return nextPeriod.difference(now).inDays;
  }

  /// Check if today is fertile
  bool get isTodayFertile {
    final now = DateTime.now();
    final fertileStart = fertileWindowStart;
    final fertileEnd = fertileWindowEnd;

    return now.isAfter(fertileStart) && now.isBefore(fertileEnd);
  }

  /// Check if today is ovulation day
  bool get isTodayOvulation {
    final now = DateTime.now();
    final ovulation = ovulationDay;

    return now.year == ovulation.year &&
        now.month == ovulation.month &&
        now.day == ovulation.day;
  }

  /// Get pregnancy probability level
  PregnancyProbability get pregnancyProbability {
    final day = currentDayInCycle;
    final ovulationDayInCycle =
        cycleLength - 14; // Ovulation typically 14 days before next period
    final fertileStart = ovulationDayInCycle -
        5; // Fertile window starts 5 days before ovulation

    // Very Low: Days 1-5 (Period)
    if (day >= 1 && day <= periodLength) {
      return PregnancyProbability.veryLow;
    }

    // Low: Days after period but before fertile window
    if (day > periodLength && day < fertileStart) {
      return PregnancyProbability.low;
    }

    // High: Fertile window (5 days before ovulation)
    if (day >= fertileStart && day < ovulationDayInCycle) {
      return PregnancyProbability.high;
    }

    // Very High: Ovulation day
    if (day == ovulationDayInCycle) {
      return PregnancyProbability.veryHigh;
    }

    // High: Day after ovulation
    if (day == ovulationDayInCycle + 1) {
      return PregnancyProbability.high;
    }

    // Medium: Days 2-3 after ovulation
    if (day >= ovulationDayInCycle + 2 && day <= ovulationDayInCycle + 3) {
      return PregnancyProbability.medium;
    }

    // Low: Rest of the cycle
    return PregnancyProbability.low;
  }

  /// Get daily dialogue for current day
  String get dailyDialogue {
    return _getDialogueForDay(currentDayInCycle);
  }

  /// Get dialogue for specific day
  String _getDialogueForDay(int day) {
    switch (day) {
      case 1:
        return "Bleed starts 💧 Pain may come — rest and drink water.";
      case 2:
        return "Pain peaks today 🌸 Take it easy, use warm things.";
      case 3:
        return "Bleed getting less 💕 Pain going away.";
      case 4:
        return "Almost done 💫 Feel better now.";
      case 5:
        return "Bleed ends 🌷 Energy coming back.";
      case 6:
        return "Egg developing ☀️ Feel happy and strong.";
      case 7:
        return "Egg growing 🌼 Body getting ready.";
      case 8:
        return "Feel creative 🎨 Good day for new things.";
      case 9:
        return "Want to meet people 💌 Feel social today.";
      case 10:
        return "Egg almost ready ✨ Feel very good.";
      case 11:
        return "Egg ready 🌸 Can get pregnant now.";
      case 12:
        return "Egg perfect 💞 Best time for baby.";
      case 13:
        return "Egg at peak 💫 Very fertile today.";
      case 14:
        return "Egg released 🥚 Can make baby today!";
      case 15:
        return "Egg gone 🌙 Safe days starting.";
      case 16:
        return "Feel calm 💆‍♀️ Rest and relax.";
      case 17:
        return "Mood down a bit 💗 Be nice to yourself.";
      case 18:
        return "Safe days 💫 No baby risk.";
      case 19:
        return "Feel cozy 💗 Want to stay home.";
      case 20:
        return "Body tender 💗 Need gentle care.";
      case 21:
        return "Feel stable 🌿 Good for work.";
      case 22:
        return "Body resting 💖 Safe days continue.";
      case 23:
        return "Pain starts 🩷 Period coming soon.";
      case 24:
        return "Mood changes 💕 Feel emotional.";
      case 25:
        return "Pain and bloating ☕ Drink warm things.";
      case 26:
        return "Feel sad 🌧️ Be kind to yourself.";
      case 27:
        return "Period coming 🌸 Take care.";
      case 28:
        return "New cycle starts 🌷 Fresh beginning!";
      default:
        return "Your body is amazing 💖";
    }
  }

  @override
  List<Object?> get props => [
        id,
        lastPeriodStart,
        cycleLength,
        periodLength,
        createdAt,
        updatedAt,
      ];
}

/// Cycle phases enum
enum CyclePhase {
  menstrual,
  follicular,
  ovulation,
  luteal,
}

/// Pregnancy probability levels
enum PregnancyProbability {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
}

/// Extension for PregnancyProbability
extension PregnancyProbabilityExtension on PregnancyProbability {
  String get displayName {
    switch (this) {
      case PregnancyProbability.veryLow:
        return 'Very Low';
      case PregnancyProbability.low:
        return 'Low';
      case PregnancyProbability.medium:
        return 'Medium';
      case PregnancyProbability.high:
        return 'High';
      case PregnancyProbability.veryHigh:
        return 'Very High';
    }
  }

  String get emoji {
    switch (this) {
      case PregnancyProbability.veryLow:
        return '💧';
      case PregnancyProbability.low:
        return '🌸';
      case PregnancyProbability.medium:
        return '🌙';
      case PregnancyProbability.high:
        return '💫';
      case PregnancyProbability.veryHigh:
        return '🥚';
    }
  }
}

/// Extension for CyclePhase
extension CyclePhaseExtension on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Bleeding';
      case CyclePhase.follicular:
        return 'Egg Growing';
      case CyclePhase.ovulation:
        return 'Egg Ready';
      case CyclePhase.luteal:
        return 'Safe Days';
    }
  }

  String get emoji {
    switch (this) {
      case CyclePhase.menstrual:
        return '💧';
      case CyclePhase.follicular:
        return '🌱';
      case CyclePhase.ovulation:
        return '🥚';
      case CyclePhase.luteal:
        return '🌙';
    }
  }
}
