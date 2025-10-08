import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';

/// Animated Background Widget
/// Follows memory_journey.md specification for romantic pastel gradients
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showFloatingHearts;
  final bool showMagicWords;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Duration animationDuration;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showFloatingHearts = true,
    this.showMagicWords = true,
    this.primaryColor,
    this.secondaryColor,
    this.animationDuration = const Duration(seconds: 8),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _heartsController;
  late AnimationController _wordsController;
  late AnimationController _pulseController;

  late Animation<double> _gradientAnimation;
  late Animation<double> _heartsAnimation;
  late Animation<double> _wordsAnimation;
  late Animation<double> _pulseAnimation;

  final List<FloatingHeartData> _floatingHearts = [];
  final List<MagicWordData> _magicWords = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateFloatingElements();
  }

  void _setupAnimations() {
    // Gradient animation
    _gradientController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    // Floating hearts animation
    _heartsController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _heartsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartsController,
      curve: Curves.easeInOut,
    ));

    // Magic words animation
    _wordsController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _wordsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _wordsController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for romantic effect
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _gradientController.repeat(reverse: true);
    _heartsController.repeat();
    _wordsController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  void _generateFloatingElements() {
    final random = math.Random();
    
    // Generate floating hearts
    for (int i = 0; i < 8; i++) {
      _floatingHearts.add(FloatingHeartData(
        id: i,
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        endX: random.nextDouble(),
        endY: random.nextDouble() * 0.5, // Hearts float upward
        size: 12.0 + random.nextDouble() * 8.0,
        color: _getRandomHeartColor(),
        delay: Duration(milliseconds: random.nextInt(3000)),
      ));
    }

    // Generate magic words
    final words = ['Forever', 'Love', 'Together', 'Always', 'Dreams', 'Happiness'];
    for (int i = 0; i < 6; i++) {
      _magicWords.add(MagicWordData(
        id: i,
        text: words[i],
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        endX: random.nextDouble(),
        endY: random.nextDouble(),
        size: 16.0 + random.nextDouble() * 8.0,
        color: _getRandomWordColor(),
        delay: Duration(milliseconds: random.nextInt(4000)),
      ));
    }
  }

  Color _getRandomHeartColor() {
    final colors = [
      AppTheme.primaryPink,
      AppTheme.primaryBlue,
      AppTheme.accentYellow,
      Colors.pink.shade300,
      Colors.purple.shade300,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  Color _getRandomWordColor() {
    final colors = [
      AppTheme.primaryPink.withValues(alpha: 0.7),
      AppTheme.primaryBlue.withValues(alpha: 0.7),
      AppTheme.accentYellow.withValues(alpha: 0.7),
      Colors.white.withValues(alpha: 0.8),
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _heartsController.dispose();
    _wordsController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _gradientAnimation,
        _heartsAnimation,
        _wordsAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: _createAnimatedGradient(),
            ),
            child: Stack(
              children: [
                if (widget.showFloatingHearts)
                  ..._buildFloatingHearts(),
                if (widget.showMagicWords)
                  ..._buildMagicWords(),
                widget.child,
              ],
            ),
          ),
        );
      },
    );
  }

  LinearGradient _createAnimatedGradient() {
    final primaryColor = widget.primaryColor ?? AppTheme.primaryPink;
    final secondaryColor = widget.secondaryColor ?? AppTheme.primaryBlue;
    
    final animationValue = _gradientAnimation.value;
    
    return LinearGradient(
      colors: [
        Color.lerp(
          primaryColor.withValues(alpha: 0.3),
          secondaryColor.withValues(alpha: 0.2),
          animationValue,
        )!,
        Color.lerp(
          secondaryColor.withValues(alpha: 0.2),
          primaryColor.withValues(alpha: 0.3),
          animationValue,
        )!,
        Color.lerp(
          AppTheme.accentYellow.withValues(alpha: 0.1),
          primaryColor.withValues(alpha: 0.2),
          animationValue,
        )!,
        Color.lerp(
          primaryColor.withValues(alpha: 0.2),
          AppTheme.accentYellow.withValues(alpha: 0.1),
          animationValue,
        )!,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  List<Widget> _buildFloatingHearts() {
    return _floatingHearts.map((heart) {
      return _FloatingHeart(
        data: heart,
        animation: _heartsAnimation,
      );
    }).toList();
  }

  List<Widget> _buildMagicWords() {
    return _magicWords.map((word) {
      return _MagicWord(
        data: word,
        animation: _wordsAnimation,
      );
    }).toList();
  }
}

/// Floating Heart Data
class FloatingHeartData {
  final int id;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final Color color;
  final Duration delay;

  FloatingHeartData({
    required this.id,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.color,
    required this.delay,
  });
}

/// Magic Word Data
class MagicWordData {
  final int id;
  final String text;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final Color color;
  final Duration delay;

  MagicWordData({
    required this.id,
    required this.text,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.color,
    required this.delay,
  });
}

/// Floating Heart Widget
class _FloatingHeart extends StatefulWidget {
  final FloatingHeartData data;
  final Animation<double> animation;

  const _FloatingHeart({
    required this.data,
    required this.animation,
  });

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart>
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
      duration: const Duration(seconds: 4),
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
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _positionAnimation = Tween<Offset>(
      begin: Offset(widget.data.startX, widget.data.startY),
      end: Offset(widget.data.endX, widget.data.endY),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation with delay
    Future.delayed(widget.data.delay, () {
      if (mounted) {
        _controller.forward();
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
          left: position.dx - widget.data.size / 2,
          top: position.dy - widget.data.size / 2,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                Icons.favorite,
                color: widget.data.color,
                size: widget.data.size,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Magic Word Widget
class _MagicWord extends StatefulWidget {
  final MagicWordData data;
  final Animation<double> animation;

  const _MagicWord({
    required this.data,
    required this.animation,
  });

  @override
  State<_MagicWord> createState() => _MagicWordState();
}

class _MagicWordState extends State<_MagicWord>
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
      duration: const Duration(seconds: 6),
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
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _positionAnimation = Tween<Offset>(
      begin: Offset(widget.data.startX, widget.data.startY),
      end: Offset(widget.data.endX, widget.data.endY),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation with delay
    Future.delayed(widget.data.delay, () {
      if (mounted) {
        _controller.forward();
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
          left: position.dx,
          top: position.dy,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Text(
                widget.data.text,
                style: TextStyle(
                  fontSize: widget.data.size,
                  color: widget.data.color,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  shadows: [
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Seasonal Theme Background
class SeasonalBackground extends StatefulWidget {
  final Widget child;
  final DateTime? date;

  const SeasonalBackground({
    super.key,
    required this.child,
    this.date,
  });

  @override
  State<SeasonalBackground> createState() => _SeasonalBackgroundState();
}

class _SeasonalBackgroundState extends State<SeasonalBackground> {
  late Color _primaryColor;
  late Color _secondaryColor;

  @override
  void initState() {
    super.initState();
    _updateSeasonalColors();
  }

  void _updateSeasonalColors() {
    final date = widget.date ?? DateTime.now();
    final month = date.month;

    if (month >= 3 && month <= 5) {
      // Spring
      _primaryColor = Colors.pink.shade300;
      _secondaryColor = Colors.green.shade300;
    } else if (month >= 6 && month <= 8) {
      // Summer
      _primaryColor = Colors.orange.shade300;
      _secondaryColor = Colors.yellow.shade300;
    } else if (month >= 9 && month <= 11) {
      // Autumn
      _primaryColor = Colors.orange.shade400;
      _secondaryColor = Colors.brown.shade300;
    } else {
      // Winter
      _primaryColor = Colors.blue.shade300;
      _secondaryColor = Colors.purple.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      primaryColor: _primaryColor,
      secondaryColor: _secondaryColor,
      child: widget.child,
    );
  }
}
