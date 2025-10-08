import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/loading_animation.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../providers/baby_generation_provider.dart';

/// Screen showing baby generation progress and results
/// Follows master plan theme standards and performance requirements
class BabyGenerationScreen extends OptimizedStatefulWidget {
  const BabyGenerationScreen({super.key});

  @override
  OptimizedState<BabyGenerationScreen> createState() =>
      _BabyGenerationScreenState();
}

class _BabyGenerationScreenState extends OptimizedState<BabyGenerationScreen> {
  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(babyGenerationProvider);
    final notifier = ref.read(babyGenerationProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Generate Baby',
          style: BabyFont.headingM,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: OptimizedContainer(
        padding: context.responsivePadding,
        child: Column(
          children: [
            if (state.isLoading || state.currentGeneration != null) ...[
              Expanded(
                child: _buildGenerationProgress(state, notifier),
              ),
            ] else ...[
              Expanded(
                child: _buildGenerationStart(notifier),
              ),
              OptimizedButton(
                text: 'Start Generation',
                onPressed: () => _startGeneration(notifier),
                type: ButtonType.primary,
                size: ButtonSize.large,
                icon: const Icon(Icons.child_care),
              ),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(state.errorMessage!, notifier),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationProgress(
      BabyGenerationState state, BabyGenerationNotifier notifier) {
    final generation = state.currentGeneration;
    if (generation == null) return const SizedBox.shrink();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LoadingAnimation(),
        SizedBox(height: context.responsiveHeight(4)),
        OptimizedText(
          'Creating your baby...',
          style: BabyFont.headingL,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        LinearProgressIndicator(
          value: generation.progress,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          minHeight: 8,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        OptimizedText(
          '${(generation.progress * 100).toInt()}%',
          style: BabyFont.bodyL.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(4)),
        OptimizedButton(
          text: 'Cancel',
          onPressed: () => notifier.cancelGeneration(),
          type: ButtonType.outline,
          size: ButtonSize.medium,
        ),
      ],
    );
  }

  Widget _buildGenerationStart(BabyGenerationNotifier notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: context.responsivePadding,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.responsiveRadius(20)),
          ),
          child: Icon(
            Icons.child_care,
            size: context.responsiveHeight(15),
            color: AppTheme.primary,
          ),
        ),
        SizedBox(height: context.responsiveHeight(4)),
        OptimizedText(
          'Ready to create your baby?',
          style: BabyFont.headingL,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        OptimizedText(
          'Upload photos of both parents to generate a beautiful baby image using AI.',
          style: BabyFont.bodyL.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.responsiveHeight(4)),
        _buildFeatureList(),
      ],
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'AI-powered face blending',
      'High-quality image generation',
      'Multiple style options',
      'Instant results',
    ];

    return Column(
      children: features
          .map((feature) => Padding(
                padding: EdgeInsets.symmetric(
                    vertical: context.responsiveHeight(0.5)),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.accent,
              size: context.responsiveFont(16),
            ),
            SizedBox(width: context.responsiveWidth(2)),
            OptimizedText(
              feature,
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
              ))
          .toList(),
    );
  }

  Widget _buildErrorMessage(String error, BabyGenerationNotifier notifier) {
    return Container(
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

  void _startGeneration(BabyGenerationNotifier notifier) {
    // TODO: Implement proper image selection from gallery
    // This should be replaced with actual image picker functionality
    notifier.startGeneration(
      maleImagePath: 'assets/images/baby1.jpg',
      femaleImagePath: 'assets/images/baby2.jpg',
    );
  }
}
