import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/gesture_recognition_service.dart';
import '../../../../shared/services/love_reactions_service.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Gesture drawing widget for love reactions
class GestureDrawingWidget extends StatefulWidget {
  final String userId;
  final String partnerId;
  final VoidCallback? onReactionCreated;

  const GestureDrawingWidget({
    super.key,
    required this.userId,
    required this.partnerId,
    this.onReactionCreated,
  });

  @override
  State<GestureDrawingWidget> createState() => _GestureDrawingWidgetState();
}

class _GestureDrawingWidgetState extends State<GestureDrawingWidget> {
  final GestureRecognitionService _gestureService = GestureRecognitionService();
  final LoveReactionsService _reactionsService = LoveReactionsService();

  List<GesturePoint> _currentGesture = [];
  List<List<GesturePoint>> _gestureHistory = [];
  bool _isDrawing = false;
  ReactionType? _recognizedType;
  String? _customMessage;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.gesture,
                  color: AppTheme.primaryPink,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Draw Love Reactions',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Draw hearts, kisses, hugs, and more!',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _clearDrawing,
                icon: Icon(
                  Icons.clear,
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Drawing area
          _buildDrawingArea(),
          SizedBox(height: 16.h),

          // Recognition result
          if (_recognizedType != null) _buildRecognitionResult(),
          SizedBox(height: 16.h),

          // Message input
          _buildMessageInput(),
          SizedBox(height: 16.h),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDrawingArea() {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.primaryPink.withValues(alpha: 0.2),
        ),
      ),
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          painter: GesturePainter(
            currentGesture: _currentGesture,
            gestureHistory: _gestureHistory,
            recognizedType: _recognizedType,
          ),
          child: Center(
            child: Text(
              'Draw your love reaction here!',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecognitionResult() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _gestureService
            .getReactionColor(_recognizedType!)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Text(
            _gestureService.getReactionEmoji(_recognizedType!),
            style: TextStyle(fontSize: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recognized: ${_gestureService.getReactionName(_recognizedType!)}',
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Great job! Your gesture was recognized.',
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      controller: _messageController,
      decoration: InputDecoration(
        labelText: 'Add a message (optional)',
        hintText: 'Express your love...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        prefixIcon: Icon(
          Icons.message,
          color: AppTheme.primaryPink,
        ),
      ),
      maxLines: 2,
      onChanged: (value) {
        setState(() {
          _customMessage = value.isNotEmpty ? value : null;
        });
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _currentGesture.isNotEmpty ? _recognizeGesture : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryPink,
              side: BorderSide(color: AppTheme.primaryPink),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text('Recognize'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _recognizedType != null ? _saveReaction : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text('Send Love'),
          ),
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _currentGesture = [];
      _recognizedType = null;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    setState(() {
      _currentGesture.add(GesturePoint(
        x: details.localPosition.dx,
        y: details.localPosition.dy,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDrawing = false;
      if (_currentGesture.isNotEmpty) {
        _gestureHistory.add(List.from(_currentGesture));
      }
    });
  }

  void _recognizeGesture() {
    if (_currentGesture.isEmpty) return;

    setState(() {
      _recognizedType = _gestureService.recognizeGesture(_currentGesture);
    });
  }

  Future<void> _saveReaction() async {
    if (_recognizedType == null) return;

    try {
      final reaction = await _reactionsService.createReactionFromGesture(
        _currentGesture,
        widget.userId,
        widget.partnerId,
        message: _customMessage,
      );

      final success = await _reactionsService.addLoveReaction(reaction);
      if (success && mounted) {
        ToastService.showSuccess(context,
            'Love reaction sent! ${_gestureService.getReactionEmoji(_recognizedType!)}');
        widget.onReactionCreated?.call();
        _clearDrawing();
      } else {
        ToastService.showError(context, 'Failed to send reaction');
      }
    } catch (e) {
      ToastService.showError(
          context, 'Failed to send reaction: ${e.toString()}');
    }
  }

  void _clearDrawing() {
    setState(() {
      _currentGesture = [];
      _gestureHistory = [];
      _recognizedType = null;
      _customMessage = null;
      _messageController.clear();
    });
  }
}

/// Custom painter for drawing gestures
class GesturePainter extends CustomPainter {
  final List<GesturePoint> currentGesture;
  final List<List<GesturePoint>> gestureHistory;
  final ReactionType? recognizedType;

  GesturePainter({
    required this.currentGesture,
    required this.gestureHistory,
    this.recognizedType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw gesture history
    for (int i = 0; i < gestureHistory.length; i++) {
      final gesture = gestureHistory[i];
      paint.color = Colors.grey.withValues(alpha: 0.3);
      _drawGesture(canvas, gesture, paint);
    }

    // Draw current gesture
    if (currentGesture.isNotEmpty) {
      paint.color = recognizedType != null
          ? _getReactionColor(recognizedType!)
          : AppTheme.primaryPink;
      paint.strokeWidth = 4.0;
      _drawGesture(canvas, currentGesture, paint);
    }
  }

  void _drawGesture(Canvas canvas, List<GesturePoint> gesture, Paint paint) {
    if (gesture.length < 2) return;

    final path = Path();
    path.moveTo(gesture.first.x, gesture.first.y);

    for (int i = 1; i < gesture.length; i++) {
      path.lineTo(gesture[i].x, gesture[i].y);
    }

    canvas.drawPath(path, paint);
  }

  Color _getReactionColor(ReactionType type) {
    switch (type) {
      case ReactionType.heart:
        return Colors.red;
      case ReactionType.kiss:
        return Colors.pink;
      case ReactionType.hug:
        return Colors.blue;
      case ReactionType.smile:
        return Colors.yellow;
      case ReactionType.star:
        return Colors.orange;
      case ReactionType.custom:
        return Colors.purple;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Love reactions history widget
class LoveReactionsHistoryWidget extends StatefulWidget {
  final String userId;
  final String partnerId;

  const LoveReactionsHistoryWidget({
    super.key,
    required this.userId,
    required this.partnerId,
  });

  @override
  State<LoveReactionsHistoryWidget> createState() =>
      _LoveReactionsHistoryWidgetState();
}

class _LoveReactionsHistoryWidgetState
    extends State<LoveReactionsHistoryWidget> {
  final LoveReactionsService _reactionsService = LoveReactionsService();
  List<LoveReaction> _reactions = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReactions();
  }

  Future<void> _loadReactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reactions = await _reactionsService.getRecentReactions(limit: 20);
      final stats = await _reactionsService.getReactionStatistics();

      setState(() {
        _reactions = reactions;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.history,
                  color: AppTheme.primaryPink,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Love Reactions History',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Your gesture-based love expressions',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadReactions,
                icon: Icon(
                  Icons.refresh,
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryPink,
              ),
            )
          else if (_reactions.isEmpty)
            _buildEmptyState()
          else
            _buildReactionsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.gesture,
          size: 48.w,
          color: AppTheme.textSecondary,
        ),
        SizedBox(height: 12.h),
        Text(
          'No love reactions yet',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Start drawing love reactions to see them here!',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReactionsList() {
    return Column(
      children: [
        // Statistics
        _buildStatistics(),
        SizedBox(height: 16.h),

        // Reactions list
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _reactions.length,
          itemBuilder: (context, index) {
            final reaction = _reactions[index];
            return _buildReactionItem(reaction);
          },
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final totalReactions = _statistics['totalReactions'] ?? 0;
    final reactionsByType =
        _statistics['reactionsByType'] as Map<String, int>? ?? {};

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              totalReactions.toString(),
              Icons.favorite,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Types',
              reactionsByType.length.toString(),
              Icons.category,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Recent',
              _reactions.length.toString(),
              Icons.history,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16.w,
          color: AppTheme.primaryPink,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: BabyFont.headingS.copyWith(
            color: AppTheme.primaryPink,
          ),
        ),
        Text(
          label,
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReactionItem(LoveReaction reaction) {
    final gestureService = GestureRecognitionService();

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Reaction emoji
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: gestureService
                  .getReactionColor(reaction.type)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                gestureService.getReactionEmoji(reaction.type),
                style: TextStyle(fontSize: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Reaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gestureService.getReactionName(reaction.type),
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (reaction.message != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    reaction.message!,
                    style: BabyFont.bodyS.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Date
          Text(
            _formatDate(reaction.createdAt),
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
