import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class CoupleChallengesBucketListScreen extends StatefulWidget {
  const CoupleChallengesBucketListScreen({super.key});

  @override
  State<CoupleChallengesBucketListScreen> createState() =>
      _CoupleChallengesBucketListScreenState();
}

class _CoupleChallengesBucketListScreenState
    extends State<CoupleChallengesBucketListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<ChallengeItem> _challenges = [];
  final List<BucketItem> _bucketItems = [];
  String _selectedTab = 'Challenges';
  int _currentStreak = 0;
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAddChallengeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddChallengeBottomSheet(),
    );
  }

  void _showAddBucketItemBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddBucketItemBottomSheet(),
    );
  }

  void _addChallenge(String title, String description, DateTime date,
      String category, String difficulty, String type) {
    final challenge = ChallengeItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date,
      category: category,
      difficulty: difficulty,
      type: type,
      isCompleted: false,
      points: _getPointsForDifficulty(difficulty),
      isFavorite: false,
    );

    setState(() {
      _challenges.insert(0, challenge);
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(
        context, 'Challenge added to Adventure Vault! 💪');
  }

  void _addBucketItem(String title, String description, DateTime date,
      String category, String difficulty, File? image) {
    final bucketItem = BucketItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date,
      category: category,
      difficulty: difficulty,
      isCompleted: false,
      isFavorite: false,
      image: image,
    );

    setState(() {
      _bucketItems.insert(0, bucketItem);
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(context, 'Bucket list item added! ✅');
  }

  void _completeChallenge(String id) {
    setState(() {
      final index = _challenges.indexWhere((c) => c.id == id);
      if (index != -1 && !_challenges[index].isCompleted) {
        _challenges[index] = _challenges[index].copyWith(isCompleted: true);
        _totalPoints += _challenges[index].points;
        _currentStreak++;
      }
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(context,
        'Challenge completed! +${_challenges.firstWhere((c) => c.id == id).points} points! 🎉');
  }

  void _completeBucketItem(String id) {
    setState(() {
      final index = _bucketItems.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bucketItems[index] = _bucketItems[index].copyWith(isCompleted: true);
      }
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(context, 'Bucket list item completed! 🌟');
  }

  void _toggleFavorite(String id, bool isChallenge) {
    setState(() {
      if (isChallenge) {
        final index = _challenges.indexWhere((c) => c.id == id);
        if (index != -1) {
          _challenges[index] = _challenges[index].copyWith(
            isFavorite: !_challenges[index].isFavorite,
          );
        }
      } else {
        final index = _bucketItems.indexWhere((b) => b.id == id);
        if (index != -1) {
          _bucketItems[index] = _bucketItems[index].copyWith(
            isFavorite: !_bucketItems[index].isFavorite,
          );
        }
      }
    });

    HapticFeedback.selectionClick();
  }

  int _getPointsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 10;
      case 'Medium':
        return 25;
      case 'Hard':
        return 50;
      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Adventure Vault 🏆',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Stats Section
            Container(
              margin: EdgeInsets.all(20.w),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('$_currentStreak', 'Streak',
                      Icons.local_fire_department, AppTheme.accentYellow),
                  _buildStatItem('$_totalPoints', 'Points', Icons.stars,
                      AppTheme.primaryBlue),
                  _buildStatItem(
                      '${_challenges.where((c) => c.isCompleted).length}',
                      'Completed',
                      Icons.check_circle,
                      AppTheme.primaryPink),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Challenges', Icons.fitness_center),
                  ),
                  Expanded(
                    child: _buildTabButton('Bucket List', Icons.checklist),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Content
            Expanded(
              child: _selectedTab == 'Challenges'
                  ? _buildChallengesList()
                  : _buildBucketList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedTab == 'Challenges'
            ? _showAddChallengeBottomSheet
            : _showAddBucketItemBottomSheet,
        backgroundColor: AppTheme.primaryPink,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24.w,
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.w),
        SizedBox(height: 8.h),
        Text(
          value,
          style: BabyFont.headingM.copyWith(
            color: color,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, IconData icon) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPink : Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 20.w,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: BabyFont.bodyM.copyWith(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesList() {
    if (_challenges.isEmpty) {
      return _buildEmptyState('No Challenges Yet',
          'Start your adventure by adding a challenge!', Icons.fitness_center);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: _challenges.length,
      itemBuilder: (context, index) {
        final challenge = _challenges[index];
        return _buildChallengeCard(challenge);
      },
    );
  }

  Widget _buildBucketList() {
    if (_bucketItems.isEmpty) {
      return _buildEmptyState('No Bucket Items Yet',
          'Start creating your dream list!', Icons.checklist);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: _bucketItems.length,
      itemBuilder: (context, index) {
        final bucketItem = _bucketItems[index];
        return _buildBucketItemCard(bucketItem);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryPink,
            size: 80.w,
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeItem challenge) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: challenge.isCompleted
                ? AppTheme.primaryPink.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
        border: challenge.isCompleted
            ? Border.all(
                color: AppTheme.primaryPink.withValues(alpha: 0.3), width: 1.w)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleFavorite(challenge.id, true),
                    child: Icon(
                      challenge.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: challenge.isFavorite
                          ? AppTheme.primaryPink
                          : Colors.grey,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (challenge.isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryPink,
                      size: 24.w,
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            challenge.description,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildCategoryChip(challenge.category, AppTheme.primaryBlue),
              SizedBox(width: 8.w),
              _buildDifficultyChip(challenge.difficulty),
              SizedBox(width: 8.w),
              _buildTypeChip(challenge.type),
              const Spacer(),
              Text(
                '${challenge.points} pts',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Due: ${_formatDate(challenge.date)}',
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          if (!challenge.isCompleted) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _completeChallenge(challenge.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  'Complete Challenge',
                  style: BabyFont.bodyS.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBucketItemCard(BucketItem bucketItem) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: bucketItem.isCompleted
                ? AppTheme.accentYellow.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
        border: bucketItem.isCompleted
            ? Border.all(
                color: AppTheme.accentYellow.withValues(alpha: 0.3), width: 1.w)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bucketItem.title,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    decoration: bucketItem.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleFavorite(bucketItem.id, false),
                    child: Icon(
                      bucketItem.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: bucketItem.isFavorite
                          ? AppTheme.primaryPink
                          : Colors.grey,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (bucketItem.isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.accentYellow,
                      size: 24.w,
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            bucketItem.description,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          if (bucketItem.image != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                bucketItem.image!,
                width: double.infinity,
                height: 120.h,
                fit: BoxFit.cover,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildCategoryChip(bucketItem.category, AppTheme.accentYellow),
              SizedBox(width: 8.w),
              _buildDifficultyChip(bucketItem.difficulty),
              const Spacer(),
              if (!bucketItem.isCompleted)
                ElevatedButton(
                  onPressed: () => _completeBucketItem(bucketItem.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentYellow,
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    'Complete',
                    style: BabyFont.bodyS.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        category,
        style: BabyFont.bodyS.copyWith(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'Easy':
        color = Colors.green;
        break;
      case 'Medium':
        color = AppTheme.accentYellow;
        break;
      case 'Hard':
        color = AppTheme.primaryPink;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        difficulty,
        style: BabyFont.bodyS.copyWith(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        type,
        style: BabyFont.bodyS.copyWith(
          color: AppTheme.primaryBlue,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAddChallengeBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: AddChallengeForm(onSave: _addChallenge),
    );
  }

  Widget _buildAddBucketItemBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: AddBucketItemForm(onSave: _addBucketItem),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class ChallengeItem {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String category;
  final String difficulty;
  final String type;
  final bool isCompleted;
  final int points;
  final bool isFavorite;

  ChallengeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.difficulty,
    required this.type,
    required this.isCompleted,
    required this.points,
    required this.isFavorite,
  });

  ChallengeItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? category,
    String? difficulty,
    String? type,
    bool? isCompleted,
    int? points,
    bool? isFavorite,
  }) {
    return ChallengeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      points: points ?? this.points,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class BucketItem {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String category;
  final String difficulty;
  final bool isCompleted;
  final bool isFavorite;
  final File? image;

  BucketItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.difficulty,
    required this.isCompleted,
    required this.isFavorite,
    this.image,
  });

  BucketItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? category,
    String? difficulty,
    bool? isCompleted,
    bool? isFavorite,
    File? image,
  }) {
    return BucketItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      image: image ?? this.image,
    );
  }
}

class AddChallengeForm extends StatefulWidget {
  final Function(String title, String description, DateTime date,
      String category, String difficulty, String type) onSave;

  const AddChallengeForm({super.key, required this.onSave});

  @override
  State<AddChallengeForm> createState() => _AddChallengeFormState();
}

class _AddChallengeFormState extends State<AddChallengeForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedCategory = 'Fun';
  String _selectedDifficulty = 'Easy';
  String _selectedType = 'Custom';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChallenge() {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ToastService.showWarning(context, 'Please fill in all fields! 📝');
      return;
    }

    widget.onSave(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      _selectedDate,
      _selectedCategory,
      _selectedDifficulty,
      _selectedType,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Text(
            'Add Challenge',
            style: BabyFont.headingM.copyWith(
              fontSize: 20.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),

          // Title Input
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Challenge Title',
              hintText: 'e.g., Cook Together',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Description Input
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe the challenge...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Category Selection
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            items: [
              'Fun',
              'Romantic',
              'Adventure',
              'Learning',
              'Fitness',
              'Creative'
            ]
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),

          SizedBox(height: 16.h),

          // Difficulty Selection
          DropdownButtonFormField<String>(
            value: _selectedDifficulty,
            decoration: InputDecoration(
              labelText: 'Difficulty',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            items: ['Easy', 'Medium', 'Hard']
                .map((difficulty) => DropdownMenuItem(
                      value: difficulty,
                      child: Text(difficulty),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDifficulty = value!;
              });
            },
          ),

          SizedBox(height: 16.h),

          // Type Selection
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            items: ['Truth', 'Dare', 'Custom']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),

          SizedBox(height: 16.h),

          // Date Selection
          ListTile(
            title: Text('Due Date'),
            subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),

          const Spacer(),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Add Challenge',
                style: BabyFont.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddBucketItemForm extends StatefulWidget {
  final Function(String title, String description, DateTime date,
      String category, String difficulty, File? image) onSave;

  const AddBucketItemForm({super.key, required this.onSave});

  @override
  State<AddBucketItemForm> createState() => _AddBucketItemFormState();
}

class _AddBucketItemFormState extends State<AddBucketItemForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  String _selectedCategory = 'Romantic';
  String _selectedDifficulty = 'Easy';
  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addImage() {
    // TODO: Implement image picker
    ToastService.showInfo(context, 'Image picker coming soon! 📸');
  }

  void _saveBucketItem() {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ToastService.showWarning(context, 'Please fill in all fields! 📝');
      return;
    }

    widget.onSave(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      _selectedDate,
      _selectedCategory,
      _selectedDifficulty,
      _selectedImage,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Text(
            'Add Bucket List Item',
            style: BabyFont.headingM.copyWith(
              fontSize: 20.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),

          // Title Input
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Item Title',
              hintText: 'e.g., Watch Sunrise Together',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Description Input
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your dream...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Category Selection
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            items: [
              'Romantic',
              'Adventure',
              'Fun',
              'Travel',
              'Food',
              'Creative',
              'Learning',
              'Giving'
            ]
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),

          SizedBox(height: 16.h),

          // Difficulty Selection
          DropdownButtonFormField<String>(
            value: _selectedDifficulty,
            decoration: InputDecoration(
              labelText: 'Difficulty',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            items: ['Easy', 'Medium', 'Hard']
                .map((difficulty) => DropdownMenuItem(
                      value: difficulty,
                      child: Text(difficulty),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDifficulty = value!;
              });
            },
          ),

          SizedBox(height: 16.h),

          // Image Section
          Row(
            children: [
              Text('Image (Optional)'),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addImage,
                icon: Icon(Icons.add_a_photo),
                label: Text('Add Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentYellow,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          if (_selectedImage != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 120.h,
                fit: BoxFit.cover,
              ),
            ),
          ],

          SizedBox(height: 16.h),

          // Date Selection
          ListTile(
            title: Text('Target Date'),
            subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),

          const Spacer(),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveBucketItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentYellow,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Add to Bucket List',
                style: BabyFont.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
