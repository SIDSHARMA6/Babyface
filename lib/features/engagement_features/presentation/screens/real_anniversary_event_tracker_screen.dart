import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class AnniversaryEventTrackerScreen extends StatefulWidget {
  const AnniversaryEventTrackerScreen({super.key});

  @override
  State<AnniversaryEventTrackerScreen> createState() =>
      _AnniversaryEventTrackerScreenState();
}

class _AnniversaryEventTrackerScreenState
    extends State<AnniversaryEventTrackerScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<AnniversaryEvent> _events = [];
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'Calendar'; // Calendar or List

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

  void _showAddEventBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddEventBottomSheet(),
    );
  }

  void _addEvent(String title, String description, DateTime date, String type,
      File? photo, bool isRecurring) {
    final event = AnniversaryEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date,
      type: type,
      isRecurring: isRecurring,
      isCompleted: false,
      photo: photo,
      isFavorite: false,
    );

    setState(() {
      _events.add(event);
      _events.sort((a, b) => a.date.compareTo(b.date));
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(
        context, 'Event added to Forever Calendar! 📅');
  }

  void _toggleEventFavorite(String id) {
    setState(() {
      final index = _events.indexWhere((e) => e.id == id);
      if (index != -1) {
        _events[index] = _events[index].copyWith(
          isFavorite: !_events[index].isFavorite,
        );
      }
    });

    HapticFeedback.selectionClick();
  }

  void _markEventCompleted(String id) {
    setState(() {
      final index = _events.indexWhere((e) => e.id == id);
      if (index != -1) {
        _events[index] = _events[index].copyWith(
          isCompleted: true,
        );
      }
    });

    HapticFeedback.mediumImpact();
    ToastService.showCelebration(context, 'Event celebrated! 🎉');
  }

  void _deleteEvent(String id) {
    setState(() {
      _events.removeWhere((e) => e.id == id);
    });

    HapticFeedback.lightImpact();
    ToastService.showInfo(context, 'Event deleted');
  }

  List<AnniversaryEvent> get _todaysEvents {
    final today = DateTime.now();
    return _events
        .where((e) =>
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day)
        .toList();
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

  String _getEventTypeEmoji(String type) {
    switch (type) {
      case 'Anniversary':
        return '💍';
      case 'Birthday':
        return '🎂';
      case 'Holiday':
        return '🎊';
      case 'Milestone':
        return '🎯';
      case 'Date':
        return '💕';
      case 'Custom':
        return '📅';
      default:
        return '📅';
    }
  }

  Color _getEventTypeColor(String type) {
    switch (type) {
      case 'Anniversary':
        return AppTheme.primaryPink;
      case 'Birthday':
        return AppTheme.accentYellow;
      case 'Holiday':
        return Colors.purple;
      case 'Milestone':
        return AppTheme.primaryBlue;
      case 'Date':
        return Colors.red;
      case 'Custom':
        return Colors.grey;
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
          'Forever Calendar 💍',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showAddEventBottomSheet,
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
            // View Mode Toggle
            Container(
              margin: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                        _buildViewModeButton('Calendar', Icons.calendar_today),
                  ),
                  Expanded(
                    child: _buildViewModeButton('List', Icons.list),
                  ),
                ],
              ),
            ),

            // Today's Events
            if (_todaysEvents.isNotEmpty) ...[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppTheme.primaryPink.withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.today,
                            color: AppTheme.primaryPink, size: 20.w),
                        SizedBox(width: 8.w),
                        Text(
                          'Today\'s Events',
                          style: BabyFont.bodyM.copyWith(
                            color: AppTheme.primaryPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ..._todaysEvents
                        .map((event) => _buildTodayEventCard(event)),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],

            // Events List/Calendar
            Expanded(
              child: _viewMode == 'Calendar'
                  ? _buildCalendarView()
                  : _buildListView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventBottomSheet,
        backgroundColor: AppTheme.primaryPink,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24.w,
        ),
      ),
    );
  }

  Widget _buildViewModeButton(String mode, IconData icon) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viewMode = mode;
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
              mode,
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

  Widget _buildTodayEventCard(AnniversaryEvent event) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Text(
            _getEventTypeEmoji(event.type),
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              event.title,
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!event.isCompleted)
            ElevatedButton(
              onPressed: () => _markEventCompleted(event.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                'Celebrate',
                style: BabyFont.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Calendar Header
          Container(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: BabyFont.headingM.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 18.sp,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(
                              _selectedDate.year, _selectedDate.month - 1);
                        });
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(
                              _selectedDate.year, _selectedDate.month + 1);
                        });
                      },
                      icon: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Calendar Grid
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final dayIndex = index - firstDayWeekday + 1;
        final isCurrentMonth = dayIndex > 0 && dayIndex <= daysInMonth;
        final day = isCurrentMonth ? dayIndex : null;
        final dayDate = isCurrentMonth
            ? DateTime(_selectedDate.year, _selectedDate.month, dayIndex)
            : null;
        final hasEvents = dayDate != null &&
            _events.any((e) =>
                e.date.year == dayDate.year &&
                e.date.month == dayDate.month &&
                e.date.day == dayDate.day);

        return Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: hasEvents
                ? AppTheme.primaryPink.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: hasEvents
                ? Border.all(color: AppTheme.primaryPink.withValues(alpha: 0.3))
                : null,
          ),
          child: Center(
            child: day != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: BabyFont.bodyM.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasEvents)
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    if (_events.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            color: AppTheme.primaryPink,
            size: 80.w,
          ),
          SizedBox(height: 20.h),
          Text(
            'No Events Yet',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start adding your special moments!',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(AnniversaryEvent event) {
    final typeColor = _getEventTypeColor(event.type);
    final daysUntil = _getDaysUntil(event.date);
    final isToday = daysUntil == 'Today!';
    final isOverdue = daysUntil.contains('days ago');

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
                _getEventTypeEmoji(event.type),
                style: TextStyle(fontSize: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  event.title,
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
                    onTap: () => _toggleEventFavorite(event.id),
                    child: Icon(
                      event.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          event.isFavorite ? AppTheme.primaryPink : Colors.grey,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => _deleteEvent(event.id),
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
            event.description,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          if (event.photo != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                event.photo!,
                width: double.infinity,
                height: 120.h,
                fit: BoxFit.cover,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildTypeChip(event.type, typeColor),
              SizedBox(width: 8.w),
              if (event.isRecurring) _buildRecurringChip(),
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
          if (!event.isCompleted && !isOverdue) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markEventCompleted(event.id),
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

  Widget _buildAddEventBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: AddEventForm(onSave: _addEvent),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

class AnniversaryEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String type;
  final bool isRecurring;
  final bool isCompleted;
  final File? photo;
  final bool isFavorite;

  AnniversaryEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.isRecurring,
    required this.isCompleted,
    this.photo,
    required this.isFavorite,
  });

  AnniversaryEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? type,
    bool? isRecurring,
    bool? isCompleted,
    File? photo,
    bool? isFavorite,
  }) {
    return AnniversaryEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      isCompleted: isCompleted ?? this.isCompleted,
      photo: photo ?? this.photo,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class AddEventForm extends StatefulWidget {
  final Function(String title, String description, DateTime date, String type,
      File? photo, bool isRecurring) onSave;

  const AddEventForm({super.key, required this.onSave});

  @override
  State<AddEventForm> createState() => _AddEventFormState();
}

class _AddEventFormState extends State<AddEventForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedType = 'Anniversary';
  bool _isRecurring = false;
  File? _selectedPhoto;

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

  void _saveEvent() {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ToastService.showWarning(context, 'Please fill in all fields! 📝');
      return;
    }

    widget.onSave(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      _selectedDate,
      _selectedType,
      _selectedPhoto,
      _isRecurring,
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
            'Add Event',
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
              labelText: 'Event Title',
              hintText: 'e.g., First Date',
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

          // Type Selection
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Event Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            items: [
              'Anniversary',
              'Birthday',
              'Holiday',
              'Milestone',
              'Date',
              'Custom'
            ]
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
            title: Text('Event Date'),
            subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),

          // Recurring Toggle
          SwitchListTile(
            title: Text('Recurring Event'),
            subtitle: Text('Repeat every year'),
            value: _isRecurring,
            onChanged: (value) {
              setState(() {
                _isRecurring = value;
              });
            },
          ),

          // Photo Section
          Row(
            children: [
              Text('Photo (Optional)'),
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

          if (_selectedPhoto != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                _selectedPhoto!,
                width: double.infinity,
                height: 120.h,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const Spacer(),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Add Event',
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
