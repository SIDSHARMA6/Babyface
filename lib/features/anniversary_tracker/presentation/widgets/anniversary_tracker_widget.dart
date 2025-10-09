import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../../../shared/models/anniversary_event.dart';
import '../../../../shared/services/anniversary_tracker_service.dart';
import 'anniversary_dialogs.dart';

/// Anniversary Tracker Widget with Calendar and List tabs
/// Real event management with SharedPreferences and Firebase integration
class AnniversaryTrackerWidget extends ConsumerStatefulWidget {
  const AnniversaryTrackerWidget({super.key});

  @override
  ConsumerState<AnniversaryTrackerWidget> createState() =>
      _AnniversaryTrackerWidgetState();
}

class _AnniversaryTrackerWidgetState
    extends ConsumerState<AnniversaryTrackerWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<AnniversaryEvent> _events = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Load events from service
  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await AnniversaryTrackerService.instance.getAllEvents();
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ToastService.showError(
              context, 'Failed to load events: ${e.toString()}');
        }
      }
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
          'Anniversary Tracker 💕',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showAddEventDialog,
            icon: Icon(
              Icons.add_rounded,
              color: AppTheme.primaryPink,
              size: 24.w,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryPink,
          labelColor: AppTheme.primaryPink,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(
              icon: Icon(Icons.calendar_today_rounded),
              text: 'Calendar',
            ),
            Tab(
              icon: Icon(Icons.list_rounded),
              text: 'Events',
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCalendarTab(),
            _buildEventsTab(),
          ],
        ),
      ),
    );
  }

  /// Build calendar tab
  Widget _buildCalendarTab() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Calendar header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateTime.now().month}/${DateTime.now().year}',
                  style: BabyFont.headingS.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: BabyFont.bold,
                  ),
                ),
                Text(
                  '${_events.length} Events',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Calendar grid
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withValues(alpha: 0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: _buildCalendarGrid(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build calendar grid
  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;

    // Get events for current month
    final monthEvents = _events.where((event) {
      return event.date.year == now.year && event.date.month == now.month;
    }).toList();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.h,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final day = index - firstWeekday + 1;

        if (day < 1 || day > lastDayOfMonth.day) {
          return Container(); // Empty cell
        }

        final date = DateTime(now.year, now.month, day);
        final dayEvents =
            monthEvents.where((event) => event.date.day == day).toList();
        final isToday = day == now.day;

        return GestureDetector(
          onTap: () => _showDateEventsDialog(date, dayEvents),
          child: Container(
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.primaryPink.withValues(alpha: 0.2)
                  : dayEvents.isNotEmpty
                      ? AppTheme.accentYellow.withValues(alpha: 0.3)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: isToday
                  ? Border.all(color: AppTheme.primaryPink, width: 2.w)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: BabyFont.bodyS.copyWith(
                    color: isToday
                        ? AppTheme.primaryPink
                        : dayEvents.isNotEmpty
                            ? AppTheme.primaryBlue
                            : AppTheme.textPrimary,
                    fontWeight: isToday ? BabyFont.bold : BabyFont.regular,
                  ),
                ),
                if (dayEvents.isNotEmpty)
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build events tab
  Widget _buildEventsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_rounded,
              size: 80.w,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 20.h),
            Text(
              'No Events Yet',
              style: BabyFont.headingM.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add your first special day!',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: _showAddEventDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventCard(event);
      },
    );
  }

  /// Build event card
  Widget _buildEventCard(AnniversaryEvent event) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.displayTitle,
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: BabyFont.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${event.date.day}/${event.date.month}/${event.date.year}',
                      style: BabyFont.bodyM.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleEventAction(value, event),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert_rounded,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (event.description.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              event.description,
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${event.daysUntil} days',
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: BabyFont.bold,
                  ),
                ),
              ),
              if (event.isRecurring) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
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
        ],
      ),
    );
  }

  /// Show add event dialog
  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        onEventAdded: (event) {
          _loadEvents();
          ToastService.showSuccess(context, 'Event added successfully! 💕');
        },
      ),
    );
  }

  /// Show date events dialog
  void _showDateEventsDialog(DateTime date, List<AnniversaryEvent> events) {
    showDialog(
      context: context,
      builder: (context) => DateEventsDialog(
        date: date,
        events: events,
        onEventTapped: (event) {
          Navigator.pop(context);
          _showEventDetails(event);
        },
        onAddEvent: () {
          Navigator.pop(context);
          _showAddEventDialog();
        },
      ),
    );
  }

  /// Show event details
  void _showEventDetails(AnniversaryEvent event) {
    showDialog(
      context: context,
      builder: (context) => EventDetailsDialog(event: event),
    );
  }

  /// Handle event action
  void _handleEventAction(String action, AnniversaryEvent event) {
    switch (action) {
      case 'edit':
        _showEditEventDialog(event);
        break;
      case 'delete':
        _showDeleteEventDialog(event);
        break;
    }
  }

  /// Show edit event dialog
  void _showEditEventDialog(AnniversaryEvent event) {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        event: event,
        onEventAdded: (updatedEvent) {
          _loadEvents();
          ToastService.showSuccess(context, 'Event updated successfully! 💕');
        },
      ),
    );
  }

  /// Show delete event dialog
  void _showDeleteEventDialog(AnniversaryEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content:
            Text('Are you sure you want to delete "${event.displayTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentContext = context;
              Navigator.pop(currentContext);
              final success = await AnniversaryTrackerService.instance
                  .deleteEvent(event.id);
              if (success) {
                _loadEvents();
                // Use a post-frame callback to ensure context is still valid
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ToastService.showSuccess(
                        context, 'Event deleted successfully!');
                  }
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ToastService.showError(context, 'Failed to delete event');
                  }
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
