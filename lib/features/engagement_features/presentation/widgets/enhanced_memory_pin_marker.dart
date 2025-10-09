import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/memory_model.dart';

/// Enhanced Memory Pin Marker with Teardrop Shape
/// Implements photo-based markers with metallic rims and animations
class EnhancedMemoryPinMarker extends StatefulWidget {
  final MemoryModel memory;
  final bool isVisible;
  final bool isFocused;
  final VoidCallback onTap;
  final String theme;
  final double zoom;
  final bool showLabels;
  final bool showDates;
  final bool showEmotions;

  const EnhancedMemoryPinMarker({
    Key? key,
    required this.memory,
    required this.isVisible,
    this.isFocused = false,
    required this.onTap,
    this.theme = 'romantic-sunset',
    this.zoom = 1.0,
    this.showLabels = true,
    this.showDates = true,
    this.showEmotions = true,
  }) : super(key: key);

  @override
  State<EnhancedMemoryPinMarker> createState() =>
      _EnhancedMemoryPinMarkerState();
}

class _EnhancedMemoryPinMarkerState extends State<EnhancedMemoryPinMarker>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _idleController;
  late AnimationController _focusController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _idleFloatAnimation;
  late Animation<double> _focusScaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    if (widget.isVisible) {
      _revealController.forward();
    }
  }

  void _initAnimations() {
    // Reveal animation
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Idle floating animation
    _idleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Focus animation
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat();

    // Scale animation with bounce
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.elasticOut,
    ));

    // Opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    // Glow animation
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Idle floating animation
    _idleFloatAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: Curves.easeInOut,
      ),
    );

    // Focus scale animation
    _focusScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _focusController,
        curve: Curves.easeOut,
      ),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(EnhancedMemoryPinMarker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible && !oldWidget.isVisible) {
      _revealController.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _revealController.reverse();
    }

    if (widget.isFocused && !oldWidget.isFocused) {
      _focusController.forward();
    } else if (!widget.isFocused && oldWidget.isFocused) {
      _focusController.reverse();
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    _idleController.dispose();
    _focusController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible &&
        _revealController.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _opacityAnimation,
          _glowAnimation,
          _idleFloatAnimation,
          _focusScaleAnimation,
          _pulseAnimation,
        ]),
        builder: (context, child) {
          final totalScale = _scaleAnimation.value * _focusScaleAnimation.value;
          final totalOffset = Offset(0, _idleFloatAnimation.value);

          return Transform.translate(
            offset: totalOffset,
            child: Transform.scale(
              scale: totalScale,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Memory title
                    if (widget.showLabels) _buildMemoryTitle(),

                    // Pin with photo
                    _buildTeardropPin(),

                    // Date badge
                    if (widget.showDates) _buildDateBadge(),

                    // Emotion indicator
                    if (widget.showEmotions) _buildEmotionIndicator(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemoryTitle() {
    final themeColors = _getThemeColors();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: themeColors['labelBackground']!.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.memory.title,
        style: TextStyle(
          color: themeColors['labelText'],
          fontSize: 14 * widget.zoom,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              blurRadius: 2,
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(1, 1),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTeardropPin() {
    final themeColors = _getThemeColors();
    final pinSize = 72.0 * widget.zoom;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        if (_glowAnimation.value > 0)
          Container(
            width: pinSize * 1.5 * _glowAnimation.value,
            height: pinSize * 1.5 * _glowAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColors['glow']!
                  .withValues(alpha: 0.3 * (1 - _glowAnimation.value)),
              boxShadow: [
                BoxShadow(
                  color: themeColors['glow']!
                      .withValues(alpha: 0.5 * _glowAnimation.value),
                  blurRadius: 15 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
            ),
          ),

        // Pulse effect
        if (_pulseAnimation.value > 0)
          Container(
            width: pinSize * (1 + _pulseAnimation.value * 0.2),
            height: pinSize * (1 + _pulseAnimation.value * 0.2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColors['pulse']!
                  .withValues(alpha: (1 - _pulseAnimation.value) * 0.4),
            ),
          ),

        // Main pin container
        Container(
          width: pinSize,
          height: pinSize * 1.25, // Teardrop shape
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(pinSize / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: _TeardropClipper(),
            child: Stack(
              children: [
                // Photo or emoji
                if (widget.memory.photoPath != null)
                  Image.file(
                    File(widget.memory.photoPath!),
                    width: pinSize,
                    height: pinSize * 1.25,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildEmojiFallback(),
                  )
                else
                  _buildEmojiFallback(),

                // Metallic rim
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(pinSize / 2),
                    border: Border.all(
                      color: themeColors['metallic']!,
                      width: 3,
                    ),
                  ),
                ),

                // Highlight effect
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(pinSize / 2),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiFallback() {
    return Center(
      child: Text(
        widget.memory.emoji,
        style: TextStyle(fontSize: 30 * widget.zoom),
      ),
    );
  }

  Widget _buildDateBadge() {
    final themeColors = _getThemeColors();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: themeColors['badgeBackground']!.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeColors['badgeBorder']!,
          width: 1,
        ),
      ),
      child: Text(
        _formatDate(
            DateTime.fromMillisecondsSinceEpoch(widget.memory.timestamp)),
        style: TextStyle(
          color: themeColors['badgeText'],
          fontSize: 12 * widget.zoom,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmotionIndicator() {
    final themeColors = _getThemeColors();
    final emotionIcon = _getEmotionIcon(widget.memory.mood);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: themeColors['emotionBackground']!.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        emotionIcon,
        size: 16 * widget.zoom,
        color: themeColors['emotionIcon'],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getEmotionIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'joyful':
        return Icons.sentiment_very_satisfied;
      case 'romantic':
        return Icons.favorite;
      case 'fun':
        return Icons.celebration;
      case 'sweet':
        return Icons.emoji_emotions;
      case 'emotional':
        return Icons.sentiment_satisfied;
      case 'excited':
        return Icons.auto_awesome;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Map<String, Color> _getThemeColors() {
    switch (widget.theme) {
      case 'romantic-sunset':
        return {
          'labelBackground': const Color(0xFFFF6B9D),
          'labelText': Colors.white,
          'glow': const Color(0xFFFF6B9D),
          'pulse': const Color(0xFFFFB347),
          'metallic': const Color(0xFFFFD700),
          'badgeBackground': const Color(0xFF2C3E50),
          'badgeBorder': const Color(0xFFFFD700),
          'badgeText': Colors.white,
          'emotionBackground': const Color(0xFFFF6B9D),
          'emotionIcon': Colors.white,
        };
      case 'love-garden':
        return {
          'labelBackground': const Color(0xFFFFB6C1),
          'labelText': Colors.white,
          'glow': const Color(0xFFFFB6C1),
          'pulse': const Color(0xFF98FB98),
          'metallic': const Color(0xFFD4A5A5),
          'badgeBackground': const Color(0xFF9CAF88),
          'badgeBorder': const Color(0xFFD4A5A5),
          'badgeText': Colors.white,
          'emotionBackground': const Color(0xFFFFB6C1),
          'emotionIcon': Colors.white,
        };
      case 'midnight-romance':
        return {
          'labelBackground': const Color(0xFF4B0082),
          'labelText': Colors.white,
          'glow': const Color(0xFFE8B4B8),
          'pulse': const Color(0xFFC0C0C0),
          'metallic': const Color(0xFFE8B4B8),
          'badgeBackground': const Color(0xFF191970),
          'badgeBorder': const Color(0xFFE8B4B8),
          'badgeText': Colors.white,
          'emotionBackground': const Color(0xFF4B0082),
          'emotionIcon': Colors.white,
        };
      default:
        return {
          'labelBackground': const Color(0xFFFF6B9D),
          'labelText': Colors.white,
          'glow': const Color(0xFFFF6B9D),
          'pulse': const Color(0xFFFFB347),
          'metallic': const Color(0xFFFFD700),
          'badgeBackground': const Color(0xFF2C3E50),
          'badgeBorder': const Color(0xFFFFD700),
          'badgeText': Colors.white,
          'emotionBackground': const Color(0xFFFF6B9D),
          'emotionIcon': Colors.white,
        };
    }
  }
}

/// Custom clipper for teardrop pin shape
class _TeardropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Create teardrop shape
    path.addOval(Rect.fromCircle(
        center: Offset(centerX, centerY - radius * 0.1), radius: radius));

    // Add pointed bottom
    path.lineTo(centerX, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
