import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class BabyNameGeneratorScreen extends StatefulWidget {
  const BabyNameGeneratorScreen({super.key});

  @override
  State<BabyNameGeneratorScreen> createState() =>
      _BabyNameGeneratorScreenState();
}

class _BabyNameGeneratorScreenState extends State<BabyNameGeneratorScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _generateController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _generateAnimation;

  final TextEditingController _boyfriendNameController =
      TextEditingController();
  final TextEditingController _girlfriendNameController =
      TextEditingController();

  List<GeneratedName> _generatedNames = [];
  bool _isGenerating = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _generateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _generateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _generateController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _generateController.dispose();
    _boyfriendNameController.dispose();
    _girlfriendNameController.dispose();
    super.dispose();
  }

  void _generateNames() {
    final boyfriendName = _boyfriendNameController.text.trim();
    final girlfriendName = _girlfriendNameController.text.trim();

    if (boyfriendName.isEmpty || girlfriendName.isEmpty) {
      ToastService.showWarning(context, 'Please enter both names! 👫');
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedNames.clear();
    });

    HapticFeedback.lightImpact();
    _generateController.forward().then((_) {
      _generateController.reset();
    });

    // Simulate AI generation with delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      final boyNames =
          _generateBabyNames(boyfriendName, girlfriendName, 'male');
      final girlNames =
          _generateBabyNames(boyfriendName, girlfriendName, 'female');

      setState(() {
        _generatedNames = [...boyNames, ...girlNames];
        _isGenerating = false;
      });

      if (!mounted) return;

      ToastService.showBabyMessage(context,
          'Generated ${_generatedNames.length} beautiful Indian names! 🇮🇳✨');
    });
  }

  List<GeneratedName> _generateBabyNames(
      String name1, String name2, String gender) {
    final names = <GeneratedName>[];

    // Indian/Hindi name generation using AI prompts
    final indianNames = _generateIndianNames(name1, name2, gender);

    for (int i = 0; i < 2; i++) {
      final nameData = indianNames[i % indianNames.length];
      final loveScore = _calculateLoveScore(nameData['name']!, name1, name2);

      names.add(GeneratedName(
        name: nameData['name']!,
        meaning: nameData['meaning']!,
        loveScore: loveScore,
        gender: gender,
        isFavorite: false,
      ));
    }

    return names;
  }

  List<Map<String, String>> _generateIndianNames(
      String name1, String name2, String gender) {
    // Indian/Hindi name generation based on AI prompts
    final names = <Map<String, String>>[];

    // Generate 4 different Indian names using various methods
    for (int i = 0; i < 4; i++) {
      Map<String, String> nameData;

      switch (i) {
        case 0:
          // Method 1: Direct combination with Indian endings
          nameData = _generateDirectCombination(name1, name2, gender);
          break;
        case 1:
          // Method 2: Syllable mixing
          nameData = _generateSyllableMix(name1, name2, gender);
          break;
        case 2:
          // Method 3: Prefix + Suffix approach
          nameData = _generatePrefixSuffix(name1, name2, gender);
          break;
        case 3:
          // Method 4: Traditional Indian name inspiration
          nameData = _generateTraditionalIndian(name1, name2, gender);
          break;
        default:
          nameData = _generateDirectCombination(name1, name2, gender);
      }

      names.add(nameData);
    }

    return names;
  }

  List<String> _getIndianCombinations(String name1, String name2) {
    // Create Indian-style combinations
    return [
      '${name1.substring(0, min(3, name1.length))}${name2.substring(max(0, name2.length - 3))}',
      '${name2.substring(0, min(3, name2.length))}${name1.substring(max(0, name1.length - 3))}',
      '${name1.substring(0, min(2, name1.length))}${name2.substring(0, min(2, name2.length))}${name1.substring(max(0, name1.length - 2))}',
      '${name2.substring(0, min(2, name2.length))}${name1.substring(0, min(2, name1.length))}${name2.substring(max(0, name2.length - 2))}',
    ];
  }

  String _createIndianName(String combination, String gender) {
    // Add Indian/Hindi-style endings
    if (gender == 'male') {
      final maleEndings = [
        'an',
        'esh',
        'raj',
        'dev',
        'pal',
        'jit',
        'deep',
        'veer',
        'kumar',
        'singh'
      ];
      return combination + maleEndings[_random.nextInt(maleEndings.length)];
    } else {
      final femaleEndings = [
        'a',
        'i',
        'ika',
        'ini',
        'ita',
        'iya',
        'ani',
        'priya',
        'devi',
        'kumari'
      ];
      return combination + femaleEndings[_random.nextInt(femaleEndings.length)];
    }
  }

  Map<String, String> _generateDirectCombination(
      String name1, String name2, String gender) {
    final combinations = _getIndianCombinations(name1, name2);
    final combination = combinations[_random.nextInt(combinations.length)];
    final name = _createIndianName(combination, gender);
    final meaning = _generateIndianMeaning(name, name1, name2);

    return {'name': name, 'meaning': meaning};
  }

  Map<String, String> _generateSyllableMix(
      String name1, String name2, String gender) {
    // Mix syllables from both names
    final syllables1 = _getSyllables(name1);
    final syllables2 = _getSyllables(name2);

    String name;
    if (gender == 'male') {
      final malePrefixes = [
        'Ar',
        'Raj',
        'Dev',
        'Kum',
        'Vik',
        'Roh',
        'Sah',
        'Man'
      ];
      final maleSuffixes = [
        'an',
        'esh',
        'raj',
        'dev',
        'pal',
        'jit',
        'deep',
        'veer'
      ];
      name = malePrefixes[_random.nextInt(malePrefixes.length)] +
          syllables1[0] +
          syllables2[0] +
          maleSuffixes[_random.nextInt(maleSuffixes.length)];
    } else {
      final femalePrefixes = [
        'Pri',
        'An',
        'Shr',
        'Kav',
        'Rit',
        'Sne',
        'Man',
        'Div'
      ];
      final femaleSuffixes = [
        'a',
        'i',
        'ika',
        'ini',
        'ita',
        'iya',
        'ani',
        'priya'
      ];
      name = femalePrefixes[_random.nextInt(femalePrefixes.length)] +
          syllables1[0] +
          syllables2[0] +
          femaleSuffixes[_random.nextInt(femaleSuffixes.length)];
    }

    final meaning = _generateIndianMeaning(name, name1, name2);
    return {'name': name, 'meaning': meaning};
  }

  Map<String, String> _generatePrefixSuffix(
      String name1, String name2, String gender) {
    String name;
    if (gender == 'male') {
      final prefixes = ['Anu', 'Bha', 'Rah', 'Sne', 'Kav', 'Rit', 'Man', 'Div'];
      final suffixes = [
        'bhav',
        'nil',
        'esh',
        'raj',
        'dev',
        'pal',
        'jit',
        'deep'
      ];
      name = prefixes[_random.nextInt(prefixes.length)] +
          suffixes[_random.nextInt(suffixes.length)];
    } else {
      final prefixes = ['An', 'Bha', 'Rah', 'Sne', 'Kav', 'Rit', 'Man', 'Div'];
      final suffixes = [
        'vitha',
        'wini',
        'isha',
        'priya',
        'devi',
        'kumari',
        'ita',
        'ani'
      ];
      name = prefixes[_random.nextInt(prefixes.length)] +
          suffixes[_random.nextInt(suffixes.length)];
    }

    final meaning = _generateIndianMeaning(name, name1, name2);
    return {'name': name, 'meaning': meaning};
  }

  Map<String, String> _generateTraditionalIndian(
      String name1, String name2, String gender) {
    // Use traditional Indian name patterns
    final traditionalNames = gender == 'male'
        ? [
            'Arjun',
            'Rahul',
            'Vikram',
            'Rajesh',
            'Suresh',
            'Mahesh',
            'Dinesh',
            'Ramesh'
          ]
        : [
            'Priya',
            'Anita',
            'Sunita',
            'Kavita',
            'Rita',
            'Sita',
            'Gita',
            'Meera'
          ];

    final baseName = traditionalNames[_random.nextInt(traditionalNames.length)];
    final name = _modifyTraditionalName(baseName, name1, name2);
    final meaning = _generateIndianMeaning(name, name1, name2);

    return {'name': name, 'meaning': meaning};
  }

  List<String> _getSyllables(String name) {
    // Simple syllable extraction
    final vowels = 'aeiouAEIOU';
    final syllables = <String>[];
    String currentSyllable = '';

    for (int i = 0; i < name.length; i++) {
      currentSyllable += name[i];
      if (i < name.length - 1 &&
          vowels.contains(name[i]) &&
          !vowels.contains(name[i + 1])) {
        syllables.add(currentSyllable);
        currentSyllable = '';
      }
    }
    if (currentSyllable.isNotEmpty) {
      syllables.add(currentSyllable);
    }

    return syllables.isNotEmpty
        ? syllables
        : [name.substring(0, min(2, name.length))];
  }

  String _modifyTraditionalName(String baseName, String name1, String name2) {
    // Modify traditional name with input names
    final name1Part = name1.substring(0, min(2, name1.length));
    final name2Part = name2.substring(0, min(2, name2.length));

    if (baseName.length > 4) {
      return baseName.substring(0, baseName.length - 2) + name1Part + name2Part;
    } else {
      return baseName + name1Part + name2Part;
    }
  }

  String _generateIndianMeaning(String name, String name1, String name2) {
    final indianMeanings = [
      'Combination of $name1 and $name2, meaning "divine blessing"',
      'Blend of $name1 and $name2, symbolizing "eternal love"',
      'Merged from $name1 and $name2, representing "sacred union"',
      'Fusion of $name1 and $name2, meaning "destined together"',
      'Union of $name1 and $name2, symbolizing "soul connection"',
      'Combination of $name1 and $name2, meaning "blessed child"',
      'Blend of $name1 and $name2, symbolizing "pure love"',
      'Merged from $name1 and $name2, representing "divine gift"',
      'Combination of $name1 and $name2, meaning "auspicious beginning"',
      'Blend of $name1 and $name2, symbolizing "sacred bond"',
      'Merged from $name1 and $name2, representing "divine grace"',
      'Fusion of $name1 and $name2, meaning "blessed union"',
    ];
    return indianMeanings[_random.nextInt(indianMeanings.length)];
  }

  int _calculateLoveScore(String name, String name1, String name2) {
    // Calculate love score based on name characteristics
    int score = 50; // Base score

    // Add points for name length (optimal 4-8 characters)
    if (name.length >= 4 && name.length <= 8) score += 20;

    // Add points for vowel-consonant balance
    final vowels =
        name.toLowerCase().split('').where((c) => 'aeiou'.contains(c)).length;
    final consonants = name.length - vowels;
    if ((vowels - consonants).abs() <= 2) score += 15;

    // Add random love factor
    score += _random.nextInt(15);

    return score.clamp(60, 100);
  }

  void _toggleFavorite(int index) {
    setState(() {
      _generatedNames[index] = _generatedNames[index].copyWith(
        isFavorite: !_generatedNames[index].isFavorite,
      );
    });

    HapticFeedback.selectionClick();
    final name = _generatedNames[index];
    if (name.isFavorite) {
      ToastService.showLove(context, 'Added ${name.name} to favorites! 💕');
    } else {
      ToastService.showInfo(context, 'Removed ${name.name} from favorites');
    }
  }

  void _shareName(GeneratedName name) {
    HapticFeedback.lightImpact();
    ToastService.showInfo(context, 'Sharing ${name.name}... 📤');
    // TODO: Implement actual sharing functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Indian Name Magic Lab 🇮🇳',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Input Section
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withValues(alpha: 0.1),
                      blurRadius: 15.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Enter Your Names (Indian Style)',
                      style: BabyFont.headingM.copyWith(
                        fontSize: 20.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Boyfriend Name Input
                    _buildNameInput(
                      'Boyfriend\'s Name 👨',
                      _boyfriendNameController,
                      AppTheme.primaryBlue,
                      Icons.male,
                    ),

                    SizedBox(height: 16.h),

                    // Girlfriend Name Input
                    _buildNameInput(
                      'Girlfriend\'s Name 👩',
                      _girlfriendNameController,
                      AppTheme.primaryPink,
                      Icons.female,
                    ),

                    SizedBox(height: 24.h),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateNames,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPink,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                        ),
                        child: _isGenerating
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Generating Magic...',
                                    style: BabyFont.bodyM.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome, size: 20.w),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Generate Indian Names 🇮🇳',
                                    style: BabyFont.bodyM.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Generated Names
              if (_generatedNames.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        blurRadius: 15.r,
                        offset: Offset(0, 5.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generated Indian Names',
                        style: BabyFont.headingM.copyWith(
                          fontSize: 18.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ..._generatedNames.asMap().entries.map((entry) {
                        final index = entry.key;
                        final name = entry.value;
                        return _buildNameCard(name, index);
                      }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput(String label, TextEditingController controller,
      Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter name here...',
            hintStyle: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            prefixIcon: Icon(icon, color: color),
            filled: true,
            fillColor: color.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: color, width: 2.w),
            ),
          ),
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNameCard(GeneratedName name, int index) {
    return AnimatedBuilder(
      animation: _generateAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isGenerating ? 0.8 + (0.2 * _generateAnimation.value) : 1.0,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: name.gender == 'male'
                  ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                  : AppTheme.primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: name.gender == 'male'
                    ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                    : AppTheme.primaryPink.withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name.gender == 'male' ? '👦' : '👧',
                      style: TextStyle(fontSize: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        name.name,
                        style: BabyFont.headingM.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleFavorite(index),
                          child: Icon(
                            name.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: name.isFavorite
                                ? AppTheme.primaryPink
                                : Colors.grey,
                            size: 24.w,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => _shareName(name),
                          child: Icon(
                            Icons.share,
                            color: AppTheme.primaryBlue,
                            size: 20.w,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  name.meaning,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppTheme.accentYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Love Score: ${name.loveScore}%',
                        style: BabyFont.bodyS.copyWith(
                          color: AppTheme.accentYellow,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ToastService.showBabyMessage(
                            context, 'Saved ${name.name} to favorites! 💕');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: name.gender == 'male'
                            ? AppTheme.primaryBlue
                            : AppTheme.primaryPink,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: BabyFont.bodyS.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GeneratedName {
  final String name;
  final String meaning;
  final int loveScore;
  final String gender;
  final bool isFavorite;

  GeneratedName({
    required this.name,
    required this.meaning,
    required this.loveScore,
    required this.gender,
    required this.isFavorite,
  });

  GeneratedName copyWith({
    String? name,
    String? meaning,
    int? loveScore,
    String? gender,
    bool? isFavorite,
  }) {
    return GeneratedName(
      name: name ?? this.name,
      meaning: meaning ?? this.meaning,
      loveScore: loveScore ?? this.loveScore,
      gender: gender ?? this.gender,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
