import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../../../shared/models/period_cycle.dart';
import '../../../../shared/services/period_tracker_service.dart';

/// Period Setup Dialog for first-time users
class PeriodSetupDialog extends StatefulWidget {
  final VoidCallback onCycleSet;

  const PeriodSetupDialog({
    super.key,
    required this.onCycleSet,
  });

  @override
  State<PeriodSetupDialog> createState() => _PeriodSetupDialogState();
}

class _PeriodSetupDialogState extends State<PeriodSetupDialog> {
  DateTime _lastPeriodDate = DateTime.now().subtract(const Duration(days: 14));
  int _cycleLength = 28;
  int _periodLength = 5;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Set Up Your Cycle 💖',
        style: BabyFont.headingM.copyWith(
          color: AppTheme.primaryPink,
          fontWeight: BabyFont.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Help us understand your cycle to provide personalized insights.',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Last period date
            _buildDateSelector(),
            SizedBox(height: 20.h),

            // Cycle length
            _buildCycleLengthSelector(),
            SizedBox(height: 20.h),

            // Period length
            _buildPeriodLengthSelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCycle,
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
              : Text('Start Tracking'),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Period Start Date',
          style: BabyFont.bodyM.copyWith(
            fontWeight: BabyFont.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectLastPeriodDate,
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
                  '${_lastPeriodDate.day}/${_lastPeriodDate.month}/${_lastPeriodDate.year}',
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

  Widget _buildCycleLengthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Cycle Length',
          style: BabyFont.bodyM.copyWith(
            fontWeight: BabyFont.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            IconButton(
              onPressed: _cycleLength > 21
                  ? () => setState(() => _cycleLength--)
                  : null,
              icon: Icon(Icons.remove_rounded),
            ),
            Expanded(
              child: Text(
                '$_cycleLength days',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: BabyFont.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: _cycleLength < 35
                  ? () => setState(() => _cycleLength++)
                  : null,
              icon: Icon(Icons.add_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodLengthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Period Length',
          style: BabyFont.bodyM.copyWith(
            fontWeight: BabyFont.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            IconButton(
              onPressed: _periodLength > 3
                  ? () => setState(() => _periodLength--)
                  : null,
              icon: Icon(Icons.remove_rounded),
            ),
            Expanded(
              child: Text(
                '$_periodLength days',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: BabyFont.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: _periodLength < 7
                  ? () => setState(() => _periodLength++)
                  : null,
              icon: Icon(Icons.add_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectLastPeriodDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _lastPeriodDate = date;
      });
    }
  }

  Future<void> _saveCycle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cycle = PeriodCycle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        lastPeriodStart: _lastPeriodDate,
        cycleLength: _cycleLength,
        periodLength: _periodLength,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await PeriodTrackerService.instance.setCycle(cycle);

      if (success) {
        widget.onCycleSet();
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ToastService.showError(context, 'Failed to save cycle data');
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Error saving cycle: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

/// Period Settings Dialog for existing users
class PeriodSettingsDialog extends StatefulWidget {
  final PeriodCycle cycle;
  final VoidCallback onCycleUpdated;

  const PeriodSettingsDialog({
    super.key,
    required this.cycle,
    required this.onCycleUpdated,
  });

  @override
  State<PeriodSettingsDialog> createState() => _PeriodSettingsDialogState();
}

class _PeriodSettingsDialogState extends State<PeriodSettingsDialog> {
  late DateTime _lastPeriodDate;
  late int _cycleLength;
  late int _periodLength;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _lastPeriodDate = widget.cycle.lastPeriodStart;
    _cycleLength = widget.cycle.cycleLength;
    _periodLength = widget.cycle.periodLength;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Cycle Settings ⚙️',
        style: BabyFont.headingM.copyWith(
          color: AppTheme.primaryPink,
          fontWeight: BabyFont.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update your cycle information for accurate predictions.',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Last period date
            _buildDateSelector(),
            SizedBox(height: 20.h),

            // Cycle length
            _buildCycleLengthSelector(),
            SizedBox(height: 20.h),

            // Period length
            _buildPeriodLengthSelector(),
            SizedBox(height: 20.h),

            // Current cycle info
            _buildCurrentCycleInfo(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateCycle,
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
              : Text('Update'),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Period Start Date',
          style: BabyFont.bodyM.copyWith(
            fontWeight: BabyFont.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectLastPeriodDate,
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
                  '${_lastPeriodDate.day}/${_lastPeriodDate.month}/${_lastPeriodDate.year}',
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

  Widget _buildCycleLengthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Cycle Length',
          style: BabyFont.bodyM.copyWith(
            fontWeight: BabyFont.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            IconButton(
              onPressed: _cycleLength > 21
                  ? () => setState(() => _cycleLength--)
                  : null,
              icon: Icon(Icons.remove_rounded),
            ),
            Expanded(
              child: Text(
                '$_cycleLength days',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: BabyFont.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: _cycleLength < 35
                  ? () => setState(() => _cycleLength++)
                  : null,
              icon: Icon(Icons.add_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodLengthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Period Length',
          style: BabyFont.bodyM.copyWith(
            fontWeight: BabyFont.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            IconButton(
              onPressed: _periodLength > 3
                  ? () => setState(() => _periodLength--)
                  : null,
              icon: Icon(Icons.remove_rounded),
            ),
            Expanded(
              child: Text(
                '$_periodLength days',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: BabyFont.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: _periodLength < 7
                  ? () => setState(() => _periodLength++)
                  : null,
              icon: Icon(Icons.add_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentCycleInfo() {
    final currentDay = widget.cycle.currentDayInCycle;
    final phase = widget.cycle.currentPhase;
    final daysUntilNext = widget.cycle.daysUntilNextPeriod;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            'Current Cycle Info',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.primaryPink,
              fontWeight: BabyFont.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Day $currentDay • ${phase.displayName} • $daysUntilNext days until next period',
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _selectLastPeriodDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _lastPeriodDate = date;
      });
    }
  }

  Future<void> _updateCycle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update last period start
      await PeriodTrackerService.instance
          .updateLastPeriodStart(_lastPeriodDate);

      // Update cycle length
      await PeriodTrackerService.instance.updateCycleLength(_cycleLength);

      // Update period length
      await PeriodTrackerService.instance.updatePeriodLength(_periodLength);

      widget.onCycleUpdated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ToastService.showError(
            context, 'Error updating cycle: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
