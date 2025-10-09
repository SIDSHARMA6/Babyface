import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

/// Love note model
class LoveNote {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final LoveNoteType type;
  final String? photoPath;
  final String? audioPath;
  final bool isRead;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoveNote({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    this.photoPath,
    this.audioPath,
    required this.isRead,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.name,
      'photoPath': photoPath,
      'audioPath': audioPath,
      'isRead': isRead,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LoveNote.fromMap(Map<String, dynamic> map) {
    return LoveNote(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: LoveNoteType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => LoveNoteType.text,
      ),
      photoPath: map['photoPath'],
      audioPath: map['audioPath'],
      isRead: map['isRead'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  LoveNote copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    LoveNoteType? type,
    String? photoPath,
    String? audioPath,
    bool? isRead,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoveNote(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      photoPath: photoPath ?? this.photoPath,
      audioPath: audioPath ?? this.audioPath,
      isRead: isRead ?? this.isRead,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Love note types
enum LoveNoteType {
  text,
  photo,
  audio,
  quote,
  memory,
  promise,
  apology,
  surprise,
  encouragement,
  gratitude,
}

/// Shared quote model
class SharedQuote {
  final String id;
  final String content;
  final String author;
  final String? source;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  SharedQuote({
    required this.id,
    required this.content,
    required this.author,
    this.source,
    required this.tags,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'author': author,
      'source': source,
      'tags': tags,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SharedQuote.fromMap(Map<String, dynamic> map) {
    return SharedQuote(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      author: map['author'] ?? '',
      source: map['source'],
      tags: List<String>.from(map['tags'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  SharedQuote copyWith({
    String? id,
    String? content,
    String? author,
    String? source,
    List<String>? tags,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SharedQuote(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      source: source ?? this.source,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Love notes service
class LoveNotesService {
  static final LoveNotesService _instance = LoveNotesService._internal();
  factory LoveNotesService() => _instance;
  LoveNotesService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'love_notes_box';
  static const String _notesKey = 'love_notes';
  static const String _quotesKey = 'shared_quotes';

  /// Get love notes service instance
  static LoveNotesService get instance => _instance;

  /// Add love note
  Future<bool> addLoveNote(LoveNote note) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final notes = await getAllLoveNotes();
      notes.add(note);

      await _hiveService.store(
          _boxName, _notesKey, notes.map((n) => n.toMap()).toList());

      // Sync to Firebase
      await _saveNoteToFirebase(note);

      developer.log('✅ [LoveNotesService] Love note added: ${note.id}');
      return true;
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error adding love note: $e');
      return false;
    }
  }

  /// Get all love notes
  Future<List<LoveNote>> getAllLoveNotes() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _notesKey);

      if (data != null) {
        return (data as List)
            .map((item) => LoveNote.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error getting love notes: $e');
      return [];
    }
  }

  /// Get love notes for user
  Future<List<LoveNote>> getLoveNotesForUser(String userId) async {
    try {
      final notes = await getAllLoveNotes();
      return notes
          .where((note) => note.senderId == userId || note.receiverId == userId)
          .toList();
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error getting love notes for user: $e');
      return [];
    }
  }

  /// Get unread love notes
  Future<List<LoveNote>> getUnreadLoveNotes(String userId) async {
    try {
      final notes = await getAllLoveNotes();
      return notes
          .where((note) => note.receiverId == userId && !note.isRead)
          .toList();
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error getting unread love notes: $e');
      return [];
    }
  }

  /// Mark love note as read
  Future<bool> markAsRead(String noteId) async {
    try {
      final notes = await getAllLoveNotes();
      final index = notes.indexWhere((note) => note.id == noteId);

      if (index != -1) {
        notes[index] = notes[index].copyWith(
          isRead: true,
          updatedAt: DateTime.now(),
        );

        await _hiveService.store(
            _boxName, _notesKey, notes.map((n) => n.toMap()).toList());

        // Sync to Firebase
        await _updateNoteInFirebase(notes[index]);

        developer.log('✅ [LoveNotesService] Love note marked as read: $noteId');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error marking note as read: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String noteId) async {
    try {
      final notes = await getAllLoveNotes();
      final index = notes.indexWhere((note) => note.id == noteId);

      if (index != -1) {
        notes[index] = notes[index].copyWith(
          isFavorite: !notes[index].isFavorite,
          updatedAt: DateTime.now(),
        );

        await _hiveService.store(
            _boxName, _notesKey, notes.map((n) => n.toMap()).toList());

        // Sync to Firebase
        await _updateNoteInFirebase(notes[index]);

        developer.log('✅ [LoveNotesService] Love note favorite toggled: $noteId');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error toggling favorite: $e');
      return false;
    }
  }

  /// Delete love note
  Future<bool> deleteLoveNote(String noteId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final notes = await getAllLoveNotes();
      notes.removeWhere((note) => note.id == noteId);

      await _hiveService.store(
          _boxName, _notesKey, notes.map((n) => n.toMap()).toList());

      // Sync to Firebase
      await _deleteNoteFromFirebase(noteId);

      developer.log('✅ [LoveNotesService] Love note deleted: $noteId');
      return true;
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error deleting love note: $e');
      return false;
    }
  }

  /// Add shared quote
  Future<bool> addSharedQuote(SharedQuote quote) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final quotes = await getAllSharedQuotes();
      quotes.add(quote);

      await _hiveService.store(
          _boxName, _quotesKey, quotes.map((q) => q.toMap()).toList());

      // Sync to Firebase
      await _saveQuoteToFirebase(quote);

      developer.log('✅ [LoveNotesService] Shared quote added: ${quote.id}');
      return true;
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error adding shared quote: $e');
      return false;
    }
  }

  /// Get all shared quotes
  Future<List<SharedQuote>> getAllSharedQuotes() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _quotesKey);

      if (data != null) {
        return (data as List)
            .map((item) => SharedQuote.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error getting shared quotes: $e');
      return [];
    }
  }

  /// Get favorite quotes
  Future<List<SharedQuote>> getFavoriteQuotes() async {
    try {
      final quotes = await getAllSharedQuotes();
      return quotes.where((quote) => quote.isFavorite).toList();
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error getting favorite quotes: $e');
      return [];
    }
  }

  /// Toggle quote favorite status
  Future<bool> toggleQuoteFavorite(String quoteId) async {
    try {
      final quotes = await getAllSharedQuotes();
      final index = quotes.indexWhere((quote) => quote.id == quoteId);

      if (index != -1) {
        quotes[index] = quotes[index].copyWith(
          isFavorite: !quotes[index].isFavorite,
          updatedAt: DateTime.now(),
        );

        await _hiveService.store(
            _boxName, _quotesKey, quotes.map((q) => q.toMap()).toList());

        // Sync to Firebase
        await _updateQuoteInFirebase(quotes[index]);

        developer.log('✅ [LoveNotesService] Quote favorite toggled: $quoteId');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error toggling quote favorite: $e');
      return false;
    }
  }

  /// Delete shared quote
  Future<bool> deleteSharedQuote(String quoteId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final quotes = await getAllSharedQuotes();
      quotes.removeWhere((quote) => quote.id == quoteId);

      await _hiveService.store(
          _boxName, _quotesKey, quotes.map((q) => q.toMap()).toList());

      // Sync to Firebase
      await _deleteQuoteFromFirebase(quoteId);

      developer.log('✅ [LoveNotesService] Shared quote deleted: $quoteId');
      return true;
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error deleting shared quote: $e');
      return false;
    }
  }

  /// Get love notes statistics
  Future<Map<String, dynamic>> getLoveNotesStatistics() async {
    try {
      final notes = await getAllLoveNotes();
      final quotes = await getAllSharedQuotes();

      if (notes.isEmpty && quotes.isEmpty) {
        return {
          'totalNotes': 0,
          'totalQuotes': 0,
          'unreadNotes': 0,
          'favoriteNotes': 0,
          'favoriteQuotes': 0,
          'notesByType': {},
          'recentActivity': [],
        };
      }

      // Calculate statistics
      final totalNotes = notes.length;
      final totalQuotes = quotes.length;
      final unreadNotes = notes.where((note) => !note.isRead).length;
      final favoriteNotes = notes.where((note) => note.isFavorite).length;
      final favoriteQuotes = quotes.where((quote) => quote.isFavorite).length;

      // Notes by type
      final notesByType = <String, int>{};
      for (final note in notes) {
        notesByType[note.type.name] = (notesByType[note.type.name] ?? 0) + 1;
      }

      // Recent activity (last 7 days)
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final recentNotes =
          notes.where((note) => note.createdAt.isAfter(weekAgo)).toList();
      final recentQuotes =
          quotes.where((quote) => quote.createdAt.isAfter(weekAgo)).toList();

      final recentActivity = <Map<String, dynamic>>[];
      for (final note in recentNotes) {
        recentActivity.add({
          'type': 'note',
          'id': note.id,
          'content': note.content,
          'createdAt': note.createdAt.toIso8601String(),
        });
      }
      for (final quote in recentQuotes) {
        recentActivity.add({
          'type': 'quote',
          'id': quote.id,
          'content': quote.content,
          'createdAt': quote.createdAt.toIso8601String(),
        });
      }

      recentActivity.sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));

      return {
        'totalNotes': totalNotes,
        'totalQuotes': totalQuotes,
        'unreadNotes': unreadNotes,
        'favoriteNotes': favoriteNotes,
        'favoriteQuotes': favoriteQuotes,
        'notesByType': notesByType,
        'recentActivity': recentActivity,
      };
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error getting statistics: $e');
      return {
        'totalNotes': 0,
        'totalQuotes': 0,
        'unreadNotes': 0,
        'favoriteNotes': 0,
        'favoriteQuotes': 0,
        'notesByType': {},
        'recentActivity': [],
      };
    }
  }

  /// Save note to Firebase
  Future<void> _saveNoteToFirebase(LoveNote note) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'love_notes',
        documentId: note.id,
        data: note.toMap(),
      );
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error saving note to Firebase: $e');
    }
  }

  /// Update note in Firebase
  Future<void> _updateNoteInFirebase(LoveNote note) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'love_notes',
        documentId: note.id,
        data: note.toMap(),
      );
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error updating note in Firebase: $e');
    }
  }

  /// Delete note from Firebase
  Future<void> _deleteNoteFromFirebase(String noteId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'love_notes',
        documentId: noteId,
      );
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error deleting note from Firebase: $e');
    }
  }

  /// Save quote to Firebase
  Future<void> _saveQuoteToFirebase(SharedQuote quote) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'shared_quotes',
        documentId: quote.id,
        data: quote.toMap(),
      );
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error saving quote to Firebase: $e');
    }
  }

  /// Update quote in Firebase
  Future<void> _updateQuoteInFirebase(SharedQuote quote) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'shared_quotes',
        documentId: quote.id,
        data: quote.toMap(),
      );
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error updating quote in Firebase: $e');
    }
  }

  /// Delete quote from Firebase
  Future<void> _deleteQuoteFromFirebase(String quoteId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'shared_quotes',
        documentId: quoteId,
      );
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error deleting quote from Firebase: $e');
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _notesKey);
      await _hiveService.delete(_boxName, _quotesKey);
      developer.log('✅ [LoveNotesService] All data cleared');
    } catch (e) {
      developer.log('❌ [LoveNotesService] Error clearing data: $e');
    }
  }
}

