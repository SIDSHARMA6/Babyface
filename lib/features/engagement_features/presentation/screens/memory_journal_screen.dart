import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../providers/memory_journal_provider.dart';
import '../../domain/entities/memory_journal_entity.dart';

/// Memory Journal Screen
/// Follows master plan theme standards and performance requirements
class MemoryJournalScreen extends OptimizedStatefulWidget {
  const MemoryJournalScreen({super.key});

  @override
  OptimizedState<MemoryJournalScreen> createState() => _MemoryJournalScreenState();
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
          'Memory Journal',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddMemoryDialog(context, notifier),
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
              Expanded(child: _buildEmptyState()),
            ] else ...[
              Expanded(child: _buildMemoriesList(state.memories)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: context.responsiveHeight(12),
            color: AppTheme.primary.withValues(alpha: 0.5),
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
            onPressed: () => _showAddMemoryDialog(context, ref.read(memoryJournalProvider.notifier)),
            type: ButtonType.primary,
            size: ButtonSize.large,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoriesList(List<MemoryJournalEntity> memories) {
    return Column(
      children: [
        _buildStatsHeader(memories),
        SizedBox(height: context.responsiveHeight(2)),
        Expanded(
          child: ListView.builder(
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return _buildMemoryCard(memory);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(List<MemoryJournalEntity> memories) {
    final totalMemories = memories.length;
    final favoriteMemories = memories.where((m) => m.isFavorite).length;
    final thisMonth = memories.where((m) => 
      m.createdAt.month == DateTime.now().month &&
      m.createdAt.year == DateTime.now().year
    ).length;

    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
        boxShadow: AppTheme.softShadow,
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

  Widget _buildMemoryCard(MemoryJournalEntity memory) {
    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: _getMemoryTypeColor(memory.type).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OptimizedText(
                  memory.title,
                  style: BabyFont.headingS,
                ),
              ),
              if (memory.isFavorite)
                Icon(
                  Icons.favorite,
                  color: AppTheme.accent,
                  size: context.responsiveFont(20),
                ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            memory.content,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (memory.imagePaths.isNotEmpty) ...[
            SizedBox(height: context.responsiveHeight(1)),
            SizedBox(
              height: context.responsiveHeight(8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: memory.imagePaths.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: context.responsiveWidth(1)),
                    width: context.responsiveWidth(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
                      color: AppTheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.image,
                      color: AppTheme.primary,
                    ),
                  );
                },
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
                  color: _getMemoryTypeColor(memory.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
                ),
                child: OptimizedText(
                  _getMemoryTypeLabel(memory.type),
                  style: BabyFont.bodyS.copyWith(
                    color: _getMemoryTypeColor(memory.type),
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
                _formatDate(memory.createdAt),
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

  Color _getMemoryTypeColor(MemoryType type) {
    switch (type) {
      case MemoryType.date:
        return AppTheme.primary;
      case MemoryType.anniversary:
        return AppTheme.accent;
      case MemoryType.vacation:
        return AppTheme.boyColor;
      case MemoryType.milestone:
        return AppTheme.girlColor;
      case MemoryType.everyday:
        return AppTheme.textSecondary;
      case MemoryType.special:
        return Colors.purple;
    }
  }

  String _getMemoryTypeLabel(MemoryType type) {
    switch (type) {
      case MemoryType.date:
        return 'Date Night';
      case MemoryType.anniversary:
        return 'Anniversary';
      case MemoryType.vacation:
        return 'Vacation';
      case MemoryType.milestone:
        return 'Milestone';
      case MemoryType.everyday:
        return 'Everyday';
      case MemoryType.special:
        return 'Special';
    }
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

  void _showAddMemoryDialog(BuildContext context, MemoryJournalNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _AddMemoryDialog(notifier: notifier),
    );
  }
}

/// Add memory dialog
class _AddMemoryDialog extends OptimizedStatefulWidget {
  final MemoryJournalNotifier notifier;

  const _AddMemoryDialog({required this.notifier});

  @override
  OptimizedState<_AddMemoryDialog> createState() => _AddMemoryDialogState();
}

class _AddMemoryDialogState extends OptimizedState<_AddMemoryDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  MemoryType _selectedType = MemoryType.everyday;
  final List<String> _tags = [];

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: OptimizedText(
        'Add Memory',
        style: BabyFont.headingM,
      ),
      content: SizedBox(
        width: context.responsiveWidth(80),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleField(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildContentField(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildTypeSelector(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildLocationField(),
            ],
          ),
        ),
      ),
      actions: [
        OptimizedButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          type: ButtonType.outline,
        ),
        OptimizedButton(
          text: 'Save',
          onPressed: _saveMemory,
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Content',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Type',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Wrap(
          spacing: context.responsiveWidth(1),
          children: MemoryType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(2),
                  vertical: context.responsiveHeight(0.5),
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.responsiveRadius(20)),
                ),
                child: OptimizedText(
                  _getMemoryTypeLabel(type),
                  style: BabyFont.bodyS.copyWith(
                    color: isSelected ? Colors.white : AppTheme.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return TextField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: 'Location (optional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
        ),
      ),
    );
  }

  void _saveMemory() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: OptimizedText('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = MemoryJournalRequest(
      title: _titleController.text,
      content: _contentController.text,
      type: _selectedType,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      tags: _tags,
    );

    widget.notifier.addMemory(request);
    Navigator.of(context).pop();
  }

  String _getMemoryTypeLabel(MemoryType type) {
    switch (type) {
      case MemoryType.date:
        return 'Date Night';
      case MemoryType.anniversary:
        return 'Anniversary';
      case MemoryType.vacation:
        return 'Vacation';
      case MemoryType.milestone:
        return 'Milestone';
      case MemoryType.everyday:
        return 'Everyday';
      case MemoryType.special:
        return 'Special';
    }
  }
}
