import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

/// Bucket list item model
class BucketListItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final int priority;
  final DateTime? targetDate;
  final DateTime? completedDate;
  final String? location;
  final double? estimatedCost;
  final List<String>? tags;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BucketListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    this.targetDate,
    this.completedDate,
    this.location,
    this.estimatedCost,
    this.tags,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'priority': priority,
      'targetDate': targetDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'location': location,
      'estimatedCost': estimatedCost,
      'tags': tags,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BucketListItem.fromMap(Map<String, dynamic> map) {
    return BucketListItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'travel',
      status: map['status'] ?? 'planned',
      priority: map['priority'] ?? 1,
      targetDate:
          map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
      completedDate: map['completedDate'] != null
          ? DateTime.parse(map['completedDate'])
          : null,
      location: map['location'],
      estimatedCost: map['estimatedCost']?.toDouble(),
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      notes: map['notes'],
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Service for managing bucket list items
class BucketListService {
  static final BucketListService _instance = BucketListService._internal();
  factory BucketListService() => _instance;
  BucketListService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'bucket_list_box';
  static const String _itemsKey = 'bucket_list_items';

  /// Get bucket list service instance
  static BucketListService get instance => _instance;

  /// Get all bucket list items
  Future<List<BucketListItem>> getAllBucketListItems() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _itemsKey);

      if (data != null) {
        return (data as List)
            .map((item) =>
                BucketListItem.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [BucketListService] Error getting bucket list items: $e');
      return [];
    }
  }

  /// Add bucket list item
  Future<bool> addBucketListItem(BucketListItem item) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final items = await getAllBucketListItems();
      items.add(item);

      await _hiveService.store(
          _boxName, _itemsKey, items.map((i) => i.toMap()).toList());

      // Sync to Firebase
      await _saveToFirebase(item);

      developer.log('✅ [BucketListService] Bucket list item added: ${item.title}');
      return true;
    } catch (e) {
      developer.log('❌ [BucketListService] Error adding bucket list item: $e');
      return false;
    }
  }

  /// Update bucket list item
  Future<bool> updateBucketListItem(BucketListItem item) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final items = await getAllBucketListItems();
      final index = items.indexWhere((i) => i.id == item.id);

      if (index != -1) {
        items[index] = item;
        await _hiveService.store(
            _boxName, _itemsKey, items.map((i) => i.toMap()).toList());

        // Sync to Firebase
        await _updateInFirebase(item);

        developer.log('✅ [BucketListService] Bucket list item updated: ${item.title}');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [BucketListService] Error updating bucket list item: $e');
      return false;
    }
  }

  /// Delete bucket list item
  Future<bool> deleteBucketListItem(String itemId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final items = await getAllBucketListItems();
      items.removeWhere((item) => item.id == itemId);

      await _hiveService.store(
          _boxName, _itemsKey, items.map((i) => i.toMap()).toList());

      // Sync to Firebase
      await _deleteFromFirebase(itemId);

      developer.log('✅ [BucketListService] Bucket list item deleted: $itemId');
      return true;
    } catch (e) {
      developer.log('❌ [BucketListService] Error deleting bucket list item: $e');
      return false;
    }
  }

  /// Save item to Firebase
  Future<void> _saveToFirebase(BucketListItem item) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'bucket_list_items',
        documentId: item.id,
        data: item.toMap(),
      );
    } catch (e) {
      developer.log('❌ [BucketListService] Error saving to Firebase: $e');
    }
  }

  /// Update item in Firebase
  Future<void> _updateInFirebase(BucketListItem item) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'bucket_list_items',
        documentId: item.id,
        data: item.toMap(),
      );
    } catch (e) {
      developer.log('❌ [BucketListService] Error updating in Firebase: $e');
    }
  }

  /// Delete item from Firebase
  Future<void> _deleteFromFirebase(String itemId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'bucket_list_items',
        documentId: itemId,
      );
    } catch (e) {
      developer.log('❌ [BucketListService] Error deleting from Firebase: $e');
    }
  }

  /// Clear all bucket list items
  Future<void> clearAllItems() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _itemsKey);
      developer.log('✅ [BucketListService] All bucket list items cleared');
    } catch (e) {
      developer.log('❌ [BucketListService] Error clearing items: $e');
    }
  }
}
