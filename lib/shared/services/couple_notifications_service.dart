import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'hive_service.dart';
import 'firebase_service.dart';

/// Notification model
class CoupleNotification {
  final String id;
  final String userId;
  final String partnerId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;

  CoupleNotification({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'data': data,
    };
  }

  factory CoupleNotification.fromMap(Map<String, dynamic> map) {
    return CoupleNotification(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.general,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      isRead: map['isRead'] ?? false,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
    );
  }

  CoupleNotification copyWith({
    String? id,
    String? userId,
    String? partnerId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
  }) {
    return CoupleNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
    );
  }
}

/// Notification types
enum NotificationType {
  loveNote,
  moodUpdate,
  anniversary,
  achievement,
  memory,
  gesture,
  journal,
  photo,
  general,
}

/// Notification priority
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// Couple notifications service
class CoupleNotificationsService {
  static final CoupleNotificationsService _instance =
      CoupleNotificationsService._internal();
  factory CoupleNotificationsService() => _instance;
  CoupleNotificationsService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'couple_notifications_box';
  static const String _notificationsKey = 'couple_notifications';

  final List<VoidCallback> _listeners = [];
  Timer? _syncTimer;

  /// Get couple notifications service instance
  static CoupleNotificationsService get instance => _instance;

  /// Initialize service
  void initialize() {
    _startSyncTimer();
  }

  /// Add notification listener
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove notification listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        developer.log('❌ [CoupleNotificationsService] Error notifying listener: $e');
      }
    }
  }

  /// Send notification
  Future<bool> sendNotification(CoupleNotification notification) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final notifications = await getAllNotifications();
      notifications.add(notification);

      await _hiveService.store(_boxName, _notificationsKey,
          notifications.map((n) => n.toMap()).toList());

      // Sync to Firebase
      await _saveNotificationToFirebase(notification);

      // Notify listeners
      _notifyListeners();

      developer.log(
          '✅ [CoupleNotificationsService] Notification sent: ${notification.id}');
      return true;
    } catch (e) {
      developer.log('❌ [CoupleNotificationsService] Error sending notification: $e');
      return false;
    }
  }

  /// Get all notifications
  Future<List<CoupleNotification>> getAllNotifications() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _notificationsKey);

      if (data != null) {
        return (data as List)
            .map((item) =>
                CoupleNotification.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [CoupleNotificationsService] Error getting notifications: $e');
      return [];
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getAllNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      developer.log('❌ [CoupleNotificationsService] Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final notifications = await getAllNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);

      if (index != -1) {
        notifications[index] = notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );

        await _hiveService.store(_boxName, _notificationsKey,
            notifications.map((n) => n.toMap()).toList());

        // Sync to Firebase
        await _updateNotificationInFirebase(notifications[index]);

        // Notify listeners
        _notifyListeners();

        return true;
      }

      return false;
    } catch (e) {
      developer.log(
          '❌ [CoupleNotificationsService] Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final notifications = await getAllNotifications();
      final updatedNotifications = notifications
          .map((n) => n.copyWith(
                isRead: true,
                readAt: DateTime.now(),
              ))
          .toList();

      await _hiveService.store(_boxName, _notificationsKey,
          updatedNotifications.map((n) => n.toMap()).toList());

      // Sync to Firebase
      for (final notification in updatedNotifications) {
        await _updateNotificationInFirebase(notification);
      }

      // Notify listeners
      _notifyListeners();

      return true;
    } catch (e) {
      developer.log(
          '❌ [CoupleNotificationsService] Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final notifications = await getAllNotifications();
      notifications.removeWhere((n) => n.id == notificationId);

      await _hiveService.store(_boxName, _notificationsKey,
          notifications.map((n) => n.toMap()).toList());

      // Sync to Firebase
      await _deleteNotificationFromFirebase(notificationId);

      // Notify listeners
      _notifyListeners();

      return true;
    } catch (e) {
      developer.log('❌ [CoupleNotificationsService] Error deleting notification: $e');
      return false;
    }
  }

  /// Create love note notification
  Future<bool> createLoveNoteNotification(
      String userId, String partnerId, String noteContent) async {
    final notification = CoupleNotification(
      id: 'love_note_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      partnerId: partnerId,
      title: 'New Love Note',
      message: noteContent,
      type: NotificationType.loveNote,
      priority: NotificationPriority.high,
      isRead: false,
      createdAt: DateTime.now(),
    );

    return await sendNotification(notification);
  }

  /// Create mood update notification
  Future<bool> createMoodUpdateNotification(
      String userId, String partnerId, String mood) async {
    final notification = CoupleNotification(
      id: 'mood_update_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      partnerId: partnerId,
      title: 'Mood Update',
      message: 'Your partner is feeling $mood today',
      type: NotificationType.moodUpdate,
      priority: NotificationPriority.normal,
      isRead: false,
      createdAt: DateTime.now(),
    );

    return await sendNotification(notification);
  }

  /// Create achievement notification
  Future<bool> createAchievementNotification(
      String userId, String partnerId, String achievement) async {
    final notification = CoupleNotification(
      id: 'achievement_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      partnerId: partnerId,
      title: 'New Achievement!',
      message: 'Your partner unlocked: $achievement',
      type: NotificationType.achievement,
      priority: NotificationPriority.high,
      isRead: false,
      createdAt: DateTime.now(),
    );

    return await sendNotification(notification);
  }

  /// Create gesture reaction notification
  Future<bool> createGestureNotification(
      String userId, String partnerId, String gestureType) async {
    final notification = CoupleNotification(
      id: 'gesture_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      partnerId: partnerId,
      title: 'Love Gesture',
      message: 'Your partner drew a $gestureType for you!',
      type: NotificationType.gesture,
      priority: NotificationPriority.high,
      isRead: false,
      createdAt: DateTime.now(),
    );

    return await sendNotification(notification);
  }

  /// Start sync timer
  void _startSyncTimer() {
    _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _syncNotifications();
    });
  }

  /// Sync notifications with Firebase
  Future<void> _syncNotifications() async {
    try {
      final notifications = await getAllNotifications();
      for (final notification in notifications) {
        await _saveNotificationToFirebase(notification);
      }
    } catch (e) {
      developer.log('❌ [CoupleNotificationsService] Error syncing notifications: $e');
    }
  }

  /// Save notification to Firebase
  Future<void> _saveNotificationToFirebase(
      CoupleNotification notification) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'couple_notifications',
        documentId: notification.id,
        data: notification.toMap(),
      );
    } catch (e) {
      developer.log(
          '❌ [CoupleNotificationsService] Error saving notification to Firebase: $e');
    }
  }

  /// Update notification in Firebase
  Future<void> _updateNotificationInFirebase(
      CoupleNotification notification) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'couple_notifications',
        documentId: notification.id,
        data: notification.toMap(),
      );
    } catch (e) {
      developer.log(
          '❌ [CoupleNotificationsService] Error updating notification in Firebase: $e');
    }
  }

  /// Delete notification from Firebase
  Future<void> _deleteNotificationFromFirebase(String notificationId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'couple_notifications',
        documentId: notificationId,
      );
    } catch (e) {
      developer.log(
          '❌ [CoupleNotificationsService] Error deleting notification from Firebase: $e');
    }
  }

  /// Dispose service
  void dispose() {
    _syncTimer?.cancel();
    _listeners.clear();
  }
}
