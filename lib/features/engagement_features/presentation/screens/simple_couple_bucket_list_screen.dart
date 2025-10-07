import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class CoupleBucketListScreen extends StatefulWidget {
  const CoupleBucketListScreen({super.key});

  @override
  State<CoupleBucketListScreen> createState() => _CoupleBucketListScreenState();
}

class _CoupleBucketListScreenState extends State<CoupleBucketListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<BucketItem> _bucketItems = [];
  String _selectedCategory = 'All';

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

    _initializeBucketList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeBucketList() {
    _bucketItems = [
      BucketItem(
        id: '1',
        title: 'Watch Sunrise Together 🌅',
        description:
            'Wake up early and watch the sunrise from a beautiful location',
        category: 'Romantic',
        difficulty: 'Easy',
        isCompleted: true,
        isFavorite: true,
      ),
      BucketItem(
        id: '2',
        title: 'Learn to Dance 💃',
        description: 'Take ballroom dancing lessons together',
        category: 'Fun',
        difficulty: 'Medium',
        isCompleted: false,
        isFavorite: true,
      ),
      BucketItem(
        id: '3',
        title: 'Go Skydiving 🪂',
        description: 'Experience the ultimate adrenaline rush together',
        category: 'Adventure',
        difficulty: 'Hard',
        isCompleted: false,
        isFavorite: false,
      ),
      BucketItem(
        id: '4',
        title: 'Cook a 5-Course Meal 👨‍🍳',
        description: 'Plan and cook an elaborate dinner together',
        category: 'Food',
        difficulty: 'Medium',
        isCompleted: false,
        isFavorite: true,
      ),
      BucketItem(
        id: '5',
        title: 'Visit All 7 Continents 🌍',
        description: 'Travel to every continent together',
        category: 'Travel',
        difficulty: 'Hard',
        isCompleted: false,
        isFavorite: false,
      ),
      BucketItem(
        id: '6',
        title: 'Write a Song Together 🎵',
        description: 'Compose and record a love song',
        category: 'Creative',
        difficulty: 'Medium',
        isCompleted: true,
        isFavorite: true,
      ),
      BucketItem(
        id: '7',
        title: 'Go Camping Under the Stars ⭐',
        description: 'Spend a night camping and stargazing',
        category: 'Adventure',
        difficulty: 'Easy',
        isCompleted: false,
        isFavorite: true,
      ),
      BucketItem(
        id: '8',
        title: 'Learn a New Language 🗣️',
        description: 'Become fluent in a foreign language together',
        category: 'Learning',
        difficulty: 'Hard',
        isCompleted: false,
        isFavorite: false,
      ),
      BucketItem(
        id: '9',
        title: 'Volunteer Together 🤝',
        description: 'Help out at a local charity or community event',
        category: 'Giving',
        difficulty: 'Easy',
        isCompleted: true,
        isFavorite: true,
      ),
      BucketItem(
        id: '10',
        title: 'Build Something Together 🔨',
        description: 'Create a piece of furniture or art project',
        category: 'Creative',
        difficulty: 'Medium',
        isCompleted: false,
        isFavorite: false,
      ),
    ];
  }

  void _addBucketItem() {
    HapticFeedback.lightImpact();
    ToastService.showInfo(
        context, 'Add bucket list item feature coming soon! ✅');
  }

  void _toggleComplete(String id) {
    setState(() {
      final index = _bucketItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _bucketItems[index] = _bucketItems[index].copyWith(
          isCompleted: !_bucketItems[index].isCompleted,
        );
      }
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(context, 'Bucket list item updated! 🎉');
  }

  void _toggleFavorite(String id) {
    setState(() {
      final index = _bucketItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _bucketItems[index] = _bucketItems[index].copyWith(
          isFavorite: !_bucketItems[index].isFavorite,
        );
      }
    });

    HapticFeedback.selectionClick();
    ToastService.showLove(context, 'Added to favorites! 💕');
  }

  List<BucketItem> get _filteredItems {
    if (_selectedCategory == 'All') {
      return _bucketItems;
    }
    return _bucketItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  String _getDifficultyEmoji(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return '🟢';
      case 'Medium':
        return '🟡';
      case 'Hard':
        return '🔴';
      default:
        return '⚪';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return AppTheme.accentYellow;
      case 'Hard':
        return AppTheme.primaryPink;
      default:
        return Colors.grey;
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
          'Couple Bucket List ✅',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addBucketItem,
            icon: Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryPink,
              size: 24.w,
            ),
          ),
        ],
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
                    color: AppTheme.accentYellow.withValues(alpha: 0.1),
                    blurRadius: 15.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${_bucketItems.length}', 'Total Items',
                      Icons.list, AppTheme.accentYellow),
                  _buildStatItem(
                      '${_bucketItems.where((item) => item.isCompleted).length}',
                      'Completed',
                      Icons.check_circle,
                      AppTheme.primaryPink),
                  _buildStatItem(
                      '${_bucketItems.where((item) => item.isFavorite).length}',
                      'Favorites',
                      Icons.favorite,
                      AppTheme.primaryBlue),
                ],
              ),
            ),

            // Category Filter
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              height: 40.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  'All',
                  'Romantic',
                  'Adventure',
                  'Fun',
                  'Travel',
                  'Food',
                  'Creative',
                  'Learning',
                  'Giving',
                ].map((category) => _buildCategoryChip(category)).toList(),
              ),
            ),

            SizedBox(height: 20.h),

            // Bucket List Items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return _buildBucketItemCard(item);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBucketItem,
        backgroundColor: AppTheme.accentYellow,
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

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentYellow
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentYellow
                : Colors.grey.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
        child: Text(
          category,
          style: BabyFont.bodyS.copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBucketItemCard(BucketItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: item.isCompleted
                ? AppTheme.primaryPink.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
        border: item.isCompleted
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
                  item.title,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    decoration:
                        item.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleFavorite(item.id),
                    child: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          item.isFavorite ? AppTheme.primaryPink : Colors.grey,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (item.isCompleted)
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
            item.description,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildCategoryChip(item.category),
              SizedBox(width: 8.w),
              _buildDifficultyChip(item.difficulty),
              const Spacer(),
              GestureDetector(
                onTap: () => _toggleComplete(item.id),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: item.isCompleted
                        ? AppTheme.primaryPink
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isCompleted ? Icons.check : Icons.add,
                        color: item.isCompleted ? Colors.white : Colors.grey,
                        size: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item.isCompleted ? 'Done' : 'Add',
                        style: BabyFont.bodyS.copyWith(
                          color: item.isCompleted ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    final color = _getDifficultyColor(difficulty);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getDifficultyEmoji(difficulty),
            style: TextStyle(fontSize: 12.sp),
          ),
          SizedBox(width: 4.w),
          Text(
            difficulty,
            style: BabyFont.bodyS.copyWith(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class BucketItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final bool isCompleted;
  final bool isFavorite;

  BucketItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.isCompleted,
    required this.isFavorite,
  });

  BucketItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? difficulty,
    bool? isCompleted,
    bool? isFavorite,
  }) {
    return BucketItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
