import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../data/models/memory_model.dart';

/// Heart Pin Marker Widget
/// Follows memory_journey.md specification for journey visualization
class HeartPinMarker extends StatefulWidget {
  final MemoryModel memory;
  final Offset position;
  final VoidCallback? onTap;
  final bool isSelected;
  final double scale;

  const HeartPinMarker({
    super.key,
    required this.memory,
    required this.position,
    this.onTap,
    this.isSelected = false,
    this.scale = 1.0,
  });

  @override
  State<HeartPinMarker> createState() => _HeartPinMarkerState();
}

class _HeartPinMarkerState extends State<HeartPinMarker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late AnimationController _glowController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Pulse animation for heartbeat effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Bounce animation for tap feedback
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Glow animation for selected state
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation
    _pulseController.repeat(reverse: true);

    if (widget.isSelected) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(HeartPinMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 20,
      top: widget.position.dy - 20,
      child: GestureDetector(
        onTap: () {
          _bounceController.forward().then((_) {
            _bounceController.reverse();
          });
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pulseAnimation,
            _bounceAnimation,
            _glowAnimation,
          ]),
          builder: (context, child) {
            final pulseScale = _pulseAnimation.value;
            final bounceScale = _bounceAnimation.value;
            final glowOpacity = _glowAnimation.value;
            final totalScale = pulseScale * bounceScale * widget.scale;

            return Transform.scale(
              scale: totalScale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect for selected state
                  if (widget.isSelected) _buildGlowEffect(glowOpacity),

                  // Main heart pin
                  _buildHeartPin(),

                  // Memory content
                  _buildMemoryContent(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlowEffect(double opacity) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getMoodColor(widget.memory.mood)
                .withValues(alpha: 0.3 * opacity),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: _getMoodColor(widget.memory.mood)
                .withValues(alpha: 0.1 * opacity),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildHeartPin() {
    return CustomPaint(
      size: const Size(40, 40),
      painter: HeartPinPainter(
        color: _getMoodColor(widget.memory.mood),
        isSelected: widget.isSelected,
      ),
    );
  }

  Widget _buildMemoryContent() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: _getMoodColor(widget.memory.mood),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: widget.memory.photoPath != null
          ? _buildPhotoThumbnail()
          : _buildEmojiContent(),
    );
  }

  Widget _buildPhotoThumbnail() {
    return ClipOval(
      child: Image.asset(
        widget.memory.photoPath!,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildEmojiContent();
        },
      ),
    );
  }

  Widget _buildEmojiContent() {
    return Center(
      child: Text(
        widget.memory.emoji,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'excited':
        return Colors.orange;
      case 'romantic':
        return Colors.pink;
      case 'grateful':
        return Colors.purple;
      case 'peaceful':
        return Colors.blue;
      case 'nostalgic':
        return Colors.indigo;
      default:
        return AppTheme.primaryPink;
    }
  }
}

/// Custom painter for heart pin shape
class HeartPinPainter extends CustomPainter {
  final Color color;
  final bool isSelected;

  HeartPinPainter({
    required this.color,
    this.isSelected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final heartPath = _createHeartPath(center, size.width * 0.4);

    // Draw heart shadow
    canvas.save();
    canvas.translate(2, 2);
    canvas.drawPath(
      heartPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // Draw main heart
    canvas.drawPath(heartPath, paint);

    // Draw white border
    canvas.drawPath(heartPath, strokePaint);

    // Draw pin point
    final pinPath = Path();
    pinPath.moveTo(center.dx, center.dy + size.height * 0.3);
    pinPath.lineTo(center.dx - size.width * 0.1, center.dy + size.height * 0.5);
    pinPath.lineTo(center.dx + size.width * 0.1, center.dy + size.height * 0.5);
    pinPath.close();

    canvas.drawPath(pinPath, paint);
    canvas.drawPath(pinPath, strokePaint);
  }

  Path _createHeartPath(Offset center, double size) {
    final path = Path();

    // Heart shape using cubic bezier curves
    final leftCurve = Offset(center.dx - size * 0.5, center.dy - size * 0.3);
    final rightCurve = Offset(center.dx + size * 0.5, center.dy - size * 0.3);

    path.moveTo(center.dx, center.dy + size * 0.1);

    // Left side of heart
    path.cubicTo(
      center.dx - size * 0.5,
      center.dy - size * 0.1,
      leftCurve.dx,
      leftCurve.dy,
      center.dx,
      center.dy - size * 0.2,
    );

    // Right side of heart
    path.cubicTo(
      rightCurve.dx,
      rightCurve.dy,
      center.dx + size * 0.5,
      center.dy - size * 0.1,
      center.dx,
      center.dy + size * 0.1,
    );

    return path;
  }

  @override
  bool shouldRepaint(HeartPinPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isSelected != isSelected;
  }
}

/// Floating heart animation for romantic effect
class FloatingHeart extends StatefulWidget {
  final Offset startPosition;
  final Duration duration;
  final Color color;

  const FloatingHeart({
    super.key,
    required this.startPosition,
    this.duration = const Duration(seconds: 3),
    this.color = AppTheme.primaryPink,
  });

  @override
  State<FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: Offset(
        widget.startPosition.dx + (math.Random().nextDouble() - 0.5) * 100,
        widget.startPosition.dy - 150,
      ),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                Icons.favorite,
                color: widget.color,
                size: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
