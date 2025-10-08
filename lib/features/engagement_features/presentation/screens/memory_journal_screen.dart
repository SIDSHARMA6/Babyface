import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../providers/memory_journal_provider.dart';
import '../../data/models/memory_model.dart';
import '../widgets/shimmer_widget.dart';
import 'add_memory_screen.dart';
import 'journey_preview_screen.dart';

/// Memory Journal Screen
/// Follows master plan theme standards and performance requirements
class MemoryJournalScreen extends OptimizedStatefulWidget {
  const MemoryJournalScreen({super.key});

  @override
  OptimizedState<MemoryJournalScreen> createState() =>
      _MemoryJournalScreenState();
}

class _MemoryJournalScreenState extends OptimizedState<MemoryJournalScreen> {
  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memoryJournalProvider);
    final notifier = ref.read(memoryJournalProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          '💖 Our Memory Journal',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _navigateToAddMemory(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: OptimizedContainer(
        padding: context.responsivePadding,
        child: Column(
          children: [
            if (state.isLoading) ...[
              Expanded(child: _buildLoadingState()),
            ] else if (state.memories.isEmpty) ...[
              Expanded(child: _buildEmptyState(context, notifier)),
            ] else ...[
              Expanded(
                  child: _buildMemoriesList(state.memories, context, notifier)),
            ],
            if (state.errorMessage != null) ...[
              _buildErrorMessage(state.errorMessage!, notifier),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Loading memories...',
            style: BabyFont.bodyL.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, MemoryJournalNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: context.responsiveHeight(12),
            color: AppTheme.primaryPink.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'No memories yet',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Start documenting your journey together',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(3)),
          OptimizedButton(
            text: 'Add First Memory',
            onPressed: () => _navigateToAddMemory(context),
            type: ButtonType.primary,
            size: ButtonSize.large,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoriesList(List<MemoryModel> memories, BuildContext context,
      MemoryJournalNotifier notifier) {
    return Column(
      children: [
        _buildStatsHeader(memories),
        SizedBox(height: context.responsiveHeight(2)),
        // Preview Journey Button
        if (memories.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: context.responsiveHeight(2)),
            child: OptimizedButton(
              text: 'Preview Your Journey 💞',
              onPressed: () => _navigateToJourneyPreview(context),
              type: ButtonType.primary,
              size: ButtonSize.large,
              icon: const Icon(Icons.route),
            ),
          ),
        Expanded(
          child: memories.isEmpty
              ? ListView.builder(
                  itemCount: 3, // Show 3 shimmer cards
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          EdgeInsets.only(bottom: context.responsiveHeight(1)),
                      child: ShimmerCard(
                        height: 120,
                        borderRadius: context.responsiveRadius(16),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: memories.length,
                  itemBuilder: (context, index) {
                    final memory = memories[index];
                    return _buildMemoryCard(memory, context, notifier);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(List<MemoryModel> memories) {
    final totalMemories = memories.length;
    final favoriteMemories = memories.where((m) => m.isFavorite).length;
    final thisMonth = memories
        .where((m) =>
            DateTime.fromMillisecondsSinceEpoch(m.timestamp).month ==
                DateTime.now().month &&
            DateTime.fromMillisecondsSinceEpoch(m.timestamp).year ==
                DateTime.now().year)
        .length;

    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPink, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Total', totalMemories.toString()),
          ),
          Container(
            width: 1,
            height: context.responsiveHeight(4),
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem('Favorites', favoriteMemories.toString()),
          ),
          Container(
            width: 1,
            height: context.responsiveHeight(4),
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem('This Month', thisMonth.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        OptimizedText(
          value,
          style: BabyFont.headingL.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.5)),
        OptimizedText(
          label,
          style: BabyFont.bodyS.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryCard(MemoryModel memory, BuildContext context,
      MemoryJournalNotifier notifier) {
    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getMoodColor(memory.mood).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                memory.emoji,
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: context.responsiveWidth(2)),
              Expanded(
                child: OptimizedText(
                  memory.title,
                  style: BabyFont.headingS,
                ),
              ),
              if (memory.isFavorite)
                Icon(
                  Icons.favorite,
                  color: AppTheme.primaryPink,
                  size: context.responsiveFont(20),
                ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            memory.description,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (memory.photoPath != null) ...[
            SizedBox(height: context.responsiveHeight(1)),
            Container(
              height: context.responsiveHeight(12),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(context.responsiveRadius(8)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(context.responsiveRadius(8)),
                child: Image.file(
                  File(memory.photoPath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ],
          SizedBox(height: context.responsiveHeight(1)),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(2),
                  vertical: context.responsiveHeight(0.5),
                ),
                decoration: BoxDecoration(
                  color: _getMoodColor(memory.mood).withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius(12)),
                ),
                child: OptimizedText(
                  _getMoodLabel(memory.mood),
                  style: BabyFont.bodyS.copyWith(
                    color: _getMoodColor(memory.mood),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (memory.location != null) ...[
                SizedBox(width: context.responsiveWidth(1)),
                Icon(
                  Icons.location_on,
                  color: AppTheme.textSecondary,
                  size: context.responsiveFont(16),
                ),
                SizedBox(width: context.responsiveWidth(0.5)),
                OptimizedText(
                  memory.location!,
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              const Spacer(),
              OptimizedText(
                _formatDate(
                    DateTime.fromMillisecondsSinceEpoch(memory.timestamp)),
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error, MemoryJournalNotifier notifier) {
    return Container(
      margin: EdgeInsets.only(top: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: context.responsiveFont(20),
          ),
          SizedBox(width: context.responsiveWidth(2)),
          Expanded(
            child: OptimizedText(
              error,
              style: BabyFont.bodyM.copyWith(
                color: Colors.red,
              ),
            ),
          ),
          IconButton(
            onPressed: () => notifier.clearError(),
            icon: const Icon(Icons.close),
            color: Colors.red,
          ),
        ],
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
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Navigation methods
  void _navigateToAddMemory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMemoryScreen(),
      ),
    );
  }

  void _navigateToJourneyPreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JourneyPreviewScreen(),
      ),
    );
  }

  // Mood helper methods
  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'excited':
        return Colors.orange;
      case 'romantic':
        return Colors.pink;
      case 'grateful':
        return Colors.purple;
      case 'peaceful':
        return Colors.blue;
      case 'nostalgic':
        return Colors.indigo;
      default:
        return AppTheme.primaryPink;
    }
  }

  String _getMoodLabel(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return 'Happy';
      case 'excited':
        return 'Excited';
      case 'romantic':
        return 'Romantic';
      case 'grateful':
        return 'Grateful';
      case 'peaceful':
        return 'Peaceful';
      case 'nostalgic':
        return 'Nostalgic';
      default:
        return 'Happy';
    }
  }
}
