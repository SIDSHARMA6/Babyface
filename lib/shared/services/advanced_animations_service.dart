import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

/// Hero transition service
class HeroTransitionService {
  static final HeroTransitionService _instance =
      HeroTransitionService._internal();
  factory HeroTransitionService() => _instance;
  HeroTransitionService._internal();

  /// Get hero transition service instance
  static HeroTransitionService get instance => _instance;

  /// Create hero transition
  Widget createHeroTransition({
    required String tag,
    required Widget child,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
    HeroPlaceholderBuilder? placeholderBuilder,
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder:
          flightShuttleBuilder ?? _defaultFlightShuttleBuilder,
      placeholderBuilder: placeholderBuilder ?? _defaultPlaceholderBuilder,
      child: child,
    );
  }

  /// Default flight shuttle builder
  Widget _defaultFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(begin: 0.8, end: 1.0)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              )
              .value,
          child: Transform.rotate(
            angle: Tween<double>(begin: 0.0, end: 0.1)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                )
                .value,
            child: child,
          ),
        );
      },
      child: flightContext.widget,
    );
  }

  /// Default placeholder builder
  Widget _defaultPlaceholderBuilder(
      BuildContext context, Size heroSize, Widget child) {
    return Container(
      width: heroSize.width,
      height: heroSize.height,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// Create page route with hero transition
  PageRouteBuilder createHeroPageRoute({
    required Widget page,
    required String heroTag,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Create scale transition
  Widget createScaleTransition({
    required Widget child,
    required Animation<double> animation,
    double beginScale = 0.8,
    double endScale = 1.0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        return Transform.scale(
          scale: Tween<double>(begin: beginScale, end: endScale)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              )
              .value,
          child: child,
        );
      },
    );
  }

  /// Create rotation transition
  Widget createRotationTransition({
    required Widget child,
    required Animation<double> animation,
    double beginAngle = 0.0,
    double endAngle = 0.1,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        return Transform.rotate(
          angle: Tween<double>(begin: beginAngle, end: endAngle)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              )
              .value,
          child: child,
        );
      },
    );
  }

  /// Create slide transition
  Widget createSlideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset beginOffset = const Offset(0.0, 1.0),
    Offset endOffset = Offset.zero,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        return SlideTransition(
          position: Tween<Offset>(begin: beginOffset, end: endOffset).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
    );
  }

  /// Create fade transition
  Widget createFadeTransition({
    required Widget child,
    required Animation<double> animation,
    double beginOpacity = 0.0,
    double endOpacity = 1.0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        return FadeTransition(
          opacity: Tween<double>(begin: beginOpacity, end: endOpacity).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
    );
  }

  /// Create combined transition
  Widget createCombinedTransition({
    required Widget child,
    required Animation<double> animation,
    bool includeScale = true,
    bool includeRotation = false,
    bool includeSlide = false,
    bool includeFade = true,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        Widget result = child;

        if (includeFade) {
          result = FadeTransition(
            opacity: animation,
            child: result,
          );
        }

        if (includeSlide) {
          result = SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: result,
          );
        }

        if (includeRotation) {
          result = Transform.rotate(
            angle: Tween<double>(begin: 0.0, end: 0.05)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                )
                .value,
            child: result,
          );
        }

        if (includeScale) {
          result = Transform.scale(
            scale: Tween<double>(begin: 0.9, end: 1.0)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                )
                .value,
            child: result,
          );
        }

        return result;
      },
    );
  }
}

/// Advanced animations service
class AdvancedAnimationsService {
  static final AdvancedAnimationsService _instance =
      AdvancedAnimationsService._internal();
  factory AdvancedAnimationsService() => _instance;
  AdvancedAnimationsService._internal();

  /// Get advanced animations service instance
  static AdvancedAnimationsService get instance => _instance;

