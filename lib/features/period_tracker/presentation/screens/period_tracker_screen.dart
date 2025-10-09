import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../../../../shared/models/period_cycle.dart';
import '../../../../shared/services/period_tracker_service.dart';
import '../widgets/period_dialogs.dart';

/// Period Tracker Screen with Calendar and List tabs
/// Real cycle logic with daily dialogues and emotional care
/// Follows periodtracker.md specification
class PeriodTrackerScreen extends ConsumerStatefulWidget {
  const PeriodTrackerScreen({super.key});

  @override
  ConsumerState<PeriodTrackerScreen> createState() =>
      _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends ConsumerState<PeriodTrackerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late AnimationController _phaseAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _phaseAnimation;

  PeriodCycle? _currentCycle;
  bool _isLoading = false;
  bool _isSetupMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _phaseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _phaseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _phaseAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _phaseAnimationController.repeat(reverse: true);
    _loadCycleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _phaseAnimationController.dispose();
    super.dispose();
  }

  /// Load cycle data from service
  Future<void> _loadCycleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cycle = await PeriodTrackerService.instance.getCurrentCycle();
      if (mounted) {
        setState(() {
          _currentCycle = cycle;
          _isSetupMode = cycle == null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ToastService.showError(
            context, 'Failed to load cycle data: ${e.toString()}');
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
          'Cycle Tracker 💖',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isSetupMode)
            IconButton(
              onPressed: _showSettingsDialog,
              icon: Icon(
                Icons.settings_rounded,
                color: AppTheme.primaryPink,
                size: 24.w,
              ),
            ),
        ],
        bottom: !_isSetupMode
            ? TabBar(
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
                    text: 'Insights',
                  ),
                ],
              )
            : null,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isSetupMode ? _buildSetupView() : _buildMainView(),
      ),
    );
  }

  /// Build setup view for first-time users
  Widget _buildSetupView() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome illustration
          Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPink.withValues(alpha: 0.1),
                  AppTheme.accentYellow.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 100.w,
              color: AppTheme.primaryPink,
            ),
          ),
          SizedBox(height: 40.h),

          Text(
            'Welcome to Your Cycle Journey 💖',
            style: BabyFont.headingL.copyWith(
              color: AppTheme.primaryPink,
              fontWeight: BabyFont.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          Text(
            'Track your cycle, understand your body, and get personalized daily insights.',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40.h),

          // Setup button
          ElevatedButton.icon(
            onPressed: _showSetupDialog,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Tracking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build main view with tabs
  Widget _buildMainView() {
    if (_isLoading || _currentCycle == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildCalendarTab(),
        _buildInsightsTab(),
      ],
    );
  }

  /// Build calendar tab
  Widget _buildCalendarTab() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Current cycle info card
          _buildCycleInfoCard(),
          SizedBox(height: 20.h),

          // Calendar grid
          Expanded(
            child: _buildCycleCalendar(),
          ),
        ],
      ),
    );
  }

  /// Build cycle info card
  Widget _buildCycleInfoCard() {
    final cycle = _currentCycle!;
    final currentDay = cycle.currentDayInCycle;
    final phase = cycle.currentPhase;
    final pregnancyProb = cycle.pregnancyProbability;
    final daysUntilNext = cycle.daysUntilNextPeriod;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.accentYellow.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.2),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Phase header
          Row(
            children: [
              AnimatedBuilder(
                animation: _phaseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_phaseAnimation.value * 0.1),
                    child: Text(
                      phase.emoji,
                      style: TextStyle(fontSize: 32.w),
                    ),
                  );
                },
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase.displayName,
                      style: BabyFont.headingM.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: BabyFont.bold,
                      ),
                    ),
                    Text(
                      'Day $currentDay of ${cycle.cycleLength}',
                      style: BabyFont.bodyM.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Daily dialogue
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              cycle.dailyDialogue,
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.h),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Fertility',
                  pregnancyProb.displayName,
                  pregnancyProb.emoji,
                ),
              ),
              Container(
                width: 1.w,
                height: 40.h,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Next Period',
                  '$daysUntilNext days',
                  '📅',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build stat item
  Widget _buildStatItem(String label, String value, String emoji) {
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 24.w),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        Text(
          label,
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Build cycle calendar
  Widget _buildCycleCalendar() {
    final cycle = _currentCycle!;
    final currentDay = cycle.currentDayInCycle;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendar header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '28-Day Cycle View',
                style: BabyFont.headingS.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: BabyFont.bold,
                ),
              ),
              Text(
                'Day $currentDay',
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Calendar grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4.w,
                mainAxisSpacing: 4.h,
              ),
              itemCount: 28,
              itemBuilder: (context, index) {
                final day = index + 1;
                final phase = _getPhaseForDay(day);
                final isCurrentDay = day == currentDay;
                final isFertile = _isFertileDay(day);

                return _buildCalendarDay(day, phase, isCurrentDay, isFertile);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build calendar day
  Widget _buildCalendarDay(
      int day, CyclePhase phase, bool isCurrentDay, bool isFertile) {
    Color backgroundColor;
    Color textColor;

    if (isCurrentDay) {
      backgroundColor = AppTheme.primaryPink;
      textColor = Colors.white;
    } else if (isFertile) {
      backgroundColor = AppTheme.accentYellow.withValues(alpha: 0.3);
      textColor = AppTheme.primaryBlue;
    } else {
      backgroundColor = phase == CyclePhase.menstrual
          ? AppTheme.primaryPink.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.1);
      textColor = AppTheme.textPrimary;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: isCurrentDay
            ? Border.all(color: AppTheme.primaryPink, width: 2.w)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.toString(),
            style: BabyFont.bodyS.copyWith(
              color: textColor,
              fontWeight: isCurrentDay ? BabyFont.bold : BabyFont.regular,
            ),
          ),
          if (isFertile)
            Container(
              width: 4.w,
              height: 4.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryPink,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  /// Build insights tab
  Widget _buildInsightsTab() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Cycle insights
          _buildInsightsCard(),
          SizedBox(height: 20.h),

          // Tips and recommendations
          Expanded(
            child: _buildTipsList(),
          ),
        ],
      ),
    );
  }

  /// Build insights card
  Widget _buildInsightsCard() {
    final cycle = _currentCycle!;
    final phase = cycle.currentPhase;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.accentYellow.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: AppTheme.primaryBlue,
                size: 24.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Cycle Insights',
                style: BabyFont.headingS.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: BabyFont.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _getPhaseInsight(phase),
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build tips list
  Widget _buildTipsList() {
    final cycle = _currentCycle!;
    final phase = cycle.currentPhase;
    final tips = _getPhaseTips(phase);

    return ListView.builder(
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
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
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  tip['icon'],
                  color: AppTheme.primaryPink,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  tip['text'],
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get phase for specific day
  CyclePhase _getPhaseForDay(int day) {
    if (day <= 5) return CyclePhase.menstrual;
    if (day <= 13) return CyclePhase.follicular;
    if (day == 14) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  /// Check if day is fertile
  bool _isFertileDay(int day) {
    return day >= 9 && day <= 15; // Fertile window
  }

  /// Get phase insight
  String _getPhaseInsight(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Your body is renewing itself. Focus on rest and self-care during this phase.';
      case CyclePhase.follicular:
        return 'Energy levels are rising! This is a great time for new projects and social activities.';
      case CyclePhase.ovulation:
        return 'Peak fertility day! Your energy and mood are at their highest.';
      case CyclePhase.luteal:
        return 'Time for reflection and nesting. Your body is preparing for the next cycle.';
    }
  }

  /// Get phase tips
  List<Map<String, dynamic>> _getPhaseTips(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return [
          {
            'icon': Icons.local_drink_rounded,
            'text': 'Stay hydrated with warm herbal teas'
          },
          {'icon': Icons.bedtime_rounded, 'text': 'Get extra rest and sleep'},
          {'icon': Icons.favorite_rounded, 'text': 'Be gentle with yourself'},
        ];
      case CyclePhase.follicular:
        return [
          {
            'icon': Icons.directions_run_rounded,
            'text': 'Perfect time for exercise and outdoor activities'
          },
          {
            'icon': Icons.lightbulb_rounded,
            'text': 'Your creativity is at its peak'
          },
          {
            'icon': Icons.people_rounded,
            'text': 'Great time for socializing and dating'
          },
        ];
      case CyclePhase.ovulation:
        return [
          {
            'icon': Icons.favorite_rounded,
            'text': 'Peak romance and intimacy time'
          },
          {
            'icon': Icons.energy_savings_leaf_rounded,
            'text': 'Your energy levels are maximum'
          },
          {
            'icon': Icons.celebration_rounded,
            'text': 'Perfect day for important decisions'
          },
        ];
      case CyclePhase.luteal:
        return [
          {
            'icon': Icons.spa_rounded,
            'text': 'Focus on relaxation and self-care'
          },
          {
            'icon': Icons.home_rounded,
            'text': 'Great time for nesting and organizing'
          },
          {
            'icon': Icons.psychology_rounded,
            'text': 'Practice mindfulness and reflection'
          },
        ];
    }
  }

  /// Show setup dialog
  void _showSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => PeriodSetupDialog(
        onCycleSet: () {
          _loadCycleData();
          ToastService.showSuccess(context, 'Cycle tracking started! 💖');
        },
      ),
    );
  }

  /// Show settings dialog
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => PeriodSettingsDialog(
        cycle: _currentCycle!,
        onCycleUpdated: () {
          _loadCycleData();
          ToastService.showSuccess(context, 'Settings updated! 💖');
        },
      ),
    );
  }
}
