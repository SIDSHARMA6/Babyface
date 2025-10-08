import 'package:flutter/material.dart';

class HeartbeatWidget extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const HeartbeatWidget({
    super.key,
    required this.child,
    this.isActive = true,
    this.duration = const Duration(milliseconds: 800),
    this.minScale = 1.0,
    this.maxScale = 1.2,
  });

  @override
  State<HeartbeatWidget> createState() => _HeartbeatWidgetState();
}

class _HeartbeatWidgetState extends State<HeartbeatWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.minScale, end: widget.maxScale),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.maxScale, end: widget.minScale),
        weight: 20,
      ),
      TweenSequenceItem(
        tween:
            Tween<double>(begin: widget.minScale, end: widget.maxScale * 0.9),
        weight: 20,
      ),
      TweenSequenceItem(
        tween:
            Tween<double>(begin: widget.maxScale * 0.9, end: widget.minScale),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _startHeartbeat();
    }
  }

  @override
  void didUpdateWidget(HeartbeatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startHeartbeat();
      } else {
        _stopHeartbeat();
      }
    }
  }

  void _startHeartbeat() {
    _controller.repeat();
  }

  void _stopHeartbeat() {
    _controller.stop();
    _controller.reset();
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

class HeartbeatIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;
  final bool isActive;

  const HeartbeatIcon({
    super.key,
    required this.icon,
    this.color,
    this.size,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return HeartbeatWidget(
      isActive: isActive,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}

class HeartbeatButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isActive;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const HeartbeatButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isActive = true,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return HeartbeatWidget(
      isActive: isActive && onPressed != null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
        ),
        child: child,
      ),
    );
  }
}
