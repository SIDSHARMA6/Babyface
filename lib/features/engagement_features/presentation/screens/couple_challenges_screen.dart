import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../providers/couple_challenges_provider.dart';
import '../../domain/entities/couple_challenge_entity.dart';

/// Couple Challenges Screen
/// Follows master plan theme standards and performance requirements
class CoupleChallengesScreen extends OptimizedStatefulWidget {
  const CoupleChallengesScreen({super.key});

  @override
  OptimizedState<CoupleChallengesScreen> createState() =>
      _CoupleChallengesScreenState();
}

class _CoupleChallengesScreenState
    extends OptimizedState<CoupleChallengesScreen> {
  ChallengeType? _selectedType;
  ChallengeDifficulty? _selectedDifficulty;

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(coupleChallengesProvider);
    final notifier = ref.read(coupleChallengesProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Couple Challenges',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context),
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
            ] else if (state.challenges.isEmpty) ...[
              Expanded(child: _buildEmptyState()),
            ] else ...[
              Expanded(child: _buildChallengesList(state.challenges, notifier)),
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
            'Strengthen Your Bond',
            style: BabyFont.headingL.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Fun activities to deepen your connection',
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
            'Loading challenges...',
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
            Icons.emoji_events_outlined,
            size: context.responsiveHeight(12),
            color: AppTheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'No challenges available',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Check back later for new challenges',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesList(List<CoupleChallengeEntity> challenges,
      CoupleChallengesNotifier notifier) {
    return Column(
      children: [
        _buildStatsRow(challenges),
        SizedBox(height: context.responsiveHeight(2)),
        Expanded(
          child: ListView.builder(
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return _buildChallengeCard(challenge, notifier);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(List<CoupleChallengeEntity> challenges) {
    final totalChallenges = challenges.length;
    final completedChallenges = challenges.where((c) => c.isCompleted).length;
    final activeChallenges = challenges
        .where((c) => !c.isCompleted && c.expiresAt.isAfter(DateTime.now()))
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              'Total', totalChallenges.toString(), AppTheme.primary),
        ),
        SizedBox(width: context.responsiveWidth(2)),
        Expanded(
          child: _buildStatCard(
              'Completed', completedChallenges.toString(), AppTheme.accent),
        ),
        SizedBox(width: context.responsiveWidth(2)),
        Expanded(
          child: _buildStatCard(
              'Active', activeChallenges.toString(), AppTheme.boyColor),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          OptimizedText(
            value,
            style: BabyFont.headingM.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.responsiveHeight(0.5)),
          OptimizedText(
            label,
            style: BabyFont.bodyS.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
      CoupleChallengeEntity challenge, CoupleChallengesNotifier notifier) {
    final isExpired = challenge.expiresAt.isBefore(DateTime.now());
    final difficultyColor = _getDifficultyColor(challenge.difficulty);
    final typeColor = _getTypeColor(challenge.type);

    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: challenge.isCompleted
              ? AppTheme.accent
              : isExpired
                  ? Colors.grey.withValues(alpha: 0.3)
                  : typeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OptimizedText(
                  challenge.title,
                  style: BabyFont.headingS,
                ),
              ),
              if (challenge.isCompleted)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.accent,
                  size: context.responsiveFont(24),
                ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            challenge.description,
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          Row(
            children: [
              _buildChallengeTag(_getTypeLabel(challenge.type), typeColor),
              SizedBox(width: context.responsiveWidth(1)),
              _buildChallengeTag(
                  _getDifficultyLabel(challenge.difficulty), difficultyColor),
              SizedBox(width: context.responsiveWidth(1)),
              _buildChallengeTag(
                  '${challenge.duration}min', AppTheme.textSecondary),
              const Spacer(),
              if (challenge.reward != null)
                Icon(
                  Icons.card_giftcard,
                  color: AppTheme.accent,
                  size: context.responsiveFont(16),
                ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(1)),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: AppTheme.textSecondary,
                size: context.responsiveFont(16),
              ),
              SizedBox(width: context.responsiveWidth(1)),
              OptimizedText(
                'Expires: ${_formatDate(challenge.expiresAt)}',
                style: BabyFont.bodyS.copyWith(
                  color: isExpired ? Colors.red : AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              if (!challenge.isCompleted && !isExpired)
                OptimizedButton(
                  text: 'Start',
                  onPressed: () => _startChallenge(challenge, notifier),
                  type: ButtonType.primary,
                  size: ButtonSize.small,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTag(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(1.5),
        vertical: context.responsiveHeight(0.5),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
      ),
      child: OptimizedText(
        label,
        style: BabyFont.bodyS.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error, CoupleChallengesNotifier notifier) {
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

  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return Colors.green;
      case ChallengeDifficulty.medium:
        return Colors.orange;
      case ChallengeDifficulty.hard:
        return Colors.red;
      case ChallengeDifficulty.expert:
        return Colors.purple;
    }
  }

  Color _getTypeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.romantic:
        return AppTheme.accent;
      case ChallengeType.fun:
        return AppTheme.boyColor;
      case ChallengeType.adventure:
        return AppTheme.girlColor;
      case ChallengeType.learning:
        return Colors.blue;
      case ChallengeType.creative:
        return Colors.purple;
      case ChallengeType.fitness:
        return Colors.green;
      case ChallengeType.cooking:
        return Colors.orange;
      case ChallengeType.communication:
        return AppTheme.primary;
    }
  }

  String _getTypeLabel(ChallengeType type) {
    switch (type) {
      case ChallengeType.romantic:
        return 'Romantic';
      case ChallengeType.fun:
        return 'Fun';
      case ChallengeType.adventure:
        return 'Adventure';
      case ChallengeType.learning:
        return 'Learning';
      case ChallengeType.creative:
        return 'Creative';
      case ChallengeType.fitness:
        return 'Fitness';
      case ChallengeType.cooking:
        return 'Cooking';
      case ChallengeType.communication:
        return 'Communication';
    }
  }

  String _getDifficultyLabel(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
      case ChallengeDifficulty.expert:
        return 'Expert';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return 'Expired';
    }
  }

  void _startChallenge(
      CoupleChallengeEntity challenge, CoupleChallengesNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) =>
          _ChallengeDialog(challenge: challenge, notifier: notifier),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedType: _selectedType,
        selectedDifficulty: _selectedDifficulty,
        onApply: (type, difficulty) {
          setState(() {
            _selectedType = type;
            _selectedDifficulty = difficulty;
          });
          // Apply filters to challenges
        },
      ),
    );
  }
}

/// Challenge dialog
class _ChallengeDialog extends OptimizedStatefulWidget {
  final CoupleChallengeEntity challenge;
  final CoupleChallengesNotifier notifier;

  const _ChallengeDialog({
    required this.challenge,
    required this.notifier,
  });

  @override
  OptimizedState<_ChallengeDialog> createState() => _ChallengeDialogState();
}

class _ChallengeDialogState extends OptimizedState<_ChallengeDialog> {
  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: OptimizedText(
        widget.challenge.title,
        style: BabyFont.headingM,
      ),
      content: SizedBox(
        width: context.responsiveWidth(80),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OptimizedText(
                widget.challenge.description,
                style: BabyFont.bodyL,
              ),
              SizedBox(height: context.responsiveHeight(2)),
              OptimizedText(
                'Instructions:',
                style: BabyFont.headingS,
              ),
              SizedBox(height: context.responsiveHeight(1)),
              ...widget.challenge.instructions.map((instruction) => Padding(
                    padding:
                        EdgeInsets.only(bottom: context.responsiveHeight(0.5)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.primary,
                          size: context.responsiveFont(16),
                        ),
                        SizedBox(width: context.responsiveWidth(1)),
                        Expanded(
                          child: OptimizedText(
                            instruction,
                            style: BabyFont.bodyM,
                          ),
                        ),
                      ],
                    ),
                  )),
              if (widget.challenge.reward != null) ...[
                SizedBox(height: context.responsiveHeight(2)),
                Container(
                  padding: context.responsivePadding,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(context.responsiveRadius(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        color: AppTheme.accent,
                        size: context.responsiveFont(20),
                      ),
                      SizedBox(width: context.responsiveWidth(1)),
                      OptimizedText(
                        'Reward: ${widget.challenge.reward}',
                        style: BabyFont.bodyM.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
          text: 'Start Challenge',
          onPressed: () {
            widget.notifier.startChallenge(widget.challenge.id);
            Navigator.of(context).pop();
          },
          type: ButtonType.primary,
        ),
      ],
    );
  }
}

/// Filter dialog
class _FilterDialog extends OptimizedStatefulWidget {
  final ChallengeType? selectedType;
  final ChallengeDifficulty? selectedDifficulty;
  final Function(ChallengeType?, ChallengeDifficulty?) onApply;

  const _FilterDialog({
    required this.selectedType,
    required this.selectedDifficulty,
    required this.onApply,
  });

  @override
  OptimizedState<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends OptimizedState<_FilterDialog> {
  ChallengeType? _selectedType;
  ChallengeDifficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedDifficulty = widget.selectedDifficulty;
  }

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: OptimizedText(
        'Filter Challenges',
        style: BabyFont.headingM,
      ),
      content: SizedBox(
        width: context.responsiveWidth(80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypeFilter(),
            SizedBox(height: context.responsiveHeight(2)),
            _buildDifficultyFilter(),
          ],
        ),
      ),
      actions: [
        OptimizedButton(
          text: 'Clear',
          onPressed: () {
            setState(() {
              _selectedType = null;
              _selectedDifficulty = null;
            });
          },
          type: ButtonType.outline,
        ),
        OptimizedButton(
          text: 'Apply',
          onPressed: () {
            widget.onApply(_selectedType, _selectedDifficulty);
            Navigator.of(context).pop();
          },
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Challenge Type',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Wrap(
          spacing: context.responsiveWidth(1),
          runSpacing: context.responsiveHeight(1),
          children: ChallengeType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedType = isSelected ? null : type),
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
                  _getTypeLabel(type),
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

  Widget _buildDifficultyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Difficulty',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Wrap(
          spacing: context.responsiveWidth(1),
          runSpacing: context.responsiveHeight(1),
          children: ChallengeDifficulty.values.map((difficulty) {
            final isSelected = _selectedDifficulty == difficulty;
            return GestureDetector(
              onTap: () => setState(
                  () => _selectedDifficulty = isSelected ? null : difficulty),
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
                  _getDifficultyLabel(difficulty),
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

  String _getTypeLabel(ChallengeType type) {
    switch (type) {
      case ChallengeType.romantic:
        return 'Romantic';
      case ChallengeType.fun:
        return 'Fun';
      case ChallengeType.adventure:
        return 'Adventure';
      case ChallengeType.learning:
        return 'Learning';
      case ChallengeType.creative:
        return 'Creative';
      case ChallengeType.fitness:
        return 'Fitness';
      case ChallengeType.cooking:
        return 'Cooking';
      case ChallengeType.communication:
        return 'Communication';
    }
  }

  String _getDifficultyLabel(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
      case ChallengeDifficulty.expert:
        return 'Expert';
    }
  }
}
