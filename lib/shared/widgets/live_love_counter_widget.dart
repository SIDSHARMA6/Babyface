import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../core/theme/baby_font.dart';
import '../services/app_data_service.dart';
import '../services/bond_profile_service.dart';

/// Live love counter widget for home screen
class LiveLoveCounterWidget extends StatefulWidget {
  const LiveLoveCounterWidget({super.key});

  @override
  State<LiveLoveCounterWidget> createState() => _LiveLoveCounterWidgetState();
}

class _LiveLoveCounterWidgetState extends State<LiveLoveCounterWidget>
    with TickerProviderStateMixin {
  final AppDataService _appDataService = AppDataService.instance;
  final BondProfileService _bondService = BondProfileService.instance;

  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  String _bondName = '';
  int _daysTogether = 0;
  int _loveScore = 0;
  int _memoriesCount = 0;
  int _achievementsCount = 0;
  bool _isLoading = true;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
    _startLiveUpdates();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  Future<void> _loadData() async {
    try {
      final bondName = await _bondService.getBondName();
      final stats = await _appDataService.getProfileStats();

      if (mounted) {
        setState(() {
          _bondName = bondName ?? 'Your Love';
          _daysTogether = stats['daysTogether'] ?? 0;
          _loveScore = stats['loveScore'] ?? 0;
          _memoriesCount = stats['memoriesCount'] ?? 0;
          _achievementsCount = stats['achievementsCount'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startLiveUpdates() {
    _updateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.primaryPink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.2),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryPink,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading love data...',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Header with bond name
        _buildHeader(),
        SizedBox(height: 20.h),

        // Main love counter
        _buildLoveCounter(),
        SizedBox(height: 20.h),

        // Stats grid
        _buildStatsGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Animated heart icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppTheme.primaryPink,
                  size: 24.w,
                ),
              ),
            );
          },
        ),
        SizedBox(width: 16.w),

        // Bond name and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _bondName,
                style: BabyFont.headingM.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Live Love Counter',
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Live indicator
        _buildLiveIndicator(),
      ],
    );
  }

  Widget _buildLiveIndicator() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color:
                Colors.red.withValues(alpha: 0.1 + _glowAnimation.value * 0.2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.red
                  .withValues(alpha: 0.3 + _glowAnimation.value * 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'LIVE',
                style: BabyFont.bodyS.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoveCounter() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPink,
                  AppTheme.primaryPink.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.3),
                  blurRadius: 15.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Days Together',
                  style: BabyFont.bodyM.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '$_daysTogether',
                  style: BabyFont.headingL.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'and counting...',
                  style: BabyFont.bodyS.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Love Score',
            '$_loveScore',
            Icons.favorite,
            Colors.red,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Memories',
            '$_memoriesCount',
            Icons.photo_library,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Achievements',
            '$_achievementsCount',
            Icons.emoji_events,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.w,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: BabyFont.headingS.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Mini live love counter widget (for smaller spaces)
class MiniLiveLoveCounterWidget extends StatefulWidget {
  const MiniLiveLoveCounterWidget({super.key});

  @override
  State<MiniLiveLoveCounterWidget> createState() =>
      _MiniLiveLoveCounterWidgetState();
}

class _MiniLiveLoveCounterWidgetState extends State<MiniLiveLoveCounterWidget>
    with SingleTickerProviderStateMixin {
  final AppDataService _appDataService = AppDataService.instance;
  final BondProfileService _bondService = BondProfileService.instance;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _bondName = '';
  int _daysTogether = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadData() async {
    try {
      final bondName = await _bondService.getBondName();
      final stats = await _appDataService.getProfileStats();

      if (mounted) {
        setState(() {
          _bondName = bondName ?? 'Your Love';
          _daysTogether = stats['daysTogether'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.1),
            AppTheme.primaryPink.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        SizedBox(
          width: 16.w,
          height: 16.w,
          child: CircularProgressIndicator(
            color: AppTheme.primaryPink,
            strokeWidth: 2,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'Loading...',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Row(
            children: [
              // Heart icon
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppTheme.primaryPink,
                  size: 12.w,
                ),
              ),
              SizedBox(width: 8.w),

              // Bond name and days
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _bondName,
                      style: BabyFont.bodyM.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$_daysTogether days together',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Live indicator
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
