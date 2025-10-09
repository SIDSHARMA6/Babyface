import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/memory_journey_entity.dart';
import '../../data/models/memory_model.dart';

/// Memory Pin Marker Widget
/// Displays a memory as a pin-shaped marker with photo and animations
class MemoryPinMarker extends StatefulWidget {
  final MemoryModel memory;
  final MemoryJourneyThemeEntity theme;
  final bool isActive;
  final VoidCallback? onTap;

  const MemoryPinMarker({
    Key? key,
    required this.memory,
    required this.theme,
    this.isActive = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<MemoryPinMarker> createState() => _MemoryPinMarkerState();
}

class _MemoryPinMarkerState extends State<MemoryPinMarker>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _floatingController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Scale animation for reveal effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Pulse animation for active state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Floating animation
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // Start scale animation for reveal
    _scaleController.forward();

    // Start floating animation
    _floatingController.repeat(reverse: true);

    // Start pulse animation if active
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MemoryPinMarker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _pulseController.repeat(reverse: true);
        _glowController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _glowController.stop();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _pulseAnimation,
          _glowAnimation,
          _floatingAnimation,
        ]),
        builder: (context, child) {
          final floatingOffset = Offset(
            0,
            math.sin(_floatingAnimation.value * 2 * math.pi) * 3,
          );

          return Transform.translate(
            offset: floatingOffset,
            child: Transform.scale(
              scale: _scaleAnimation.value *
                  (widget.isActive ? _pulseAnimation.value : 1.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  if (widget.isActive) _buildGlowEffect(),

                  // Pin shadow
                  _buildPinShadow(),

                  // Pin body
                  _buildPinBody(),

                  // Memory photo
                  _buildMemoryPhoto(),

                  // Pin tip
                  _buildPinTip(),

                  // Memory label
                  _buildMemoryLabel(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlowEffect() {
    return Container(
      width: 120 + (_glowAnimation.value * 20),
      height: 120 + (_glowAnimation.value * 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.theme.primaryColor
                .withValues(alpha: 0.3 * _glowAnimation.value),
            blurRadius: 20 + (_glowAnimation.value * 10),
            spreadRadius: 5 + (_glowAnimation.value * 5),
          ),
        ],
      ),
    );
  }

  Widget _buildPinShadow() {
    return Transform.translate(
      offset: const Offset(2, 2),
      child: CustomPaint(
        size: const Size(80, 100),
        painter: PinShapePainter(
          color: Colors.black.withValues(alpha: 0.3),
          isShadow: true,
        ),
      ),
    );
  }

  Widget _buildPinBody() {
    return CustomPaint(
      size: const Size(80, 100),
      painter: PinShapePainter(
        color: widget.theme.accentColor,
        isShadow: false,
      ),
    );
  }

  Widget _buildMemoryPhoto() {
    if (widget.memory.photoPath == null) {
      return _buildPlaceholderPhoto();
    }

    return Positioned(
      top: 8,
      child: ClipOval(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.theme.primaryColor,
              width: 2,
            ),
          ),
          child: Image.asset(
            widget.memory.photoPath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderPhoto();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Positioned(
      top: 8,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.theme.primaryColor.withValues(alpha: 0.3),
          border: Border.all(
            color: widget.theme.primaryColor,
            width: 2,
          ),
        ),
        child: Icon(
          _getMoodIcon(),
          color: widget.theme.primaryColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildPinTip() {
    return Positioned(
      bottom: 0,
      child: CustomPaint(
        size: const Size(80, 20),
        painter: PinTipPainter(
          color: widget.theme.accentColor,
        ),
      ),
    );
  }

  Widget _buildMemoryLabel() {
    return Positioned(
      top: -30,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.theme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.memory.title,
          style: TextStyle(
            color: widget.theme.textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  IconData _getMoodIcon() {
    switch (widget.memory.mood) {
      case 'romantic':
        return Icons.favorite;
      case 'joyful':
        return Icons.sentiment_very_satisfied;
      case 'sweet':
        return Icons.sentiment_satisfied;
      case 'emotional':
        return Icons.sentiment_dissatisfied;
      case 'fun':
        return Icons.sentiment_very_satisfied;
      case 'excited':
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.favorite;
    }
  }
}

/// Custom painter for pin shape
class PinShapePainter extends CustomPainter {
  final Color color;
  final bool isShadow;

  PinShapePainter({
    required this.color,
    this.isShadow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create teardrop shape
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2 - 5;

    // Top circle
    path.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY - 10),
      radius: radius,
    ));

    // Bottom point
    path.moveTo(centerX - radius, centerY + 5);
    path.lineTo(centerX, size.height - 5);
    path.lineTo(centerX + radius, centerY + 5);

    canvas.drawPath(path, paint);

    // Add highlight if not shadow
    if (!isShadow) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      final highlightPath = Path();
      highlightPath.addOval(Rect.fromCircle(
        center: Offset(centerX - 5, centerY - 15),
        radius: radius * 0.3,
      ));

      canvas.drawPath(highlightPath, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(PinShapePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isShadow != isShadow;
  }
}

/// Custom painter for pin tip
class PinTipPainter extends CustomPainter {
  final Color color;

  PinTipPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PinTipPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
