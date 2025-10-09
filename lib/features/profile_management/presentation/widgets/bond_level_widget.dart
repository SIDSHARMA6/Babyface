import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/bond_level_service.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Bond level widget for profile screen
class BondLevelWidget extends StatefulWidget {
  const BondLevelWidget({super.key});

  @override
  State<BondLevelWidget> createState() => _BondLevelWidgetState();
}

class _BondLevelWidgetState extends State<BondLevelWidget> {
  final BondLevelService _bondLevelService = BondLevelService.instance;
  BondLevel? _currentLevel;
  Map<String, dynamic> _statistics = {};
  List<XPActivity> _recentActivities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBondLevelData();
  }

  Future<void> _loadBondLevelData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final level = await _bondLevelService.getCurrentLevel();
      final stats = await _bondLevelService.getBondLevelStatistics();
      final activities = await _bondLevelService.getXPActivities(limit: 5);

      setState(() {
        _currentLevel = level;
        _statistics = stats;
        _recentActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: AppTheme.primaryPink,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bond Level',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Track your relationship progress',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showLevelDetails,
                icon: Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryPink,
              ),
            )
          else if (_currentLevel == null)
            _buildEmptyState()
          else
            _buildBondLevelContent(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.favorite_border,
          size: 48.w,
          color: AppTheme.textSecondary,
        ),
        SizedBox(height: 12.h),
        Text(
          'Start your journey together!',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Complete activities together to level up your bond',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: _showEarnXPDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text('Earn XP'),
        ),
      ],
    );
  }

  Widget _buildBondLevelContent() {
    return Column(
      children: [
        // Level display
        _buildLevelDisplay(),
        SizedBox(height: 16.h),

        // XP progress bar
        _buildXPProgressBar(),
        SizedBox(height: 16.h),

        // Statistics
        _buildStatistics(),
        SizedBox(height: 16.h),

        // Recent activities
        if (_recentActivities.isNotEmpty) ...[
          _buildRecentActivities(),
          SizedBox(height: 16.h),
        ],

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _showEarnXPDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  side: BorderSide(color: AppTheme.primaryPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Earn XP'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _showLevelDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('View Details'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelDisplay() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.primaryPink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Level emoji and number
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryPink,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentLevel!.emoji,
                  style: TextStyle(fontSize: 20.sp),
                ),
                Text(
                  'Lv.${_currentLevel!.level}',
                  style: BabyFont.bodyS.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),

          // Level info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentLevel!.title,
                  style: BabyFont.headingM.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _currentLevel!.description,
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${_currentLevel!.currentXP} XP',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPProgressBar() {
    final progress = _statistics['levelProgress'] ?? 0.0;
    final xpToNext = _statistics['xpToNextLevel'] ?? 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress to Next Level',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.textSecondary.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
          minHeight: 8.h,
        ),
        SizedBox(height: 4.h),
        Text(
          '${_currentLevel!.currentXP % _getXPRequiredForLevel(_currentLevel!.level)} / $xpToNext XP',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final totalXP = _statistics['totalXP'] ?? 0;
    final totalActivities = _statistics['totalActivities'] ?? 0;
    final xpThisWeek = _statistics['xpThisWeek'] ?? 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total XP',
              totalXP.toString(),
              Icons.star,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Activities',
              totalActivities.toString(),
              Icons.check_circle,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'This Week',
              xpThisWeek.toString(),
              Icons.trending_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16.w,
          color: AppTheme.primaryPink,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: BabyFont.headingS.copyWith(
            color: AppTheme.primaryPink,
          ),
        ),
        Text(
          label,
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        ...(_recentActivities.map((activity) => _buildActivityItem(activity))),
      ],
    );
  }

  Widget _buildActivityItem(XPActivity activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _getActivityIcon(activity.activityType),
              color: AppTheme.primaryPink,
              size: 16.w,
            ),
          ),
          SizedBox(width: 12.w),

          // Activity info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatDate(activity.createdAt),
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // XP earned
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '+${activity.xpEarned} XP',
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'mood_entry':
        return Icons.mood;
      case 'love_note':
        return Icons.favorite;
      case 'photo_added':
        return Icons.photo;
      case 'quiz_completed':
        return Icons.quiz;
      case 'anniversary_event':
        return Icons.event;
      case 'memory_created':
        return Icons.memory;
      case 'challenge_completed':
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  int _getXPRequiredForLevel(int level) {
    if (level <= 1) return 100;
    if (level <= 2) return 200;
    if (level <= 3) return 300;
    if (level <= 4) return 400;
    if (level <= 5) return 500;
    if (level <= 10) return 1000;
    if (level <= 20) return 2000;
    if (level <= 30) return 3000;
    if (level <= 40) return 4000;
    if (level <= 50) return 5000;
    return 5000;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showEarnXPDialog() {
    showDialog(
      context: context,
      builder: (context) => EarnXPDialog(
        onXPEarned: () {
          _loadBondLevelData();
        },
      ),
    );
  }

  void _showLevelDetails() {
    showDialog(
      context: context,
      builder: (context) => LevelDetailsDialog(
        currentLevel: _currentLevel!,
        statistics: _statistics,
      ),
    );
  }
}

