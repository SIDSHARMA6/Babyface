import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/memory_model.dart';

/// Journey Anchor Widget
/// Represents start and end points of the memory journey
class JourneyAnchor extends StatefulWidget {
  final AnchorType type;
  final String? label;
  final MemoryModel? memory;
  final String theme;
  final double zoom;
  final VoidCallback? onTap;

  const JourneyAnchor({
    Key? key,
    required this.type,
    this.label,
    this.memory,
    this.theme = 'romantic-sunset',
    this.zoom = 1.0,
    this.onTap,
  }) : super(key: key);

  @override
  State<JourneyAnchor> createState() => _JourneyAnchorState();
}

enum AnchorType { start, end }

class _JourneyAnchorState extends State<JourneyAnchor>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _sparkleController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Floating animation
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Sparkle animation (only for end point)
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _floatAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sparkleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = _getThemeColors();
    final size = 80.0 * widget.zoom;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _floatAnimation,
          _sparkleAnimation,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  if (widget.label != null) _buildLabel(themeColors),

                  // Main anchor
                  _buildAnchor(themeColors, size),

                  // Sparkles (end point only)
                  if (widget.type == AnchorType.end)
                    _buildSparkles(themeColors, size),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(Map<String, Color> themeColors) {
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
        widget.label!,
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
      ),
    );
  }

  Widget _buildAnchor(Map<String, Color> themeColors, double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: size * 1.5,
          height: size * 1.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: themeColors['glow']!.withValues(alpha: 0.3),
            boxShadow: [
              BoxShadow(
                color: themeColors['glow']!.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),

        // Main anchor container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: themeColors['background'] ?? Colors.white,
            border: Border.all(
              color: themeColors['border'] ?? Colors.grey,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Memory photo (if available)
              if (widget.memory?.photoPath != null)
                ClipOval(
                  child: Image.network(
                    widget.memory!.photoPath!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildIcon(themeColors, size),
                  ),
                )
              else
                _buildIcon(themeColors, size),

              // Highlight effect
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(Map<String, Color> themeColors, double size) {
    final iconSize = size * 0.5;

    if (widget.type == AnchorType.start) {
      return Icon(
        Icons.favorite,
        size: iconSize,
        color: themeColors['icon'],
      );
    } else {
      return Icon(
        Icons.auto_awesome,
        size: iconSize,
        color: themeColors['icon'],
      );
    }
  }

  Widget _buildSparkles(Map<String, Color> themeColors, double size) {
    return SizedBox(
      width: size * 2,
      height: size * 2,
      child: CustomPaint(
        painter: SparklePainter(
          animation: _sparkleAnimation.value,
          color: themeColors['sparkle']!,
        ),
      ),
    );
  }

  Map<String, Color> _getThemeColors() {
    switch (widget.theme) {
      case 'romantic-sunset':
        return {
          'labelBackground': const Color(0xFFFF6B9D),
          'labelText': Colors.white,
          'glow': widget.type == AnchorType.start
              ? const Color(0xFFFF6B9D)
              : const Color(0xFFFFD700),
          'background': Colors.white,
          'border': widget.type == AnchorType.start
              ? const Color(0xFFFF6B9D)
              : const Color(0xFFFFD700),
          'icon': widget.type == AnchorType.start
              ? const Color(0xFFFF6B9D)
              : const Color(0xFFFFD700),
          'sparkle': const Color(0xFFFFD700),
        };
      case 'love-garden':
        return {
          'labelBackground': const Color(0xFFFFB6C1),
          'labelText': Colors.white,
          'glow': widget.type == AnchorType.start
              ? const Color(0xFFFFB6C1)
              : const Color(0xFF98FB98),
          'background': Colors.white,
          'border': widget.type == AnchorType.start
              ? const Color(0xFFFFB6C1)
              : const Color(0xFF98FB98),
          'icon': widget.type == AnchorType.start
              ? const Color(0xFFFFB6C1)
              : const Color(0xFF98FB98),
          'sparkle': const Color(0xFF98FB98),
        };
      case 'midnight-romance':
        return {
          'labelBackground': const Color(0xFF4B0082),
          'labelText': Colors.white,
          'glow': widget.type == AnchorType.start
              ? const Color(0xFFE8B4B8)
              : const Color(0xFFC0C0C0),
          'background': Colors.white,
          'border': widget.type == AnchorType.start
              ? const Color(0xFFE8B4B8)
              : const Color(0xFFC0C0C0),
          'icon': widget.type == AnchorType.start
              ? const Color(0xFFE8B4B8)
              : const Color(0xFFC0C0C0),
          'sparkle': const Color(0xFFC0C0C0),
        };
      default:
        return {
          'labelBackground': const Color(0xFFFF6B9D),
          'labelText': Colors.white,
          'glow': widget.type == AnchorType.start
              ? const Color(0xFFFF6B9D)
              : const Color(0xFFFFD700),
          'background': Colors.white,
          'border': widget.type == AnchorType.start
              ? const Color(0xFFFF6B9D)
              : const Color(0xFFFFD700),
          'icon': widget.type == AnchorType.start
              ? const Color(0xFFFF6B9D)
              : const Color(0xFFFFD700),
          'sparkle': const Color(0xFFFFD700),
        };
    }
  }
}

/// Custom painter for sparkle effects
class SparklePainter extends CustomPainter {
  final double animation;
  final Color color;

  SparklePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final sparkleCount = 8;

    for (int i = 0; i < sparkleCount; i++) {
      final angle = (i * 2 * math.pi) / sparkleCount + animation * 2 * math.pi;
      final radius = 30.0 + math.sin(animation * 2 * math.pi + i) * 10;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      final alpha = (math.sin(animation * 2 * math.pi + i) + 1) / 2;
      final sparkleSize = 3.0 + math.sin(animation * 4 * math.pi + i) * 2;

      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      // Draw sparkle as a star
      _drawStar(canvas, Offset(x, y), sparkleSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.5;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi) / 5 - math.pi / 2;
      final outerX = center.dx + math.cos(angle) * outerRadius;
      final outerY = center.dy + math.sin(angle) * outerRadius;
      final innerX = center.dx + math.cos(angle + math.pi / 5) * innerRadius;
      final innerY = center.dy + math.sin(angle + math.pi / 5) * innerRadius;

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.color != color;
  }
}
