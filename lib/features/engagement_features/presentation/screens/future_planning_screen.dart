import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../../../../shared/widgets/toast_service.dart';
import '../providers/future_planning_provider.dart';
import '../../domain/entities/future_planning_entity.dart';

/// Future Planning Screen
/// Follows master plan theme standards and performance requirements
class FuturePlanningScreen extends OptimizedStatefulWidget {
  const FuturePlanningScreen({super.key});

  @override
  OptimizedState<FuturePlanningScreen> createState() =>
      _FuturePlanningScreenState();
}

class _FuturePlanningScreenState extends OptimizedState<FuturePlanningScreen> {
  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(futurePlanningProvider);
    final notifier = ref.read(futurePlanningProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Future Planning',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddGoalDialog(context, notifier),
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
            ] else if (state.goals.isEmpty) ...[
              Expanded(child: _buildEmptyState()),
            ] else ...[
              Expanded(child: _buildGoalsList(state.goals)),
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
            'Dream Together',
            style: BabyFont.headingL.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Plan your beautiful future as a couple',
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
      FuturePlanningState state, FuturePlanningNotifier notifier) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(1)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null, state.selectedCategory, notifier),
            SizedBox(width: context.responsiveWidth(1)),
            _buildFilterChip(
                'Relationship',
                FuturePlanningCategory.relationship,
                state.selectedCategory,
                notifier),
            SizedBox(width: context.responsiveWidth(1)),
            _buildFilterChip('Family', FuturePlanningCategory.family,
                state.selectedCategory, notifier),
            SizedBox(width: context.responsiveWidth(1)),
            _buildFilterChip('Career', FuturePlanningCategory.career,
                state.selectedCategory, notifier),
            SizedBox(width: context.responsiveWidth(1)),
            _buildFilterChip('Travel', FuturePlanningCategory.travel,
                state.selectedCategory, notifier),
            SizedBox(width: context.responsiveWidth(1)),
            _buildFilterChip('Home', FuturePlanningCategory.home,
                state.selectedCategory, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label,
      FuturePlanningCategory? category,
      FuturePlanningCategory? selectedCategory,
      FuturePlanningNotifier notifier) {
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
            'Loading your dreams...',
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
            Icons.lightbulb_outline,
            size: context.responsiveHeight(12),
            color: AppTheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'No goals yet',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Start planning your beautiful future together',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(3)),
          OptimizedButton(
            text: 'Add First Goal',
            onPressed: () => _showAddGoalDialog(
                context, ref.read(futurePlanningProvider.notifier)),
            type: ButtonType.primary,
            size: ButtonSize.large,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(List<FuturePlanningEntity> goals) {
    return ListView.builder(
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildGoalCard(goal);
      },
    );
  }

  Widget _buildGoalCard(FuturePlanningEntity goal) {
    final isOverdue = goal.isOverdue;
    final isDueSoon = goal.isDueSoon;
    final daysUntil = goal.daysUntil;

    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: _getStatusColor(goal.status).withValues(alpha: 0.3),
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
                  goal.title,
                  style: BabyFont.headingS,
                ),
              ),
              if (isOverdue)
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
            goal.description,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          Row(
            children: [
              Icon(
                _getCategoryIcon(goal.category),
                color: _getCategoryColor(goal.category),
                size: context.responsiveFont(20),
              ),
              SizedBox(width: context.responsiveWidth(1)),
              OptimizedText(
                _getCategoryLabel(goal.category),
                style: BabyFont.bodyM.copyWith(
                  color: _getCategoryColor(goal.category),
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
                  color: _getStatusColor(goal.status),
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius(8)),
                ),
                child: OptimizedText(
                  _getStatusLabel(goal.status),
                  style: BabyFont.bodyS.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
                _formatDate(goal.targetDate),
                style: BabyFont.bodyM.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
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
          if (goal.tags.isNotEmpty) ...[
            SizedBox(height: context.responsiveHeight(1)),
            Wrap(
              spacing: context.responsiveWidth(1),
              runSpacing: context.responsiveHeight(0.5),
              children: goal.tags
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
                  onPressed: () => _showEditGoalDialog(
                      context, goal, ref.read(futurePlanningProvider.notifier)),
                  type: ButtonType.outline,
                  size: ButtonSize.small,
                ),
              ),
              SizedBox(width: context.responsiveWidth(1)),
              Expanded(
                child: OptimizedButton(
                  text: goal.status == FuturePlanningStatus.completed
                      ? 'Reopen'
                      : 'Complete',
                  onPressed: () => _toggleGoalStatus(
                      goal, ref.read(futurePlanningProvider.notifier)),
                  type: goal.status == FuturePlanningStatus.completed
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

  Widget _buildErrorMessage(String error, FuturePlanningNotifier notifier) {
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

  IconData _getCategoryIcon(FuturePlanningCategory category) {
    switch (category) {
      case FuturePlanningCategory.relationship:
        return Icons.favorite;
      case FuturePlanningCategory.career:
        return Icons.work;
      case FuturePlanningCategory.family:
        return Icons.family_restroom;
      case FuturePlanningCategory.health:
        return Icons.health_and_safety;
      case FuturePlanningCategory.finance:
        return Icons.account_balance_wallet;
      case FuturePlanningCategory.travel:
        return Icons.flight;
      case FuturePlanningCategory.home:
        return Icons.home;
      case FuturePlanningCategory.personal:
        return Icons.person;
      case FuturePlanningCategory.education:
        return Icons.school;
      case FuturePlanningCategory.hobbies:
        return Icons.palette;
    }
  }

  Color _getCategoryColor(FuturePlanningCategory category) {
    switch (category) {
      case FuturePlanningCategory.relationship:
        return AppTheme.accent;
      case FuturePlanningCategory.career:
        return AppTheme.primary;
      case FuturePlanningCategory.family:
        return AppTheme.boyColor;
      case FuturePlanningCategory.health:
        return Colors.green;
      case FuturePlanningCategory.finance:
        return Colors.orange;
      case FuturePlanningCategory.travel:
        return AppTheme.girlColor;
      case FuturePlanningCategory.home:
        return Colors.brown;
      case FuturePlanningCategory.personal:
        return Colors.purple;
      case FuturePlanningCategory.education:
        return Colors.blue;
      case FuturePlanningCategory.hobbies:
        return Colors.pink;
    }
  }

  String _getCategoryLabel(FuturePlanningCategory category) {
    switch (category) {
      case FuturePlanningCategory.relationship:
        return 'Relationship';
      case FuturePlanningCategory.career:
        return 'Career';
      case FuturePlanningCategory.family:
        return 'Family';
      case FuturePlanningCategory.health:
        return 'Health';
      case FuturePlanningCategory.finance:
        return 'Finance';
      case FuturePlanningCategory.travel:
        return 'Travel';
      case FuturePlanningCategory.home:
        return 'Home';
      case FuturePlanningCategory.personal:
        return 'Personal';
      case FuturePlanningCategory.education:
        return 'Education';
      case FuturePlanningCategory.hobbies:
        return 'Hobbies';
    }
  }

  Color _getStatusColor(FuturePlanningStatus status) {
    switch (status) {
      case FuturePlanningStatus.planning:
        return Colors.grey;
      case FuturePlanningStatus.inProgress:
        return AppTheme.primary;
      case FuturePlanningStatus.onHold:
        return Colors.orange;
      case FuturePlanningStatus.completed:
        return Colors.green;
      case FuturePlanningStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusLabel(FuturePlanningStatus status) {
    switch (status) {
      case FuturePlanningStatus.planning:
        return 'Planning';
      case FuturePlanningStatus.inProgress:
        return 'In Progress';
      case FuturePlanningStatus.onHold:
        return 'On Hold';
      case FuturePlanningStatus.completed:
        return 'Completed';
      case FuturePlanningStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddGoalDialog(
      BuildContext context, FuturePlanningNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _AddGoalDialog(notifier: notifier),
    );
  }

  void _showEditGoalDialog(BuildContext context, FuturePlanningEntity goal,
      FuturePlanningNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _EditGoalDialog(goal: goal, notifier: notifier),
    );
  }

  void _toggleGoalStatus(
      FuturePlanningEntity goal, FuturePlanningNotifier notifier) {
    final newStatus = goal.status == FuturePlanningStatus.completed
        ? FuturePlanningStatus.inProgress
        : FuturePlanningStatus.completed;

    notifier.updateGoalStatus(goal.id, newStatus);

    ToastService.showSuccess(
      context,
      newStatus == FuturePlanningStatus.completed
          ? 'Goal completed! 🎉'
          : 'Goal reopened! 💪',
    );
  }
}

/// Add goal dialog
class _AddGoalDialog extends OptimizedStatefulWidget {
  final FuturePlanningNotifier notifier;

  const _AddGoalDialog({required this.notifier});

  @override
  OptimizedState<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends OptimizedState<_AddGoalDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  FuturePlanningCategory _selectedCategory =
      FuturePlanningCategory.relationship;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  int _selectedPriority = 1;
  final List<String> _tags = [];

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: OptimizedText(
        'Add New Goal',
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
          text: 'Save',
          onPressed: _saveGoal,
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Goal Title',
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
          children: FuturePlanningCategory.values.map((category) {
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

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Target Date',
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

  void _saveGoal() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ToastService.showError(
        context,
        'Please fill in all required fields 💕',
      );
      return;
    }

    final request = FuturePlanningRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      targetDate: _selectedDate,
      priority: _selectedPriority,
      tags: _tags,
      notes: _notesController.text,
    );

    widget.notifier.addGoal(request);
    Navigator.of(context).pop();

    ToastService.showSuccess(
      context,
      'New goal added! 🌟',
    );
  }

  String _getCategoryLabel(FuturePlanningCategory category) {
    switch (category) {
      case FuturePlanningCategory.relationship:
        return 'Relationship';
      case FuturePlanningCategory.career:
        return 'Career';
      case FuturePlanningCategory.family:
        return 'Family';
      case FuturePlanningCategory.health:
        return 'Health';
      case FuturePlanningCategory.finance:
        return 'Finance';
      case FuturePlanningCategory.travel:
        return 'Travel';
      case FuturePlanningCategory.home:
        return 'Home';
      case FuturePlanningCategory.personal:
        return 'Personal';
      case FuturePlanningCategory.education:
        return 'Education';
      case FuturePlanningCategory.hobbies:
        return 'Hobbies';
    }
  }
}

/// Edit goal dialog
class _EditGoalDialog extends OptimizedStatefulWidget {
  final FuturePlanningEntity goal;
  final FuturePlanningNotifier notifier;

  const _EditGoalDialog({required this.goal, required this.notifier});

  @override
  OptimizedState<_EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends OptimizedState<_EditGoalDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late FuturePlanningCategory _selectedCategory;
  late DateTime _selectedDate;
  late int _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _descriptionController =
        TextEditingController(text: widget.goal.description);
    _notesController = TextEditingController(text: widget.goal.notes ?? '');
    _selectedCategory = widget.goal.category;
    _selectedDate = widget.goal.targetDate;
    _selectedPriority = widget.goal.priority;
  }

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: OptimizedText(
        'Edit Goal',
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
          onPressed: _updateGoal,
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Goal Title',
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
          children: FuturePlanningCategory.values.map((category) {
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

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Target Date',
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

  void _updateGoal() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ToastService.showError(
        context,
        'Please fill in all required fields 💕',
      );
      return;
    }

    final request = FuturePlanningRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      targetDate: _selectedDate,
      priority: _selectedPriority,
      tags: widget.goal.tags,
      notes: _notesController.text,
    );

    widget.notifier.updateGoal(widget.goal.id, request);
    Navigator.of(context).pop();

    ToastService.showSuccess(
      context,
      'Goal updated! ✨',
    );
  }

  String _getCategoryLabel(FuturePlanningCategory category) {
    switch (category) {
      case FuturePlanningCategory.relationship:
        return 'Relationship';
      case FuturePlanningCategory.career:
        return 'Career';
      case FuturePlanningCategory.family:
        return 'Family';
      case FuturePlanningCategory.health:
        return 'Health';
      case FuturePlanningCategory.finance:
        return 'Finance';
      case FuturePlanningCategory.travel:
        return 'Travel';
      case FuturePlanningCategory.home:
        return 'Home';
      case FuturePlanningCategory.personal:
        return 'Personal';
      case FuturePlanningCategory.education:
        return 'Education';
      case FuturePlanningCategory.hobbies:
        return 'Hobbies';
    }
  }
}
