import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/typography_manager.dart';

/// Enhanced Map Controls for Memory Journey Visualizer
/// Implements 2D/3D toggle, compass reset, center on journey, and zoom controls
class EnhancedMapControls extends StatefulWidget {
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final bool is3DView;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetToOverview;
  final VoidCallback onCenterOnJourney;
  final VoidCallback onToggle2D3D;
  final VoidCallback onCompassReset;
  final String theme;

  const EnhancedMapControls({
    Key? key,
    required this.currentZoom,
    required this.minZoom,
    required this.maxZoom,
    required this.is3DView,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetToOverview,
    required this.onCenterOnJourney,
    required this.onToggle2D3D,
    required this.onCompassReset,
    required this.theme,
  }) : super(key: key);

  @override
  State<EnhancedMapControls> createState() => _EnhancedMapControlsState();
}

class _EnhancedMapControlsState extends State<EnhancedMapControls>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 120,
      child: Column(
        children: [
          // Zoom In Button
          _buildControlButton(
            icon: Icons.add,
            onPressed:
                widget.currentZoom >= widget.maxZoom ? null : widget.onZoomIn,
            isEnabled: widget.currentZoom < widget.maxZoom,
            tooltip: 'Zoom In',
          ),

          const SizedBox(height: 8),

          // Zoom Level Indicator
          _buildZoomIndicator(),

          const SizedBox(height: 8),

          // Zoom Out Button
          _buildControlButton(
            icon: Icons.remove,
            onPressed:
                widget.currentZoom <= widget.minZoom ? null : widget.onZoomOut,
            isEnabled: widget.currentZoom > widget.minZoom,
            tooltip: 'Zoom Out',
          ),

          const SizedBox(height: 16),

          // Reset to Overview Button (Compass)
          _buildControlButton(
            icon: Icons.explore,
            onPressed: widget.onResetToOverview,
            isEnabled: true,
            tooltip: 'Reset to Overview',
            isSpecial: true,
          ),

          const SizedBox(height: 8),

          // Center on Journey Button (Target)
          _buildControlButton(
            icon: Icons.my_location,
            onPressed: widget.onCenterOnJourney,
            isEnabled: true,
            tooltip: 'Center on Journey',
          ),

          const SizedBox(height: 16),

          // 2D/3D Toggle Button
          _buildControlButton(
            icon: widget.is3DView ? Icons.view_in_ar : Icons.view_quilt,
            onPressed: widget.onToggle2D3D,
            isEnabled: true,
            tooltip: widget.is3DView ? 'Switch to 2D' : 'Switch to 3D',
            isSpecial: true,
          ),

          const SizedBox(height: 8),

          // Compass Reset Button (North)
          _buildControlButton(
            icon: Icons.navigation,
            onPressed: widget.onCompassReset,
            isEnabled: true,
            tooltip: 'Reset to North',
            isSpecial: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
    required String tooltip,
    bool isSpecial = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: AnimatedBuilder(
        animation:
            isSpecial ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: isSpecial ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSpecial
                    ? _getSpecialButtonColor()
                    : _getButtonColor(isEnabled),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  if (isSpecial)
                    BoxShadow(
                      color: _getAccentColor().withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 0),
                    ),
                ],
                border: isSpecial
                    ? Border.all(
                        color: _getAccentColor().withValues(alpha: 0.5),
                        width: 2,
                      )
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: isEnabled
                      ? () {
                          HapticFeedback.lightImpact();
                          onPressed?.call();
                        }
                      : null,
                  child: Icon(
                    icon,
                    color:
                        isEnabled ? _getIconColor() : _getDisabledIconColor(),
                    size: 24,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildZoomIndicator() {
    final zoomPercentage = ((widget.currentZoom - widget.minZoom) /
            (widget.maxZoom - widget.minZoom) *
            100)
        .round();

    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: _getButtonColor(true),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${zoomPercentage}%',
          style: TypographyManager.uiLabel(
            fontSize: 10,
            color: _getIconColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getButtonColor(bool isEnabled) {
    if (!isEnabled) {
      return Colors.grey.withValues(alpha: 0.3);
    }

    switch (widget.theme) {
      case 'romantic-sunset':
        return Colors.white.withValues(alpha: 0.9);
      case 'love-garden':
        return const Color(0xFFF8F8F8).withValues(alpha: 0.9);
      case 'midnight-romance':
        return const Color(0xFF2C2C2C).withValues(alpha: 0.9);
      default:
        return Colors.white.withValues(alpha: 0.9);
    }
  }

  Color _getSpecialButtonColor() {
    switch (widget.theme) {
      case 'romantic-sunset':
        return const Color(0xFFFF6B9D).withValues(alpha: 0.9);
      case 'love-garden':
        return const Color(0xFF9CAF88).withValues(alpha: 0.9);
      case 'midnight-romance':
        return const Color(0xFF4B0082).withValues(alpha: 0.9);
      default:
        return const Color(0xFFFF6B9D).withValues(alpha: 0.9);
    }
  }

  Color _getIconColor() {
    switch (widget.theme) {
      case 'romantic-sunset':
        return const Color(0xFF2C3E50);
      case 'love-garden':
        return const Color(0xFF2D5016);
      case 'midnight-romance':
        return const Color(0xFFE8B4B8);
      default:
        return const Color(0xFF2C3E50);
    }
  }

  Color _getDisabledIconColor() {
    return Colors.grey.withValues(alpha: 0.5);
  }

  Color _getAccentColor() {
    switch (widget.theme) {
      case 'romantic-sunset':
        return const Color(0xFFFF6B9D);
      case 'love-garden':
        return const Color(0xFF9CAF88);
      case 'midnight-romance':
        return const Color(0xFF4B0082);
      default:
        return const Color(0xFFFF6B9D);
    }
  }
}
