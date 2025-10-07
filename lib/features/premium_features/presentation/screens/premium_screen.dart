import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../providers/premium_provider.dart';
import '../../domain/entities/premium_subscription_entity.dart';

/// Premium Screen
/// Follows master plan theme standards and performance requirements
class PremiumScreen extends OptimizedStatefulWidget {
  const PremiumScreen({super.key});

  @override
  OptimizedState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends OptimizedState<PremiumScreen> {
  SubscriptionType _selectedPlan = SubscriptionType.monthly;

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumProvider);
    final notifier = ref.read(premiumProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Premium Features',
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: context.responsiveHeight(3)),
                    _buildFeaturesList(),
                    SizedBox(height: context.responsiveHeight(3)),
                    _buildPricingPlans(),
                    SizedBox(height: context.responsiveHeight(3)),
                    _buildTestimonials(),
                  ],
                ),
              ),
            ),
            _buildSubscribeButton(state, notifier),
            if (state.errorMessage != null) ...[
              SizedBox(height: context.responsiveHeight(1)),
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
            Icons.diamond,
            size: context.responsiveHeight(10),
            color: Colors.white,
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Unlock Premium Features',
            style: BabyFont.headingL.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Get unlimited access to all premium features and create amazing baby images',
            style: BabyFont.bodyL.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      _FeatureItem(
        icon: Icons.high_quality,
        title: 'HD Image Generation',
        description: 'Generate high-resolution baby images up to 4K quality',
        color: AppTheme.primary,
      ),
      _FeatureItem(
        icon: Icons.remove_circle_outline,
        title: 'Watermark Removal',
        description: 'Remove watermarks from all generated images',
        color: AppTheme.accent,
      ),
      _FeatureItem(
        icon: Icons.all_inclusive,
        title: 'Unlimited Generations',
        description: 'Generate as many baby images as you want',
        color: AppTheme.boyColor,
      ),
      _FeatureItem(
        icon: Icons.flash_on,
        title: 'Priority Processing',
        description: 'Get your images processed faster with priority queue',
        color: AppTheme.girlColor,
      ),
      _FeatureItem(
        icon: Icons.tune,
        title: 'Advanced Filters',
        description: 'Access to exclusive filters and editing tools',
        color: Colors.purple,
      ),
      _FeatureItem(
        icon: Icons.cloud_upload,
        title: 'Cloud Storage',
        description: 'Store all your images safely in the cloud',
        color: Colors.blue,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Premium Features',
          style: BabyFont.headingS,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        ...features.map((feature) => _buildFeatureItem(feature)),
      ],
    );
  }

  Widget _buildFeatureItem(_FeatureItem feature) {
    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: feature.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.responsiveWidth(2)),
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.responsiveRadius(8)),
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: context.responsiveFont(24),
            ),
          ),
          SizedBox(width: context.responsiveWidth(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OptimizedText(
                  feature.title,
                  style: BabyFont.headingS,
                ),
                SizedBox(height: context.responsiveHeight(0.5)),
                OptimizedText(
                  feature.description,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppTheme.accent,
            size: context.responsiveFont(20),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Choose Your Plan',
          style: BabyFont.headingS,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        Row(
          children: [
            Expanded(
              child: _buildPlanCard(
                SubscriptionType.monthly,
                '\$9.99',
                'per month',
                'Most Popular',
                false,
              ),
            ),
            SizedBox(width: context.responsiveWidth(2)),
            Expanded(
              child: _buildPlanCard(
                SubscriptionType.yearly,
                '\$79.99',
                'per year',
                'Save 33%',
                true,
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(2)),
        _buildPlanCard(
          SubscriptionType.lifetime,
          '\$199.99',
          'one-time payment',
          'Best Value',
          false,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    SubscriptionType type,
    String price,
    String period,
    String badge,
    bool isRecommended, {
    bool isWide = false,
  }) {
    final isSelected = _selectedPlan == type;
    final cardColor = isSelected ? AppTheme.primary : Colors.white;
    final textColor = isSelected ? Colors.white : AppTheme.textPrimary;
    final secondaryTextColor = isSelected
        ? Colors.white.withValues(alpha: 0.8)
        : AppTheme.textSecondary;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = type),
      child: Container(
        padding: context.responsivePadding,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
          boxShadow: AppTheme.softShadow,
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.primary.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isRecommended) ...[
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
                  badge,
                  style: BabyFont.bodyS.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: context.responsiveHeight(1)),
            ],
            OptimizedText(
              _getPlanTitle(type),
              style: BabyFont.headingS.copyWith(
                color: textColor,
              ),
            ),
            SizedBox(height: context.responsiveHeight(1)),
            OptimizedText(
              price,
              style: BabyFont.headingL.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            OptimizedText(
              period,
              style: BabyFont.bodyM.copyWith(
                color: secondaryTextColor,
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: context.responsiveHeight(1)),
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: context.responsiveFont(24),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonials() {
    final testimonials = [
      _Testimonial(
        name: 'Sarah & Mike',
        text: 'The HD images are absolutely stunning! Worth every penny.',
        rating: 5,
      ),
      _Testimonial(
        name: 'Emma & James',
        text: 'Unlimited generations let us create so many beautiful memories.',
        rating: 5,
      ),
      _Testimonial(
        name: 'Lisa & David',
        text: 'Priority processing is amazing - we get our images so fast!',
        rating: 5,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'What Our Users Say',
          style: BabyFont.headingS,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        SizedBox(
          height: context.responsiveHeight(20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = testimonials[index];
              return Container(
                width: context.responsiveWidth(70),
                margin: EdgeInsets.only(right: context.responsiveWidth(2)),
                padding: context.responsivePadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(context.responsiveRadius(12)),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                          5,
                          (i) => Icon(
                                i < testimonial.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppTheme.accent,
                                size: context.responsiveFont(16),
                              )),
                    ),
                    SizedBox(height: context.responsiveHeight(1)),
                    OptimizedText(
                      testimonial.text,
                      style: BabyFont.bodyM,
                    ),
                    const Spacer(),
                    OptimizedText(
                      '- ${testimonial.name}',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(PremiumState state, PremiumNotifier notifier) {
    return OptimizedButton(
      text: state.isLoading ? 'Processing...' : 'Subscribe Now',
      onPressed: state.isLoading ? null : () => _subscribe(notifier),
      type: ButtonType.primary,
      size: ButtonSize.large,
      icon: state.isLoading ? null : const Icon(Icons.diamond),
      isLoading: state.isLoading,
    );
  }

  Widget _buildErrorMessage(String error, PremiumNotifier notifier) {
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

  String _getPlanTitle(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.monthly:
        return 'Monthly';
      case SubscriptionType.yearly:
        return 'Yearly';
      case SubscriptionType.lifetime:
        return 'Lifetime';
    }
  }

  void _subscribe(PremiumNotifier notifier) {
    final request = PremiumSubscriptionRequest(
      type: _selectedPlan,
      startTrial: true,
    );

    notifier.subscribe(request);
  }
}

/// Feature item data class
class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// Testimonial data class
class _Testimonial {
  final String name;
  final String text;
  final int rating;

  _Testimonial({
    required this.name,
    required this.text,
    required this.rating,
  });
}
