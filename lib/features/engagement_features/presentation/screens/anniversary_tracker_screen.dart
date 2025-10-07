import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../providers/anniversary_tracker_provider.dart';
import '../../domain/entities/anniversary_entity.dart';

/// Anniversary Tracker Screen
/// Follows master plan theme standards and performance requirements
class AnniversaryTrackerScreen extends OptimizedStatefulWidget {
  const AnniversaryTrackerScreen({super.key});

  @override
  OptimizedState<AnniversaryTrackerScreen> createState() =>
      _AnniversaryTrackerScreenState();
}

class _AnniversaryTrackerScreenState
    extends OptimizedState<AnniversaryTrackerScreen> {
  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(anniversaryTrackerProvider);
    final notifier = ref.read(anniversaryTrackerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Anniversary Tracker',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddAnniversaryDialog(context, notifier),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: OptimizedContainer(
        padding: context.responsivePadding,
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: context.responsiveHeight(2)),
            if (state.isLoading) ...[
              Expanded(child: _buildLoadingState()),
            ] else if (state.anniversaries.isEmpty) ...[
              Expanded(child: _buildEmptyState()),
            ] else ...[
              Expanded(child: _buildAnniversariesList(state.anniversaries)),
            ],
            if (state.errorMessage != null) ...[
              _buildErrorMessage(state.errorMessage!, notifier),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(context.responsiveRadius(16)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            size: context.responsiveHeight(8),
            color: Colors.white,
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Celebrate Your Love',
            style: BabyFont.headingL.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Track and celebrate your special moments together',
            style: BabyFont.bodyM.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
            'Loading anniversaries...',
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
            Icons.calendar_today_outlined,
            size: context.responsiveHeight(12),
            color: AppTheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'No anniversaries yet',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Add your special dates to start tracking',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(3)),
          OptimizedButton(
            text: 'Add First Anniversary',
            onPressed: () => _showAddAnniversaryDialog(
                context, ref.read(anniversaryTrackerProvider.notifier)),
            type: ButtonType.primary,
            size: ButtonSize.large,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildAnniversariesList(List<AnniversaryEntity> anniversaries) {
    return ListView.builder(
      itemCount: anniversaries.length,
      itemBuilder: (context, index) {
        final anniversary = anniversaries[index];
        return _buildAnniversaryCard(anniversary);
      },
    );
  }

  Widget _buildAnniversaryCard(AnniversaryEntity anniversary) {
    final isToday = anniversary.isToday;
    final isUpcoming = anniversary.isUpcoming;
    final daysUntil = anniversary.daysUntil;

    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: isToday
              ? AppTheme.accent.withValues(alpha: 0.5)
              : isUpcoming
                  ? AppTheme.primary.withValues(alpha: 0.3)
                  : AppTheme.textSecondary.withValues(alpha: 0.2),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OptimizedText(
                  anniversary.title,
                  style: BabyFont.headingS,
                ),
              ),
              if (isToday)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveWidth(2),
                    vertical: context.responsiveHeight(0.5),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius:
                        BorderRadius.circular(context.responsiveRadius(12)),
                  ),
                  child: OptimizedText(
                    'TODAY!',
                    style: BabyFont.bodyS.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(0.5)),
          OptimizedText(
            anniversary.description,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          Row(
            children: [
              Icon(
                _getAnniversaryIcon(anniversary.type),
                color: _getAnniversaryColor(anniversary.type),
                size: context.responsiveFont(20),
              ),
              SizedBox(width: context.responsiveWidth(1)),
              OptimizedText(
                _getAnniversaryTypeLabel(anniversary.type),
                style: BabyFont.bodyM.copyWith(
                  color: _getAnniversaryColor(anniversary.type),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (anniversary.years > 0)
                OptimizedText(
                  '${anniversary.years} years',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
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
                _formatDate(anniversary.date),
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              if (!isToday)
                OptimizedText(
                  isUpcoming
                      ? 'In $daysUntil days'
                      : '${_getDaysSince(anniversary.date)} days ago',
                  style: BabyFont.bodyS.copyWith(
                    color:
                        isUpcoming ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
          if (anniversary.tags.isNotEmpty) ...[
            SizedBox(height: context.responsiveHeight(1)),
            Wrap(
              spacing: context.responsiveWidth(1),
              runSpacing: context.responsiveHeight(0.5),
              children: anniversary.tags
                  .map((tag) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsiveWidth(1.5),
                          vertical: context.responsiveHeight(0.3),
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              context.responsiveRadius(8)),
                        ),
                        child: OptimizedText(
                          tag,
                          style: BabyFont.bodyS.copyWith(
                            color: AppTheme.primary,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error, AnniversaryTrackerNotifier notifier) {
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

  IconData _getAnniversaryIcon(AnniversaryType type) {
    switch (type) {
      case AnniversaryType.relationship:
        return Icons.favorite;
      case AnniversaryType.marriage:
        return Icons.favorite_border;
      case AnniversaryType.engagement:
        return Icons.diamond;
      case AnniversaryType.firstDate:
        return Icons.restaurant;
      case AnniversaryType.firstKiss:
        return Icons.sentiment_very_satisfied;
      case AnniversaryType.movingIn:
        return Icons.home;
      case AnniversaryType.custom:
        return Icons.star;
    }
  }

  Color _getAnniversaryColor(AnniversaryType type) {
    switch (type) {
      case AnniversaryType.relationship:
        return AppTheme.accent;
      case AnniversaryType.marriage:
        return AppTheme.primary;
      case AnniversaryType.engagement:
        return AppTheme.boyColor;
      case AnniversaryType.firstDate:
        return AppTheme.girlColor;
      case AnniversaryType.firstKiss:
        return Colors.purple;
      case AnniversaryType.movingIn:
        return Colors.orange;
      case AnniversaryType.custom:
        return AppTheme.textSecondary;
    }
  }

  String _getAnniversaryTypeLabel(AnniversaryType type) {
    switch (type) {
      case AnniversaryType.relationship:
        return 'Relationship';
      case AnniversaryType.marriage:
        return 'Marriage';
      case AnniversaryType.engagement:
        return 'Engagement';
      case AnniversaryType.firstDate:
        return 'First Date';
      case AnniversaryType.firstKiss:
        return 'First Kiss';
      case AnniversaryType.movingIn:
        return 'Moving In';
      case AnniversaryType.custom:
        return 'Custom';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _getDaysSince(DateTime date) {
    final now = DateTime.now();
    final anniversaryThisYear = DateTime(now.year, date.month, date.day);
    if (anniversaryThisYear.isAfter(now)) {
      final lastYear = DateTime(now.year - 1, date.month, date.day);
      return now.difference(lastYear).inDays;
    }
    return now.difference(anniversaryThisYear).inDays;
  }

  void _showAddAnniversaryDialog(
      BuildContext context, AnniversaryTrackerNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _AddAnniversaryDialog(notifier: notifier),
    );
  }
}

/// Add anniversary dialog
class _AddAnniversaryDialog extends OptimizedStatefulWidget {
  final AnniversaryTrackerNotifier notifier;

  const _AddAnniversaryDialog({required this.notifier});

  @override
  OptimizedState<_AddAnniversaryDialog> createState() =>
      _AddAnniversaryDialogState();
}

class _AddAnniversaryDialogState extends OptimizedState<_AddAnniversaryDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  AnniversaryType _selectedType = AnniversaryType.relationship;
  DateTime _selectedDate = DateTime.now();
  final List<String> _tags = [];

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: OptimizedText(
        'Add Anniversary',
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
              _buildDescriptionField(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildTypeSelector(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildDateSelector(),
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
          onPressed: _saveAnniversary,
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

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description',
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
          runSpacing: context.responsiveHeight(1),
          children: AnniversaryType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(2),
                  vertical: context.responsiveHeight(0.5),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius(20)),
                ),
                child: OptimizedText(
                  _getAnniversaryTypeLabel(type),
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

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Date',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            padding: context.responsivePadding,
            decoration: BoxDecoration(
              border:
                  Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.primary,
                  size: context.responsiveFont(20),
                ),
                SizedBox(width: context.responsiveWidth(2)),
                OptimizedText(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: BabyFont.bodyM,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveAnniversary() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: OptimizedText('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = AnniversaryRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      type: _selectedType,
      tags: _tags,
    );

    widget.notifier.addAnniversary(request);
    Navigator.of(context).pop();
  }

  String _getAnniversaryTypeLabel(AnniversaryType type) {
    switch (type) {
      case AnniversaryType.relationship:
        return 'Relationship';
      case AnniversaryType.marriage:
        return 'Marriage';
      case AnniversaryType.engagement:
        return 'Engagement';
      case AnniversaryType.firstDate:
        return 'First Date';
      case AnniversaryType.firstKiss:
        return 'First Kiss';
      case AnniversaryType.movingIn:
        return 'Moving In';
      case AnniversaryType.custom:
        return 'Custom';
    }
  }
}
