import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Particle System for Atmospheric Effects
/// Creates floating particles, sparkles, heart shapes, and light orbs
class ParticleSystem extends StatefulWidget {
  final String theme;
  final double zoom;
  final Offset pan;
  final bool isAnimating;
  final bool showParticles;

  const ParticleSystem({
    Key? key,
    required this.theme,
    this.zoom = 1.0,
    this.pan = Offset.zero,
    this.isAnimating = true,
    this.showParticles = true,
  }) : super(key: key);

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _heartController;
  late AnimationController _sparkleController;

  late Animation<double> _particleAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _sparkleAnimation;

  final List<Particle> _particles = [];
  final List<HeartParticle> _heartParticles = [];
  final List<SparkleParticle> _sparkleParticles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
  }

  void _initializeAnimations() {
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _heartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimating) {
      _particleController.repeat();
      _heartController.repeat();
      _sparkleController.repeat();
    }
  }

  void _generateParticles() {
    final random = math.Random();
    final screenSize = MediaQuery.of(context).size;

    // Generate floating particles
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        position: Offset(
          random.nextDouble() * screenSize.width,
          random.nextDouble() * screenSize.height,
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 0.5,
          (random.nextDouble() - 0.5) * 0.5,
        ),
        size: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.6 + 0.2,
        color: _getRandomParticleColor(),
        life: random.nextDouble() * 0.5 + 0.5,
      ));
    }

    // Generate heart particles
    for (int i = 0; i < 8; i++) {
      _heartParticles.add(HeartParticle(
        position: Offset(
          random.nextDouble() * screenSize.width,
          random.nextDouble() * screenSize.height,
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 0.3,
          (random.nextDouble() - 0.5) * 0.3,
        ),
        size: random.nextDouble() * 8 + 4,
        opacity: random.nextDouble() * 0.8 + 0.2,
        color: _getHeartColor(),
        life: random.nextDouble() * 0.8 + 0.2,
        rotation: random.nextDouble() * 2 * math.pi,
      ));
    }

    // Generate sparkle particles
    for (int i = 0; i < 20; i++) {
      _sparkleParticles.add(SparkleParticle(
        position: Offset(
          random.nextDouble() * screenSize.width,
          random.nextDouble() * screenSize.height,
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 1.0,
          (random.nextDouble() - 0.5) * 1.0,
        ),
        size: random.nextDouble() * 4 + 2,
        opacity: random.nextDouble() * 0.9 + 0.1,
        color: _getSparkleColor(),
        life: random.nextDouble() * 0.6 + 0.4,
        rotation: random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  Color _getRandomParticleColor() {
    final colors = _getThemeColors()['particles'] ??
        [
          Colors.white.withValues(alpha: 0.6),
          Colors.pink.withValues(alpha: 0.4),
          Colors.purple.withValues(alpha: 0.4),
          Colors.amber.withValues(alpha: 0.4),
        ];
    return colors[math.Random().nextInt(colors.length)];
  }

  Color _getHeartColor() {
    final themeColors = _getThemeColors();
    return themeColors['heart'] ?? Colors.pink.withValues(alpha: 0.7);
  }

  Color _getSparkleColor() {
    final themeColors = _getThemeColors();
    return themeColors['sparkle'] ?? Colors.white.withValues(alpha: 0.8);
  }

  Map<String, dynamic> _getThemeColors() {
    switch (widget.theme) {
      case 'romantic-sunset':
        return {
          'particles': [
            Colors.white.withValues(alpha: 0.6),
            const Color(0xFFFF6B9D).withValues(alpha: 0.4),
            const Color(0xFFFFB347).withValues(alpha: 0.4),
            const Color(0xFFDDA0DD).withValues(alpha: 0.4),
          ],
          'heart': const Color(0xFFFF6B9D).withValues(alpha: 0.7),
          'sparkle': Colors.white.withValues(alpha: 0.8),
        };
      case 'love-garden':
        return {
          'particles': [
            Colors.white.withValues(alpha: 0.6),
            const Color(0xFFFFB6C1).withValues(alpha: 0.4),
            const Color(0xFF9CAF88).withValues(alpha: 0.4),
            const Color(0xFF98FB98).withValues(alpha: 0.4),
          ],
          'heart': const Color(0xFFFFB6C1).withValues(alpha: 0.7),
          'sparkle': Colors.white.withValues(alpha: 0.8),
        };
      case 'midnight-romance':
        return {
          'particles': [
            Colors.white.withValues(alpha: 0.6),
            const Color(0xFF4B0082).withValues(alpha: 0.4),
            const Color(0xFFC0C0C0).withValues(alpha: 0.4),
            const Color(0xFFE8B4B8).withValues(alpha: 0.4),
          ],
          'heart': const Color(0xFFE8B4B8).withValues(alpha: 0.7),
          'sparkle': Colors.white.withValues(alpha: 0.8),
        };
      default:
        return {
          'particles': [
            Colors.white.withValues(alpha: 0.6),
            Colors.pink.withValues(alpha: 0.4),
            Colors.purple.withValues(alpha: 0.4),
            Colors.amber.withValues(alpha: 0.4),
          ],
          'heart': Colors.pink.withValues(alpha: 0.7),
          'sparkle': Colors.white.withValues(alpha: 0.8),
        };
    }
  }

  @override
  void didUpdateWidget(ParticleSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _particleController.repeat();
        _heartController.repeat();
        _sparkleController.repeat();
      } else {
        _particleController.stop();
        _heartController.stop();
        _sparkleController.stop();
      }
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _heartController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showParticles) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _particleAnimation,
        _heartAnimation,
        _sparkleAnimation,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            heartParticles: _heartParticles,
            sparkleParticles: _sparkleParticles,
            particleProgress: _particleAnimation.value,
            heartProgress: _heartAnimation.value,
            sparkleProgress: _sparkleAnimation.value,
            zoom: widget.zoom,
            pan: widget.pan,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Base particle class
class Particle {
  Offset position;
  final Offset velocity;
  final double size;
  double opacity;
  final Color color;
  final double life;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
    required this.life,
  });

  void update(double deltaTime) {
    position += velocity * deltaTime;
    opacity = (life - deltaTime).clamp(0.0, 1.0);
  }
}

