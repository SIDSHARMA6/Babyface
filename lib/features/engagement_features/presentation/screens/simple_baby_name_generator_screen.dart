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
  late AnimationController _shuffleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shuffleAnimation;

  String? _selectedGender;
  List<String> _generatedNames = [];
  bool _isGenerating = false;
  final Random _random = Random();

  // Baby names database
  final Map<String, List<String>> _babyNames = {
    'Male': [
      'Alexander',
      'Benjamin',
      'Christopher',
      'Daniel',
      'Ethan',
      'Felix',
      'Gabriel',
      'Henry',
      'Isaac',
      'James',
      'Kai',
      'Liam',
      'Mason',
      'Noah',
      'Oliver',
      'Parker',
      'Quinn',
      'Ryan',
      'Sebastian',
      'Theodore',
      'Ulysses',
      'Vincent',
      'William',
      'Xavier',
      'Yusuf',
      'Zachary',
      'Aiden',
      'Blake',
      'Caleb',
      'Dylan',
      'Elijah',
      'Finn',
      'Grayson',
      'Hunter',
      'Ian',
      'Jaxon',
      'Knox',
      'Lucas',
      'Max',
      'Nathan',
      'Owen',
      'Preston',
      'Quentin',
      'Riley',
      'Samuel',
      'Tyler'
    ],
    'Female': [
      'Amelia',
      'Bella',
      'Charlotte',
      'Diana',
      'Emma',
      'Fiona',
      'Grace',
      'Hannah',
      'Isabella',
      'Julia',
      'Katherine',
      'Lily',
      'Mia',
      'Nora',
      'Olivia',
      'Penelope',
      'Quinn',
      'Ruby',
      'Sophia',
      'Tessa',
      'Uma',
      'Violet',
      'Willow',
      'Xara',
      'Yara',
      'Zoe',
      'Aria',
      'Brielle',
      'Chloe',
      'Delilah',
      'Elena',
      'Faith',
      'Gabriella',
      'Hazel',
      'Iris',
      'Jade',
      'Kira',
      'Luna',
      'Maya',
      'Natalie',
      'Ophelia',
      'Paisley',
      'Quinn',
      'Rose',
      'Stella',
      'Talia',
      'Vera'
    ],
    'Unisex': [
      'Alex',
      'Avery',
      'Blake',
      'Cameron',
      'Dakota',
      'Emery',
      'Finley',
      'Gray',
      'Hayden',
      'Indigo',
      'Jordan',
      'Kendall',
      'Lane',
      'Morgan',
      'Nico',
      'Ocean',
      'Parker',
      'Quinn',
      'River',
      'Sage',
      'Taylor',
      'Uriel',
      'Valentine',
      'Winter',
      'Xen',
      'Yael',
      'Zion',
      'Adrian',
      'Blair',
      'Casey',
      'Drew',
      'Eden',
      'Frankie',
      'Grey',
      'Harper',
      'Iris',
      'Jules'
    ]
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shuffleController = AnimationController(
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

    _shuffleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shuffleController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shuffleController.dispose();
    super.dispose();
  }

  void _generateNames() {
    if (_selectedGender == null) {
      ToastService.showWarning(context, 'Please select a gender first! 👶');
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedNames.clear();
    });

    HapticFeedback.lightImpact();
    _shuffleController.forward().then((_) {
      _shuffleController.reset();
    });

    // Simulate AI generation with delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      final names = _babyNames[_selectedGender!]!;
      final shuffledNames = List<String>.from(names)..shuffle(_random);

      setState(() {
        _generatedNames = shuffledNames.take(12).toList();
        _isGenerating = false;
      });

      if (!mounted) return;

      ToastService.showBabyMessage(
          context, 'Generated ${_generatedNames.length} beautiful names! ✨');
    });
  }

  void _addToFavorites(String name) {
    HapticFeedback.selectionClick();
    ToastService.showLove(context, 'Added $name to favorites! 💕');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Baby Names 👶',
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
              // Gender Selection
              Container(
                padding: EdgeInsets.all(20.w),
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
                      'Choose Gender',
                      style: BabyFont.headingM.copyWith(
                        fontSize: 18.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderOption(
                              'Male', Icons.male, AppTheme.primaryBlue),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildGenderOption(
                              'Female', Icons.female, AppTheme.primaryPink),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildGenderOption('Unisex', Icons.child_care,
                              AppTheme.accentYellow),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _generateNames,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPink,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
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
                                    'Generating...',
                                    style: BabyFont.bodyM.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Generate Names ✨',
                                style: BabyFont.bodyM.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
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
                        'Generated Names',
                        style: BabyFont.headingM.copyWith(
                          fontSize: 18.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.5,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                        ),
                        itemCount: _generatedNames.length,
                        itemBuilder: (context, index) {
                          final name = _generatedNames[index];
                          return _buildNameCard(name);
                        },
                      ),
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

  Widget _buildGenderOption(String gender, IconData icon, Color color) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: 2.w,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 24.w,
            ),
            SizedBox(height: 4.h),
            Text(
              gender,
              style: BabyFont.bodyS.copyWith(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameCard(String name) {
    return AnimatedBuilder(
      animation: _shuffleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isGenerating ? 0.8 + (0.2 * _shuffleAnimation.value) : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.primaryPink.withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      name,
                      style: BabyFont.bodyM.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _addToFavorites(name),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      Icons.favorite_border,
                      color: AppTheme.primaryPink,
                      size: 18.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
