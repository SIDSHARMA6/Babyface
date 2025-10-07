import '../entities/baby_name_entity.dart';

/// Generate baby names use case
/// Follows master plan clean architecture
class GenerateBabyNamesUsecase {
  /// Execute generate baby names
  Future<List<BabyNameEntity>> execute(BabyNameRequest request) async {
    // Simulate AI-powered name generation
    await Future.delayed(const Duration(seconds: 2));

    final names = <BabyNameEntity>[];
    // final now = DateTime.now();

    // Generate names based on request
    for (int i = 0; i < request.count; i++) {
      final name = _generateRandomName(request, i);
      names.add(name);
    }

    return names;
  }

  /// Generate a random name based on request
  BabyNameEntity _generateRandomName(BabyNameRequest request, int index) {
    final names = _getNamesByGender(request.gender);
    final origins = _getOriginsByPreference(request.origin);
    final meanings = _getMeaningsByStyle(request.style);

    final randomName = names[index % names.length];
    final randomOrigin = origins[index % origins.length];
    final randomMeaning = meanings[index % meanings.length];
    final popularity = (0.3 + (index * 0.1)).clamp(0.0, 1.0);

    return BabyNameEntity(
      id: 'name_${DateTime.now().millisecondsSinceEpoch}_$index',
      name: randomName,
      gender: request.gender ?? 'unisex',
      origin: randomOrigin,
      meaning: randomMeaning,
      popularity: popularity,
      similarNames: _getSimilarNames(randomName),
      createdAt: DateTime.now(),
    );
  }

  /// Get names by gender preference
  List<String> _getNamesByGender(String? gender) {
    switch (gender) {
      case 'boy':
        return [
          'Alexander', 'Benjamin', 'Christopher', 'Daniel', 'Ethan',
          'Gabriel', 'Henry', 'Isaac', 'James', 'Liam',
          'Mason', 'Noah', 'Oliver', 'Sebastian', 'William',
          'Zachary', 'Andrew', 'Caleb', 'David', 'Elijah',
        ];
      case 'girl':
        return [
          'Amelia', 'Ava', 'Charlotte', 'Emma', 'Isabella',
          'Olivia', 'Sophia', 'Abigail', 'Emily', 'Elizabeth',
          'Grace', 'Harper', 'Lily', 'Mia', 'Natalie',
          'Penelope', 'Riley', 'Scarlett', 'Victoria', 'Zoe',
        ];
      default:
        return [
          'Alex', 'Avery', 'Blake', 'Cameron', 'Casey',
          'Dakota', 'Drew', 'Emery', 'Finley', 'Hayden',
          'Jordan', 'Kai', 'Logan', 'Morgan', 'Parker',
          'Quinn', 'Riley', 'Sage', 'Taylor', 'River',
        ];
    }
  }

  /// Get origins by preference
  List<String> _getOriginsByPreference(String? origin) {
    if (origin == null || origin == 'any') {
      return ['English', 'Spanish', 'French', 'German', 'Italian', 'Arabic', 'Hebrew', 'Japanese'];
    }
    return [origin];
  }

  /// Get meanings by style
  List<String> _getMeaningsByStyle(String? style) {
    switch (style) {
      case 'traditional':
        return [
          'Strong and noble',
          'Blessed by God',
          'Gift from heaven',
          'Protector of peace',
          'Bearer of light',
          'Guardian angel',
          'Divine blessing',
          'Sacred treasure',
        ];
      case 'modern':
        return [
          'Bright future',
          'Digital native',
          'Global citizen',
          'Innovation leader',
          'Creative spirit',
          'Tech pioneer',
          'Social connector',
          'Dream achiever',
        ];
      case 'unique':
        return [
          'One of a kind',
          'Rare gem',
          'Unique spirit',
          'Special soul',
          'Extraordinary being',
          'Uncommon beauty',
          'Distinctive charm',
          'Exceptional talent',
        ];
      default:
        return [
          'Beloved child',
          'Joyful spirit',
          'Peaceful soul',
          'Brave heart',
          'Wise mind',
          'Kind spirit',
          'Pure heart',
          'Gentle soul',
        ];
    }
  }

  /// Get similar names
  List<String> _getSimilarNames(String name) {
    // Simple similarity based on first letter and length
    final firstLetter = name[0];
    final length = name.length;
    
    return [
      '${firstLetter}ara',
      '${firstLetter}ina',
      '${firstLetter}ora',
      '${firstLetter}ena',
    ].where((similarName) => similarName.length == length).take(3).toList();
  }
}
