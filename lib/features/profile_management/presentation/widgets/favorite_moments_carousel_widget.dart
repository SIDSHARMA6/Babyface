import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/favorite_moments_service.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Favorite moments carousel widget for profile screen
class FavoriteMomentsCarouselWidget extends StatefulWidget {
  const FavoriteMomentsCarouselWidget({super.key});

  @override
  State<FavoriteMomentsCarouselWidget> createState() =>
      _FavoriteMomentsCarouselWidgetState();
}

class _FavoriteMomentsCarouselWidgetState
    extends State<FavoriteMomentsCarouselWidget> {
  final FavoriteMomentsService _momentsService =
      FavoriteMomentsService.instance;
  List<FavoriteMoment> _moments = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMoments();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadMoments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final moments = await _momentsService.getRecentMoments(limit: 10);
      final stats = await _momentsService.getMomentsStatistics();

      setState(() {
        _moments = moments;
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
                  Icons.favorite,
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
                      'Favorite Moments',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Your most cherished memories',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showAddMomentDialog,
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
          else if (_moments.isEmpty)
            _buildEmptyState()
          else
            _buildCarouselContent(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.star_border,
          size: 48.w,
          color: AppTheme.textSecondary,
        ),
        SizedBox(height: 12.h),
        Text(
          'No favorite moments yet',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Start capturing your special memories together!',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: _showAddMomentDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text('Add First Moment'),
        ),
      ],
    );
  }

  Widget _buildCarouselContent() {
    return Column(
      children: [
        // Statistics
        _buildStatistics(),
        SizedBox(height: 16.h),

        // Carousel
        _buildCarousel(),
        SizedBox(height: 16.h),

        // Page indicators
        _buildPageIndicators(),
        SizedBox(height: 16.h),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _showAddMomentDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  side: BorderSide(color: AppTheme.primaryPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Add Moment'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _showAllMoments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('View All'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final totalMoments = _statistics['totalMoments'] ?? 0;
    final averageLoveScore = _statistics['averageLoveScore'] ?? 0.0;
    final topMomentType = _statistics['topMomentType'] ?? '';

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
              'Moments',
              totalMoments.toString(),
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
              'Love Score',
              averageLoveScore.toStringAsFixed(1),
              Icons.favorite,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Top Type',
              topMomentType.isNotEmpty ? topMomentType : 'None',
              Icons.category,
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

  Widget _buildCarousel() {
    return Container(
      height: 200.h,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: _moments.length,
        itemBuilder: (context, index) {
          final moment = _moments[index];
          return _buildMomentCard(moment);
        },
      ),
    );
  }

  Widget _buildMomentCard(FavoriteMoment moment) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Background image or gradient
            if (moment.photoPath != null &&
                File(moment.photoPath!).existsSync())
              Image.file(
                File(moment.photoPath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(int.parse(
                          moment.momentType.color.replaceAll('#', '0xFF'))),
                      Color(int.parse(
                              moment.momentType.color.replaceAll('#', '0xFF')))
                          .withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Moment type and emoji
                    Row(
                      children: [
                        Text(
                          moment.momentType.emoji,
                          style: TextStyle(fontSize: 20.sp),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            moment.momentType.displayName,
                            style: BabyFont.bodyS.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 12.w,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${moment.loveScore}',
                                style: BabyFont.bodyS.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Title
                    Text(
                      moment.title,
                      style: BabyFont.headingM.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),

                    // Description
                    Text(
                      moment.description,
                      style: BabyFont.bodyS.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),

                    // Date
                    Text(
                      _formatDate(moment.momentDate),
                      style: BabyFont.bodyS.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _moments.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: _currentIndex == index ? 24.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? AppTheme.primaryPink
                : AppTheme.textSecondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddMomentDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMomentDialog(
        onMomentAdded: () {
          _loadMoments();
        },
      ),
    );
  }

  void _showAllMoments() {
    showDialog(
      context: context,
      builder: (context) => AllMomentsDialog(
        moments: _moments,
        onMomentUpdated: () {
          _loadMoments();
        },
      ),
    );
  }
}

/// Add moment dialog
class AddMomentDialog extends StatefulWidget {
  final VoidCallback onMomentAdded;

  const AddMomentDialog({
    super.key,
    required this.onMomentAdded,
  });

  @override
  State<AddMomentDialog> createState() => _AddMomentDialogState();
}

class _AddMomentDialogState extends State<AddMomentDialog> {
  final FavoriteMomentsService _momentsService =
      FavoriteMomentsService.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String _selectedMomentType = 'memory';
  DateTime _selectedDate = DateTime.now();
  int _loveScore = 5;
  bool _isShared = false;

  final List<Map<String, dynamic>> _momentTypes = [
    {'type': 'anniversary', 'name': 'Anniversary', 'emoji': '🎉'},
    {'type': 'date', 'name': 'Date', 'emoji': '💕'},
    {'type': 'vacation', 'name': 'Vacation', 'emoji': '✈️'},
    {'type': 'surprise', 'name': 'Surprise', 'emoji': '🎁'},
    {'type': 'achievement', 'name': 'Achievement', 'emoji': '🏆'},
    {'type': 'milestone', 'name': 'Milestone', 'emoji': '🎯'},
    {'type': 'memory', 'name': 'Memory', 'emoji': '💝'},
    {'type': 'adventure', 'name': 'Adventure', 'emoji': '🗺️'},
    {'type': 'celebration', 'name': 'Celebration', 'emoji': '🎊'},
    {'type': 'romantic', 'name': 'Romantic', 'emoji': '🌹'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Favorite Moment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Moment type selection
            Text(
              'What type of moment?',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildMomentTypeGrid(),
            SizedBox(height: 20.h),

            // Title input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Moment Title',
                hintText: 'Give your moment a title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Description input
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe what made this moment special...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),

            // Date selection
            ListTile(
              title: Text('Date'),
              subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              trailing: Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            SizedBox(height: 16.h),

            // Love score
            Text(
              'Love Score: $_loveScore',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            Slider(
              value: _loveScore.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppTheme.primaryPink,
              onChanged: (value) {
                setState(() {
                  _loveScore = value.round();
                });
              },
            ),
            SizedBox(height: 16.h),

            // Tags input
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: 'Tags (optional)',
                hintText: 'anniversary, special, unforgettable',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Shared toggle
            Row(
              children: [
                Checkbox(
                  value: _isShared,
                  onChanged: (value) {
                    setState(() {
                      _isShared = value ?? false;
                    });
                  },
                  activeColor: AppTheme.primaryPink,
                ),
                Text('Share this moment with your partner'),
              ],
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
          onPressed: _titleController.text.isNotEmpty ? _saveMoment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
          ),
          child: Text('Save Moment'),
        ),
      ],
    );
  }

  Widget _buildMomentTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: _momentTypes.length,
      itemBuilder: (context, index) {
        final momentType = _momentTypes[index];
        final isSelected = _selectedMomentType == momentType['type'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMomentType = momentType['type'];
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
                  momentType['emoji'],
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  momentType['name'],
                  style: BabyFont.bodyS.copyWith(
                    color: isSelected
                        ? AppTheme.primaryPink
                        : AppTheme.textSecondary,
                    fontSize: 10.sp,
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

  Future<void> _selectDate() async {
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
  }

  Future<void> _saveMoment() async {
    try {
      final tags = _tagsController.text.isNotEmpty
          ? _tagsController.text.split(',').map((tag) => tag.trim()).toList()
          : <String>[];

      final moment = FavoriteMoment(
        id: 'moment_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        description: _descriptionController.text,
        momentType: _selectedMomentType,
        momentDate: _selectedDate,
        tags: tags,
        isShared: _isShared,
        loveScore: _loveScore,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _momentsService.addFavoriteMoment(moment);
      if (success && mounted) {
        Navigator.pop(context);
        widget.onMomentAdded();
        ToastService.showSuccess(context, 'Favorite moment saved! ⭐');
      } else {
        ToastService.showError(context, 'Failed to save moment');
      }
    } catch (e) {
      ToastService.showError(context, 'Failed to save moment: ${e.toString()}');
    }
  }
}

/// All moments dialog
class AllMomentsDialog extends StatelessWidget {
  final List<FavoriteMoment> moments;
  final VoidCallback onMomentUpdated;

  const AllMomentsDialog({
    super.key,
    required this.moments,
    required this.onMomentUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('All Favorite Moments'),
      content: Container(
        width: double.maxFinite,
        height: 400.h,
        child: ListView.builder(
          itemCount: moments.length,
          itemBuilder: (context, index) {
            final moment = moments[index];
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppTheme.textSecondary.withValues(alpha: 0.1),
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Color(int.parse(
                            moment.momentType.color.replaceAll('#', '0xFF')))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      moment.momentType.emoji,
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                ),
                title: Text(moment.title),
                subtitle: Text(moment.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: AppTheme.primaryPink,
                      size: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    Text('${moment.loveScore}'),
                  ],
                ),
                onTap: () {
                  _showMomentDetails(context, moment);
                },
              ),
            );
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

  void _showMomentDetails(BuildContext context, FavoriteMoment moment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(moment.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                moment.description,
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Type: ${moment.momentType.displayName}'),
                  Text('Score: ${moment.loveScore}'),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                  'Date: ${moment.momentDate.day}/${moment.momentDate.month}/${moment.momentDate.year}'),
            ],
          ),
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
}
