import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';

/// Floating Hearts Layer Widget
/// Follows memory_journey.md specification for romantic animations
class FloatingHeartsLayer extends StatefulWidget {
  final Widget child;
  final int heartCount;
  final Duration animationDuration;
  final bool isActive;
  final Color? heartColor;
  final double heartSize;
  final double animationSpeed;

  const FloatingHeartsLayer({
    super.key,
    required this.child,
    this.heartCount = 12,
    this.animationDuration = const Duration(seconds: 4),
    this.isActive = true,
    this.heartColor,
    this.heartSize = 16.0,
    this.animationSpeed = 1.0,
  });

  @override
  State<FloatingHeartsLayer> createState() => _FloatingHeartsLayerState();
}

class _FloatingHeartsLayerState extends State<FloatingHeartsLayer>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;

  late Animation<double> _mainAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  final List<FloatingHeart> _hearts = [];
  final List<Sparkle> _sparkles = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateHearts();
    _generateSparkles();
  }

  void _setupAnimations() {
    // Main floating animation
    _mainController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _mainAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for romantic effect
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _mainController.repeat();
    _pulseController.repeat(reverse: true);
    _sparkleController.repeat();
  }

  void _generateHearts() {
    final random = math.Random();
    final colors = [
      widget.heartColor ?? AppTheme.primaryPink,
      AppTheme.primaryBlue,
      AppTheme.accentYellow,
      Colors.pink.shade300,
      Colors.purple.shade300,
      Colors.red.shade300,
    ];

    for (int i = 0; i < widget.heartCount; i++) {
      _hearts.add(FloatingHeart(
        id: i,
        startX: random.nextDouble(),
        startY: 1.0 + random.nextDouble() * 0.2, // Start from bottom
        endX: random.nextDouble(),
        endY: -0.2 - random.nextDouble() * 0.2, // End at top
        size: widget.heartSize + random.nextDouble() * 8.0,
        color: colors[random.nextInt(colors.length)],
        delay: Duration(milliseconds: random.nextInt(3000)),
        speed: 0.5 + random.nextDouble() * 0.5,
        rotation: random.nextDouble() * 2 * math.pi,
        scale: 0.5 + random.nextDouble() * 0.5,
      ));
    }
  }

  void _generateSparkles() {
    final random = math.Random();
    
    for (int i = 0; i < 20; i++) {
      _sparkles.add(Sparkle(
        id: i,
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 2.0 + random.nextDouble() * 4.0,
        color: Colors.white.withValues(alpha: 0.8),
        delay: Duration(milliseconds: random.nextInt(2000)),
        duration: Duration(milliseconds: 1000 + random.nextInt(2000)),
      ));
    }
  }

  @override
  void didUpdateWidget(FloatingHeartsLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimations();
      } else {
        _mainController.stop();
        _pulseController.stop();
        _sparkleController.stop();
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainAnimation,
        _pulseAnimation,
        _sparkleAnimation,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            widget.child,
            ..._buildFloatingHearts(),
            ..._buildSparkles(),
          ],
        );
      },
    );
  }

  List<Widget> _buildFloatingHearts() {
    return _hearts.map((heart) {
      return _FloatingHeartWidget(
        heart: heart,
        animation: _mainAnimation,
        pulseAnimation: _pulseAnimation,
      );
    }).toList();
  }

  List<Widget> _buildSparkles() {
    return _sparkles.map((sparkle) {
      return _SparkleWidget(
        sparkle: sparkle,
        animation: _sparkleAnimation,
      );
    }).toList();
  }
}

/// Floating Heart Data
class FloatingHeart {
  final int id;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final Color color;
  final Duration delay;
  final double speed;
  final double rotation;
  final double scale;

  FloatingHeart({
    required this.id,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.color,
    required this.delay,
    required this.speed,
    required this.rotation,
    required this.scale,
  });
}

/// Sparkle Data
class Sparkle {
  final int id;
  final double x;
  final double y;
  final double size;
  final Color color;
  final Duration delay;
  final Duration duration;

  Sparkle({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.delay,
    required this.duration,
  });
}

/// Floating Heart Widget
class _FloatingHeartWidget extends StatefulWidget {
  final FloatingHeart heart;
  final Animation<double> animation;
  final Animation<double> pulseAnimation;

  const _FloatingHeartWidget({
    required this.heart,
    required this.animation,
    required this.pulseAnimation,
  });

