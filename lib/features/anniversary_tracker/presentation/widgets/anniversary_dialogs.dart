import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../../../shared/models/anniversary_event.dart';
import '../../../../shared/services/anniversary_tracker_service.dart';

/// Add Event Dialog for Anniversary Tracker
class AddEventDialog extends StatefulWidget {
  final AnniversaryEvent? event;
  final Function(AnniversaryEvent) onEventAdded;

  const AddEventDialog({
    super.key,
    this.event,
    required this.onEventAdded,
  });

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'Anniversary';
  bool _isRecurring = false;
  RecurringType _recurringType = RecurringType.yearly;
  bool _isCustomType = false;
  File? _selectedPhoto;
  bool _isLoading = false;

  final List<String> _predefinedTypes = [
    'Anniversary',
    'Birthday',
    'First Date',
    'Engagement',
    'Wedding',
    'Valentine\'s Day',
    'Christmas',
    'New Year',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _selectedDate = widget.event!.date;
      _selectedType = widget.event!.title;
      _isRecurring = widget.event!.isRecurring;
      _recurringType = widget.event!.recurringType;
      _customNameController.text = widget.event!.customEventName ?? '';
      _isCustomType = widget.event!.customEventName != null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.event != null ? 'Edit Event 💕' : 'Add New Event 💕',
        style: BabyFont.headingM.copyWith(
          color: AppTheme.primaryPink,
          fontWeight: BabyFont.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Event Type Selection
            _buildTypeSelector(),
            SizedBox(height: 16.h),

            // Custom Name Field (if custom type selected)
            if (_isCustomType) ...[
              TextField(
                controller: _customNameController,
                decoration: InputDecoration(
                  labelText: 'Custom Event Name',
                  hintText: 'e.g., "Our Special Day"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.edit_rounded),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                hintText: 'Enter event title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: const Icon(Icons.title_rounded),
              ),
            ),
            SizedBox(height: 16.h),

            // Description Field
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe this special moment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: const Icon(Icons.description_rounded),
              ),
            ),
            SizedBox(height: 16.h),

            // Date Selection
            _buildDateSelector(),
            SizedBox(height: 16.h),

            // Photo Selection
            _buildPhotoSelector(),
            SizedBox(height: 16.h),

            // Recurring Toggle
            _buildRecurringToggle(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.event != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Type',
          style: BabyFont.bodyM.copyWith(
            fontWeight: BabyFont.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: [
            ..._predefinedTypes.map((type) => _buildTypeChip(type)),
            _buildTypeChip('Custom'),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = _selectedType == type;
    final isCustom = type == 'Custom';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _isCustomType = isCustom;
          if (!isCustom) {
            _titleController.text = type;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPink
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? Border.all(color: AppTheme.primaryPink, width: 2.w)
              : null,
        ),
        child: Text(
          type,
          style: BabyFont.bodyS.copyWith(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? BabyFont.bold : BabyFont.regular,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Date',
          style: BabyFont.bodyM.copyWith(
            fontWeight: BabyFont.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: AppTheme.primaryPink),
                SizedBox(width: 8.w),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Photo (Optional)',
          style: BabyFont.bodyM.copyWith(
            fontWeight: BabyFont.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectPhoto,
          child: Container(
            height: 100.h,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: _selectedPhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(
                      _selectedPhoto!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        color: AppTheme.primaryPink,
                        size: 32.w,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap to add photo',
                        style: BabyFont.bodyS.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value ?? false;
                });
              },
              activeColor: AppTheme.primaryPink,
            ),
            Expanded(
              child: Text(
                'Recurring Event',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        if (_isRecurring) ...[
          SizedBox(height: 8.h),
          Text(
            'Recurring Type',
            style: BabyFont.bodyS.copyWith(
              fontWeight: BabyFont.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child:
                    _buildRecurringTypeChip('Monthly', RecurringType.monthly),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildRecurringTypeChip('Yearly', RecurringType.yearly),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRecurringTypeChip(String label, RecurringType type) {
    final isSelected = _recurringType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _recurringType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPink
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? Border.all(color: AppTheme.primaryPink, width: 2.w)
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: BabyFont.bodyS.copyWith(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? BabyFont.bold : BabyFont.regular,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectPhoto() async {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Photo'),
          content: Text('Choose how you want to add the photo'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              child: Text('Camera 📷'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: Text('Gallery 🖼️'),
            ),
          ],
        ),
      );
    } catch (e) {
      ToastService.showError(
          context, 'Failed to select photo: ${e.toString()}');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(
            context, 'Failed to pick image: ${e.toString()}');
      }
    }
  }

  Future<void> _saveEvent() async {
    if (_titleController.text.trim().isEmpty) {
      ToastService.showError(context, 'Please enter event title');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? photoPath;
      if (_selectedPhoto != null) {
        photoPath = await AnniversaryTrackerService.instance
            .saveEventImage(_selectedPhoto!);
      }

      final event = AnniversaryEvent(
        id: widget.event?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        photoPath: photoPath,
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : RecurringType.none,
        customEventName:
            _isCustomType ? _customNameController.text.trim() : null,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.event != null) {
        success = await AnniversaryTrackerService.instance.updateEvent(event);
      } else {
        success = await AnniversaryTrackerService.instance.addEvent(event);
      }

      if (success) {
        widget.onEventAdded(event);
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) ToastService.showError(context, 'Failed to save event');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Error saving event: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

/// Date Events Dialog for Anniversary Tracker
class DateEventsDialog extends StatelessWidget {
  final DateTime date;
  final List<AnniversaryEvent> events;
  final Function(AnniversaryEvent) onEventTapped;
  final VoidCallback onAddEvent;

  const DateEventsDialog({
    super.key,
    required this.date,
    required this.events,
    required this.onEventTapped,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '${date.day}/${date.month}/${date.year}',
        style: BabyFont.headingM.copyWith(
          color: AppTheme.primaryPink,
          fontWeight: BabyFont.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: events.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_note_rounded,
                    size: 60.w,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No events on this date',
                    style: BabyFont.bodyM.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(event);
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: onAddEvent,
          child: Text('Add Event'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget _buildEventCard(AnniversaryEvent event) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.primaryPink.withValues(alpha: 0.3),
        ),
      ),
      child: GestureDetector(
        onTap: () => onEventTapped(event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.displayTitle,
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: BabyFont.bold,
              ),
            ),
            if (event.description.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                event.description,
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (event.isRecurring) ...[
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Recurring',
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.accentYellow,
                    fontWeight: BabyFont.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Event Details Dialog for Anniversary Tracker
class EventDetailsDialog extends StatelessWidget {
  final AnniversaryEvent event;

  const EventDetailsDialog({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        event.displayTitle,
        style: BabyFont.headingM.copyWith(
          color: AppTheme.primaryPink,
          fontWeight: BabyFont.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Event Photo
            if (event.photoPath != null) ...[
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(event.photoPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 50.w,
                          color: AppTheme.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Event Date
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: AppTheme.primaryPink),
                SizedBox(width: 8.w),
                Text(
                  '${event.date.day}/${event.date.month}/${event.date.year}',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: BabyFont.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Days Until
            Row(
              children: [
                Icon(Icons.schedule_rounded, color: AppTheme.primaryPink),
                SizedBox(width: 8.w),
                Text(
                  '${event.daysUntil} days until event',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Recurring Status
            if (event.isRecurring) ...[
              Row(
                children: [
                  Icon(Icons.repeat_rounded, color: AppTheme.accentYellow),
                  SizedBox(width: 8.w),
                  Text(
                    'Recurring Event (${event.recurringType.name})',
                    style: BabyFont.bodyM.copyWith(
                      color: AppTheme.accentYellow,
                      fontWeight: BabyFont.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],

            // Description
            if (event.description.isNotEmpty) ...[
              Text(
                'Description',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: BabyFont.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                event.description,
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
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
}