/// Love note type extensions
extension LoveNoteTypeExtension on LoveNoteType {
  String get emoji {
    switch (this) {
      case LoveNoteType.text:
        return '💌';
      case LoveNoteType.photo:
        return '📸';
      case LoveNoteType.audio:
        return '🎵';
      case LoveNoteType.quote:
        return '💭';
      case LoveNoteType.memory:
        return '💝';
      case LoveNoteType.promise:
        return '🤝';
      case LoveNoteType.apology:
        return '🙏';
      case LoveNoteType.surprise:
        return '🎁';
      case LoveNoteType.encouragement:
        return '💪';
      case LoveNoteType.gratitude:
        return '🙏';
    }
  }

  String get displayName {
    switch (this) {
      case LoveNoteType.text:
        return 'Text Note';
      case LoveNoteType.photo:
        return 'Photo Note';
      case LoveNoteType.audio:
        return 'Audio Note';
      case LoveNoteType.quote:
        return 'Quote';
      case LoveNoteType.memory:
        return 'Memory';
      case LoveNoteType.promise:
        return 'Promise';
      case LoveNoteType.apology:
        return 'Apology';
      case LoveNoteType.surprise:
        return 'Surprise';
      case LoveNoteType.encouragement:
        return 'Encouragement';
      case LoveNoteType.gratitude:
        return 'Gratitude';
    }
  }

  String get color {
    switch (this) {
      case LoveNoteType.text:
        return '#E91E63';
      case LoveNoteType.photo:
        return '#9C27B0';
      case LoveNoteType.audio:
        return '#673AB7';
      case LoveNoteType.quote:
        return '#3F51B5';
      case LoveNoteType.memory:
        return '#2196F3';
      case LoveNoteType.promise:
        return '#00BCD4';
      case LoveNoteType.apology:
        return '#009688';
      case LoveNoteType.surprise:
        return '#4CAF50';
      case LoveNoteType.encouragement:
        return '#8BC34A';
      case LoveNoteType.gratitude:
        return '#CDDC39';
    }
  }
}
