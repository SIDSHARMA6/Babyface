import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Audio reactive particle model
class AudioParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double velocityX;
  final double velocityY;
  final double opacity;
  final double life;
  final ParticleType type;

  AudioParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocityX,
    required this.velocityY,
    required this.opacity,
    required this.life,
    required this.type,
  });

  AudioParticle copyWith({
    double? x,
    double? y,
    double? size,
    Color? color,
    double? velocityX,
    double? velocityY,
    double? opacity,
    double? life,
    ParticleType? type,
  }) {
    return AudioParticle(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      color: color ?? this.color,
      velocityX: velocityX ?? this.velocityX,
      velocityY: velocityY ?? this.velocityY,
      opacity: opacity ?? this.opacity,
      life: life ?? this.life,
      type: type ?? this.type,
    );
  }
}

/// Particle types
enum ParticleType {
  heart,
  star,
  circle,
  sparkle,
  wave,
}

/// Audio reactive background service
class AudioReactiveBackgroundService {
  static final AudioReactiveBackgroundService _instance =
      AudioReactiveBackgroundService._internal();
  factory AudioReactiveBackgroundService() => _instance;
  AudioReactiveBackgroundService._internal();

  final List<AudioParticle> _particles = [];
  final List<AudioParticle> _waves = [];
  Timer? _animationTimer;
  bool _isAnimating = false;
  double _audioLevel = 0.0;
  double _bassLevel = 0.0;
  final List<VoidCallback> _listeners = [];

  /// Get audio reactive background service instance
  static AudioReactiveBackgroundService get instance => _instance;

  /// Start audio reactive animation
  void startAnimation() {
    if (_isAnimating) return;

    _isAnimating = true;
    _animationTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      _updateParticles();
      _notifyListeners();
    });
  }

  /// Stop audio reactive animation
  void stopAnimation() {
    _isAnimating = false;
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  /// Update audio levels (simulated for now)
  void updateAudioLevels(double audioLevel, {double? bassLevel}) {
    _audioLevel = audioLevel.clamp(0.0, 1.0);
    _bassLevel = (bassLevel ?? _audioLevel).clamp(0.0, 1.0);

    // Create particles based on audio levels
    _createParticlesFromAudio();
  }

  /// Get current particles
  List<AudioParticle> get particles => List.unmodifiable(_particles);

  /// Get current waves
  List<AudioParticle> get waves => List.unmodifiable(_waves);

  /// Add listener for animation updates
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        developer.log(
            '❌ [AudioReactiveBackgroundService] Error notifying listener: $e');
      }
    }
  }

  /// Update particles
  void _updateParticles() {
    // Update existing particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      final particle = _particles[i];
      final newParticle = particle.copyWith(
        x: particle.x + particle.velocityX,
        y: particle.y + particle.velocityY,
        opacity: particle.opacity - 0.01,
        life: particle.life - 0.01,
        size: particle.size * 0.99,
      );

      if (newParticle.life <= 0 || newParticle.opacity <= 0) {
        _particles.removeAt(i);
      } else {
        _particles[i] = newParticle;
      }
    }

    // Update waves
    for (int i = _waves.length - 1; i >= 0; i--) {
      final wave = _waves[i];
      final newWave = wave.copyWith(
        size: wave.size + 2.0,
        opacity: wave.opacity - 0.02,
        life: wave.life - 0.02,
      );

      if (newWave.life <= 0 || newWave.opacity <= 0) {
        _waves.removeAt(i);
      } else {
        _waves[i] = newWave;
      }
    }
  }

  /// Create particles based on audio levels
  void _createParticlesFromAudio() {
    if (_audioLevel < 0.1) return;

    final random = math.Random();
    final particleCount = (_audioLevel * 10).round();

    for (int i = 0; i < particleCount; i++) {
      _createRandomParticle(random);
    }

    // Create waves for bass
    if (_bassLevel > 0.3) {
      _createWave(random);
    }
  }

  /// Create random particle
  void _createRandomParticle(math.Random random) {
    final particleType =
        ParticleType.values[random.nextInt(ParticleType.values.length)];
    final color = _getParticleColor(particleType);

    final particle = AudioParticle(
      x: random.nextDouble() * 400, // Screen width
      y: random.nextDouble() * 800, // Screen height
      size: (random.nextDouble() * 20 + 5) * _audioLevel,
      color: color,
      velocityX: (random.nextDouble() - 0.5) * 4 * _audioLevel,
      velocityY: (random.nextDouble() - 0.5) * 4 * _audioLevel,
      opacity: 0.8 * _audioLevel,
      life: 1.0,
      type: particleType,
    );

    _particles.add(particle);
  }

  /// Create wave particle
  void _createWave(math.Random random) {
    final wave = AudioParticle(
      x: random.nextDouble() * 400,
      y: random.nextDouble() * 800,
      size: 10.0,
      color: Colors.blue.withValues(alpha: 0.3),
      velocityX: 0.0,
      velocityY: 0.0,
      opacity: 0.6 * _bassLevel,
      life: 1.0,
      type: ParticleType.wave,
    );

    _waves.add(wave);
  }

  /// Get particle color based on type
  Color _getParticleColor(ParticleType type) {
    switch (type) {
      case ParticleType.heart:
        return Colors.red;
      case ParticleType.star:
        return Colors.yellow;
      case ParticleType.circle:
        return Colors.blue;
      case ParticleType.sparkle:
        return Colors.white;
      case ParticleType.wave:
        return Colors.cyan;
    }
  }

  /// Simulate audio input (for testing)
  void simulateAudioInput() {
    final random = math.Random();
    final audioLevel = random.nextDouble();
    final bassLevel = random.nextDouble() * 0.8;

    updateAudioLevels(audioLevel, bassLevel: bassLevel);
  }

  /// Clear all particles
  void clearParticles() {
    _particles.clear();
    _waves.clear();
  }

  /// Dispose service
  void dispose() {
    stopAnimation();
    _listeners.clear();
  }
}