  /// Create bounce animation
  AnimationController createBounceAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create elastic animation
  AnimationController createElasticAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create pulse animation
  AnimationController createPulseAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create shake animation
  AnimationController createShakeAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create wiggle animation
  AnimationController createWiggleAnimation({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create bounce widget
  Widget createBounceWidget({
    required Widget child,
    required Animation<double> animation,
    double maxScale = 1.2,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        final scale = 1.0 +
            (maxScale - 1.0) * Curves.elasticOut.transform(animation.value);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
    );
  }

  /// Create elastic widget
  Widget createElasticWidget({
    required Widget child,
    required Animation<double> animation,
    double maxScale = 1.3,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        final scale = 1.0 +
            (maxScale - 1.0) * Curves.elasticOut.transform(animation.value);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
    );
  }

  /// Create pulse widget
  Widget createPulseWidget({
    required Widget child,
    required Animation<double> animation,
    double minScale = 0.8,
    double maxScale = 1.2,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        final scale = minScale +
            (maxScale - minScale) * Curves.easeInOut.transform(animation.value);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
    );
  }

  /// Create shake widget
  Widget createShakeWidget({
    required Widget child,
    required Animation<double> animation,
    double intensity = 10.0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        final offset = Offset(
          intensity * Curves.elasticIn.transform(animation.value),
          0.0,
        );
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
    );
  }

  /// Create wiggle widget
  Widget createWiggleWidget({
    required Widget child,
    required Animation<double> animation,
    double intensity = 5.0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        final angle =
            intensity * Curves.elasticIn.transform(animation.value) * 0.1;
        return Transform.rotate(
          angle: angle,
          child: child,
        );
      },
    );
  }

  /// Create staggered animation
  List<AnimationController> createStaggeredAnimations({
    required TickerProvider vsync,
    int count = 3,
    Duration duration = const Duration(milliseconds: 300),
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    final controllers = <AnimationController>[];

    for (int i = 0; i < count; i++) {
      controllers.add(
        AnimationController(
          duration: duration,
          vsync: vsync,
        ),
      );
    }

    return controllers;
  }

  /// Start staggered animations
  void startStaggeredAnimations(List<AnimationController> controllers) {
    for (int i = 0; i < controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        controllers[i].forward();
      });
    }
  }

  /// Create staggered widget
  Widget createStaggeredWidget({
    required Widget child,
    required Animation<double> animation,
    int index = 0,
    double beginOffset = 50.0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        final offset = Tween<Offset>(
          begin: Offset(0.0, beginOffset),
          end: Offset.zero,
        )
            .animate(
              CurvedAnimation(
                parent: animation,
                curve: Interval(
                  index * 0.1,
                  (index * 0.1) + 0.6,
                  curve: Curves.easeOut,
                ),
              ),
            )
            .value;

        return Transform.translate(
          offset: offset,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Parallax effects service
class ParallaxEffectsService {
  static final ParallaxEffectsService _instance =
      ParallaxEffectsService._internal();
  factory ParallaxEffectsService() => _instance;
  ParallaxEffectsService._internal();

  /// Get parallax effects service instance
  static ParallaxEffectsService get instance => _instance;

  /// Create parallax widget
  Widget createParallaxWidget({
    required Widget child,
    required ScrollController scrollController,
    double parallaxFactor = 0.5,
  }) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, widget) {
        final offset = scrollController.offset * parallaxFactor;
        return Transform.translate(
          offset: Offset(0.0, offset),
          child: child,
        );
      },
    );
  }

  /// Create glassmorphism effect
  Widget createGlassmorphismWidget({
    required Widget child,
    double blur = 10.0,
    double opacity = 0.1,
    Color color = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: child,
        ),
      ),
    );
  }

  /// Create floating effect
  Widget createFloatingWidget({
    required Widget child,
    required Animation<double> animation,
    double amplitude = 10.0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        final offset = Offset(
          0.0,
          amplitude * Curves.easeInOut.transform(animation.value),
        );
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
    );
  }

  /// Create morphing effect
  Widget createMorphingWidget({
    required Widget child,
    required Animation<double> animation,
    double beginRadius = 0.0,
    double endRadius = 50.0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, widget) {
        final radius = Tween<double>(begin: beginRadius, end: endRadius)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            )
            .value;

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: child,
        );
      },
    );
  }
}

/// Soft scroll physics service
class SoftScrollPhysicsService {
  static final SoftScrollPhysicsService _instance =
      SoftScrollPhysicsService._internal();
  factory SoftScrollPhysicsService() => _instance;
  SoftScrollPhysicsService._internal();

  /// Get soft scroll physics service instance
  static SoftScrollPhysicsService get instance => _instance;

  /// Create soft scroll physics
  ScrollPhysics createSoftScrollPhysics({
    double springConstant = 100.0,
    double dampingRatio = 0.8,
  }) {
    return BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  /// Create over-scroll stretch effect
  Widget createOverScrollStretchEffect({
    required Widget child,
    required ScrollController scrollController,
    double stretchFactor = 0.1,
  }) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, widget) {
        final offset = scrollController.offset;
        final stretch = offset < 0 ? offset * stretchFactor : 0.0;

        return Transform.translate(
          offset: Offset(0.0, stretch),
          child: Transform.scale(
            scale: 1.0 + (stretch.abs() * 0.001),
            child: child,
          ),
        );
      },
    );
  }

  /// Create elastic scroll effect
  Widget createElasticScrollEffect({
    required Widget child,
    required ScrollController scrollController,
    double elasticity = 0.3,
  }) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, widget) {
        final offset = scrollController.offset;
        final elasticOffset = offset * elasticity;

        return Transform.translate(
          offset: Offset(0.0, elasticOffset),
          child: child,
        );
      },
    );
  }
}