  @override
  State<_FloatingHeartWidget> createState() => _FloatingHeartWidgetState();
}

class _FloatingHeartWidgetState extends State<_FloatingHeartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: Duration(
        milliseconds: (4000 / widget.heart.speed).round(),
      ),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: widget.heart.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _positionAnimation = Tween<Offset>(
      begin: Offset(widget.heart.startX, widget.heart.startY),
      end: Offset(widget.heart.endX, widget.heart.endY),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: widget.heart.rotation,
      end: widget.heart.rotation + 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Start animation with delay
    Future.delayed(widget.heart.delay, () {
      if (mounted) {
        _controller.forward().then((_) {
          // Restart animation for continuous effect
          _controller.reset();
          _controller.forward();
        });
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
        final screenSize = MediaQuery.of(context).size;
        final position = Offset(
          _positionAnimation.value.dx * screenSize.width,
          _positionAnimation.value.dy * screenSize.height,
        );

        return Positioned(
          left: position.dx - widget.heart.size / 2,
          top: position.dy - widget.heart.size / 2,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value * widget.pulseAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: CustomPaint(
                  size: Size(widget.heart.size, widget.heart.size),
                  painter: HeartPainter(
                    color: widget.heart.color,
                    size: widget.heart.size,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Sparkle Widget
class _SparkleWidget extends StatefulWidget {
  final Sparkle sparkle;
  final Animation<double> animation;

  const _SparkleWidget({
    required this.sparkle,
    required this.animation,
  });

  @override
  State<_SparkleWidget> createState() => _SparkleWidgetState();
}

class _SparkleWidgetState extends State<_SparkleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: widget.sparkle.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Start animation with delay
    Future.delayed(widget.sparkle.delay, () {
      if (mounted) {
        _controller.forward().then((_) {
          // Restart animation for continuous effect
          _controller.reset();
          _controller.forward();
        });
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
        final screenSize = MediaQuery.of(context).size;
        final position = Offset(
          widget.sparkle.x * screenSize.width,
          widget.sparkle.y * screenSize.height,
        );

        return Positioned(
          left: position.dx - widget.sparkle.size / 2,
          top: position.dy - widget.sparkle.size / 2,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: CustomPaint(
                  size: Size(widget.sparkle.size, widget.sparkle.size),
                  painter: SparklePainter(
                    color: widget.sparkle.color,
                    size: widget.sparkle.size,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Heart Painter
class HeartPainter extends CustomPainter {
  final Color color;
  final double size;

  HeartPainter({
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final heartPath = _createHeartPath(center, size.width * 0.4);

    // Draw heart shadow
    canvas.save();
    canvas.translate(1, 1);
    canvas.drawPath(
      heartPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // Draw main heart
    canvas.drawPath(heartPath, paint);

    // Draw highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.15),
      size.width * 0.1,
      highlightPaint,
    );
  }

  Path _createHeartPath(Offset center, double size) {
    final path = Path();
    
    // Heart shape using cubic bezier curves
    final leftCurve = Offset(center.dx - size * 0.5, center.dy - size * 0.3);
    final rightCurve = Offset(center.dx + size * 0.5, center.dy - size * 0.3);
    
    path.moveTo(center.dx, center.dy + size * 0.1);
    
    // Left side of heart
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.1,
      leftCurve.dx, leftCurve.dy,
      center.dx, center.dy - size * 0.2,
    );
    
    // Right side of heart
    path.cubicTo(
      rightCurve.dx, rightCurve.dy,
      center.dx + size * 0.5, center.dy - size * 0.1,
      center.dx, center.dy + size * 0.1,
    );
    
    return path;
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.size != size;
  }
}

/// Sparkle Painter
class SparklePainter extends CustomPainter {
  final Color color;
  final double size;

  SparklePainter({
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final sparklePath = _createSparklePath(center, size.width * 0.4);

    canvas.drawPath(sparklePath, paint);
  }

  Path _createSparklePath(Offset center, double size) {
    final path = Path();
    
    // Create star shape
    final points = <Offset>[];
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final radius = i % 2 == 0 ? size : size * 0.5;
      points.add(Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      ));
    }
    
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    
    return path;
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.size != size;
  }
}

/// Heartbeat Animation Widget
class HeartbeatAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scale;

  const HeartbeatAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.scale = 1.1,
  });

  @override
  State<HeartbeatAnimation> createState() => _HeartbeatAnimationState();
}

class _HeartbeatAnimationState extends State<HeartbeatAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
