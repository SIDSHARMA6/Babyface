import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../core/theme/baby_font.dart';
import '../services/hive_service.dart';
import '../services/firebase_service.dart';
import '../widgets/toast_service.dart';

/// Shared journal entry model
class SharedJournalEntry {
  final String id;
  final String userId;
  final String partnerId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isShared;
  final String? mood;
  final List<String> tags;

  SharedJournalEntry({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isShared,
    this.mood,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isShared': isShared,
      'mood': mood,
      'tags': tags,
    };
  }

  factory SharedJournalEntry.fromMap(Map<String, dynamic> map) {
    return SharedJournalEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      content: map['content'] ?? '',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      isShared: map['isShared'] ?? false,
      mood: map['mood'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  SharedJournalEntry copyWith({
    String? id,
    String? userId,
    String? partnerId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isShared,
    String? mood,
    List<String>? tags,
  }) {
    return SharedJournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isShared: isShared ?? this.isShared,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
    );
  }
}

/// Shared journal service
class SharedJournalService {
  static final SharedJournalService _instance =
      SharedJournalService._internal();
  factory SharedJournalService() => _instance;
  SharedJournalService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'shared_journal_box';
  static const String _entriesKey = 'shared_journal_entries';
  static const String _draftKey = 'shared_journal_draft';

  /// Get shared journal service instance
  static SharedJournalService get instance => _instance;

  /// Add journal entry
  Future<bool> addJournalEntry(SharedJournalEntry entry) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final entries = await getAllEntries();
      entries.add(entry);

      await _hiveService.store(
          _boxName, _entriesKey, entries.map((e) => e.toMap()).toList());

      // Sync to Firebase
      await _saveEntryToFirebase(entry);

      developer.log('✅ [SharedJournalService] Entry added: ${entry.id}');
      return true;
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error adding entry: $e');
      return false;
    }
  }

  /// Get all journal entries
  Future<List<SharedJournalEntry>> getAllEntries() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _entriesKey);

      if (data != null) {
        return (data as List)
            .map((item) =>
                SharedJournalEntry.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error getting entries: $e');
      return [];
    }
  }

  /// Get entries by user
  Future<List<SharedJournalEntry>> getEntriesByUser(String userId) async {
    try {
      final entries = await getAllEntries();
      return entries.where((entry) => entry.userId == userId).toList();
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error getting entries by user: $e');
      return [];
    }
  }

  /// Get shared entries
  Future<List<SharedJournalEntry>> getSharedEntries() async {
    try {
      final entries = await getAllEntries();
      return entries.where((entry) => entry.isShared).toList();
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error getting shared entries: $e');
      return [];
    }
  }

  /// Get recent entries
  Future<List<SharedJournalEntry>> getRecentEntries({int limit = 10}) async {
    try {
      final entries = await getAllEntries();
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries.take(limit).toList();
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error getting recent entries: $e');
      return [];
    }
  }

  /// Update journal entry
  Future<bool> updateEntry(SharedJournalEntry entry) async {
    try {
      final entries = await getAllEntries();
      final index = entries.indexWhere((e) => e.id == entry.id);

      if (index != -1) {
        entries[index] = entry;
        await _hiveService.store(
            _boxName, _entriesKey, entries.map((e) => e.toMap()).toList());

        // Sync to Firebase
        await _updateEntryInFirebase(entry);

        developer.log('✅ [SharedJournalService] Entry updated: ${entry.id}');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error updating entry: $e');
      return false;
    }
  }

  /// Delete journal entry
  Future<bool> deleteEntry(String entryId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final entries = await getAllEntries();
      entries.removeWhere((entry) => entry.id == entryId);

      await _hiveService.store(
          _boxName, _entriesKey, entries.map((e) => e.toMap()).toList());

      // Sync to Firebase
      await _deleteEntryFromFirebase(entryId);

      developer.log('✅ [SharedJournalService] Entry deleted: $entryId');
      return true;
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error deleting entry: $e');
      return false;
    }
  }

  /// Save draft
  Future<void> saveDraft(String content) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.store(_boxName, _draftKey, content);
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error saving draft: $e');
    }
  }

  /// Get draft
  Future<String> getDraft() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _draftKey);
      return data?.toString() ?? '';
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error getting draft: $e');
      return '';
    }
  }

  /// Clear draft
  Future<void> clearDraft() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _draftKey);
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error clearing draft: $e');
    }
  }

  /// Save entry to Firebase
  Future<void> _saveEntryToFirebase(SharedJournalEntry entry) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'shared_journal',
        documentId: entry.id,
        data: entry.toMap(),
      );
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error saving entry to Firebase: $e');
    }
  }

  /// Update entry in Firebase
  Future<void> _updateEntryInFirebase(SharedJournalEntry entry) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'shared_journal',
        documentId: entry.id,
        data: entry.toMap(),
      );
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error updating entry in Firebase: $e');
    }
  }

  /// Delete entry from Firebase
  Future<void> _deleteEntryFromFirebase(String entryId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'shared_journal',
        documentId: entryId,
      );
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error deleting entry from Firebase: $e');
    }
  }

  /// Clear all entries
  Future<void> clearAllEntries() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _entriesKey);
      developer.log('✅ [SharedJournalService] All entries cleared');
    } catch (e) {
      developer.log('❌ [SharedJournalService] Error clearing entries: $e');
    }
  }
}

