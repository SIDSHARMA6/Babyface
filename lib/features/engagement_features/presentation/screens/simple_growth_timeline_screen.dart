import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class GrowthTimelineScreen extends StatefulWidget {
  const GrowthTimelineScreen({super.key});

  @override
  State<GrowthTimelineScreen> createState() => _GrowthTimelineScreenState();
}

class _GrowthTimelineScreenState extends State<GrowthTimelineScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<GrowthMilestone> _milestones = [];
  int _currentWeek = 0;

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

    _initializeMilestones();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeMilestones() {
    _milestones = [
      GrowthMilestone(
        week: 4,
        title: 'Heartbeat Begins 💓',
        description:
            'Your baby\'s heart starts beating! It\'s the size of a poppy seed.',
        isCompleted: true,
        size: 'Poppy Seed',
        development: 'Heart formation begins',
      ),
      GrowthMilestone(
        week: 8,
        title: 'Tiny Limbs Form 👶',
        description:
            'Arms and legs start developing. Baby is the size of a raspberry.',
        isCompleted: true,
        size: 'Raspberry',
        development: 'Limb buds appear',
      ),
      GrowthMilestone(
        week: 12,
        title: 'Fingerprints Form 👆',
        description: 'Unique fingerprints develop. Baby is the size of a lime.',
        isCompleted: true,
        size: 'Lime',
        development: 'Fingerprints and nails form',
      ),
      GrowthMilestone(
        week: 16,
        title: 'Hair Starts Growing 💇',
        description:
            'First hair appears on the scalp. Baby is the size of an avocado.',
        isCompleted: false,
        size: 'Avocado',
        development: 'Hair follicles develop',
      ),
      GrowthMilestone(
        week: 20,
        title: 'Can Hear Your Voice 👂',
        description:
            'Baby can hear your voice and heartbeat. Size of a banana.',
        isCompleted: false,
        size: 'Banana',
        development: 'Hearing develops',
      ),
      GrowthMilestone(
        week: 24,
        title: 'Eyes Open 👀',
        description:
            'Eyelids open for the first time. Baby is the size of an ear of corn.',
        isCompleted: false,
        size: 'Ear of Corn',
        development: 'Vision begins',
      ),
      GrowthMilestone(
        week: 28,
        title: 'Dreams Begin 💭',
        description:
            'Baby starts having REM sleep and dreams. Size of a large eggplant.',
        isCompleted: false,
        size: 'Large Eggplant',
        development: 'Brain activity increases',
      ),
      GrowthMilestone(
        week: 32,
        title: 'Practice Breathing 🫁',
        description: 'Baby practices breathing movements. Size of a jicama.',
        isCompleted: false,
        size: 'Jicama',
        development: 'Lung development',
      ),
      GrowthMilestone(
        week: 36,
        title: 'Ready to Meet You 👶',
        description:
            'Baby is fully developed and ready for birth! Size of a head of romaine lettuce.',
        isCompleted: false,
        size: 'Head of Romaine Lettuce',
        development: 'Full development',
      ),
    ];

    _currentWeek = 14; // Sample current week
  }

  void _markMilestoneComplete(int week) {
    setState(() {
      final index = _milestones.indexWhere((m) => m.week == week);
      if (index != -1) {
        _milestones[index] = _milestones[index].copyWith(isCompleted: true);
      }
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(
        context, 'Milestone completed! Amazing progress! 🎉');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Growth Timeline 📈',
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
            // Current Progress
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
              child: Column(
                children: [
                  Text(
                    'Current Progress',
                    style: BabyFont.headingM.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressItem('Week $_currentWeek', 'Current Week',
                          Icons.calendar_today, AppTheme.primaryBlue),
                      _buildProgressItem(
                          '${_milestones.where((m) => m.isCompleted).length}',
                          'Milestones',
                          Icons.flag,
                          AppTheme.primaryPink),
                      _buildProgressItem('${_milestones.length}', 'Total',
                          Icons.timeline, AppTheme.accentYellow),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  LinearProgressIndicator(
                    value: _currentWeek / 40,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
                    minHeight: 8.h,
                  ),
                ],
              ),
            ),

            // Timeline
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _milestones.length,
                itemBuilder: (context, index) {
                  final milestone = _milestones[index];
                  final isCurrent = milestone.week == _currentWeek;
                  final isUpcoming = milestone.week > _currentWeek;

                  return _buildMilestoneCard(milestone, isCurrent, isUpcoming);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
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

  Widget _buildMilestoneCard(
      GrowthMilestone milestone, bool isCurrent, bool isUpcoming) {
    Color cardColor;
    Color borderColor;

    if (milestone.isCompleted) {
      cardColor = AppTheme.primaryPink.withValues(alpha: 0.1);
      borderColor = AppTheme.primaryPink;
    } else if (isCurrent) {
      cardColor = AppTheme.primaryBlue.withValues(alpha: 0.1);
      borderColor = AppTheme.primaryBlue;
    } else if (isUpcoming) {
      cardColor = Colors.grey.withValues(alpha: 0.1);
      borderColor = Colors.grey.withValues(alpha: 0.3);
    } else {
      cardColor = Colors.white;
      borderColor = Colors.grey.withValues(alpha: 0.3);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.1),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Week ${milestone.week}',
                  style: BabyFont.bodyS.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  milestone.title,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              if (milestone.isCompleted)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryPink,
                  size: 24.w,
                )
              else if (isCurrent)
                Icon(
                  Icons.play_circle,
                  color: AppTheme.primaryBlue,
                  size: 24.w,
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            milestone.description,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildInfoChip('Size: ${milestone.size}', Icons.straighten,
                  AppTheme.accentYellow),
              SizedBox(width: 8.w),
              _buildInfoChip(milestone.development, Icons.psychology,
                  AppTheme.primaryBlue),
            ],
          ),
          if (!milestone.isCompleted && !isUpcoming) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markMilestoneComplete(milestone.week),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  'Mark Complete',
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

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.w),
          SizedBox(width: 4.w),
          Text(
            text,
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

class GrowthMilestone {
  final int week;
  final String title;
  final String description;
  final bool isCompleted;
  final String size;
  final String development;

  GrowthMilestone({
    required this.week,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.size,
    required this.development,
  });

  GrowthMilestone copyWith({
    int? week,
    String? title,
    String? description,
    bool? isCompleted,
    String? size,
    String? development,
  }) {
    return GrowthMilestone(
      week: week ?? this.week,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      size: size ?? this.size,
      development: development ?? this.development,
    );
  }
}