/// Audio reactive background widget
class AudioReactiveBackgroundWidget extends StatefulWidget {
  final Widget child;
  final bool enableAudioReaction;
  final Duration animationDuration;

  const AudioReactiveBackgroundWidget({
    super.key,
    required this.child,
    this.enableAudioReaction = true,
    this.animationDuration = const Duration(seconds: 30),
  });

  @override
  State<AudioReactiveBackgroundWidget> createState() =>
      _AudioReactiveBackgroundWidgetState();
}

class _AudioReactiveBackgroundWidgetState
    extends State<AudioReactiveBackgroundWidget> with TickerProviderStateMixin {
  final AudioReactiveBackgroundService _audioService =
      AudioReactiveBackgroundService.instance;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAudioReaction();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _simulationTimer?.cancel();
    _audioService.removeListener(_onAnimationUpdate);
    super.dispose();
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _backgroundController.repeat(reverse: true);
  }

  void _startAudioReaction() {
    if (!widget.enableAudioReaction) return;

    _audioService.addListener(_onAnimationUpdate);
    _audioService.startAnimation();

    // Simulate audio input for testing
    _simulationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _audioService.simulateAudioInput();
    });
  }

  void _onAnimationUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(Colors.purple, Colors.pink,
                        _backgroundAnimation.value)!,
                    Color.lerp(
                        Colors.blue, Colors.cyan, _backgroundAnimation.value)!,
                    Color.lerp(
                        Colors.pink, Colors.red, _backgroundAnimation.value)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        ),

        // Audio reactive particles
        if (widget.enableAudioReaction)
          CustomPaint(
            painter: AudioReactivePainter(
              particles: _audioService.particles,
              waves: _audioService.waves,
            ),
            size: Size.infinite,
          ),

        // Content
        widget.child,
      ],
    );
  }
}

/// Audio reactive painter
class AudioReactivePainter extends CustomPainter {
  final List<AudioParticle> particles;
  final List<AudioParticle> waves;

  AudioReactivePainter({
    required this.particles,
    required this.waves,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw waves first (background)
    for (final wave in waves) {
      _drawWave(canvas, wave);
    }

    // Draw particles
    for (final particle in particles) {
      _drawParticle(canvas, particle);
    }
  }

  void _drawWave(Canvas canvas, AudioParticle wave) {
    final paint = Paint()
      ..color = wave.color.withValues(alpha: wave.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset(wave.x, wave.y),
      wave.size,
      paint,
    );
  }

  void _drawParticle(Canvas canvas, AudioParticle particle) {
    final paint = Paint()
      ..color = particle.color.withValues(alpha: particle.opacity);

    switch (particle.type) {
      case ParticleType.heart:
        _drawHeart(canvas, particle, paint);
        break;
      case ParticleType.star:
        _drawStar(canvas, particle, paint);
        break;
      case ParticleType.circle:
        _drawCircle(canvas, particle, paint);
        break;
      case ParticleType.sparkle:
        _drawSparkle(canvas, particle, paint);
        break;
      case ParticleType.wave:
        _drawWave(canvas, particle);
        break;
    }
  }

  void _drawHeart(Canvas canvas, AudioParticle particle, Paint paint) {
    final path = Path();
    final center = Offset(particle.x, particle.y);
    final size = particle.size;

    // Heart shape
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.5,
      center.dy - size * 0.3,
      center.dx - size * 0.5,
      center.dy + size * 0.1,
      center.dx,
      center.dy + size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.5,
      center.dy + size * 0.1,
      center.dx + size * 0.5,
      center.dy - size * 0.3,
      center.dx,
      center.dy + size * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, AudioParticle particle, Paint paint) {
    final center = Offset(particle.x, particle.y);
    final size = particle.size;
    final path = Path();

    for (int i = 0; i < 5; i++) {
      final angle = (i * 144) * math.pi / 180;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawCircle(Canvas canvas, AudioParticle particle, Paint paint) {
    canvas.drawCircle(
      Offset(particle.x, particle.y),
      particle.size,
      paint,
    );
  }

  void _drawSparkle(Canvas canvas, AudioParticle particle, Paint paint) {
    final center = Offset(particle.x, particle.y);
    final size = particle.size;

    // Draw cross sparkle
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
