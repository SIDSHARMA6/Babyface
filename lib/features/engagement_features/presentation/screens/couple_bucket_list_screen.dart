import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../providers/couple_bucket_list_provider.dart';
import '../../domain/entities/couple_bucket_list_entity.dart';

/// Couple Bucket List Screen
/// Follows master plan theme standards and performance requirements
class CoupleBucketListScreen extends OptimizedStatefulWidget {
  const CoupleBucketListScreen({super.key});

  @override
  OptimizedState<CoupleBucketListScreen> createState() =>
      _CoupleBucketListScreenState();
}

class _CoupleBucketListScreenState
    extends OptimizedState<CoupleBucketListScreen> {
  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(coupleBucketListProvider);
    final notifier = ref.read(coupleBucketListProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Couple Bucket List',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddItemDialog(context, notifier),
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
            _buildFilterTabs(state, notifier),
            SizedBox(height: context.responsiveHeight(2)),
            if (state.isLoading) ...[
              Expanded(child: _buildLoadingState()),
            ] else if (state.bucketList.isEmpty) ...[
              Expanded(child: _buildEmptyState()),
            ] else ...[
              Expanded(child: _buildBucketList(state.bucketList)),
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
            Icons.list_alt,
            size: context.responsiveHeight(8),
            color: Colors.white,
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Adventure Together',
            style: BabyFont.headingL.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Create memories and check off amazing experiences',
            style: BabyFont.bodyM.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(
      CoupleBucketListState state, CoupleBucketListNotifier notifier) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(1)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null, state.selectedCategory, notifier),
            SizedBox(width: context.responsiveWidth(1)),
            _buildFilterChip('Travel', BucketListCategory.travel,
                state.selectedCategory, notifier),
            SizedBox(width: context.responsiveWidth(1)),
            _buildFilterChip('Romantic', BucketListCategory.romantic,
                state.selectedCategory, notifier),
            SizedBox(width: context.responsiveWidth(1)),
            _buildFilterChip('Adventure', BucketListCategory.adventure,
                state.selectedCategory, notifier),
            SizedBox(width: context.responsiveWidth(1)),
            _buildFilterChip('Food', BucketListCategory.food,
                state.selectedCategory, notifier),
            SizedBox(width: context.responsiveWidth(1)),
            _buildFilterChip('Entertainment', BucketListCategory.entertainment,
                state.selectedCategory, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, BucketListCategory? category,
      BucketListCategory? selectedCategory, CoupleBucketListNotifier notifier) {
    final isSelected = category == selectedCategory;
    return GestureDetector(
      onTap: () => notifier.filterByCategory(category),
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Loading your adventures...',
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
            Icons.explore_outlined,
            size: context.responsiveHeight(12),
            color: AppTheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'No adventures yet',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Start adding amazing experiences to your bucket list',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(3)),
          OptimizedButton(
            text: 'Add First Adventure',
            onPressed: () => _showAddItemDialog(
                context, ref.read(coupleBucketListProvider.notifier)),
            type: ButtonType.primary,
            size: ButtonSize.large,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildBucketList(List<CoupleBucketListEntity> bucketList) {
    return ListView.builder(
      itemCount: bucketList.length,
      itemBuilder: (context, index) {
        final item = bucketList[index];
        return _buildBucketListItem(item);
      },
    );
  }

  Widget _buildBucketListItem(CoupleBucketListEntity item) {
    final isOverdue = item.isOverdue;
    final isDueSoon = item.isDueSoon;
    final daysUntil = item.daysUntil;

    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: _getStatusColor(item.status).withValues(alpha: 0.3),
          width: isOverdue ? 2 : 1,
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
              if (item.status == BucketListStatus.completed)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: context.responsiveFont(24),
                )
              else if (isOverdue)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveWidth(1.5),
                    vertical: context.responsiveHeight(0.3),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.circular(context.responsiveRadius(8)),
                  ),
                  child: OptimizedText(
                    'OVERDUE',
                    style: BabyFont.bodyS.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isDueSoon)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveWidth(1.5),
                    vertical: context.responsiveHeight(0.3),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius:
                        BorderRadius.circular(context.responsiveRadius(8)),
                  ),
                  child: OptimizedText(
                    'DUE SOON',
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
            item.description,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          Row(
            children: [
              Icon(
                _getCategoryIcon(item.category),
                color: _getCategoryColor(item.category),
                size: context.responsiveFont(20),
              ),
              SizedBox(width: context.responsiveWidth(1)),
              OptimizedText(
                _getCategoryLabel(item.category),
                style: BabyFont.bodyM.copyWith(
                  color: _getCategoryColor(item.category),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(1.5),
                  vertical: context.responsiveHeight(0.3),
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status),
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius(8)),
                ),
                child: OptimizedText(
                  _getStatusLabel(item.status),
                  style: BabyFont.bodyS.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (item.location != null || item.estimatedCost != null) ...[
            SizedBox(height: context.responsiveHeight(1)),
            Row(
              children: [
                if (item.location != null) ...[
                  Icon(
                    Icons.location_on,
                    color: AppTheme.textSecondary,
                    size: context.responsiveFont(16),
                  ),
                  SizedBox(width: context.responsiveWidth(1)),
                  OptimizedText(
                    item.location!,
                    style: BabyFont.bodyM.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                if (item.location != null && item.estimatedCost != null)
                  SizedBox(width: context.responsiveWidth(2)),
                if (item.estimatedCost != null) ...[
                  Icon(
                    Icons.attach_money,
                    color: AppTheme.textSecondary,
                    size: context.responsiveFont(16),
                  ),
                  SizedBox(width: context.responsiveWidth(1)),
                  OptimizedText(
                    '\$${item.estimatedCost!.toStringAsFixed(0)}',
                    style: BabyFont.bodyM.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const Spacer(),
                if (item.targetDate != null)
                  OptimizedText(
                    isOverdue
                        ? '${daysUntil.abs()} days overdue'
                        : isDueSoon
                            ? 'In $daysUntil days'
                            : 'In ${daysUntil.abs()} days',
                    style: BabyFont.bodyS.copyWith(
                      color: isOverdue
                          ? Colors.red
                          : isDueSoon
                              ? Colors.orange
                              : AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
          if (item.tags.isNotEmpty) ...[
            SizedBox(height: context.responsiveHeight(1)),
            Wrap(
              spacing: context.responsiveWidth(1),
              runSpacing: context.responsiveHeight(0.5),
              children: item.tags
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
          SizedBox(height: context.responsiveHeight(1)),
          Row(
            children: [
              Expanded(
                child: OptimizedButton(
                  text: 'Edit',
                  onPressed: () => _showEditItemDialog(context, item,
                      ref.read(coupleBucketListProvider.notifier)),
                  type: ButtonType.outline,
                  size: ButtonSize.small,
                ),
              ),
              SizedBox(width: context.responsiveWidth(1)),
              Expanded(
                child: OptimizedButton(
                  text: item.status == BucketListStatus.completed
                      ? 'Reopen'
                      : 'Complete',
                  onPressed: () => _toggleItemStatus(
                      item, ref.read(coupleBucketListProvider.notifier)),
                  type: item.status == BucketListStatus.completed
                      ? ButtonType.outline
                      : ButtonType.primary,
                  size: ButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error, CoupleBucketListNotifier notifier) {
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

  IconData _getCategoryIcon(BucketListCategory category) {
    switch (category) {
      case BucketListCategory.travel:
        return Icons.flight;
      case BucketListCategory.adventure:
        return Icons.hiking;
      case BucketListCategory.romantic:
        return Icons.favorite;
      case BucketListCategory.food:
        return Icons.restaurant;
      case BucketListCategory.entertainment:
        return Icons.movie;
      case BucketListCategory.learning:
        return Icons.school;
      case BucketListCategory.fitness:
        return Icons.fitness_center;
      case BucketListCategory.creative:
        return Icons.palette;
      case BucketListCategory.social:
        return Icons.people;
      case BucketListCategory.personal:
        return Icons.person;
    }
  }

  Color _getCategoryColor(BucketListCategory category) {
    switch (category) {
      case BucketListCategory.travel:
        return AppTheme.primary;
      case BucketListCategory.adventure:
        return Colors.green;
      case BucketListCategory.romantic:
        return AppTheme.accent;
      case BucketListCategory.food:
        return Colors.orange;
      case BucketListCategory.entertainment:
        return Colors.purple;
      case BucketListCategory.learning:
        return Colors.blue;
      case BucketListCategory.fitness:
        return Colors.red;
      case BucketListCategory.creative:
        return Colors.pink;
      case BucketListCategory.social:
        return Colors.teal;
      case BucketListCategory.personal:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(BucketListCategory category) {
    switch (category) {
      case BucketListCategory.travel:
        return 'Travel';
      case BucketListCategory.adventure:
        return 'Adventure';
      case BucketListCategory.romantic:
        return 'Romantic';
      case BucketListCategory.food:
        return 'Food';
      case BucketListCategory.entertainment:
        return 'Entertainment';
      case BucketListCategory.learning:
        return 'Learning';
      case BucketListCategory.fitness:
        return 'Fitness';
      case BucketListCategory.creative:
        return 'Creative';
      case BucketListCategory.social:
        return 'Social';
      case BucketListCategory.personal:
        return 'Personal';
    }
  }

  Color _getStatusColor(BucketListStatus status) {
    switch (status) {
      case BucketListStatus.wishlist:
        return Colors.grey;
      case BucketListStatus.planned:
        return AppTheme.primary;
      case BucketListStatus.inProgress:
        return Colors.blue;
      case BucketListStatus.completed:
        return Colors.green;
      case BucketListStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusLabel(BucketListStatus status) {
    switch (status) {
      case BucketListStatus.wishlist:
        return 'Wishlist';
      case BucketListStatus.planned:
        return 'Planned';
      case BucketListStatus.inProgress:
        return 'In Progress';
      case BucketListStatus.completed:
        return 'Completed';
      case BucketListStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _showAddItemDialog(
      BuildContext context, CoupleBucketListNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(notifier: notifier),
    );
  }

  void _showEditItemDialog(BuildContext context, CoupleBucketListEntity item,
      CoupleBucketListNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _EditItemDialog(item: item, notifier: notifier),
    );
  }

  void _toggleItemStatus(
      CoupleBucketListEntity item, CoupleBucketListNotifier notifier) {
    final newStatus = item.status == BucketListStatus.completed
        ? BucketListStatus.planned
        : BucketListStatus.completed;

    notifier.updateItemStatus(item.id, newStatus);

    ToastService.showSuccess(
      context,
      newStatus == BucketListStatus.completed
          ? 'Adventure completed! 🎉'
          : 'Adventure reopened! 💪',
    );
  }
}

/// Add item dialog
class _AddItemDialog extends OptimizedStatefulWidget {
  final CoupleBucketListNotifier notifier;

  const _AddItemDialog({required this.notifier});

  @override
  OptimizedState<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends OptimizedState<_AddItemDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  BucketListCategory _selectedCategory = BucketListCategory.travel;
  DateTime? _selectedDate;
  int _selectedPriority = 1;
  final List<String> _tags = [];

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: OptimizedText(
        'Add to Bucket List',
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
              _buildCategorySelector(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildLocationField(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildCostField(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildDateSelector(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildPrioritySelector(),
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
          text: 'Add',
          onPressed: _saveItem,
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Adventure Title',
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

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Category',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Wrap(
          spacing: context.responsiveWidth(1),
          runSpacing: context.responsiveHeight(1),
          children: BucketListCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
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
                  _getCategoryLabel(category),
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
        labelText: 'Location (Optional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
        ),
      ),
    );
  }

  Widget _buildCostField() {
    return TextField(
      controller: _costController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Estimated Cost (Optional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Target Date (Optional)',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate:
                  _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
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
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                  style: BabyFont.bodyM,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Priority',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Row(
          children: List.generate(5, (index) {
            final priority = index + 1;
            final isSelected = _selectedPriority == priority;
            return GestureDetector(
              onTap: () => setState(() => _selectedPriority = priority),
              child: Container(
                margin: EdgeInsets.only(right: context.responsiveWidth(1)),
                padding: EdgeInsets.all(context.responsiveWidth(1)),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius(8)),
                ),
                child: Icon(
                  Icons.star,
                  color: isSelected ? Colors.white : AppTheme.primary,
                  size: context.responsiveFont(20),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _saveItem() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ToastService.showError(
        context,
        'Please fill in all required fields 💕',
      );
      return;
    }

    double? cost;
    if (_costController.text.isNotEmpty) {
      cost = double.tryParse(_costController.text);
    }

    final request = CoupleBucketListRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      priority: _selectedPriority,
      targetDate: _selectedDate,
      location:
          _locationController.text.isEmpty ? null : _locationController.text,
      estimatedCost: cost,
      tags: _tags,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    widget.notifier.addItem(request);
    Navigator.of(context).pop();

    ToastService.showSuccess(
      context,
      'Adventure added to bucket list! 🌟',
    );
  }

  String _getCategoryLabel(BucketListCategory category) {
    switch (category) {
      case BucketListCategory.travel:
        return 'Travel';
      case BucketListCategory.adventure:
        return 'Adventure';
      case BucketListCategory.romantic:
        return 'Romantic';
      case BucketListCategory.food:
        return 'Food';
      case BucketListCategory.entertainment:
        return 'Entertainment';
      case BucketListCategory.learning:
        return 'Learning';
      case BucketListCategory.fitness:
        return 'Fitness';
      case BucketListCategory.creative:
        return 'Creative';
      case BucketListCategory.social:
        return 'Social';
      case BucketListCategory.personal:
        return 'Personal';
    }
  }
}

/// Edit item dialog
class _EditItemDialog extends OptimizedStatefulWidget {
  final CoupleBucketListEntity item;
  final CoupleBucketListNotifier notifier;

  const _EditItemDialog({required this.item, required this.notifier});

  @override
  OptimizedState<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends OptimizedState<_EditItemDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _costController;
  late TextEditingController _notesController;
  late BucketListCategory _selectedCategory;
  late DateTime? _selectedDate;
  late int _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _locationController =
        TextEditingController(text: widget.item.location ?? '');
    _costController = TextEditingController(
        text: widget.item.estimatedCost?.toString() ?? '');
    _notesController = TextEditingController(text: widget.item.notes ?? '');
    _selectedCategory = widget.item.category;
    _selectedDate = widget.item.targetDate;
    _selectedPriority = widget.item.priority;
  }

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: OptimizedText(
        'Edit Adventure',
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
              _buildCategorySelector(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildLocationField(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildCostField(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildDateSelector(),
              SizedBox(height: context.responsiveHeight(2)),
              _buildPrioritySelector(),
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
          text: 'Update',
          onPressed: _updateItem,
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Adventure Title',
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

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Category',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Wrap(
          spacing: context.responsiveWidth(1),
          runSpacing: context.responsiveHeight(1),
          children: BucketListCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
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
                  _getCategoryLabel(category),
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
        labelText: 'Location (Optional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
        ),
      ),
    );
  }

  Widget _buildCostField() {
    return TextField(
      controller: _costController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Estimated Cost (Optional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Target Date (Optional)',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate:
                  _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
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
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                  style: BabyFont.bodyM,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Priority',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Row(
          children: List.generate(5, (index) {
            final priority = index + 1;
            final isSelected = _selectedPriority == priority;
            return GestureDetector(
              onTap: () => setState(() => _selectedPriority = priority),
              child: Container(
                margin: EdgeInsets.only(right: context.responsiveWidth(1)),
                padding: EdgeInsets.all(context.responsiveWidth(1)),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius(8)),
                ),
                child: Icon(
                  Icons.star,
                  color: isSelected ? Colors.white : AppTheme.primary,
                  size: context.responsiveFont(20),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _updateItem() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ToastService.showError(
        context,
        'Please fill in all required fields 💕',
      );
      return;
    }

    double? cost;
    if (_costController.text.isNotEmpty) {
      cost = double.tryParse(_costController.text);
    }

    final request = CoupleBucketListRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      priority: _selectedPriority,
      targetDate: _selectedDate,
      location:
          _locationController.text.isEmpty ? null : _locationController.text,
      estimatedCost: cost,
      tags: widget.item.tags,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    widget.notifier.updateItem(widget.item.id, request);
    Navigator.of(context).pop();

    ToastService.showSuccess(
      context,
      'Adventure updated! ✨',
    );
  }

  String _getCategoryLabel(BucketListCategory category) {
    switch (category) {
      case BucketListCategory.travel:
        return 'Travel';
      case BucketListCategory.adventure:
        return 'Adventure';
      case BucketListCategory.romantic:
        return 'Romantic';
      case BucketListCategory.food:
        return 'Food';
      case BucketListCategory.entertainment:
        return 'Entertainment';
      case BucketListCategory.learning:
        return 'Learning';
      case BucketListCategory.fitness:
        return 'Fitness';
      case BucketListCategory.creative:
        return 'Creative';
      case BucketListCategory.social:
        return 'Social';
      case BucketListCategory.personal:
        return 'Personal';
    }
  }
}
