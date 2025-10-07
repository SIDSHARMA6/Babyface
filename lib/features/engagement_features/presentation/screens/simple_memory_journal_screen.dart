import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/widgets/toast_service.dart';

class MemoryJournalScreen extends StatefulWidget {
  const MemoryJournalScreen({super.key});

  @override
  State<MemoryJournalScreen> createState() => _MemoryJournalScreenState();
}

class _MemoryJournalScreenState extends State<MemoryJournalScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<MemoryEntry> _memories = [];
  bool _isAddingMemory = false;

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

    // Add some sample memories
    _memories = [
      MemoryEntry(
        id: '1',
        title: 'Our First Date 💕',
        content:
            'Remember when we went to that cute little café? The way you smiled when you saw me...',
        date: DateTime.now().subtract(const Duration(days: 30)),
        mood: 'happy',
        isFavorite: true,
      ),
      MemoryEntry(
        id: '2',
        title: 'Movie Night 🍿',
        content:
            'We watched that romantic movie and you cried at the end. So adorable!',
        date: DateTime.now().subtract(const Duration(days: 15)),
        mood: 'romantic',
        isFavorite: false,
      ),
      MemoryEntry(
        id: '3',
        title: 'Cooking Together 👨‍🍳',
        content:
            'The kitchen was a mess but we had so much fun making pasta together!',
        date: DateTime.now().subtract(const Duration(days: 7)),
        mood: 'fun',
        isFavorite: true,
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addMemory() {
    setState(() {
      _isAddingMemory = true;
    });

    // Simulate adding memory
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      
      final newMemory = MemoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Memory ✨',
        content: 'A beautiful moment we shared together...',
        date: DateTime.now(),
        mood: 'happy',
        isFavorite: false,
      );

      setState(() {
        _memories.insert(0, newMemory);
        _isAddingMemory = false;
      });

      ToastService.showLove(context, 'Memory added to our journal! 📖💕');
    });
  }

  void _toggleFavorite(String id) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Memory Journal 📖',
          style: BabyFont.headingM.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: BabyFont.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addMemory,
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
            // Stats Section
            Container(
              margin: EdgeInsets.all(20.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentYellow.withValues(alpha: 0.1),
                    blurRadius: 15.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${_memories.length}', 'Memories', Icons.book,
                      AppTheme.primaryPink),
                  _buildStatItem(
                      '${_memories.where((m) => m.isFavorite).length}',
                      'Favorites',
                      Icons.favorite,
                      AppTheme.primaryBlue),
                  _buildStatItem(
                      '${_memories.where((m) => m.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length}',
                      'This Week',
                      Icons.calendar_today,
                      AppTheme.accentYellow),
                ],
              ),
            ),

            // Memories List
            Expanded(
              child: _memories.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: _memories.length,
                      itemBuilder: (context, index) {
                        final memory = _memories[index];
                        return _buildMemoryCard(memory);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemory,
        backgroundColor: AppTheme.accentYellow,
        child: _isAddingMemory
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Icon(
                Icons.add,
                color: Colors.white,
                size: 24.w,
              ),
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.w),
        SizedBox(height: 8.h),
        Text(
          value,
          style: BabyFont.headingM.copyWith(
            color: color,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            color: AppTheme.accentYellow,
            size: 80.w,
          ),
          SizedBox(height: 20.h),
          Text(
            'No Memories Yet',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start capturing your beautiful moments together!',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _addMemory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentYellow,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: Text(
              'Add First Memory',
              style: BabyFont.bodyM.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(MemoryEntry memory) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentYellow.withValues(alpha: 0.1),
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
              GestureDetector(
                onTap: () => _toggleFavorite(memory.id),
                child: Icon(
                  memory.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: memory.isFavorite ? AppTheme.primaryPink : Colors.grey,
                  size: 20.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            memory.content,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildMoodChip(memory.mood),
              const Spacer(),
              Text(
                _formatDate(memory.date),
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChip(String mood) {
    Color color;
    String emoji;

    switch (mood) {
      case 'happy':
        color = AppTheme.accentYellow;
        emoji = '😊';
        break;
      case 'romantic':
        color = AppTheme.primaryPink;
        emoji = '💕';
        break;
      case 'fun':
        color = AppTheme.primaryBlue;
        emoji = '😄';
        break;
      default:
        color = Colors.grey;
        emoji = '😊';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: 12.sp),
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
  final String content;
  final DateTime date;
  final String mood;
  final bool isFavorite;

  MemoryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.isFavorite,
  });

  MemoryEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? mood,
    bool? isFavorite,
  }) {
    return MemoryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
