import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/baby_font.dart';
import '../../../../shared/services/love_notes_service.dart';
import '../../../../shared/widgets/toast_service.dart';

/// Love notes widget for profile screen
class LoveNotesWidget extends StatefulWidget {
  const LoveNotesWidget({super.key});

  @override
  State<LoveNotesWidget> createState() => _LoveNotesWidgetState();
}

class _LoveNotesWidgetState extends State<LoveNotesWidget> {
  final LoveNotesService _loveNotesService = LoveNotesService.instance;
  List<LoveNote> _recentNotes = [];
  List<SharedQuote> _recentQuotes = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLoveNotesData();
  }

  Future<void> _loadLoveNotesData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await _loveNotesService.getAllLoveNotes();
      final quotes = await _loveNotesService.getAllSharedQuotes();
      final stats = await _loveNotesService.getLoveNotesStatistics();

      setState(() {
        _recentNotes = notes.take(3).toList();
        _recentQuotes = quotes.take(3).toList();
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
                  Icons.favorite,
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
                      'Love Notes',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Share sweet messages and quotes',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showAddNoteDialog,
                icon: Icon(
                  Icons.add_circle_outline,
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
          else if (_recentNotes.isEmpty && _recentQuotes.isEmpty)
            _buildEmptyState()
          else
            _buildLoveNotesContent(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.favorite_border,
          size: 48.w,
          color: AppTheme.textSecondary,
        ),
        SizedBox(height: 12.h),
        Text(
          'No love notes yet',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Start sharing sweet messages with each other!',
          style: BabyFont.bodyS.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: _showAddNoteDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text('Add First Note'),
        ),
      ],
    );
  }

  Widget _buildLoveNotesContent() {
    return Column(
      children: [
        // Statistics
        _buildStatistics(),
        SizedBox(height: 16.h),

        // Recent notes
        if (_recentNotes.isNotEmpty) ...[
          _buildRecentNotes(),
          SizedBox(height: 16.h),
        ],

        // Recent quotes
        if (_recentQuotes.isNotEmpty) ...[
          _buildRecentQuotes(),
          SizedBox(height: 16.h),
        ],

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _showAddNoteDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  side: BorderSide(color: AppTheme.primaryPink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Add Note'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _showAddQuoteDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Add Quote'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final totalNotes = _statistics['totalNotes'] ?? 0;
    final totalQuotes = _statistics['totalQuotes'] ?? 0;
    final unreadNotes = _statistics['unreadNotes'] ?? 0;

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
              'Notes',
              totalNotes.toString(),
              Icons.note,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Quotes',
              totalQuotes.toString(),
              Icons.format_quote,
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Unread',
              unreadNotes.toString(),
              Icons.mark_email_unread,
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

  Widget _buildRecentNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Notes',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        ...(_recentNotes.map((note) => _buildNoteItem(note))),
      ],
    );
  }

  Widget _buildRecentQuotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Quotes',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        ...(_recentQuotes.map((quote) => _buildQuoteItem(quote))),
      ],
    );
  }

  Widget _buildNoteItem(LoveNote note) {
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
          Text(
            note.type.emoji,
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  note.type.displayName,
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (!note.isRead)
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink,
                    shape: BoxShape.circle,
                  ),
                ),
              SizedBox(height: 4.h),
              Text(
                _formatDate(note.createdAt),
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteItem(SharedQuote quote) {
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
          Text(
            '💭',
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote.content,
                  style: BabyFont.bodyM.copyWith(
                    color: AppTheme.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '- ${quote.author}',
                  style: BabyFont.bodyS.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (quote.isFavorite)
                Icon(
                  Icons.favorite,
                  color: AppTheme.primaryPink,
                  size: 16.w,
                ),
              SizedBox(height: 4.h),
              Text(
                _formatDate(quote.createdAt),
                style: BabyFont.bodyS.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
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
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AddNoteDialog(
        onNoteAdded: () {
          _loadLoveNotesData();
        },
      ),
    );
  }

  void _showAddQuoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AddQuoteDialog(
        onQuoteAdded: () {
          _loadLoveNotesData();
        },
      ),
    );
  }
}

/// Add note dialog
class AddNoteDialog extends StatefulWidget {
  final VoidCallback onNoteAdded;

  const AddNoteDialog({
    super.key,
    required this.onNoteAdded,
  });

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final LoveNotesService _loveNotesService = LoveNotesService.instance;
  final TextEditingController _contentController = TextEditingController();

  LoveNoteType _selectedType = LoveNoteType.text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Love Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Note type selection
            Text(
              'What type of note?',
              style: BabyFont.bodyM.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildTypeGrid(),
            SizedBox(height: 20.h),

            // Content input
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Your message',
                hintText: 'Write something sweet...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _contentController.text.isNotEmpty ? _saveNote : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
          ),
          child: Text('Send'),
        ),
      ],
    );
  }

  Widget _buildTypeGrid() {
    final types = LoveNoteType.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = _selectedType == type;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = type;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryPink.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryPink
                    : AppTheme.textSecondary.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type.emoji,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  type.displayName,
                  style: BabyFont.bodyS.copyWith(
                    color: isSelected
                        ? AppTheme.primaryPink
                        : AppTheme.textSecondary,
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveNote() async {
    try {
      final note = LoveNote(
        id: 'note_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'current_user', // TODO: Get from auth
        receiverId: 'partner_user', // TODO: Get from auth
        content: _contentController.text,
        type: _selectedType,
        isRead: false,
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _loveNotesService.addLoveNote(note);
      if (success && mounted) {
        Navigator.pop(context);
        widget.onNoteAdded();
        ToastService.showSuccess(context, 'Love note sent! 💌');
      } else {
        ToastService.showError(context, 'Failed to send note');
      }
    } catch (e) {
      ToastService.showError(context, 'Failed to send note: ${e.toString()}');
    }
  }
}

/// Add quote dialog
class AddQuoteDialog extends StatefulWidget {
  final VoidCallback onQuoteAdded;

  const AddQuoteDialog({
    super.key,
    required this.onQuoteAdded,
  });

  @override
  State<AddQuoteDialog> createState() => _AddQuoteDialogState();
}

class _AddQuoteDialogState extends State<AddQuoteDialog> {
  final LoveNotesService _loveNotesService = LoveNotesService.instance;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Shared Quote'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Quote',
                hintText: 'Enter the quote...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                hintText: 'Who said this?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _sourceController,
              decoration: InputDecoration(
                labelText: 'Source (optional)',
                hintText: 'Book, movie, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _contentController.text.isNotEmpty &&
                  _authorController.text.isNotEmpty
              ? _saveQuote
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
          ),
          child: Text('Add Quote'),
        ),
      ],
    );
  }

  Future<void> _saveQuote() async {
    try {
      final quote = SharedQuote(
        id: 'quote_${DateTime.now().millisecondsSinceEpoch}',
        content: _contentController.text,
        author: _authorController.text,
        source:
            _sourceController.text.isNotEmpty ? _sourceController.text : null,
        tags: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _loveNotesService.addSharedQuote(quote);
      if (success && mounted) {
        Navigator.pop(context);
        widget.onQuoteAdded();
        ToastService.showSuccess(context, 'Quote added! 💭');
      } else {
        ToastService.showError(context, 'Failed to add quote');
      }
    } catch (e) {
      ToastService.showError(context, 'Failed to add quote: ${e.toString()}');
    }
  }
}
