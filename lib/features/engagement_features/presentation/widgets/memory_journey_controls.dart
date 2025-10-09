import 'package:flutter/material.dart';
import '../../data/models/memory_model.dart';

/// Memory Journey Controls Widget
/// Bottom control panel for the memory journey visualizer
class MemoryJourneyControls extends StatefulWidget {
  final bool isPlaying;
  final double progress;
  final VoidCallback onPlayPause;
  final Function(double) onSeek;
  final VoidCallback onReset;
  final Function(int) onMemoryFocus;
  final List<MemoryModel> memories;
  final int currentIndex;

  const MemoryJourneyControls({
    Key? key,
    required this.isPlaying,
    required this.progress,
    required this.onPlayPause,
    required this.onSeek,
    required this.onReset,
    required this.onMemoryFocus,
    required this.memories,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<MemoryJourneyControls> createState() => _MemoryJourneyControlsState();
}

class _MemoryJourneyControlsState extends State<MemoryJourneyControls> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          _buildProgressBar(),
          const SizedBox(height: 16),

          // Control buttons
          _buildControlButtons(),
          const SizedBox(height: 12),

          // Memory indicators
          if (widget.memories.isNotEmpty) _buildMemoryIndicators(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(widget.progress * _getTotalDuration()),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              _formatTime(_getTotalDuration()),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress slider
        GestureDetector(
          onPanStart: (details) {
            _isDragging = true;
            _updateProgressFromPosition(details.localPosition);
          },
          onPanUpdate: (details) {
            if (_isDragging) {
              _updateProgressFromPosition(details.localPosition);
            }
          },
          onPanEnd: (details) {
            _isDragging = false;
          },
          onTapDown: (details) {
            _updateProgressFromPosition(details.localPosition);
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomPaint(
              painter: ProgressBarPainter(
                progress: widget.progress,
                memories: widget.memories,
                currentIndex: widget.currentIndex,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reset button
        IconButton(
          onPressed: widget.onReset,
          icon: const Icon(Icons.refresh, color: Colors.white70),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            shape: const CircleBorder(),
          ),
        ),

        // Play/Pause button
        FloatingActionButton(
          onPressed: widget.onPlayPause,
          backgroundColor: Colors.white,
          child: Icon(
            widget.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.black,
            size: 28,
          ),
        ),

        // Speed control
        PopupMenuButton<double>(
          icon: const Icon(Icons.speed, color: Colors.white70),
          onSelected: (speed) {
            // TODO: Implement speed control
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 0.5, child: Text('0.5x')),
            const PopupMenuItem(value: 1.0, child: Text('1x')),
            const PopupMenuItem(value: 1.5, child: Text('1.5x')),
            const PopupMenuItem(value: 2.0, child: Text('2x')),
          ],
        ),
      ],
    );
  }

  Widget _buildMemoryIndicators() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.memories.length,
        itemBuilder: (context, index) {
          final memory = widget.memories[index];
          final isActive = index == widget.currentIndex;
          final isPast = index < widget.currentIndex;

          return GestureDetector(
            onTap: () => widget.onMemoryFocus(index),
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  // Memory indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.white
                          : isPast
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.3),
                      border: Border.all(
                        color: isActive ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: memory.photoPath != null
                        ? ClipOval(
                            child: Image.asset(
                              memory.photoPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  _getMoodIcon(memory.mood),
                                  color: Colors.black54,
                                  size: 20,
                                );
                              },
                            ),
                          )
                        : Icon(
                            _getMoodIcon(memory.mood),
                            color: Colors.black54,
                            size: 20,
                          ),
                  ),

                  // Memory title
                  const SizedBox(height: 4),
                  Text(
                    memory.title,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: 10,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateProgressFromPosition(Offset position) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final width = box.size.width;
    final progress = (position.dx / width).clamp(0.0, 1.0);
    widget.onSeek(progress);
  }

  double _getTotalDuration() {
    // Base duration + per memory duration
    return 6.0 + (widget.memories.length * 0.8);
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'romantic':
        return Icons.favorite;
      case 'joyful':
        return Icons.sentiment_very_satisfied;
      case 'sweet':
        return Icons.sentiment_satisfied;
      case 'emotional':
        return Icons.sentiment_dissatisfied;
      case 'fun':
        return Icons.sentiment_very_satisfied;
      case 'excited':
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.favorite;
    }
  }
}

/// Custom painter for progress bar with memory markers
class ProgressBarPainter extends CustomPainter {
  final double progress;
  final List<MemoryModel> memories;
  final int currentIndex;

  ProgressBarPainter({
    required this.progress,
    required this.memories,
    required this.currentIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Background track
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height / 2 - 2, size.width, 4),
      const Radius.circular(2),
    );
    canvas.drawRRect(trackRect, paint);

    // Progress track
    final progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final progressRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height / 2 - 2, size.width * progress, 4),
      const Radius.circular(2),
    );
    canvas.drawRRect(progressRect, progressPaint);

    // Memory markers
    for (int i = 0; i < memories.length; i++) {
      final memoryProgress = i / (memories.length - 1);
      final x = memoryProgress * size.width;
      final isActive = i == currentIndex;
      final isPast = i < currentIndex;

      final markerPaint = Paint()
        ..color = isActive
            ? Colors.blue
            : isPast
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5);

      canvas.drawCircle(
        Offset(x, size.height / 2),
        isActive ? 6 : 4,
        markerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.memories.length != memories.length;
  }
}