/// Earn XP dialog
class EarnXPDialog extends StatefulWidget {
  final VoidCallback onXPEarned;

  const EarnXPDialog({
    super.key,
    required this.onXPEarned,
  });

  @override
  State<EarnXPDialog> createState() => _EarnXPDialogState();
}

class _EarnXPDialogState extends State<EarnXPDialog> {
  final BondLevelService _bondLevelService = BondLevelService.instance;
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedActivityType = 'mood_entry';
  int _selectedXPAmount = 10;

  final List<Map<String, dynamic>> _activities = [
    {'type': 'mood_entry', 'name': 'Mood Entry', 'xp': 10, 'emoji': '😊'},
    {'type': 'love_note', 'name': 'Love Note', 'xp': 15, 'emoji': '💌'},
    {'type': 'photo_added', 'name': 'Photo Added', 'xp': 20, 'emoji': '📸'},
    {
      'type': 'quiz_completed',
      'name': 'Quiz Completed',
      'xp': 25,
      'emoji': '🧠'
    },
    {
      'type': 'anniversary_event',
      'name': 'Anniversary Event',
      'xp': 30,
      'emoji': '🎉'
    },
    {
      'type': 'memory_created',
      'name': 'Memory Created',
      'xp': 15,
      'emoji': '💝'
    },
    {
      'type': 'challenge_completed',
      'name': 'Challenge Completed',
      'xp': 50,
      'emoji': '🏆'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Earn XP'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Activity selection
            Text(
              'What did you do together?',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildActivityGrid(),
            SizedBox(height: 20.h),

            // Description input
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe what you did together...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16.h),

            // XP amount
            Text(
              'XP Amount: $_selectedXPAmount',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            Slider(
              value: _selectedXPAmount.toDouble(),
              min: 5,
              max: 100,
              divisions: 19,
              activeColor: AppTheme.primaryPink,
              onChanged: (value) {
                setState(() {
                  _selectedXPAmount = value.round();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _descriptionController.text.isNotEmpty ? _earnXP : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
          ),
          child: Text('Earn XP'),
        ),
      ],
    );
  }

  Widget _buildActivityGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        final isSelected = _selectedActivityType == activity['type'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedActivityType = activity['type'];
              _selectedXPAmount = activity['xp'];
            });
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryPink.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryPink
                    : AppTheme.textSecondary.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  activity['emoji'],
                  style: TextStyle(fontSize: 20.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  activity['name'],
                  style: BabyFont.bodyS.copyWith(
                    color: isSelected
                        ? AppTheme.primaryPink
                        : AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${activity['xp']} XP',
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _earnXP() async {
    try {
      final success = await _bondLevelService.addXP(
        _selectedActivityType,
        _descriptionController.text,
        _selectedXPAmount,
      );

      if (success && mounted) {
        Navigator.pop(context);
        widget.onXPEarned();
        ToastService.showSuccess(context, 'Earned $_selectedXPAmount XP! ⭐');
      } else {
        ToastService.showError(context, 'Failed to earn XP');
      }
    } catch (e) {
      ToastService.showError(context, 'Failed to earn XP: ${e.toString()}');
    }
  }
}

/// Level details dialog
class LevelDetailsDialog extends StatelessWidget {
  final BondLevel currentLevel;
  final Map<String, dynamic> statistics;

  const LevelDetailsDialog({
    super.key,
    required this.currentLevel,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Level Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current level info
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPink.withValues(alpha: 0.1),
                    AppTheme.primaryPink.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    currentLevel.emoji,
                    style: TextStyle(fontSize: 48.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Level ${currentLevel.level}',
                    style: BabyFont.headingM.copyWith(
                      color: AppTheme.primaryPink,
                    ),
                  ),
                  Text(
                    currentLevel.title,
                    style: BabyFont.bodyM.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    currentLevel.description,
                    style: BabyFont.bodyS.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Unlocked features
            if (currentLevel.unlockedFeatures.isNotEmpty) ...[
              Text(
                'Unlocked Features',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              ...(currentLevel.unlockedFeatures.map((feature) => Container(
                    margin: EdgeInsets.only(bottom: 4.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryPink,
                          size: 16.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          feature,
                          style: BabyFont.bodyS.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ))),
              SizedBox(height: 16.h),
            ],

            // Statistics
            Text(
              'Statistics',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            _buildStatRow('Total XP', '${statistics['totalXP'] ?? 0}'),
            _buildStatRow(
                'Total Activities', '${statistics['totalActivities'] ?? 0}'),
            _buildStatRow('XP This Week', '${statistics['xpThisWeek'] ?? 0}'),
            _buildStatRow('XP This Month', '${statistics['xpThisMonth'] ?? 0}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
