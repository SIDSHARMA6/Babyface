import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Accessibility Manager for Memory Journey Visualizer
/// Provides comprehensive accessibility features including screen reader support,
/// high contrast mode, reduced motion, and motor accessibility
class AccessibilityManager {
  static final AccessibilityManager _instance =
      AccessibilityManager._internal();
  factory AccessibilityManager() => _instance;
  AccessibilityManager._internal();

  bool _isHighContrastMode = false;
  bool _isReducedMotionMode = false;
  bool _isScreenReaderEnabled = false;
  double _fontScale = 1.0;
  bool _isMotorAccessibilityEnabled = false;

  /// Initialize accessibility manager
  void initialize() {
    _checkSystemSettings();
  }

  /// Check system accessibility settings
  void _checkSystemSettings() {
    // Check if screen reader is enabled
    _isScreenReaderEnabled =
        SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation;

    // Check if high contrast is enabled
    _isHighContrastMode =
        SemanticsBinding.instance.accessibilityFeatures.highContrast;

    // Check if reduced motion is enabled
    _isReducedMotionMode =
        SemanticsBinding.instance.accessibilityFeatures.reduceMotion;

    // Get font scale
    _fontScale = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
        .textScaleFactor;
  }

  /// Get accessibility-aware colors
  Map<String, Color> getAccessibleColors(String theme) {
    final baseColors = _getBaseThemeColors(theme);

    if (_isHighContrastMode) {
      return _applyHighContrast(baseColors);
    }

    return baseColors;
  }

  /// Get accessibility-aware animation duration
  Duration getAccessibleDuration(Duration baseDuration) {
    if (_isReducedMotionMode) {
      return Duration(
          milliseconds: (baseDuration.inMilliseconds * 0.3).round());
    }
    return baseDuration;
  }

  /// Get accessibility-aware font size
  double getAccessibleFontSize(double baseSize) {
    return baseSize * _fontScale;
  }

  /// Check if animations should be reduced
  bool get shouldReduceAnimations => _isReducedMotionMode;

  /// Check if high contrast is enabled
  bool get isHighContrastMode => _isHighContrastMode;

  /// Check if screen reader is enabled
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;

  /// Check if motor accessibility is enabled
  bool get isMotorAccessibilityEnabled => _isMotorAccessibilityEnabled;

  /// Get base theme colors
  Map<String, Color> _getBaseThemeColors(String theme) {
    switch (theme) {
      case 'romantic-sunset':
        return {
          'primary': const Color(0xFFFF6B9D),
          'secondary': const Color(0xFFFFB347),
          'accent': const Color(0xFFFFD700),
          'background': const Color(0xFF2C3E50),
          'surface': Colors.white,
          'text': Colors.white,
          'textSecondary': Colors.grey,
        };
      case 'love-garden':
        return {
          'primary': const Color(0xFFFFB6C1),
          'secondary': const Color(0xFF98FB98),
          'accent': const Color(0xFFD4A5A5),
          'background': const Color(0xFF9CAF88),
          'surface': Colors.white,
          'text': Colors.white,
          'textSecondary': Colors.grey,
        };
      case 'midnight-romance':
        return {
          'primary': const Color(0xFF4B0082),
          'secondary': const Color(0xFFC0C0C0),
          'accent': const Color(0xFFE8B4B8),
          'background': const Color(0xFF191970),
          'surface': Colors.white,
          'text': Colors.white,
          'textSecondary': Colors.grey,
        };
      default:
        return {
          'primary': const Color(0xFFFF6B9D),
          'secondary': const Color(0xFFFFB347),
          'accent': const Color(0xFFFFD700),
          'background': const Color(0xFF2C3E50),
          'surface': Colors.white,
          'text': Colors.white,
          'textSecondary': Colors.grey,
        };
    }
  }

  /// Apply high contrast to colors
  Map<String, Color> _applyHighContrast(Map<String, Color> baseColors) {
    return {
      'primary': Colors.white,
      'secondary': Colors.yellow,
      'accent': Colors.cyan,
      'background': Colors.black,
      'surface': Colors.white,
      'text': Colors.white,
      'textSecondary': Colors.grey.shade300,
    };
  }
}

