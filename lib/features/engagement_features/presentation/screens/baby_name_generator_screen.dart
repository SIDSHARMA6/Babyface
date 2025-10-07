import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../core/theme/responsive_utils.dart';
import '../../../../shared/widgets/optimized_widget.dart';
import '../providers/baby_name_provider.dart';
import '../../domain/entities/baby_name_entity.dart';

/// Baby Name Generator Screen
/// Follows master plan theme standards and performance requirements
class BabyNameGeneratorScreen extends OptimizedStatefulWidget {
  const BabyNameGeneratorScreen({super.key});

  @override
  OptimizedState<BabyNameGeneratorScreen> createState() => _BabyNameGeneratorScreenState();
}

class _BabyNameGeneratorScreenState extends OptimizedState<BabyNameGeneratorScreen> {
  String? _selectedGender;
  String? _selectedOrigin;
  String? _selectedStyle;
  int _nameCount = 10;

  @override
  Widget buildOptimized(BuildContext context, WidgetRef ref) {
    final state = ref.watch(babyNameProvider);
    final notifier = ref.read(babyNameProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: OptimizedText(
          'Baby Name Generator',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: context.responsiveHeight(3)),
                    _buildFilters(),
                    SizedBox(height: context.responsiveHeight(3)),
                    if (state.isLoading) ...[
                      _buildLoadingState(),
                    ] else if (state.names.isNotEmpty) ...[
                      _buildNamesList(state.names),
                    ] else ...[
                      _buildEmptyState(),
                    ],
                  ],
                ),
              ),
            ),
            _buildGenerateButton(notifier),
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
            Icons.auto_awesome,
            size: context.responsiveHeight(8),
            color: Colors.white,
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Discover Perfect Baby Names',
            style: BabyFont.headingL.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'AI-powered name suggestions with meanings and origins',
            style: BabyFont.bodyM.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Preferences',
          style: BabyFont.headingS,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        _buildGenderFilter(),
        SizedBox(height: context.responsiveHeight(2)),
        _buildOriginFilter(),
        SizedBox(height: context.responsiveHeight(2)),
        _buildStyleFilter(),
        SizedBox(height: context.responsiveHeight(2)),
        _buildCountFilter(),
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
            _buildFilterChip('Any', _selectedGender == null, () {
              setState(() => _selectedGender = null);
            }),
            SizedBox(width: context.responsiveWidth(2)),
            _buildFilterChip('Boy', _selectedGender == 'boy', () {
              setState(() => _selectedGender = 'boy');
            }),
            SizedBox(width: context.responsiveWidth(2)),
            _buildFilterChip('Girl', _selectedGender == 'girl', () {
              setState(() => _selectedGender = 'girl');
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildOriginFilter() {
    final origins = ['Any', 'English', 'Spanish', 'French', 'German', 'Italian', 'Arabic', 'Hebrew', 'Japanese'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Origin',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Wrap(
          spacing: context.responsiveWidth(1),
          runSpacing: context.responsiveHeight(1),
          children: origins.map((origin) => _buildFilterChip(
            origin,
            _selectedOrigin == origin.toLowerCase(),
            () {
              setState(() => _selectedOrigin = origin.toLowerCase());
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildStyleFilter() {
    final styles = ['Any', 'Traditional', 'Modern', 'Unique', 'Classic', 'Trendy'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Style',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Wrap(
          spacing: context.responsiveWidth(1),
          runSpacing: context.responsiveHeight(1),
          children: styles.map((style) => _buildFilterChip(
            style,
            _selectedStyle == style.toLowerCase(),
            () {
              setState(() => _selectedStyle = style.toLowerCase());
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCountFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Number of Names: $_nameCount',
          style: BabyFont.bodyM.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveHeight(1)),
        Slider(
          value: _nameCount.toDouble(),
          min: 5,
          max: 50,
          divisions: 9,
          activeColor: AppTheme.primary,
          inactiveColor: AppTheme.primary.withValues(alpha: 0.3),
          onChanged: (value) {
            setState(() => _nameCount = value.round());
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(3),
          vertical: context.responsiveHeight(1),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.responsiveRadius(20)),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: OptimizedText(
          label,
          style: BabyFont.bodyS.copyWith(
            color: isSelected ? Colors.white : AppTheme.primary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: context.responsiveHeight(4)),
          CircularProgressIndicator(
            color: AppTheme.primary,
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Generating names...',
            style: BabyFont.bodyL.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamesList(List<BabyNameEntity> names) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptimizedText(
          'Generated Names',
          style: BabyFont.headingS,
        ),
        SizedBox(height: context.responsiveHeight(2)),
        ...names.map((name) => _buildNameCard(name)),
      ],
    );
  }

  Widget _buildNameCard(BabyNameEntity name) {
    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(1)),
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: name.gender == 'boy' ? AppTheme.boyColor : AppTheme.girlColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OptimizedText(
                  name.name,
                  style: BabyFont.headingM.copyWith(
                    color: name.gender == 'boy' ? AppTheme.boyColor : AppTheme.girlColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(2),
                  vertical: context.responsiveHeight(0.5),
                ),
                decoration: BoxDecoration(
                  color: name.gender == 'boy' ? AppTheme.boyColor : AppTheme.girlColor,
                  borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
                ),
                child: OptimizedText(
                  name.gender.toUpperCase(),
                  style: BabyFont.bodyS.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Origin: ${name.origin}',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(0.5)),
          OptimizedText(
            'Meaning: ${name.meaning}',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: context.responsiveHeight(1)),
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppTheme.accent,
                size: context.responsiveFont(16),
              ),
              SizedBox(width: context.responsiveWidth(1)),
              OptimizedText(
                'Popularity: ${(name.popularity * 100).toInt()}%',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: context.responsiveHeight(4)),
          Icon(
            Icons.auto_awesome_outlined,
            size: context.responsiveHeight(12),
            color: AppTheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.responsiveHeight(2)),
          OptimizedText(
            'Ready to discover names?',
            style: BabyFont.headingM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(1)),
          OptimizedText(
            'Tap the generate button to get personalized baby name suggestions',
            style: BabyFont.bodyM.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(BabyNameNotifier notifier) {
    return OptimizedButton(
      text: 'Generate Names',
      onPressed: () => _generateNames(notifier),
      type: ButtonType.primary,
      size: ButtonSize.large,
      icon: const Icon(Icons.auto_awesome),
    );
  }

  void _generateNames(BabyNameNotifier notifier) {
    final request = BabyNameRequest(
      gender: _selectedGender,
      origin: _selectedOrigin,
      style: _selectedStyle,
      count: _nameCount,
    );
    
    notifier.generateNames(request);
  }
}
