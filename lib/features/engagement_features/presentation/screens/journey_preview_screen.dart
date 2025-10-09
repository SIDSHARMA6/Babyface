import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../providers/memory_journal_provider.dart';
import '../../data/models/memory_model.dart';
import '../../data/services/seasonal_theme_service.dart';
import '../widgets/floating_text_widget.dart';
import 'add_memory_screen.dart';
import '../widgets/journey_helper.dart';

/// Journey Preview Screen
/// Follows memory_journey.md specification for 3D road visualization
class JourneyPreviewScreen extends ConsumerStatefulWidget {
  const JourneyPreviewScreen({super.key});

  @override
  ConsumerState<JourneyPreviewScreen> createState() =>
      _JourneyPreviewScreenState();
}

class _JourneyPreviewScreenState extends ConsumerState<JourneyPreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _roadAnimationController;
  late AnimationController _heartsController;

  /// Build safe image widget with error handling for missing files
  Widget _buildSafeImageWidget(String photoPath) {
    return FutureBuilder<bool>(
      future: File(photoPath).exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return Image.file(
            File(photoPath),
            height: 100.h,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageErrorWidget();
            },
          );
        } else {
          return _buildImageErrorWidget();
        }
      },
    );
  }

  /// Build error widget for missing images
  Widget _buildImageErrorWidget() {
    return Container(
      height: 100.h,
      color: AppTheme.primaryPink.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 32,
            color: AppTheme.primaryPink.withValues(alpha: 0.5),
          ),
          SizedBox(height: 4),
          Text(
            'Image not found',
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.primaryPink.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  late Animation<double> _fadeAnimation;
  late Animation<double> _pinAnimation;

  final ScrollController _scrollController = ScrollController();
  List<MemoryModel> _memories = [];
  List<Offset> _roadPoints = [];
  late Season _currentSeason;

  @override
  void initState() {
    super.initState();
    _currentSeason = SeasonalThemeService.getCurrentSeason();
    _initAnimations();
    _loadMemories();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _roadAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _heartsController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _pinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _roadAnimationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _roadAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _heartsController.repeat();
    });
  }

  void _loadMemories() {
    final memoryState = ref.read(memoryJournalProvider);
    _memories = List.from(memoryState.memories);

    // Sort memories by date (oldest first for road progression)
    _memories.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    _generateRoadPoints();
  }

  void _generateRoadPoints() {
    _roadPoints.clear();

    if (_memories.isEmpty) return;

    // Use JourneyHelper to generate romantic road points
    _roadPoints = JourneyHelper.generateRoadPoints(
      screenSize: Size(400.w, 500.h),
      memoryCount: _memories.length,
      curveIntensity: 0.4,
    );

    // Calculate memory positions along the road
    final memoryPositions = JourneyHelper.calculateMemoryPositions(
      roadPoints: _roadPoints,
      memories: _memories,
    );

    // Assign positions to memories
    for (int i = 0; i < _memories.length && i < memoryPositions.length; i++) {
      _memories[i] = _memories[i].copyWith(
        roadPosition: memoryPositions[i],
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _roadAnimationController.dispose();
    _heartsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            Text(
              '${SeasonalThemeService.getSeasonalEmoji(_currentSeason)} Your Love Journey',
              style: BabyFont.headingM.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: BabyFont.bold,
              ),
            ),
            Text(
              SeasonalThemeService.getSeasonalMessage(_currentSeason),
              style: BabyFont.bodyS.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.primaryPink,
            size: 20.w,
          ),
        ),
      ),
      body: FloatingTextOverlay(
        texts: [
          '💕 Love is in the air',
          '🌸 Making memories together',
          '💖 Every moment counts',
          '✨ Your journey awaits',
        ],
        isActive: _memories.isNotEmpty,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Text(
                      'From your first meet to forever...',
                      style: BabyFont.bodyM.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    _buildJourneyStats(),
                  ],
                ),
              ),

              // Road Visualization
              Expanded(
                child: _memories.isEmpty
                    ? _buildEmptyJourney()
                    : SingleChildScrollView(
                        controller: _scrollController,
                        child: SizedBox(
                          height: 500.h,
                          child: CustomPaint(
                            painter: JourneyRoadPainter(
                              roadPoints: _roadPoints
                                  .map((offset) =>
                                      RoadPoint(offset.dx, offset.dy))
                                  .toList(),
                              memories: _memories,
                              pinAnimation: _pinAnimation.value,
                              season: _currentSeason,
                            ),
                            child: Stack(
                              children: [
                                // Memory pins
                                ..._memories.map((memory) {
                                  if (memory.roadPosition == null) {
                                    return SizedBox.shrink();
                                  }

                                  return Positioned(
                                    left: memory.roadPosition!.dx - 20.w,
                                    top: memory.roadPosition!.dy - 20.h,
                                    child: _buildMemoryPin(memory),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),

              // Bottom section
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Text(
                      'Your next memory is waiting to be written...',
                      style: BabyFont.bodyM.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddMemoryScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentYellow,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          elevation: 8,
                          shadowColor:
                              AppTheme.accentYellow.withValues(alpha: 0.3),
                        ),
                        icon: Icon(Icons.add, size: 20.w),
                        label: Text(
                          'Add New Memory 💞',
                          style: BabyFont.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyStats() {
    final totalMemories = _memories.length;
    final favoriteMemories = _memories.where((m) => m.isFavorite).length;
    final daysSinceFirst = _memories.isNotEmpty
        ? DateTime.now()
            .difference(
                DateTime.fromMillisecondsSinceEpoch(_memories.first.timestamp))
            .inDays
        : 0;

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              '$totalMemories', 'Memories', Icons.book, AppTheme.primaryPink),
          _buildStatItem('$favoriteMemories', 'Favorites', Icons.favorite,
              AppTheme.primaryBlue),
          _buildStatItem('$daysSinceFirst', 'Days', Icons.calendar_today,
              AppTheme.accentYellow),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.w),
        SizedBox(height: 4.h),
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
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyJourney() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route,
            color: AppTheme.accentYellow,
            size: 80.w,
          ),
          SizedBox(height: 20.h),
          Text(
            'No Journey Yet',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start creating memories to see your love journey!',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryPin(MemoryModel memory) {
    final pinColor = _getPinColor(memory.mood);

    return GestureDetector(
      onTap: () => _showMemoryDetails(memory),
      child: AnimatedBuilder(
        animation: _pinAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pinAnimation.value,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: pinColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: pinColor.withValues(alpha: 0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  memory.emoji,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getPinColor(String mood) {
    // Use seasonal colors as base, with mood-based variations
    final baseColor = SeasonalThemeService.getPinColor(_currentSeason);
    final accentColor = SeasonalThemeService.getPinAccentColor(_currentSeason);

    switch (mood) {
      case 'joyful':
        return baseColor;
      case 'romantic':
        return accentColor;
      case 'fun':
        return baseColor.withValues(alpha: 0.8);
      case 'sweet':
        return accentColor.withValues(alpha: 0.8);
      case 'emotional':
        return baseColor.withValues(alpha: 0.6);
      case 'excited':
        return accentColor;
      default:
        return baseColor;
    }
  }

  void _showMemoryDetails(MemoryModel memory) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(memory.emoji, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                memory.title,
                style: BabyFont.headingM.copyWith(color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              memory.description,
              style: BabyFont.bodyM.copyWith(color: AppTheme.textSecondary),
            ),
            if (memory.photoPath != null) ...[
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: _buildSafeImageWidget(memory.photoPath!),
              ),
            ],
            SizedBox(height: 12.h),
            Text(
              _formatDate(
                  DateTime.fromMillisecondsSinceEpoch(memory.timestamp)),
              style: BabyFont.bodyS.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
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

/// Road point for path generation
class RoadPoint {
  final double x;
  final double y;

  RoadPoint(this.x, this.y);
}

/// Custom painter for the journey road
class JourneyRoadPainter extends CustomPainter {
  final List<RoadPoint> roadPoints;
  final List<MemoryModel> memories;
  final double pinAnimation;
  final Season season;

  JourneyRoadPainter({
    required this.roadPoints,
    required this.memories,
    required this.pinAnimation,
    required this.season,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (roadPoints.isEmpty) return;

    final paint = Paint()
      ..color = SeasonalThemeService.getRoadColor(season)
      ..strokeWidth = 8.w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = SeasonalThemeService.getRoadShadowColor(season)
      ..strokeWidth = 8.w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw road shadow
    final shadowPath = Path();
    for (int i = 0; i < roadPoints.length; i++) {
      final point = roadPoints[i];
      if (i == 0) {
        shadowPath.moveTo(point.x, point.y + 2);
      } else {
        shadowPath.lineTo(point.x, point.y + 2);
      }
    }
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main road
    final roadPath = Path();
    for (int i = 0; i < roadPoints.length; i++) {
      final point = roadPoints[i];
      if (i == 0) {
        roadPath.moveTo(point.x, point.y);
      } else {
        roadPath.lineTo(point.x, point.y);
      }
    }
    canvas.drawPath(roadPath, paint);

    // Draw road center line
    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerPath = Path();
    for (int i = 0; i < roadPoints.length; i++) {
      final point = roadPoints[i];
      if (i == 0) {
        centerPath.moveTo(point.x, point.y);
      } else {
        centerPath.lineTo(point.x, point.y);
      }
    }
    canvas.drawPath(centerPath, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