/// Accessible Memory Journey Visualizer
/// Provides full accessibility support for the memory journey visualizer
class AccessibleMemoryJourneyVisualizer extends StatefulWidget {
  final Widget child;
  final String journeyTitle;
  final List<String> memoryTitles;
  final int currentMemoryIndex;
  final double progress;
  final VoidCallback? onPreviousMemory;
  final VoidCallback? onNextMemory;
  final VoidCallback? onPlayPause;
  final VoidCallback? onReset;

  const AccessibleMemoryJourneyVisualizer({
    Key? key,
    required this.child,
    required this.journeyTitle,
    required this.memoryTitles,
    required this.currentMemoryIndex,
    required this.progress,
    this.onPreviousMemory,
    this.onNextMemory,
    this.onPlayPause,
    this.onReset,
  }) : super(key: key);

  @override
  State<AccessibleMemoryJourneyVisualizer> createState() =>
      _AccessibleMemoryJourneyVisualizerState();
}

class _AccessibleMemoryJourneyVisualizerState
    extends State<AccessibleMemoryJourneyVisualizer> {
  final AccessibilityManager _accessibilityManager = AccessibilityManager();
  final FocusNode _focusNode = FocusNode();
  int _currentFocusIndex = 0;

  @override
  void initState() {
    super.initState();
    _accessibilityManager.initialize();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memory Journey Visualizer: ${widget.journeyTitle}',
      hint:
          'Interactive memory journey with ${widget.memoryTitles.length} memories',
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) => KeyEventResult.handled,
        child: Stack(
          children: [
            widget.child,
            if (_accessibilityManager.isScreenReaderEnabled)
              _buildScreenReaderOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenReaderOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            // Journey progress announcement
            Semantics(
              label:
                  'Journey Progress: ${(widget.progress * 100).round()}% complete',
              child: Container(
                height: 1,
                width: double.infinity,
                color: Colors.transparent,
              ),
            ),

            // Memory navigation
            if (widget.memoryTitles.isNotEmpty)
              Semantics(
                label:
                    'Current Memory: ${widget.memoryTitles[widget.currentMemoryIndex]} (${widget.currentMemoryIndex + 1} of ${widget.memoryTitles.length})',
                child: Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.transparent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTap() {
    // Handle tap for screen reader users
    if (_accessibilityManager.isScreenReaderEnabled) {
      _announceCurrentMemory();
    }
  }

  void _handleLongPress() {
    // Handle long press for screen reader users
    if (_accessibilityManager.isScreenReaderEnabled) {
      _showMemoryList();
    }
  }

  bool _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_accessibilityManager.isScreenReaderEnabled) return false;

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          widget.onPreviousMemory?.call();
          return true;
        case LogicalKeyboardKey.arrowRight:
          widget.onNextMemory?.call();
          return true;
        case LogicalKeyboardKey.space:
          widget.onPlayPause?.call();
          return true;
        case LogicalKeyboardKey.home:
          widget.onReset?.call();
          return true;
      }
    }
    return false;
  }

  void _announceCurrentMemory() {
    if (widget.memoryTitles.isNotEmpty) {
      final currentMemory = widget.memoryTitles[widget.currentMemoryIndex];
      SemanticsService.announce(
        'Current memory: $currentMemory',
        TextDirection.ltr,
      );
    }
  }

  void _showMemoryList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Memory List',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.memoryTitles.length,
                itemBuilder: (context, index) {
                  final isCurrent = index == widget.currentMemoryIndex;
                  return ListTile(
                    title: Text(widget.memoryTitles[index]),
                    subtitle: Text('Memory ${index + 1}'),
                    selected: isCurrent,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to specific memory
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Accessible Memory Marker
/// Provides accessibility support for memory markers
class AccessibleMemoryMarker extends StatelessWidget {
  final String memoryTitle;
  final String memoryDescription;
  final String memoryDate;
  final String memoryMood;
  final bool isVisible;
  final bool isFocused;
  final VoidCallback onTap;
  final Widget child;

  const AccessibleMemoryMarker({
    Key? key,
    required this.memoryTitle,
    required this.memoryDescription,
    required this.memoryDate,
    required this.memoryMood,
    required this.isVisible,
    required this.isFocused,
    required this.onTap,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memory: $memoryTitle',
      hint:
          'Description: $memoryDescription. Date: $memoryDate. Mood: $memoryMood',
      button: true,
      enabled: isVisible,
      selected: isFocused,
      onTap: isVisible ? onTap : null,
      child: child,
    );
  }
}

/// Accessible Journey Controls
/// Provides accessibility support for journey controls
class AccessibleJourneyControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReset;
  final double progress;
  final int totalMemories;
  final Widget child;

  const AccessibleJourneyControls({
    Key? key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onReset,
    required this.progress,
    required this.totalMemories,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Journey Controls',
      hint: 'Use these controls to navigate through your memory journey',
      child: Column(
        children: [
          // Progress indicator
          Semantics(
            label: 'Journey Progress: ${(progress * 100).round()}% complete',
            child: LinearProgressIndicator(
              value: progress,
              semanticsLabel: 'Journey Progress',
            ),
          ),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Semantics(
                label: 'Previous Memory',
                button: true,
                onTap: onPrevious,
                child: IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: onPrevious,
                ),
              ),
              Semantics(
                label: isPlaying ? 'Pause Journey' : 'Play Journey',
                button: true,
                onTap: onPlayPause,
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: onPlayPause,
                ),
              ),
              Semantics(
                label: 'Next Memory',
                button: true,
                onTap: onNext,
                child: IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: onNext,
                ),
              ),
              Semantics(
                label: 'Reset Journey',
                button: true,
                onTap: onReset,
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onReset,
                ),
              ),
            ],
          ),

          child,
        ],
      ),
    );
  }
}

