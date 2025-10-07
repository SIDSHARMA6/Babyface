import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class GrowthMemoryTimelineScreen extends StatefulWidget {
  const GrowthMemoryTimelineScreen({super.key});

  @override
  State<GrowthMemoryTimelineScreen> createState() =>
      _GrowthMemoryTimelineScreenState();
}

class _GrowthMemoryTimelineScreenState extends State<GrowthMemoryTimelineScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<MemoryEntry> _memories = [];
  List<GrowthMilestone> _milestones = [];
  DateTime? _pregnancyDate;
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
        isCompleted: false,
        size: 'Poppy Seed',
        development: 'Heart formation begins',
      ),
      GrowthMilestone(
        week: 8,
        title: 'Tiny Limbs Form 👶',
        description:
            'Arms and legs start developing. Baby is the size of a raspberry.',
        isCompleted: false,
        size: 'Raspberry',
        development: 'Limb buds appear',
      ),
      GrowthMilestone(
        week: 12,
        title: 'Fingerprints Form 👆',
        description: 'Unique fingerprints develop. Baby is the size of a lime.',
        isCompleted: false,
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
  }

  void _showAddMemoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddMemoryBottomSheet(),
    );
  }

  void _showAddPregnancyDateDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildPregnancyDateDialog(),
    );
  }

  void _addMemory(
      String title, String description, DateTime date, List<File> photos) {
    final memory = MemoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date,
      photos: photos,
      isFavorite: false,
    );

    setState(() {
      _memories.insert(0, memory);
    });

    HapticFeedback.mediumImpact();
    ToastService.showLove(context, 'Memory added to our timeline! 📖💕');
  }

  void _addPregnancyDate(DateTime date) {
    setState(() {
      _pregnancyDate = date;
      _currentWeek = DateTime.now().difference(date).inDays ~/ 7;
    });

    HapticFeedback.lightImpact();
    ToastService.showBabyMessage(
        context, 'Pregnancy date added! Tracking week $_currentWeek 👶');
  }

  void _toggleMemoryFavorite(String id) {
    setState(() {
      final index = _memories.indexWhere((memory) => memory.id == id);
      if (index != -1) {
        _memories[index] = _memories[index].copyWith(
          isFavorite: !_memories[index].isFavorite,
        );
      }
    });

    HapticFeedback.selectionClick();
  }

  void _deleteMemory(String id) {
    setState(() {
      _memories.removeWhere((memory) => memory.id == id);
    });

    HapticFeedback.lightImpact();
    ToastService.showInfo(context, 'Memory deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Our Love Story 📖',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showAddMemoryBottomSheet,
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Pregnancy Progress (if set)
              if (_pregnancyDate != null) ...[
                _buildPregnancyProgress(),
                SizedBox(height: 20.h),
              ],

              // Add Pregnancy Date Button
              if (_pregnancyDate == null) _buildAddPregnancyDateCard(),

              SizedBox(height: 20.h),

              // Timeline
              _buildTimeline(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemoryBottomSheet,
        backgroundColor: AppTheme.primaryPink,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24.w,
        ),
      ),
    );
  }

  Widget _buildPregnancyProgress() {
    return Container(
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
            'Pregnancy Progress',
            style: BabyFont.headingM.copyWith(
              fontSize: 18.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Week $_currentWeek of 40',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.primaryBlue,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
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
    );
  }

  Widget _buildAddPregnancyDateCard() {
    return GestureDetector(
      onTap: _showAddPregnancyDateDialog,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            width: 2.w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.pregnant_woman,
              color: AppTheme.primaryBlue,
              size: 32.w,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Pregnancy Date',
                    style: BabyFont.bodyM.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Track your baby\'s growth journey',
                    style: BabyFont.bodyS.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryBlue,
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final allItems = <TimelineItem>[];

    // Add memories
    for (final memory in _memories) {
      allItems.add(TimelineItem.memory(memory));
    }

    // Add milestones
    for (final milestone in _milestones) {
      allItems.add(TimelineItem.milestone(milestone));
    }

    // Sort by date
    allItems.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: allItems.map((item) => _buildTimelineItem(item)).toList(),
    );
  }

  Widget _buildTimelineItem(TimelineItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color:
                  item.isMemory ? AppTheme.primaryPink : AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 16.w),

          // Content
          Expanded(
            child: item.isMemory
                ? _buildMemoryCard(item.memory!)
                : _buildMilestoneCard(item.milestone!),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(MemoryEntry memory) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  memory.title,
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
                    onTap: () => _toggleMemoryFavorite(memory.id),
                    child: Icon(
                      memory.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: memory.isFavorite
                          ? AppTheme.primaryPink
                          : Colors.grey,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => _deleteMemory(memory.id),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20.w,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            memory.description,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          if (memory.photos.isNotEmpty) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: memory.photos.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 8.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        memory.photos[index],
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Text(
            _formatDate(memory.date),
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(GrowthMilestone milestone) {
    final isCurrent = _pregnancyDate != null && milestone.week == _currentWeek;
    final isCompleted = _pregnancyDate != null && milestone.week < _currentWeek;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppTheme.primaryBlue.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isCurrent
            ? Border.all(color: AppTheme.primaryBlue, width: 2.w)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
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
              if (isCompleted)
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

  Widget _buildAddMemoryBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: AddMemoryForm(onSave: _addMemory),
    );
  }

  Widget _buildPregnancyDateDialog() {
    return AlertDialog(
      title: Text(
        'Add Pregnancy Date',
        style: BabyFont.headingM.copyWith(
          color: AppTheme.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'When did your pregnancy start?',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 30)),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                _addPregnancyDate(date);
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: Text(
              'Select Date',
              style: BabyFont.bodyM.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class MemoryEntry {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final List<File> photos;
  final bool isFavorite;

  MemoryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.photos,
    required this.isFavorite,
  });

  MemoryEntry copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    List<File>? photos,
    bool? isFavorite,
  }) {
    return MemoryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      photos: photos ?? this.photos,
      isFavorite: isFavorite ?? this.isFavorite,
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
}

class TimelineItem {
  final MemoryEntry? memory;
  final GrowthMilestone? milestone;
  final DateTime date;
  final bool isMemory;

  TimelineItem.memory(this.memory)
      : milestone = null,
        date = memory!.date,
        isMemory = true;

  TimelineItem.milestone(this.milestone)
      : memory = null,
        date = DateTime.now().subtract(Duration(days: (40 - milestone!.week) * 7)),
        isMemory = false;
}

class AddMemoryForm extends StatefulWidget {
  final Function(
          String title, String description, DateTime date, List<File> photos)
      onSave;

  const AddMemoryForm({super.key, required this.onSave});

  @override
  State<AddMemoryForm> createState() => _AddMemoryFormState();
}

class _AddMemoryFormState extends State<AddMemoryForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<File> _photos = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addPhoto() {
    // TODO: Implement image picker
    ToastService.showInfo(context, 'Photo picker coming soon! 📸');
  }

  void _saveMemory() {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ToastService.showWarning(context, 'Please fill in all fields! 📝');
      return;
    }

    widget.onSave(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      _selectedDate,
      _photos,
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
            'Add Memory',
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
              labelText: 'Memory Title',
              hintText: 'e.g., First Meet',
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
              hintText: 'Tell your story...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Date Selection
          ListTile(
            title: Text('Date'),
            subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),

          SizedBox(height: 16.h),

          // Photo Section
          Row(
            children: [
              Text('Photos'),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addPhoto,
                icon: Icon(Icons.add_a_photo),
                label: Text('Add Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          if (_photos.isNotEmpty) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 8.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        _photos[index],
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const Spacer(),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveMemory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Save Memory',
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
