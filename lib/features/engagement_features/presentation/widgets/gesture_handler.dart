import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;

/// Advanced Gesture Handler for Memory Journey Visualizer
/// Implements swipe, rotate, multi-touch, and map-style navigation
class GestureHandler extends StatefulWidget {
  final Widget child;
  final Function(double) onZoom;
  final Function(Offset) onPan;
  final Function(double) onRotate;
  final Function() onDoubleTap;
  final Function() onTwoFingerTap;
  final Function(Offset) onSwipeLeft;
  final Function(Offset) onSwipeRight;
  final Function(Offset) onSwipeUp;
  final Function(Offset) onSwipeDown;
  final Function() onThreeFingerTap;
  final Function(double, double) onPinchRotate;
  final Function()? onLongPress;
  final Function()? onTwoFingerRotate;
  final double minZoom;
  final double maxZoom;
  final bool enableGestures;

  const GestureHandler({
    Key? key,
    required this.child,
    required this.onZoom,
    required this.onPan,
    required this.onRotate,
    required this.onDoubleTap,
    required this.onTwoFingerTap,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
    required this.onSwipeDown,
    required this.onThreeFingerTap,
    required this.onPinchRotate,
    this.onLongPress,
    this.onTwoFingerRotate,
    this.minZoom = 0.5,
    this.maxZoom = 4.0,
    this.enableGestures = true,
  }) : super(key: key);

  @override
  State<GestureHandler> createState() => _GestureHandlerState();
}

class _GestureHandlerState extends State<GestureHandler> {
  final TransformationController _transformationController =
      TransformationController();

  // Gesture tracking
  Offset? _lastPanPosition;
  double _lastScale = 1.0;
  double _lastRotation = 0.0;
  int _pointerCount = 0;

  // Swipe detection
  Offset? _swipeStartPosition;
  DateTime? _swipeStartTime;
  static const double _swipeThreshold = 50.0;
  static const Duration _swipeMaxDuration = Duration(milliseconds: 300);

  // Rotation tracking
  double _lastRotationAngle = 0.0;
  Offset? _rotationCenter;

  // Momentum scrolling
  Offset _velocity = Offset.zero;
  DateTime? _lastPanTime;
  Offset? _lastPanDelta;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final matrix = _transformationController.value;
    final scale = _getScaleFromMatrix(matrix);
    final translation = _getTranslationFromMatrix(matrix);
    final rotation = _getRotationFromMatrix(matrix);