/// Accessibility Settings Screen
/// Allows users to configure accessibility options
class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  final AccessibilityManager _accessibilityManager = AccessibilityManager();
  bool _isHighContrastMode = false;
  bool _isReducedMotionMode = false;
  bool _isScreenReaderEnabled = false;
  double _fontScale = 1.0;

  @override
  void initState() {
    super.initState();
    _accessibilityManager.initialize();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _isHighContrastMode = _accessibilityManager.isHighContrastMode;
      _isReducedMotionMode = _accessibilityManager.shouldReduceAnimations;
      _isScreenReaderEnabled = _accessibilityManager.isScreenReaderEnabled;
      _fontScale = _accessibilityManager._fontScale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // High Contrast Mode
          SwitchListTile(
            title: const Text('High Contrast Mode'),
            subtitle: const Text('Enhance contrast for better visibility'),
            value: _isHighContrastMode,
            onChanged: (value) {
              setState(() {
                _isHighContrastMode = value;
              });
              // TODO: Apply high contrast mode
            },
          ),

          // Reduced Motion
          SwitchListTile(
            title: const Text('Reduce Motion'),
            subtitle: const Text('Reduce animations for motion sensitivity'),
            value: _isReducedMotionMode,
            onChanged: (value) {
              setState(() {
                _isReducedMotionMode = value;
              });
              // TODO: Apply reduced motion
            },
          ),

          // Font Scale
          ListTile(
            title: const Text('Font Scale'),
            subtitle: Text('Current: ${_fontScale.toStringAsFixed(1)}x'),
            trailing: Slider(
              value: _fontScale,
              min: 0.8,
              max: 2.0,
              divisions: 12,
              onChanged: (value) {
                setState(() {
                  _fontScale = value;
                });
                // TODO: Apply font scale
              },
            ),
          ),

          // Screen Reader Support
          SwitchListTile(
            title: const Text('Screen Reader Support'),
            subtitle: const Text('Enable enhanced screen reader support'),
            value: _isScreenReaderEnabled,
            onChanged: (value) {
              setState(() {
                _isScreenReaderEnabled = value;
              });
              // TODO: Apply screen reader support
            },
          ),

          const Divider(),

          // Accessibility Help
          ListTile(
            title: const Text('Accessibility Help'),
            subtitle: const Text('Learn about accessibility features'),
            trailing: const Icon(Icons.help_outline),
            onTap: () {
              _showAccessibilityHelp();
            },
          ),
        ],
      ),
    );
  }

  void _showAccessibilityHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accessibility Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('High Contrast Mode:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Enhances color contrast for better visibility'),
              SizedBox(height: 16),
              Text('Reduce Motion:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Reduces animations for users with motion sensitivity'),
              SizedBox(height: 16),
              Text('Font Scale:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Adjusts text size for better readability'),
              SizedBox(height: 16),
              Text('Screen Reader Support:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Provides enhanced support for screen readers'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