/// Heart-shaped particle
class HeartParticle extends Particle {
  double rotation;
  final double rotationSpeed;

  HeartParticle({
    required super.position,
    required super.velocity,
    required super.size,
    required super.opacity,
    required super.color,
    required super.life,
    required this.rotation,
  }) : rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.02;

  @override
  void update(double deltaTime) {
    super.update(deltaTime);
    rotation += rotationSpeed * deltaTime;
  }
}

/// Sparkle particle with twinkling effect
class SparkleParticle extends Particle {
  double rotation;
  final double rotationSpeed;
  double twinklePhase;

  SparkleParticle({
    required super.position,
    required super.velocity,
    required super.size,
    required super.opacity,
    required super.color,
    required super.life,
    required this.rotation,
  })  : rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.05,
        twinklePhase = math.Random().nextDouble() * 2 * math.pi;

  @override
  void update(double deltaTime) {
    super.update(deltaTime);
    rotation += rotationSpeed * deltaTime;
    twinklePhase += deltaTime * 3.0;
  }

  double get twinkleOpacity {
    return opacity * (0.5 + 0.5 * math.sin(twinklePhase));
  }
}

/// Custom painter for rendering particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final List<HeartParticle> heartParticles;
  final List<SparkleParticle> sparkleParticles;
  final double particleProgress;
  final double heartProgress;
  final double sparkleProgress;
  final double zoom;
  final Offset pan;

  ParticlePainter({
    required this.particles,
    required this.heartParticles,
    required this.sparkleParticles,
    required this.particleProgress,
    required this.heartProgress,
    required this.sparkleProgress,
    required this.zoom,
    required this.pan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = Matrix4.identity()
      ..translate(pan.dx, pan.dy)
      ..scale(zoom);

    canvas.save();
    canvas.transform(matrix.storage);

    // Draw floating particles
    _drawFloatingParticles(canvas, size);

    // Draw heart particles
    _drawHeartParticles(canvas, size);

    // Draw sparkle particles
    _drawSparkleParticles(canvas, size);

    canvas.restore();
  }

  void _drawFloatingParticles(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );
    }
  }

  void _drawHeartParticles(Canvas canvas, Size size) {
    for (final heart in heartParticles) {
      final paint = Paint()
        ..color = heart.color.withValues(alpha: heart.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(heart.position.dx, heart.position.dy);
      canvas.rotate(heart.rotation);
      canvas.scale(heart.size / 10.0);

      _drawHeartShape(canvas, paint);
      canvas.restore();
    }
  }

  void _drawSparkleParticles(Canvas canvas, Size size) {
    for (final sparkle in sparkleParticles) {
      final paint = Paint()
        ..color = sparkle.color.withValues(alpha: sparkle.twinkleOpacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(sparkle.position.dx, sparkle.position.dy);
      canvas.rotate(sparkle.rotation);

      _drawSparkleShape(canvas, paint, sparkle.size);
      canvas.restore();
    }
  }

  void _drawHeartShape(Canvas canvas, Paint paint) {
    final path = Path();
    final size = 10.0;

    // Heart shape using cubic bezier curves
    path.moveTo(size * 0.5, size * 0.3);
    path.cubicTo(
      size * 0.1,
      size * 0.1,
      size * 0.1,
      size * 0.4,
      size * 0.5,
      size * 0.7,
    );
    path.cubicTo(
      size * 0.9,
      size * 0.4,
      size * 0.9,
      size * 0.1,
      size * 0.5,
      size * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  void _drawSparkleShape(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final halfSize = size / 2;

    // Create a 4-pointed star
    path.moveTo(0, -halfSize);
    path.lineTo(halfSize * 0.3, -halfSize * 0.3);
    path.lineTo(halfSize, 0);
    path.lineTo(halfSize * 0.3, halfSize * 0.3);
    path.lineTo(0, halfSize);
    path.lineTo(-halfSize * 0.3, halfSize * 0.3);
    path.lineTo(-halfSize, 0);
    path.lineTo(-halfSize * 0.3, -halfSize * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