    widget.onZoom(scale);
    widget.onPan(translation);
    widget.onRotate(rotation);
  }

  double _getScaleFromMatrix(Matrix4 matrix) {
    final scaleX = math.sqrt(matrix.getColumn(0).length2);
    return scaleX.clamp(widget.minZoom, widget.maxZoom);
  }

  Offset _getTranslationFromMatrix(Matrix4 matrix) {
    return Offset(matrix.getTranslation().x, matrix.getTranslation().y);
  }

  double _getRotationFromMatrix(Matrix4 matrix) {
    return math.atan2(matrix.getColumn(0).y, matrix.getColumn(0).x);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableGestures) {
      return widget.child;
    }

    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      onTap: () => _onTap(TapDownDetails(
          globalPosition: Offset.zero, localPosition: Offset.zero)),
      onDoubleTap: () => _onDoubleTap(TapDownDetails(
          globalPosition: Offset.zero, localPosition: Offset.zero)),
      onLongPress: _onLongPress,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanDown: _onPanDown,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: widget.minZoom,
        maxScale: widget.maxZoom,
        onInteractionStart: _onInteractionStart,
        onInteractionUpdate: _onInteractionUpdate,
        onInteractionEnd: _onInteractionEnd,
        child: widget.child,
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _lastPanPosition = details.localFocalPoint;
    _lastScale = _getScaleFromMatrix(_transformationController.value);
    _lastRotation = _getRotationFromMatrix(_transformationController.value);
    _pointerCount = details.pointerCount;
    _rotationCenter = details.localFocalPoint;
    _lastRotationAngle = 0.0;

    // Haptic feedback for gesture start
    HapticFeedback.lightImpact();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_pointerCount == 1) {
      // Single finger - pan only
      _handlePan(details);
    } else if (_pointerCount == 2) {
      // Two fingers - scale and rotate
      _handleScaleAndRotate(details);
    } else if (_pointerCount == 3) {
      // Three fingers - special gesture
      _handleThreeFingerGesture(details);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _handleMomentumScrolling(details.velocity);
    _pointerCount = 0;
    _lastPanPosition = null;
    _rotationCenter = null;
  }

  void _handlePan(ScaleUpdateDetails details) {
    if (_lastPanPosition == null) return;

    final delta = details.localFocalPoint - _lastPanPosition!;
    _lastPanPosition = details.localFocalPoint;

    // Update transformation
    final matrix = _transformationController.value.clone();
    matrix.translate(delta.dx, delta.dy);
    _transformationController.value = matrix;

    // Track for momentum
    _lastPanDelta = delta;
    _lastPanTime = DateTime.now();
  }

  void _handleScaleAndRotate(ScaleUpdateDetails details) {
    final scale = details.scale;
    final rotation = details.rotation;

    // Apply scale
    final currentScale = _getScaleFromMatrix(_transformationController.value);
    final newScale =
        (currentScale * scale).clamp(widget.minZoom, widget.maxZoom);
    final scaleFactor = newScale / currentScale;

    // Apply rotation
    final currentRotation =
        _getRotationFromMatrix(_transformationController.value);
    final newRotation = currentRotation + rotation;

    // Update transformation
    final matrix = _transformationController.value.clone();

    if (_rotationCenter != null) {
      // Scale around the rotation center
      matrix.translate(_rotationCenter!.dx, _rotationCenter!.dy);
      matrix.scale(scaleFactor);
      matrix.rotateZ(rotation);
      matrix.translate(-_rotationCenter!.dx, -_rotationCenter!.dy);
    } else {
      matrix.scale(scaleFactor);
      matrix.rotateZ(rotation);
    }

    _transformationController.value = matrix;

    // Call callbacks
    widget.onZoom(newScale);
    widget.onRotate(newRotation);

    // Haptic feedback for scale/rotate
    if (scaleFactor > 1.1 || scaleFactor < 0.9) {
      HapticFeedback.selectionClick();
    }
  }

  void _handleThreeFingerGesture(ScaleUpdateDetails details) {
    // Three finger gesture - could be used for special actions
    // For now, we'll just provide haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _handleMomentumScrolling(Velocity velocity) {
    final velocityOffset =
        Offset(velocity.pixelsPerSecond.dx, velocity.pixelsPerSecond.dy);
    if (velocityOffset.distance < 100) return; // Too slow for momentum

    _velocity = velocityOffset;
    _applyMomentum();
  }

  void _applyMomentum() {
    if (_velocity.distance < 10) return; // Stop when velocity is too low

    final matrix = _transformationController.value.clone();
    matrix.translate(_velocity.dx * 0.1, _velocity.dy * 0.1);
    _transformationController.value = matrix;

    // Decay velocity
    _velocity *= 0.95;

    // Continue momentum if still moving
    if (_velocity.distance > 10) {
      Future.delayed(const Duration(milliseconds: 16), _applyMomentum);
    }
  }

  void _onTap(TapDownDetails details) {
    // Single tap - could be used for memory selection
    HapticFeedback.lightImpact();
  }

  void _onDoubleTap(TapDownDetails details) {
    // Double tap - zoom in on tapped area
    widget.onDoubleTap();
    HapticFeedback.mediumImpact();

    // Zoom to tapped position
    final matrix = _transformationController.value.clone();
    final scale = _getScaleFromMatrix(matrix) * 1.5;
    final clampedScale = scale.clamp(widget.minZoom, widget.maxZoom);

    if (clampedScale != _getScaleFromMatrix(matrix)) {
      matrix.scale(clampedScale / _getScaleFromMatrix(matrix));
      _transformationController.value = matrix;
    }
  }

  void _onLongPress() {
    // Long press - could be used for context menu
    HapticFeedback.heavyImpact();
    widget.onLongPress?.call();
  }

  void _onPanStart(DragStartDetails details) {
    _swipeStartPosition = details.localPosition;
    _swipeStartTime = DateTime.now();
    _lastPanPosition = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_lastPanPosition == null) return;

    final delta = details.localPosition - _lastPanPosition!;
    _lastPanPosition = details.localPosition;

    // Update transformation for pan
    final matrix = _transformationController.value.clone();
    matrix.translate(delta.dx, delta.dy);
    _transformationController.value = matrix;
  }

  void _onPanEnd(DragEndDetails details) {
    _handleSwipeDetection();
    _handleMomentumScrolling(details.velocity);
  }

  void _onPanDown(DragDownDetails details) {
    _swipeStartPosition = details.localPosition;
    _swipeStartTime = DateTime.now();
  }

  void _handleSwipeDetection() {
    if (_swipeStartPosition == null || _swipeStartTime == null) return;

    final currentPosition = _lastPanPosition ?? _swipeStartPosition!;
    final delta = currentPosition - _swipeStartPosition!;
    final duration = DateTime.now().difference(_swipeStartTime!);

    if (duration > _swipeMaxDuration) return;

    final distance = delta.distance;
    if (distance < _swipeThreshold) return;

    // Determine swipe direction
    final angle = math.atan2(delta.dy, delta.dx) * 180 / math.pi;

    if (angle >= -45 && angle < 45) {
      // Right swipe
      widget.onSwipeRight(delta);
    } else if (angle >= 45 && angle < 135) {
      // Down swipe
      widget.onSwipeDown(delta);
    } else if (angle >= 135 || angle < -135) {
      // Left swipe
      widget.onSwipeLeft(delta);
    } else if (angle >= -135 && angle < -45) {
      // Up swipe
      widget.onSwipeUp(delta);
    }

    // Haptic feedback for swipe
    HapticFeedback.lightImpact();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    _onScaleStart(details);
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    _onScaleUpdate(details);
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    _onScaleEnd(details);
  }

  // Public methods for programmatic control
  void zoomTo(double scale) {
    final clampedScale = scale.clamp(widget.minZoom, widget.maxZoom);
    final matrix = _transformationController.value.clone();
    final currentScale = _getScaleFromMatrix(matrix);
    final scaleFactor = clampedScale / currentScale;

    matrix.scale(scaleFactor);
    _transformationController.value = matrix;
  }

  void panTo(Offset offset) {
    final matrix = _transformationController.value.clone();
    matrix.setTranslation(Vector3(offset.dx, offset.dy, 0.0));
    _transformationController.value = matrix;
  }

  void rotateTo(double angle) {
    final matrix = _transformationController.value.clone();
    final currentRotation = _getRotationFromMatrix(matrix);
    matrix.rotateZ(angle - currentRotation);
    _transformationController.value = matrix;
  }

  void reset() {
    _transformationController.value = Matrix4.identity();
  }

  void zoomToFit(Size contentSize, Size viewportSize) {
    final scaleX = viewportSize.width / contentSize.width;
    final scaleY = viewportSize.height / contentSize.height;
    final scale = math.min(scaleX, scaleY) * 0.9; // 90% to leave some margin

    zoomTo(scale);
    panTo(Offset.zero);
  }
}
