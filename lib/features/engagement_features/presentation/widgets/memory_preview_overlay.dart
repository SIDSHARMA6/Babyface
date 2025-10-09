import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/memory_model.dart';
import '../services/typography_manager.dart';
import '../services/theme_manager.dart';

/// Memory Preview Overlay
/// Shows full photo and details when user long presses a memory marker
class MemoryPreviewOverlay extends StatefulWidget {
  final MemoryModel memory;
  final VoidCallback onClose;
  final String theme;

  const MemoryPreviewOverlay({
    Key? key,
    required this.memory,
    required this.onClose,
    required this.theme,
  }) : super(key: key);

  @override
  State<MemoryPreviewOverlay> createState() => _MemoryPreviewOverlayState();
}

class _MemoryPreviewOverlayState extends State<MemoryPreviewOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = ThemeManager.getThemeColors(widget.theme);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeAnimation,
        _scaleAnimation,
        _slideAnimation,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.black.withValues(alpha: 0.8 * _fadeAnimation.value),
            child: Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildPreviewCard(themeColors),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewCard(Map<String, Color> themeColors) {
    return Container(
      margin: const EdgeInsets.all(20),
      constraints: const BoxConstraints(
        maxWidth: 400,
        maxHeight: 600,
      ),
      decoration: BoxDecoration(
        color: themeColors['background'] ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          _buildHeader(themeColors),

          // Photo section
          _buildPhotoSection(themeColors),

          // Memory details
          _buildMemoryDetails(themeColors),

          // Action buttons
          _buildActionButtons(themeColors),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, Color> themeColors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColors['primary']?.withValues(alpha: 0.1) ??
            Colors.grey.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Memory emoji
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: themeColors['accent']?.withValues(alpha: 0.2) ??
                  Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                widget.memory.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Memory title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.memory.title,
                  style: TypographyManager.memoryTitle(
                    fontSize: 18,
                    color: themeColors['text'],
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.memory.description.isNotEmpty)
                  Text(
                    widget.memory.description,
                    style: TypographyManager.memoryDescription(
                      fontSize: 14,
                      color: themeColors['text']?.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Close button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _closeOverlay();
            },
            icon: Icon(
              Icons.close,
              color: themeColors['text'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(Map<String, Color> themeColors) {
    return Container(
      height: 250,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.memory.photoPath != null
            ? Image.network(
                widget.memory.photoPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPhotoPlaceholder(themeColors);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPhotoLoading(themeColors);
                },
              )
            : _buildPhotoPlaceholder(themeColors),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(Map<String, Color> themeColors) {
    return Container(
      color: themeColors['accent']?.withValues(alpha: 0.1) ??
          Colors.grey.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo,
              size: 48,
              color: themeColors['accent']?.withValues(alpha: 0.5) ??
                  Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Photo',
              style: TypographyManager.uiLabel(
                color: themeColors['text']?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoLoading(Map<String, Color> themeColors) {
    return Container(
      color: themeColors['accent']?.withValues(alpha: 0.1) ??
          Colors.grey.withValues(alpha: 0.1),
      child: Center(
        child: CircularProgressIndicator(
          color: themeColors['accent'],
        ),
      ),
    );
  }

  Widget _buildMemoryDetails(Map<String, Color> themeColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Date and time
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: themeColors['accent'],
              ),
              const SizedBox(width: 8),
              Text(
                widget.memory.date,
                style: TypographyManager.dateTime(
                  color: themeColors['text'],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: themeColors['accent'],
              ),
              const SizedBox(width: 8),
              Text(
                _formatTimestamp(widget.memory.timestamp),
                style: TypographyManager.dateTime(
                  color: themeColors['text'],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location
          if (widget.memory.location != null) ...[
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: themeColors['accent'],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.memory.location!,
                    style: TypographyManager.uiLabel(
                      color: themeColors['text'],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Mood and emotion
          Row(
            children: [
              Icon(
                _getMoodIcon(widget.memory.mood),
                size: 16,
                color: themeColors['accent'],
              ),
              const SizedBox(width: 8),
              Text(
                _getMoodText(widget.memory.mood),
                style: TypographyManager.emotionLabel(
                  color: themeColors['text'],
                ),
              ),
              const SizedBox(width: 16),
              if (widget.memory.isFavorite)
                Icon(
                  Icons.favorite,
                  size: 16,
                  color: Colors.red,
                ),
            ],
          ),

          // Tags
          if (widget.memory.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.memory.tags.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeColors['accent']?.withValues(alpha: 0.2) ??
                        Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: TypographyManager.caption(
                      color: themeColors['text'],
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, Color> themeColors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                // TODO: Implement share functionality
              },
              icon: const Icon(Icons.share, size: 18),
              label: Text(
                'Share',
                style: TypographyManager.buttonText(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColors['accent'],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                // TODO: Implement edit functionality
              },
              icon: const Icon(Icons.edit, size: 18),
              label: Text(
                'Edit',
                style: TypographyManager.buttonText(
                  fontSize: 14,
                  color: themeColors['text'],
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: themeColors['text'],
                side: BorderSide(color: themeColors['accent'] ?? Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _closeOverlay() {
    _fadeController.reverse().then((_) {
      widget.onClose();
    });
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'excited':
        return Icons.sentiment_satisfied_alt;
      case 'peaceful':
        return Icons.sentiment_neutral;
      case 'romantic':
        return Icons.favorite;
      case 'nostalgic':
        return Icons.history;
      case 'grateful':
        return Icons.emoji_emotions;
      case 'energetic':
        return Icons.bolt;
      case 'contemplative':
        return Icons.psychology;
      case 'celebratory':
        return Icons.celebration;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  String _getMoodText(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return 'Happy';
      case 'sad':
        return 'Sad';
      case 'excited':
        return 'Excited';
      case 'peaceful':
        return 'Peaceful';
      case 'romantic':
        return 'Romantic';
      case 'nostalgic':
        return 'Nostalgic';
      case 'grateful':
        return 'Grateful';
      case 'energetic':
        return 'Energetic';
      case 'contemplative':
        return 'Contemplative';
      case 'celebratory':
        return 'Celebratory';
      default:
        return mood;
    }
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
