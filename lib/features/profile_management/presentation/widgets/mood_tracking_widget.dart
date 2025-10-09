import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/mood_tracking_service.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Mood tracking widget for profile screen
class MoodTrackingWidget extends StatefulWidget {
  const MoodTrackingWidget({super.key});

  @override
  State<MoodTrackingWidget> createState() => _MoodTrackingWidgetState();
}

class _MoodTrackingWidgetState extends State<MoodTrackingWidget> {
  final MoodTrackingService _moodService = MoodTrackingService.instance;
  List<MoodEntry> _recentEntries = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _moodService.getAllMoodEntries();
      final stats = await _moodService.getMoodStatistics();

      setState(() {
        _recentEntries = entries.take(5).toList();
        _statistics = stats;
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
                  Icons.mood,
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
                      'Mood Tracker',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Track your daily emotions together',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showAddMoodDialog,
                icon: Icon(
                  Icons.add_circle_outline,
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
          else if (_recentEntries.isEmpty)
            _buildEmptyState()
          else
            _buildMoodContent(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.mood_outlined,
          size: 48.w,
          color: AppTheme.textSecondary,
        ),
        SizedBox(height: 12.h),
        Text(
          'No mood entries yet',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Start tracking your emotions together!',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: _showAddMoodDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text('Add First Mood'),
        ),
      ],
    );
  }

  Widget _buildMoodContent() {
    return Column(
      children: [
        // Statistics
        _buildStatistics(),
        SizedBox(height: 16.h),

        // Recent entries
        _buildRecentEntries(),
        SizedBox(height: 16.h),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _showAddMoodDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  side: BorderSide(color: AppTheme.primaryPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Add Mood'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _showMoodHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('View History'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final totalEntries = _statistics['totalEntries'] ?? 0;
    final averageIntensity = _statistics['averageIntensity'] ?? 0.0;
    final mostCommonMood = _statistics['mostCommonMood'] ?? 'neutral';

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
              'Total Entries',
              totalEntries.toString(),
              Icons.analytics,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Avg Intensity',
              averageIntensity.toStringAsFixed(1),
              Icons.speed,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Most Common',
              _getMoodEmoji(mostCommonMood),
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

  Widget _buildRecentEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Entries',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        ...(_recentEntries.map((entry) => _buildMoodEntryItem(entry))),
      ],
    );
  }

  Widget _buildMoodEntryItem(MoodEntry entry) {
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
          Text(
            entry.mood.emoji,
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.mood.displayName,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (entry.note != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    entry.note!,
                    style: BabyFont.bodyS.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${entry.intensity}/10',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.primaryPink,
                ),
              ),
              Text(
                _formatDate(entry.createdAt),
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(String moodName) {
    try {
      final mood = MoodType.values.firstWhere((m) => m.name == moodName);
      return mood.emoji;
    } catch (e) {
      return '😐';
    }
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

  void _showAddMoodDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMoodDialog(
        onMoodAdded: () {
          _loadMoodData();
        },
      ),
    );
  }

  void _showMoodHistory() {
    showDialog(
      context: context,
      builder: (context) => MoodHistoryDialog(),
    );
  }
}

/// Add mood dialog
class AddMoodDialog extends StatefulWidget {
  final VoidCallback onMoodAdded;

  const AddMoodDialog({
    super.key,
    required this.onMoodAdded,
  });

  @override
  State<AddMoodDialog> createState() => _AddMoodDialogState();
}

class _AddMoodDialogState extends State<AddMoodDialog> {
  final MoodTrackingService _moodService = MoodTrackingService.instance;
  final TextEditingController _noteController = TextEditingController();

  MoodType? _selectedMood;
  int _intensity = 5;
  List<String> _selectedEmotions = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Mood Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mood selection
            Text(
              'How are you feeling?',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildMoodGrid(),
            SizedBox(height: 20.h),

            // Intensity slider
            Text(
              'Intensity: $_intensity/10',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            Slider(
              value: _intensity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppTheme.primaryPink,
              onChanged: (value) {
                setState(() {
                  _intensity = value.round();
                });
              },
            ),
            SizedBox(height: 20.h),

            // Note input
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 3,
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
          onPressed: _selectedMood != null ? _saveMood : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
          ),
          child: Text('Save'),
        ),
      ],
    );
  }

  Widget _buildMoodGrid() {
    final moods = MoodType.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        final isSelected = _selectedMood == mood;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMood = mood;
            });
          },
          child: Container(
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
                  mood.emoji,
                  style: TextStyle(fontSize: 20.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  mood.displayName,
                  style: BabyFont.bodyS.copyWith(
                    color: isSelected
                        ? AppTheme.primaryPink
                        : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) return;

    try {
      final entry = MoodEntry(
        id: 'mood_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user', // TODO: Get from auth
        partnerId: 'partner_user', // TODO: Get from auth
        mood: _selectedMood!,
        intensity: _intensity,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        emotions: _selectedEmotions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _moodService.addMoodEntry(entry);
      if (success && mounted) {
        Navigator.pop(context);
        widget.onMoodAdded();
        ToastService.showSuccess(context, 'Mood entry added! 😊');
      } else {
        ToastService.showError(context, 'Failed to add mood entry');
      }
    } catch (e) {
      ToastService.showError(
          context, 'Failed to add mood entry: ${e.toString()}');
    }
  }
}

/// Mood history dialog
class MoodHistoryDialog extends StatefulWidget {
  @override
  State<MoodHistoryDialog> createState() => _MoodHistoryDialogState();
}

class _MoodHistoryDialogState extends State<MoodHistoryDialog> {
  final MoodTrackingService _moodService = MoodTrackingService.instance;
  List<MoodEntry> _entries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _moodService.getAllMoodEntries();
      setState(() {
        _entries = entries;
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
    return AlertDialog(
      title: Text('Mood History'),
      content: Container(
        width: double.maxFinite,
        height: 400.h,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink))
            : _entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mood_outlined,
                            size: 48.w, color: AppTheme.textSecondary),
                        SizedBox(height: 12.h),
                        Text('No mood entries yet',
                            style: BabyFont.bodyM
                                .copyWith(color: AppTheme.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return _buildHistoryItem(entry);
                    },
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

  Widget _buildHistoryItem(MoodEntry entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border:
            Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Text(entry.mood.emoji, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.mood.displayName, style: BabyFont.bodyM),
                if (entry.note != null) ...[
                  SizedBox(height: 2.h),
                  Text(entry.note!,
                      style: BabyFont.bodyS
                          .copyWith(color: AppTheme.textSecondary)),
                ],
                Text(
                  '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
                  style: BabyFont.bodyS.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text('${entry.intensity}/10',
              style: BabyFont.bodyS.copyWith(color: AppTheme.primaryPink)),
        ],
      ),
    );
  }
}
