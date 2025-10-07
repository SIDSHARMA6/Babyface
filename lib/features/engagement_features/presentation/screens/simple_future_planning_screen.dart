import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class FuturePlanningScreen extends StatefulWidget {
  const FuturePlanningScreen({super.key});

  @override
  State<FuturePlanningScreen> createState() => _FuturePlanningScreenState();
}

class _FuturePlanningScreenState extends State<FuturePlanningScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<FutureGoal> _goals = [];
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

    _initializeGoals();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeGoals() {
    _goals = [
      FutureGoal(
        id: '1',
        title: 'Buy Our Dream Home 🏠',
        description: 'Save for a house with a garden and a nursery',
        category: 'Housing',
        priority: 'High',
        targetDate: DateTime.now().add(const Duration(days: 365)),
        isCompleted: false,
        progress: 35,
      ),
      FutureGoal(
        id: '2',
        title: 'Plan Our Wedding 💒',
        description: 'Organize the perfect wedding ceremony',
        category: 'Wedding',
        priority: 'High',
        targetDate: DateTime.now().add(const Duration(days: 180)),
        isCompleted: false,
        progress: 60,
      ),
      FutureGoal(
        id: '3',
        title: 'Travel to Europe ✈️',
        description: 'Visit Paris, Rome, and Barcelona together',
        category: 'Travel',
        priority: 'Medium',
        targetDate: DateTime.now().add(const Duration(days: 240)),
        isCompleted: false,
        progress: 20,
      ),
      FutureGoal(
        id: '4',
        title: 'Start a Family 👶',
        description: 'Prepare for having our first child',
        category: 'Family',
        priority: 'High',
        targetDate: DateTime.now().add(const Duration(days: 540)),
        isCompleted: false,
        progress: 10,
      ),
      FutureGoal(
        id: '5',
        title: 'Learn a New Language 🗣️',
        description: 'Take Spanish classes together',
        category: 'Personal',
        priority: 'Low',
        targetDate: DateTime.now().add(const Duration(days: 120)),
        isCompleted: true,
        progress: 100,
      ),
      FutureGoal(
        id: '6',
        title: 'Start a Business 💼',
        description: 'Launch our own consulting company',
        category: 'Career',
        priority: 'Medium',
        targetDate: DateTime.now().add(const Duration(days: 720)),
        isCompleted: false,
        progress: 5,
      ),
    ];
  }

  void _addGoal() {
    HapticFeedback.lightImpact();
    ToastService.showInfo(context, 'Add goal feature coming soon! 🎯');
  }

  void _toggleGoalComplete(String id) {
    setState(() {
      final index = _goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _goals[index] = _goals[index].copyWith(
          isCompleted: !_goals[index].isCompleted,
          progress: _goals[index].isCompleted ? 0 : 100,
        );
      }
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(context, 'Goal updated! Keep going! 🎉');
  }

  void _updateProgress(String id, int progress) {
    setState(() {
      final index = _goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _goals[index] = _goals[index].copyWith(progress: progress);
      }
    });

    HapticFeedback.lightImpact();
    ToastService.showInfo(context, 'Progress updated! 📈');
  }

  List<FutureGoal> get _filteredGoals {
    if (_selectedCategory == 'All') {
      return _goals;
    }
    return _goals.where((goal) => goal.category == _selectedCategory).toList();
  }

  String _getPriorityEmoji(String priority) {
    switch (priority) {
      case 'High':
        return '🔴';
      case 'Medium':
        return '🟡';
      case 'Low':
        return '🟢';
      default:
        return '⚪';
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
          'Future Planning 🚀',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addGoal,
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
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 15.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${_goals.length}', 'Total Goals', Icons.flag,
                      AppTheme.primaryBlue),
                  _buildStatItem('${_goals.where((g) => g.isCompleted).length}',
                      'Completed', Icons.check_circle, AppTheme.primaryPink),
                  _buildStatItem(
                      '${_goals.where((g) => !g.isCompleted).length}',
                      'In Progress',
                      Icons.trending_up,
                      AppTheme.accentYellow),
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
                  'Housing',
                  'Wedding',
                  'Travel',
                  'Family',
                  'Personal',
                  'Career',
                ].map((category) => _buildCategoryChip(category)).toList(),
              ),
            ),

            SizedBox(height: 20.h),

            // Goals List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _filteredGoals.length,
                itemBuilder: (context, index) {
                  final goal = _filteredGoals[index];
                  return _buildGoalCard(goal);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        backgroundColor: AppTheme.primaryBlue,
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
              ? AppTheme.primaryBlue
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
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

  Widget _buildGoalCard(FutureGoal goal) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: goal.isCompleted
                ? AppTheme.primaryPink.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
        border: goal.isCompleted
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
                  goal.title,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    _getPriorityEmoji(goal.priority),
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(width: 8.w),
                  if (goal.isCompleted)
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
            goal.description,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildCategoryChip(goal.category),
              SizedBox(width: 8.w),
              Text(
                'Due: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: BabyFont.bodyS.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  Text(
                    '${goal.progress}%',
                    style: BabyFont.bodyS.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              LinearProgressIndicator(
                value: goal.progress / 100,
                backgroundColor: Colors.grey.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation(
                  goal.isCompleted
                      ? AppTheme.primaryPink
                      : AppTheme.primaryBlue,
                ),
                minHeight: 6.h,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _toggleGoalComplete(goal.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goal.isCompleted
                        ? Colors.grey.withValues(alpha: 0.3)
                        : AppTheme.primaryPink,
                    foregroundColor:
                        goal.isCompleted ? Colors.grey : Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    goal.isCompleted ? 'Completed ✓' : 'Mark Complete',
                    style: BabyFont.bodyS.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              if (!goal.isCompleted)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateProgress(
                        goal.id, (goal.progress + 10).clamp(0, 100)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: Text(
                      'Update',
                      style: BabyFont.bodyS.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class FutureGoal {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final DateTime targetDate;
  final bool isCompleted;
  final int progress;

  FutureGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.targetDate,
    required this.isCompleted,
    required this.progress,
  });

  FutureGoal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? targetDate,
    bool? isCompleted,
    int? progress,
  }) {
    return FutureGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }
}
