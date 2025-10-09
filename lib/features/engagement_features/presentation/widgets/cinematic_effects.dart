import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/memory_journey_entity.dart';
import '../services/theme_manager.dart';

/// Cinematic Effects System
/// Implements lens flares, bokeh depth, camera shakes, and color grading
class CinematicEffects extends StatefulWidget {
  final MemoryJourneyEntity journey;
  final double zoom;
  final Offset pan;
  final bool isAnimating;
  final bool showEffects;
  final Widget child;

  const CinematicEffects({
    Key? key,
    required this.journey,
    required this.zoom,
    required this.pan,
    required this.isAnimating,
    this.showEffects = true,
    required this.child,
  }) : super(key: key);

  @override
  State<CinematicEffects> createState() => _CinematicEffectsState();
}

class _CinematicEffectsState extends State<CinematicEffects>
    with TickerProviderStateMixin {
  late AnimationController _lensFlareController;
  late AnimationController _bokehController;
  late AnimationController _cameraShakeController;
  late AnimationController _colorGradingController;

  late Animation<double> _lensFlareAnimation;
  late Animation<double> _bokehAnimation;
  late Animation<double> _cameraShakeAnimation;
  late Animation<double> _colorGradingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Lens flare animation
    _lensFlareController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _lensFlareAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _lensFlareController,
      curve: Curves.easeInOut,
    ));

    // Bokeh animation
    _bokehController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    _bokehAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bokehController,
      curve: Curves.easeInOut,
    ));

    // Camera shake animation
    _cameraShakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cameraShakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cameraShakeController,
      curve: Curves.elasticOut,
    ));

    // Color grading animation
    _colorGradingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _colorGradingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _colorGradingController,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimating) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _lensFlareController.repeat(reverse: true);
    _bokehController.repeat(reverse: true);
    _colorGradingController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _lensFlareController.stop();
    _bokehController.stop();
    _cameraShakeController.stop();
    _colorGradingController.stop();
  }

  void triggerCameraShake() {
    _cameraShakeController.forward().then((_) {
      _cameraShakeController.reset();
    });
  }

  @override
  void didUpdateWidget(CinematicEffects oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    _lensFlareController.dispose();
    _bokehController.dispose();
    _cameraShakeController.dispose();
    _colorGradingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showEffects) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _lensFlareAnimation,
        _bokehAnimation,
        _cameraShakeAnimation,
        _colorGradingAnimation,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // Main content
            Transform.translate(
              offset: _getCameraShakeOffset(),
              child: widget.child,
            ),

            // Lens flares
            _buildLensFlares(),

            // Bokeh depth
            _buildBokehDepth(),

            // Color grading overlay
            _buildColorGradingOverlay(),
          ],
        );
      },
    );
  }

  Offset _getCameraShakeOffset() {
    if (!widget.isAnimating) return Offset.zero;

    final shakeIntensity = 2.0 * _cameraShakeAnimation.value;
    final shakeX = (math.Random().nextDouble() - 0.5) * shakeIntensity;
    final shakeY = (math.Random().nextDouble() - 0.5) * shakeIntensity;

    return Offset(shakeX, shakeY);
  }

  Widget _buildLensFlares() {
    final themeColors = ThemeManager.getThemeColors(widget.journey.theme);
    final screenSize = MediaQuery.of(context).size;

    return CustomPaint(
      painter: LensFlarePainter(
        animationValue: _lensFlareAnimation.value,
        themeColors: themeColors,
        zoom: widget.zoom,
        pan: widget.pan,
        screenSize: screenSize,
      ),
      size: screenSize,
    );
  }

  Widget _buildBokehDepth() {
    final themeColors = ThemeManager.getThemeColors(widget.journey.theme);
    final screenSize = MediaQuery.of(context).size;

    return CustomPaint(
      painter: BokehDepthPainter(
        animationValue: _bokehAnimation.value,
        themeColors: themeColors,
        zoom: widget.zoom,
        pan: widget.pan,
        screenSize: screenSize,
        showDepthOfField: widget.journey.settings.depthOfField,
      ),
      size: screenSize,
    );
  }

  Widget _buildColorGradingOverlay() {
    final themeColors = ThemeManager.getThemeColors(widget.journey.theme);
    final screenSize = MediaQuery.of(context).size;

    return CustomPaint(
      painter: ColorGradingPainter(
        animationValue: _colorGradingAnimation.value,
        themeColors: themeColors,
        theme: widget.journey.theme,
      ),
      size: screenSize,
    );
  }
}

/// Lens Flare Painter
/// Creates realistic lens flares with multiple elements
class LensFlarePainter extends CustomPainter {
  final double animationValue;
  final Map<String, Color> themeColors;
  final double zoom;
  final Offset pan;
  final Size screenSize;

