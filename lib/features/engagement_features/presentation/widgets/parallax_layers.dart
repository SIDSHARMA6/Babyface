import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/theme_manager.dart';

/// Parallax Layers for 3D Depth Effect
/// Implements 5 layers with different parallax speeds for immersive 3D feel
class ParallaxLayers extends StatefulWidget {
  final String theme;
  final double zoom;
  final Offset pan;
  final bool isAnimating;
  final Widget child;

  const ParallaxLayers({
    Key? key,
    required this.theme,
    this.zoom = 1.0,
    this.pan = Offset.zero,
    this.isAnimating = true,
    required this.child,
  }) : super(key: key);

  @override
  State<ParallaxLayers> createState() => _ParallaxLayersState();
}

class _ParallaxLayersState extends State<ParallaxLayers>
    with TickerProviderStateMixin {
  late AnimationController _parallaxController;
  late Animation<double> _parallaxAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _parallaxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.linear,
    ));

    if (widget.isAnimating) {
      _parallaxController.repeat();
    }
  }

  @override
  void didUpdateWidget(ParallaxLayers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _parallaxController.repeat();
      } else {
        _parallaxController.stop();
      }
    }
  }

  @override
  void dispose() {
    _parallaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = ThemeManager.getThemeColors(widget.theme);
    final themeGradients = ThemeManager.getThemeGradients(widget.theme);

    return AnimatedBuilder(
      animation: _parallaxAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Layer 5: Sky (furthest back, slowest movement)
            _buildSkyLayer(themeGradients['background']!),

            // Layer 4: Distant atmospheric effects
            _buildAtmosphericLayer(themeColors),

            // Layer 3: Background particles and effects
            _buildBackgroundEffectsLayer(themeColors),

            // Layer 2: Road surface and secondary elements
            _buildRoadLayer(themeColors),

            // Layer 1: Foreground elements (highest motion)
            _buildForegroundLayer(themeColors),

            // Main content (child)
            widget.child,
          ],
        );
      },
    );
  }

  /// Layer 5: Sky gradient background
  Widget _buildSkyLayer(LinearGradient gradient) {
    final parallaxOffset = _calculateParallaxOffset(0.1); // Slowest movement

    return Positioned.fill(
      child: Transform.translate(
        offset: parallaxOffset,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
          ),
        ),
      ),
    );
  }

  /// Layer 4: Atmospheric effects (clouds, mist, etc.)
  Widget _buildAtmosphericLayer(Map<String, Color> themeColors) {
    final parallaxOffset = _calculateParallaxOffset(0.2);

    return Positioned.fill(
      child: Transform.translate(
        offset: parallaxOffset,
        child: CustomPaint(
          painter: AtmosphericPainter(
            themeColors: themeColors,
            animationValue: _parallaxAnimation.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  /// Layer 3: Background particles and effects
  Widget _buildBackgroundEffectsLayer(Map<String, Color> themeColors) {
    final parallaxOffset = _calculateParallaxOffset(0.4);

    return Positioned.fill(
      child: Transform.translate(
        offset: parallaxOffset,
        child: CustomPaint(
          painter: BackgroundEffectsPainter(
            themeColors: themeColors,
            animationValue: _parallaxAnimation.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  /// Layer 2: Road surface and secondary elements
  Widget _buildRoadLayer(Map<String, Color> themeColors) {
    final parallaxOffset = _calculateParallaxOffset(0.6);

    return Positioned.fill(
      child: Transform.translate(
        offset: parallaxOffset,
        child: CustomPaint(
          painter: RoadLayerPainter(
            themeColors: themeColors,
            animationValue: _parallaxAnimation.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  /// Layer 1: Foreground elements (highest motion)
  Widget _buildForegroundLayer(Map<String, Color> themeColors) {
    final parallaxOffset = _calculateParallaxOffset(0.8);

    return Positioned.fill(
      child: Transform.translate(
        offset: parallaxOffset,
        child: CustomPaint(
          painter: ForegroundLayerPainter(
            themeColors: themeColors,
            animationValue: _parallaxAnimation.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  /// Calculate parallax offset based on layer speed and pan/zoom
  Offset _calculateParallaxOffset(double layerSpeed) {
    final baseOffset = widget.pan * layerSpeed;
    final animationOffset = Offset(
      math.sin(_parallaxAnimation.value * 2 * math.pi) * 10 * layerSpeed,
      math.cos(_parallaxAnimation.value * 2 * math.pi) * 5 * layerSpeed,
    );
    return baseOffset + animationOffset;
  }
}

/// Atmospheric effects painter (Layer 4)
class AtmosphericPainter extends CustomPainter {
  final Map<String, Color> themeColors;
  final double animationValue;

  AtmosphericPainter({
    required this.themeColors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    // Draw floating clouds
    _drawClouds(canvas, size, paint);

    // Draw mist effects
    _drawMist(canvas, size, paint);
  }

  void _drawClouds(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42); // Fixed seed for consistent clouds
    final cloudColor =
        themeColors['text']?.withValues(alpha: 0.1) ?? Colors.white.withValues(alpha: 0.1);

    paint.color = cloudColor;

    for (int i = 0; i < 5; i++) {
      final x = (random.nextDouble() * size.width) +
          (math.sin(animationValue * 2 * math.pi + i) * 50);
      final y = (random.nextDouble() * size.height * 0.3) +
          (math.cos(animationValue * 2 * math.pi + i) * 20);
      final radius = 30 + (random.nextDouble() * 40);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawMist(Canvas canvas, Size size, Paint paint) {
    final mistColor = themeColors['text']?.withValues(alpha: 0.05) ??
        Colors.white.withValues(alpha: 0.05);

    paint.color = mistColor;

    for (int i = 0; i < 3; i++) {
      final x = (i * size.width / 3) +
          (math.sin(animationValue * 2 * math.pi + i) * 100);
      final y =
          size.height * 0.7 + (math.cos(animationValue * 2 * math.pi + i) * 30);

      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: 200,
        height: 100,
      );

      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Background effects painter (Layer 3)
class BackgroundEffectsPainter extends CustomPainter {
  final Map<String, Color> themeColors;
  final double animationValue;

  BackgroundEffectsPainter({
    required this.themeColors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw distant light orbs
    _drawLightOrbs(canvas, size, paint);

    // Draw subtle sparkles
    _drawSparkles(canvas, size, paint);
  }

  void _drawLightOrbs(Canvas canvas, Size size, Paint paint) {
    final orbColor = themeColors['particle']?.withValues(alpha: 0.3) ??
        Colors.white.withValues(alpha: 0.3);

    paint.color = orbColor;

    for (int i = 0; i < 8; i++) {
      final x = (i * size.width / 8) +
          (math.sin(animationValue * 2 * math.pi + i) * 30);
      final y = (i * size.height / 8) +
          (math.cos(animationValue * 2 * math.pi + i) * 20);
      final radius = 5 + (math.sin(animationValue * 2 * math.pi + i) * 3);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawSparkles(Canvas canvas, Size size, Paint paint) {
    final sparkleColor = themeColors['sparkle']?.withValues(alpha: 0.4) ??
        Colors.white.withValues(alpha: 0.4);

    paint.color = sparkleColor;

    for (int i = 0; i < 15; i++) {
      final x = (i * size.width / 15) +
          (math.sin(animationValue * 3 * math.pi + i) * 20);
      final y = (i * size.height / 15) +
          (math.cos(animationValue * 3 * math.pi + i) * 15);
      final particleSize =
          1 + (math.sin(animationValue * 4 * math.pi + i) * 0.5);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Road layer painter (Layer 2)
class RoadLayerPainter extends CustomPainter {
  final Map<String, Color> themeColors;
  final double animationValue;

  RoadLayerPainter({
    required this.themeColors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw road surface texture
    _drawRoadTexture(canvas, size, paint);

    // Draw road markings
    _drawRoadMarkings(canvas, size, paint);
  }

  void _drawRoadTexture(Canvas canvas, Size size, Paint paint) {
    final roadColor =
        themeColors['road']?.withValues(alpha: 0.1) ?? Colors.grey.withValues(alpha: 0.1);

    paint.color = roadColor;

    // Draw subtle road texture lines
    for (int i = 0; i < 20; i++) {
      final y = (i * size.height / 20) +
          (math.sin(animationValue * 2 * math.pi + i) * 2);

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint..strokeWidth = 0.5,
      );
    }
  }

  void _drawRoadMarkings(Canvas canvas, Size size, Paint paint) {
    final markingColor = themeColors['roadHighlight']?.withValues(alpha: 0.2) ??
        Colors.yellow.withValues(alpha: 0.2);

    paint.color = markingColor;

    // Draw center line markings
    for (int i = 0; i < 10; i++) {
      final x = (i * size.width / 10) +
          (math.sin(animationValue * 2 * math.pi + i) * 5);
      final y =
          size.height * 0.5 + (math.cos(animationValue * 2 * math.pi + i) * 3);

      canvas.drawLine(
        Offset(x, y - 10),
        Offset(x, y + 10),
        paint..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Foreground layer painter (Layer 1)
class ForegroundLayerPainter extends CustomPainter {
  final Map<String, Color> themeColors;
  final double animationValue;

  ForegroundLayerPainter({
    required this.themeColors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw foreground particles
    _drawForegroundParticles(canvas, size, paint);

    // Draw depth of field effects
    _drawDepthOfField(canvas, size, paint);
  }

  void _drawForegroundParticles(Canvas canvas, Size size, Paint paint) {
    final particleColor = themeColors['particle']?.withValues(alpha: 0.6) ??
        Colors.white.withValues(alpha: 0.6);

    paint.color = particleColor;

    for (int i = 0; i < 10; i++) {
      final x = (i * size.width / 10) +
          (math.sin(animationValue * 4 * math.pi + i) * 15);
      final y = (i * size.height / 10) +
          (math.cos(animationValue * 4 * math.pi + i) * 10);
      final radius = 2 + (math.sin(animationValue * 6 * math.pi + i) * 1);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawDepthOfField(Canvas canvas, Size size, Paint paint) {
    final dofColor = themeColors['shadow']?.withValues(alpha: 0.1) ??
        Colors.black.withValues(alpha: 0.1);

    paint.color = dofColor;

    // Draw subtle vignette effect
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.8;

    final gradient = RadialGradient(
      colors: [
        Colors.transparent,
        dofColor,
      ],
      stops: const [0.7, 1.0],
    );

    paint.shader = gradient.createShader(Rect.fromCircle(
      center: center,
      radius: radius,
    ));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