/// Mini shared journal widget
class MiniSharedJournalWidget extends StatefulWidget {
  final String userId;
  final String partnerId;
  final VoidCallback? onEntryAdded;

  const MiniSharedJournalWidget({
    super.key,
    required this.userId,
    required this.partnerId,
    this.onEntryAdded,
  });

  @override
  State<MiniSharedJournalWidget> createState() =>
      _MiniSharedJournalWidgetState();
}

class _MiniSharedJournalWidgetState extends State<MiniSharedJournalWidget> {
  final SharedJournalService _journalService = SharedJournalService.instance;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<SharedJournalEntry> _recentEntries = [];
  bool _isWriting = false;
  bool _isLoading = false;
  Timer? _autoSaveTimer;
  String _currentDraft = '';

  @override
  void initState() {
    super.initState();
    _loadRecentEntries();
    _loadDraft();
    _setupAutoSave();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _setupAutoSave() {
    _autoSaveTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_textController.text.isNotEmpty &&
          _textController.text != _currentDraft) {
        _saveDraft();
      }
    });
  }

  Future<void> _loadRecentEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _journalService.getRecentEntries(limit: 3);
      setState(() {
        _recentEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDraft() async {
    try {
      final draft = await _journalService.getDraft();
      if (draft.isNotEmpty) {
        _textController.text = draft;
        _currentDraft = draft;
      }
    } catch (e) {
      developer.log('Error loading draft: $e');
    }
  }

  Future<void> _saveDraft() async {
    try {
      await _journalService.saveDraft(_textController.text);
      _currentDraft = _textController.text;
    } catch (e) {
      developer.log('Error saving draft: $e');
    }
  }

  Future<void> _addEntry() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final entry = SharedJournalEntry(
        id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
        userId: widget.userId,
        partnerId: widget.partnerId,
        content: _textController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isShared: true,
        tags: [],
      );

      final success = await _journalService.addJournalEntry(entry);
      if (success && mounted) {
        await _journalService.clearDraft();
        _textController.clear();
        _currentDraft = '';
        _loadRecentEntries();
        widget.onEntryAdded?.call();
        if (mounted) {
          ToastService.showSuccess(context, 'Journal entry added! 📝');
        }
      } else {
        if (mounted) ToastService.showError(context, 'Failed to add entry');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Failed to add entry: ${e.toString()}');
      }
    } finally {
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
                  Icons.edit_note,
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
                      'Shared Journal',
                      style: BabyFont.headingS.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Write together in real-time',
                      style: BabyFont.bodyS.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadRecentEntries,
                icon: Icon(
                  Icons.refresh,
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Writing area
          _buildWritingArea(),
          SizedBox(height: 16.h),

          // Recent entries
          if (_recentEntries.isNotEmpty) ...[
            _buildRecentEntries(),
            SizedBox(height: 16.h),
          ],

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildWritingArea() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isWriting
              ? AppTheme.primaryPink
              : AppTheme.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'What\'s on your mind? Share it with your partner...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
        ),
        maxLines: 4,
        onTap: () {
          setState(() {
            _isWriting = true;
          });
        },
        onChanged: (value) {
          setState(() {
            _isWriting = value.isNotEmpty;
          });
        },
      ),
    );
  }

  Widget _buildRecentEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Entries',
          style: BabyFont.bodyM.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        ..._recentEntries.map((entry) => _buildEntryItem(entry)),
      ],
    );
  }

  Widget _buildEntryItem(SharedJournalEntry entry) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.content,
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            _formatDate(entry.createdAt),
            style: BabyFont.bodyS.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _textController.text.trim().isEmpty ? null : _addEntry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryPink,
              side: BorderSide(color: AppTheme.primaryPink),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryPink,
                      strokeWidth: 2,
                    ),
                  )
                : Text('Share Entry'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _showFullJournal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text('View All'),
          ),
        ),
      ],
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

  void _showFullJournal() {
    showDialog(
      context: context,
      builder: (context) => FullJournalDialog(
        userId: widget.userId,
        partnerId: widget.partnerId,
        onEntryAdded: () {
          _loadRecentEntries();
          widget.onEntryAdded?.call();
        },
      ),
    );
  }
}

/// Full journal dialog
class FullJournalDialog extends StatefulWidget {
  final String userId;
  final String partnerId;
  final VoidCallback? onEntryAdded;

  const FullJournalDialog({
    super.key,
    required this.userId,
    required this.partnerId,
    this.onEntryAdded,
  });

  @override
  State<FullJournalDialog> createState() => _FullJournalDialogState();
}

class _FullJournalDialogState extends State<FullJournalDialog> {
  final SharedJournalService _journalService = SharedJournalService.instance;
  List<SharedJournalEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await _journalService.getAllEntries();
      setState(() {
        _entries = entries;
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
    return AlertDialog(
      title: Text('Shared Journal'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400.h,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink))
            : ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.content,
                          style: BabyFont.bodyM.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(entry.createdAt),
                              style: BabyFont.bodyS.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (entry.isShared)
                              Icon(
                                Icons.share,
                                color: AppTheme.primaryPink,
                                size: 16.w,
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