  LensFlarePainter({
    required this.animationValue,
    required this.themeColors,
    required this.zoom,
    required this.pan,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final lightSource = Offset(
      center.dx + math.sin(animationValue * 2 * math.pi) * 100,
      center.dy + math.cos(animationValue * 2 * math.pi) * 80,
    );

    _drawMainFlare(canvas, lightSource);
    _drawSecondaryFlares(canvas, lightSource);
    _drawLensReflections(canvas, lightSource);
  }

  void _drawMainFlare(Canvas canvas, Offset lightSource) {
    final gradient = RadialGradient(
      colors: [
        themeColors['accent']?.withValues(alpha: 0.8) ??
            Colors.orange.withValues(alpha: 0.8),
        themeColors['primary']?.withValues(alpha: 0.4) ??
            Colors.pink.withValues(alpha: 0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: lightSource,
        radius: 60 * zoom,
      ));

    canvas.drawCircle(lightSource, 60 * zoom, paint);
  }

  void _drawSecondaryFlares(Canvas canvas, Offset lightSource) {
    final flarePositions = [
      Offset(lightSource.dx - 80, lightSource.dy - 60),
      Offset(lightSource.dx + 100, lightSource.dy + 40),
      Offset(lightSource.dx - 40, lightSource.dy + 120),
    ];

    for (int i = 0; i < flarePositions.length; i++) {
      final position = flarePositions[i];
      final intensity =
          0.3 + (math.sin(animationValue * 3 * math.pi + i) * 0.2);

      final paint = Paint()
        ..color = (themeColors['accent'] ?? Colors.orange)
            .withValues(alpha: intensity * 0.6);

      canvas.drawCircle(position, 15 * zoom, paint);
    }
  }

  void _drawLensReflections(Canvas canvas, Offset lightSource) {
    final reflectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Horizontal lens reflection
    final rect = Rect.fromCenter(
      center: lightSource,
      width: 200 * zoom,
      height: 4 * zoom,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      reflectionPaint,
    );

    // Vertical lens reflection
    final verticalRect = Rect.fromCenter(
      center: lightSource,
      width: 4 * zoom,
      height: 200 * zoom,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(verticalRect, const Radius.circular(2)),
      reflectionPaint,
    );
  }

  @override
  bool shouldRepaint(LensFlarePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        zoom != oldDelegate.zoom ||
        pan != oldDelegate.pan;
  }
}

/// Bokeh Depth Painter
/// Creates depth of field effects with bokeh circles
class BokehDepthPainter extends CustomPainter {
  final double animationValue;
  final Map<String, Color> themeColors;
  final double zoom;
  final Offset pan;
  final Size screenSize;
  final bool showDepthOfField;

  BokehDepthPainter({
    required this.animationValue,
    required this.themeColors,
    required this.zoom,
    required this.pan,
    required this.screenSize,
    required this.showDepthOfField,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!showDepthOfField) return;

    _drawBokehCircles(canvas, size);
    _drawDepthBlur(canvas, size);
  }

  void _drawBokehCircles(Canvas canvas, Size size) {
    final bokehCount = (20 * zoom).round();

    for (int i = 0; i < bokehCount; i++) {
      final x = (i * size.width / bokehCount) +
          (math.sin(animationValue * 2 * math.pi + i) * 30);
      final y = (i * size.height / bokehCount) +
          (math.cos(animationValue * 2 * math.pi + i) * 20);

      final radius = 2 + (math.sin(animationValue * 3 * math.pi + i) * 3);
      final opacity = 0.1 + (math.sin(animationValue * 4 * math.pi + i) * 0.1);

      final paint = Paint()
        ..color = (themeColors['accent'] ?? Colors.white).withValues(alpha: opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawDepthBlur(Canvas canvas, Size size) {
    final blurPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    // Top and bottom depth blur
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.1),
      blurPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.9, size.width, size.height * 0.1),
      blurPaint,
    );
  }

  @override
  bool shouldRepaint(BokehDepthPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        zoom != oldDelegate.zoom ||
        pan != oldDelegate.pan ||
        showDepthOfField != oldDelegate.showDepthOfField;
  }
}

/// Color Grading Painter
/// Applies cinematic color grading based on theme
class ColorGradingPainter extends CustomPainter {
  final double animationValue;
  final Map<String, Color> themeColors;
  final String theme;

  ColorGradingPainter({
    required this.animationValue,
    required this.themeColors,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _applyColorGrading(canvas, size);
    _applyVignette(canvas, size);
  }

  void _applyColorGrading(Canvas canvas, Size size) {
    Color overlayColor;
    double intensity;

    switch (theme) {
      case 'romantic-sunset':
        overlayColor = Colors.orange.withValues(alpha: 0.1);
        intensity = 0.3 + (math.sin(animationValue * 2 * math.pi) * 0.1);
        break;
      case 'mystical-moonlight':
        overlayColor = Colors.blue.withValues(alpha: 0.15);
        intensity = 0.4 + (math.cos(animationValue * 2 * math.pi) * 0.1);
        break;
      case 'vibrant-aurora':
        overlayColor = Colors.green.withValues(alpha: 0.12);
        intensity = 0.35 + (math.sin(animationValue * 3 * math.pi) * 0.15);
        break;
      default:
        overlayColor = Colors.transparent;
        intensity = 0.0;
    }

    final paint = Paint()..color = overlayColor.withValues(alpha: intensity);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  void _applyVignette(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.8;

    final gradient = RadialGradient(
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: 0.3),
      ],
      stops: const [0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: center,
        radius: radius,
      ));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(ColorGradingPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        theme != oldDelegate.theme;
  }
}
