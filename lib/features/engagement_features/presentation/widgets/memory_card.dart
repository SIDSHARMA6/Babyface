import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../../data/models/memory_model.dart';
import '../providers/memory_journal_provider.dart';
import '../screens/memory_detail_screen.dart';
import 'heartbeat_widget.dart';

/// Memory Card Widget
/// Follows memory_journey.md specification for displaying memory cards
class MemoryCard extends ConsumerWidget {
  final MemoryModel memory;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MemoryCard({
    super.key,
    required this.memory,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(memoryJournalProvider.notifier);

    return GestureDetector(
      onTap: onTap ?? () => _navigateToDetail(context),
      onLongPress: onLongPress ?? () => _showMemoryOptions(context, notifier),
      child: HeartbeatWidget(
        isActive: memory.isFavorite,
        child: Container(
          margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: _getMoodColor(memory.mood).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: _getMoodColor(memory.mood).withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(context),
              _buildCardContent(context),
              _buildCardFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.responsivePadding.left),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getMoodColor(memory.mood).withValues(alpha: 0.1),
            _getMoodColor(memory.mood).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.responsiveRadius(16)),
          topRight: Radius.circular(context.responsiveRadius(16)),
        ),
      ),
      child: Row(
        children: [
          // Emoji with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Text(
                  memory.emoji,
                  style: TextStyle(fontSize: 28),
                ),
              );
            },
          ),
          SizedBox(width: context.responsiveWidth(2)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OptimizedText(
                  memory.title,
                  style: BabyFont.headingS.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.responsiveHeight(0.5)),
                OptimizedText(
                  _formatDate(
                      DateTime.fromMillisecondsSinceEpoch(memory.timestamp)),
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (memory.isFavorite)
          Container(
            padding: EdgeInsets.all(context.responsiveWidth(1)),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              color: AppTheme.primaryPink,
              size: context.responsiveFont(16),
            ),
          ),
        SizedBox(width: context.responsiveWidth(1)),
        Container(
          padding: EdgeInsets.all(context.responsiveWidth(1)),
          decoration: BoxDecoration(
            color: _getMoodColor(memory.mood).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getMoodIcon(memory.mood),
            color: _getMoodColor(memory.mood),
            size: context.responsiveFont(16),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.responsivePadding.left),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptimizedText(
            memory.description,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (memory.photoPath != null) ...[
            SizedBox(height: context.responsiveHeight(1)),
            _buildPhotoPreview(context),
          ],
          if (memory.tags.isNotEmpty) ...[
            SizedBox(height: context.responsiveHeight(1)),
            _buildTagsPreview(context),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(BuildContext context) {
    return Container(
      height: context.responsiveHeight(12),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
        child: Image.file(
          File(memory.photoPath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.primaryPink.withValues(alpha: 0.1),
              child: Icon(
                Icons.image,
                color: AppTheme.primaryPink,
                size: context.responsiveFont(32),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTagsPreview(BuildContext context) {
    return Wrap(
      spacing: context.responsiveWidth(1),
      runSpacing: context.responsiveHeight(0.5),
      children: memory.tags
          .take(3)
          .map((tag) => _buildTagChip(context, tag))
          .toList(),
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(1.5),
        vertical: context.responsiveHeight(0.3),
      ),
      decoration: BoxDecoration(
        color: _getMoodColor(memory.mood).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        border: Border.all(
          color: _getMoodColor(memory.mood).withValues(alpha: 0.3),
        ),
      ),
      child: OptimizedText(
        '#$tag',
        style: BabyFont.bodyS.copyWith(
          color: _getMoodColor(memory.mood),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.responsivePadding.left),
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.responsiveRadius(16)),
          bottomRight: Radius.circular(context.responsiveRadius(16)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveWidth(2),
              vertical: context.responsiveHeight(0.5),
            ),
            decoration: BoxDecoration(
              color: _getMoodColor(memory.mood).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getMoodIcon(memory.mood),
                  color: _getMoodColor(memory.mood),
                  size: context.responsiveFont(14),
                ),
                SizedBox(width: context.responsiveWidth(0.5)),
                OptimizedText(
                  _getMoodLabel(memory.mood),
                  style: BabyFont.bodyS.copyWith(
                    color: _getMoodColor(memory.mood),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (memory.location != null) ...[
            SizedBox(width: context.responsiveWidth(1)),
            Icon(
              Icons.location_on,
              color: AppTheme.textSecondary,
              size: context.responsiveFont(14),
            ),
            SizedBox(width: context.responsiveWidth(0.5)),
            Expanded(
              child: OptimizedText(
                memory.location!,
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const Spacer(),
          if (memory.voicePath != null)
            Icon(
              Icons.mic,
              color: AppTheme.primaryPink,
              size: context.responsiveFont(16),
            ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailScreen(memory: memory),
      ),
    );
  }

  void _showMemoryOptions(
      BuildContext context, MemoryJournalNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.responsiveRadius(20)),
            topRight: Radius.circular(context.responsiveRadius(20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin:
                  EdgeInsets.symmetric(vertical: context.responsiveHeight(1)),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                memory.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: AppTheme.primaryPink,
              ),
              title: OptimizedText(
                memory.isFavorite
                    ? 'Remove from Favorites'
                    : 'Add to Favorites',
                style: BabyFont.bodyM,
              ),
              onTap: () {
                notifier.toggleFavorite(memory.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.primaryBlue),
              title: OptimizedText(
                'Edit Memory',
                style: BabyFont.bodyM,
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToDetail(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: OptimizedText(
                'Delete Memory',
                style: BabyFont.bodyM.copyWith(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, notifier);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, MemoryJournalNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: OptimizedText(
          'Delete Memory',
          style: BabyFont.headingS,
        ),
        content: OptimizedText(
          'Are you sure you want to delete "${memory.title}"? This action cannot be undone.',
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
              notifier.deleteMemory(memory.id);
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

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'excited':
        return Icons.celebration;
      case 'romantic':
        return Icons.favorite;
      case 'grateful':
        return Icons.volunteer_activism;
      case 'peaceful':
        return Icons.spa;
      case 'nostalgic':
        return Icons.history;
      default:
        return Icons.sentiment_satisfied;
    }
  }
}
