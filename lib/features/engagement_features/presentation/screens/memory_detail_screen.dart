import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../../data/models/memory_model.dart';
import '../providers/memory_journal_provider.dart';
import 'add_memory_screen.dart';

/// Memory Detail Screen
/// Follows memory_journey.md specification for viewing/editing memories
class MemoryDetailScreen extends ConsumerWidget {
  final MemoryModel memory;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
  });

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
            width: double.infinity,
            height: 200,
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
      color: AppTheme.primaryPink.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 48,
            color: AppTheme.primaryPink.withValues(alpha: 0.5),
          ),
          SizedBox(height: 8),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(memoryJournalProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Memory Details',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _editMemory(context, memory),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _deleteMemory(context, notifier, memory.id),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPink.withValues(alpha: 0.1),
              AppTheme.primaryBlue.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: context.responsivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMemoryHeader(context),
              SizedBox(height: context.responsiveHeight(2)),
              _buildMemoryContent(context),
              SizedBox(height: context.responsiveHeight(2)),
              _buildMemoryActions(context, notifier),
              SizedBox(height: context.responsiveHeight(3)),
              _buildHeartAnimation(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryHeader(BuildContext context) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                memory.emoji,
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(width: context.responsiveWidth(2)),
              Expanded(
                child: OptimizedText(
                  memory.title,
                  style: BabyFont.headingL.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (memory.isFavorite)
                Icon(
                  Icons.favorite,
                  color: AppTheme.primaryPink,
                  size: context.responsiveFont(24),
                ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(1)),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppTheme.textSecondary,
                size: context.responsiveFont(16),
              ),
              SizedBox(width: context.responsiveWidth(1)),
              OptimizedText(
                _formatDate(
                    DateTime.fromMillisecondsSinceEpoch(memory.timestamp)),
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              if (memory.location != null) ...[
                SizedBox(width: context.responsiveWidth(2)),
                Icon(
                  Icons.location_on,
                  color: AppTheme.textSecondary,
                  size: context.responsiveFont(16),
                ),
                SizedBox(width: context.responsiveWidth(0.5)),
                OptimizedText(
                  memory.location!,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryContent(BuildContext context) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
        border: Border.all(
          color: AppTheme.primaryPink.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptimizedText(
            'Description',
            style: BabyFont.headingS.copyWith(
              color: AppTheme.primaryPink,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            memory.description,
            style: BabyFont.bodyL.copyWith(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          if (memory.photoPath != null) ...[
            SizedBox(height: context.responsiveHeight(2)),
            _buildPhotoSection(context),
          ],
          if (memory.voicePath != null) ...[
            SizedBox(height: context.responsiveHeight(2)),
            _buildVoiceSection(context),
          ],
          if (memory.tags.isNotEmpty) ...[
            SizedBox(height: context.responsiveHeight(2)),
            _buildTagsSection(context),
          ],
          SizedBox(height: context.responsiveHeight(1)),
          _buildMoodSection(context),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Photo',
          style: BabyFont.headingS.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            child: _buildSafeImageWidget(memory.photoPath!),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Voice Note',
          style: BabyFont.headingS.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Container(
          padding: context.responsivePadding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            border: Border.all(
              color: AppTheme.primaryPink.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_filled,
                color: AppTheme.primaryPink,
                size: context.responsiveFont(32),
              ),
              SizedBox(width: context.responsiveWidth(2)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OptimizedText(
                      'Voice Memory',
                      style: BabyFont.bodyM.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    OptimizedText(
                      'Tap to play',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.volume_up,
                color: AppTheme.primaryPink,
                size: context.responsiveFont(20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Tags',
          style: BabyFont.headingS.copyWith(
            color: AppTheme.primaryPink,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Wrap(
          spacing: context.responsiveWidth(1),
          runSpacing: context.responsiveHeight(0.5),
          children:
              memory.tags.map((tag) => _buildTagChip(context, tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(2),
        vertical: context.responsiveHeight(0.5),
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
        border: Border.all(
          color: AppTheme.primaryPink.withValues(alpha: 0.5),
        ),
      ),
      child: OptimizedText(
        '#$tag',
        style: BabyFont.bodyS.copyWith(
          color: AppTheme.primaryPink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMoodSection(BuildContext context) {
    return Row(
      children: [
        OptimizedText(
          'Mood: ',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(2),
            vertical: context.responsiveHeight(0.5),
          ),
          decoration: BoxDecoration(
            color: _getMoodColor(memory.mood).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
          ),
          child: OptimizedText(
            _getMoodLabel(memory.mood),
            style: BabyFont.bodyM.copyWith(
              color: _getMoodColor(memory.mood),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryActions(
      BuildContext context, MemoryJournalNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: OptimizedButton(
            text: 'Edit Memory',
            onPressed: () => _editMemory(context, memory),
            type: ButtonType.primary,
            size: ButtonSize.large,
            icon: const Icon(Icons.edit),
          ),
        ),
        SizedBox(width: context.responsiveWidth(2)),
        Expanded(
          child: OptimizedButton(
            text: memory.isFavorite
                ? 'Remove from Favorites'
                : 'Add to Favorites',
            onPressed: () => notifier.toggleFavorite(memory.id),
            type: ButtonType.secondary,
            size: ButtonSize.large,
            icon: Icon(
                memory.isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ),
      ],
    );
  }

  Widget _buildHeartAnimation(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween(begin: 0.8, end: 1.2),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Icon(
              Icons.favorite,
              color: AppTheme.primaryPink.withValues(alpha: 0.6),
              size: context.responsiveFont(48),
            ),
          );
        },
        onEnd: () {
          // Restart animation
        },
      ),
    );
  }

  void _editMemory(BuildContext context, MemoryModel memory) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMemoryScreen(
          existingMemory: memory,
        ),
      ),
    );
  }

  void _deleteMemory(
      BuildContext context, MemoryJournalNotifier notifier, String memoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: OptimizedText(
          'Delete Memory',
          style: BabyFont.headingS,
        ),
        content: OptimizedText(
          'Are you sure you want to delete this memory? This action cannot be undone.',
          style: BabyFont.bodyM,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: OptimizedText(
              'Cancel',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteMemory(memoryId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: OptimizedText(
              'Delete',
              style: BabyFont.bodyM.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
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
