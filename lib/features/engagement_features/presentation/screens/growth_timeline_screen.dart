import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../providers/growth_timeline_provider.dart';
import '../../domain/entities/growth_timeline_entity.dart';

/// Growth Timeline Screen
/// Follows master plan theme standards and performance requirements
class GrowthTimelineScreen extends OptimizedStatefulWidget {
  const GrowthTimelineScreen({super.key});

  @override
  OptimizedState<GrowthTimelineScreen> createState() =>
      _GrowthTimelineScreenState();
}

class _GrowthTimelineScreenState extends OptimizedState<GrowthTimelineScreen> {
  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(growthTimelineProvider);
    final notifier = ref.read(growthTimelineProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Growth Timeline',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context, notifier),
            icon: const Icon(Icons.filter_list),
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
            ] else if (state.timeline.isEmpty) ...[
              Expanded(child: _buildEmptyState()),
            ] else ...[
              Expanded(child: _buildTimelineList(state.timeline)),
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
            Icons.timeline,
            size: context.responsiveHeight(8),
            color: Colors.white,
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Baby Development Journey',
            style: BabyFont.headingL.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Track your baby\'s growth month by month',
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
            'Loading timeline...',
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
            Icons.child_care_outlined,
            size: context.responsiveHeight(12),
            color: AppTheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'No timeline available',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Check back later for growth milestones',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(List<GrowthTimelineEntity> timeline) {
    return ListView.builder(
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final item = timeline[index];
        return _buildTimelineItem(item, index == timeline.length - 1);
      },
    );
  }

  Widget _buildTimelineItem(GrowthTimelineEntity item, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineIndicator(item.month, item.isCompleted, isLast),
          SizedBox(width: context.responsiveWidth(3)),
          Expanded(
            child: _buildTimelineContent(item),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator(int month, bool isCompleted, bool isLast) {
    return Column(
      children: [
        Container(
          width: context.responsiveWidth(8),
          height: context.responsiveWidth(8),
          decoration: BoxDecoration(
            color: isCompleted ? AppTheme.accent : AppTheme.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: AppTheme.softShadow,
          ),
          child: Center(
            child: Text(
              '$month',
              style: BabyFont.bodyS.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: context.responsiveFont(10),
              ),
            ),
          ),
        ),
        if (!isLast)
          Container(
            width: 2,
            height: context.responsiveHeight(8),
            color: AppTheme.primary.withValues(alpha: 0.3),
          ),
      ],
    );
  }

  Widget _buildTimelineContent(GrowthTimelineEntity item) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: item.isCompleted
              ? AppTheme.accent.withValues(alpha: 0.3)
              : AppTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OptimizedText(
                  item.title,
                  style: BabyFont.headingS,
                ),
              ),
              if (item.isCompleted)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.accent,
                  size: context.responsiveFont(20),
                ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            item.description,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          _buildMilestones(item.milestones),
          SizedBox(height: context.responsiveHeight(1)),
          _buildTips(item.tips),
        ],
      ),
    );
  }

  Widget _buildMilestones(List<String> milestones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Key Milestones',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.5)),
        ...milestones.map((milestone) => Padding(
              padding: EdgeInsets.only(bottom: context.responsiveHeight(0.5)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.accent,
                    size: context.responsiveFont(16),
                  ),
                  SizedBox(width: context.responsiveWidth(1)),
                  Expanded(
                    child: OptimizedText(
                      milestone,
                      style: BabyFont.bodyM,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildTips(List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Parenting Tips',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.boyColor,
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.5)),
        ...tips.map((tip) => Padding(
              padding: EdgeInsets.only(bottom: context.responsiveHeight(0.5)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.boyColor,
                    size: context.responsiveFont(16),
                  ),
                  SizedBox(width: context.responsiveWidth(1)),
                  Expanded(
                    child: OptimizedText(
                      tip,
                      style: BabyFont.bodyM,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildErrorMessage(String error, GrowthTimelineNotifier notifier) {
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

  void _showFilterDialog(
      BuildContext context, GrowthTimelineNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(notifier: notifier),
    );
  }
}

/// Filter dialog for growth timeline
class _FilterDialog extends OptimizedStatefulWidget {
  final GrowthTimelineNotifier notifier;

  const _FilterDialog({required this.notifier});

  @override
  OptimizedState<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends OptimizedState<_FilterDialog> {
  int? _selectedMonth;
  String? _selectedGender;

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: OptimizedText(
        'Filter Timeline',
        style: BabyFont.headingM,
      ),
      content: SizedBox(
        width: context.responsiveWidth(80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMonthFilter(),
            SizedBox(height: context.responsiveHeight(2)),
            _buildGenderFilter(),
          ],
        ),
      ),
      actions: [
        OptimizedButton(
          text: 'Clear',
          onPressed: () {
            setState(() {
              _selectedMonth = null;
              _selectedGender = null;
            });
          },
          type: ButtonType.outline,
        ),
        OptimizedButton(
          text: 'Apply',
          onPressed: () {
            // Apply filters
            Navigator.of(context).pop();
          },
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildMonthFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Month',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Wrap(
          spacing: context.responsiveWidth(1),
          runSpacing: context.responsiveHeight(1),
          children: List.generate(12, (index) {
            final month = index + 1;
            final isSelected = _selectedMonth == month;
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedMonth = isSelected ? null : month),
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
                  'Month $month',
                  style: BabyFont.bodyS.copyWith(
                    color: isSelected ? Colors.white : AppTheme.primary,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGenderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Gender',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Row(
          children: [
            _buildGenderChip('Any', _selectedGender == null),
            SizedBox(width: context.responsiveWidth(2)),
            _buildGenderChip('Boy', _selectedGender == 'boy'),
            SizedBox(width: context.responsiveWidth(2)),
            _buildGenderChip('Girl', _selectedGender == 'girl'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(
          () => _selectedGender = isSelected ? null : label.toLowerCase()),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(2),
          vertical: context.responsiveHeight(0.5),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.responsiveRadius(20)),
        ),
        child: OptimizedText(
          label,
          style: BabyFont.bodyS.copyWith(
            color: isSelected ? Colors.white : AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
