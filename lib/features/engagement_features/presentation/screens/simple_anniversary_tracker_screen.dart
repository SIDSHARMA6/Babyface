import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class AnniversaryTrackerScreen extends StatefulWidget {
  const AnniversaryTrackerScreen({super.key});

  @override
  State<AnniversaryTrackerScreen> createState() =>
      _AnniversaryTrackerScreenState();
}

class _AnniversaryTrackerScreenState extends State<AnniversaryTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Anniversary> _anniversaries = [];
  final DateTime _relationshipStartDate =
      DateTime.now().subtract(const Duration(days: 365));

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

    _initializeAnniversaries();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnniversaries() {
    _anniversaries = [
      Anniversary(
        id: '1',
        title: 'First Date 💕',
        date: DateTime.now().subtract(const Duration(days: 365)),
        type: 'Relationship',
        isRecurring: true,
        isCompleted: true,
      ),
      Anniversary(
        id: '2',
        title: 'First Kiss 💋',
        date: DateTime.now().subtract(const Duration(days: 360)),
        type: 'Milestone',
        isRecurring: false,
        isCompleted: true,
      ),
      Anniversary(
        id: '3',
        title: 'First "I Love You" 💝',
        date: DateTime.now().subtract(const Duration(days: 300)),
        type: 'Milestone',
        isRecurring: false,
        isCompleted: true,
      ),
      Anniversary(
        id: '4',
        title: 'First Trip Together ✈️',
        date: DateTime.now().subtract(const Duration(days: 200)),
        type: 'Experience',
        isRecurring: false,
        isCompleted: true,
      ),
      Anniversary(
        id: '5',
        title: 'Moving In Together 🏠',
        date: DateTime.now().subtract(const Duration(days: 100)),
        type: 'Milestone',
        isRecurring: false,
        isCompleted: true,
      ),
      Anniversary(
        id: '6',
        title: '1 Year Anniversary 🎉',
        date: DateTime.now().add(const Duration(days: 0)),
        type: 'Relationship',
        isRecurring: true,
        isCompleted: false,
      ),
      Anniversary(
        id: '7',
        title: 'Valentine\'s Day 💘',
        date: DateTime(DateTime.now().year, 2, 14),
        type: 'Holiday',
        isRecurring: true,
        isCompleted: false,
      ),
    ];
  }

  void _addAnniversary() {
    HapticFeedback.lightImpact();
    ToastService.showInfo(context, 'Add anniversary feature coming soon! 📅');
  }

  void _markAnniversaryComplete(String id) {
    setState(() {
      final index = _anniversaries.indexWhere((a) => a.id == id);
      if (index != -1) {
        _anniversaries[index] =
            _anniversaries[index].copyWith(isCompleted: true);
      }
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(context, 'Anniversary celebrated! 🎉');
  }

  String _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return '${-difference} days ago';
    } else if (difference == 0) {
      return 'Today!';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '$difference days';
    }
  }

  String _getAnniversaryTypeEmoji(String type) {
    switch (type) {
      case 'Relationship':
        return '💕';
      case 'Milestone':
        return '🎯';
      case 'Experience':
        return '🌟';
      case 'Holiday':
        return '🎊';
      default:
        return '📅';
    }
  }

  Color _getAnniversaryTypeColor(String type) {
    switch (type) {
      case 'Relationship':
        return AppTheme.primaryPink;
      case 'Milestone':
        return AppTheme.primaryBlue;
      case 'Experience':
        return AppTheme.accentYellow;
      case 'Holiday':
        return Colors.purple;
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
          'Anniversary Tracker 💍',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addAnniversary,
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
            // Relationship Stats
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
              child: Column(
                children: [
                  Text(
                    'Relationship Timeline',
                    style: BabyFont.headingM.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          '${DateTime.now().difference(_relationshipStartDate).inDays}',
                          'Days Together',
                          Icons.favorite,
                          AppTheme.primaryPink),
                      _buildStatItem(
                          '${_anniversaries.where((a) => a.isCompleted).length}',
                          'Celebrated',
                          Icons.celebration,
                          AppTheme.accentYellow),
                      _buildStatItem(
                          '${_anniversaries.where((a) => !a.isCompleted).length}',
                          'Upcoming',
                          Icons.schedule,
                          AppTheme.primaryBlue),
                    ],
                  ),
                ],
              ),
            ),

            // Anniversaries List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _anniversaries.length,
                itemBuilder: (context, index) {
                  final anniversary = _anniversaries[index];
                  return _buildAnniversaryCard(anniversary);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAnniversary,
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

  Widget _buildAnniversaryCard(Anniversary anniversary) {
    final typeColor = _getAnniversaryTypeColor(anniversary.type);
    final typeEmoji = _getAnniversaryTypeEmoji(anniversary.type);
    final daysUntil = _getDaysUntil(anniversary.date);
    final isToday = anniversary.date.day == DateTime.now().day &&
        anniversary.date.month == DateTime.now().month;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isToday ? typeColor.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isToday ? typeColor : Colors.grey.withValues(alpha: 0.3),
          width: isToday ? 2.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                typeEmoji,
                style: TextStyle(fontSize: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  anniversary.title,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              if (anniversary.isCompleted)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryPink,
                  size: 24.w,
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildTypeChip(anniversary.type, typeColor),
              SizedBox(width: 8.w),
              if (anniversary.isRecurring) _buildRecurringChip(),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: typeColor,
                size: 16.w,
              ),
              SizedBox(width: 8.w),
              Text(
                '${anniversary.date.day}/${anniversary.date.month}/${anniversary.date.year}',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              const Spacer(),
              Text(
                daysUntil,
                style: BabyFont.bodyS.copyWith(
                  color: isToday ? typeColor : AppTheme.textSecondary,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          if (!anniversary.isCompleted && !isToday) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markAnniversaryComplete(anniversary.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  'Mark as Celebrated',
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

  Widget _buildTypeChip(String type, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        type,
        style: BabyFont.bodyS.copyWith(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecurringChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        'Recurring',
        style: BabyFont.bodyS.copyWith(
          color: AppTheme.accentYellow,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class Anniversary {
  final String id;
  final String title;
  final DateTime date;
  final String type;
  final bool isRecurring;
  final bool isCompleted;

  Anniversary({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.isRecurring,
    required this.isCompleted,
  });

  Anniversary copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? type,
    bool? isRecurring,
    bool? isCompleted,
  }) {
    return Anniversary(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
