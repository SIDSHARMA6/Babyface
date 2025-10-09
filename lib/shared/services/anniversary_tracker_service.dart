import 'dart:io';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/anniversary_event.dart';
import 'hive_service.dart';
import 'firebase_service.dart';

/// Service to manage anniversary events with SharedPreferences and Firebase
class AnniversaryTrackerService {
  static const String _eventsKey = 'anniversary_events';
  static const String _notificationsEnabledKey =
      'anniversary_notifications_enabled';

  static AnniversaryTrackerService? _instance;
  static AnniversaryTrackerService get instance =>
      _instance ??= AnniversaryTrackerService._();

  AnniversaryTrackerService._();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();

  /// Get all anniversary events
  Future<List<AnniversaryEvent>> getAllEvents() async {
    try {
      // Ensure box is open before accessing
      await _hiveService.ensureBoxOpen('anniversary_box');

      if (!_hiveService.isBoxOpen('anniversary_box')) {
        developer.log(
            '🔐 [AnniversaryTrackerService] Box not open, returning empty list');
        return [];
      }

      final eventsJson = _hiveService.retrieve('anniversary_box', _eventsKey)
          as List<dynamic>?;
      if (eventsJson == null) return [];

      return eventsJson
          .map(
              (json) => AnniversaryEvent.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      developer.log('Error getting anniversary events: $e');
      return [];
    }
  }

  /// Add new anniversary event
  Future<bool> addEvent(AnniversaryEvent event) async {
    try {
      // Ensure box is open before accessing
      await _hiveService.ensureBoxOpen('anniversary_box');

      if (!_hiveService.isBoxOpen('anniversary_box')) {
        developer.log(
            '🔐 [AnniversaryTrackerService] Box not open, cannot add event');
        return false;
      }

      final events = await getAllEvents();
      events.add(event);

      final eventsJson = events.map((e) => e.toJson()).toList();
      await _hiveService.store('anniversary_box', _eventsKey, eventsJson);

      // Also save to Firebase
      await _saveToFirebase(event);

      return true;
    } catch (e) {
      developer.log('Error adding anniversary event: $e');
      return false;
    }
  }

  /// Update existing anniversary event
  Future<bool> updateEvent(AnniversaryEvent event) async {
    try {
      final events = await getAllEvents();
      final index = events.indexWhere((e) => e.id == event.id);

      if (index == -1) return false;

      events[index] = event;

      final eventsJson = events.map((e) => e.toJson()).toList();
      await _hiveService.store('anniversary_box', _eventsKey, eventsJson);

      // Also update in Firebase
      await _updateInFirebase(event);

      return true;
    } catch (e) {
      developer.log('Error updating anniversary event: $e');
      return false;
    }
  }

  /// Delete anniversary event
  Future<bool> deleteEvent(String eventId) async {
    try {
      final events = await getAllEvents();
      events.removeWhere((e) => e.id == eventId);

      final eventsJson = events.map((e) => e.toJson()).toList();
      await _hiveService.store('anniversary_box', _eventsKey, eventsJson);

      // Also delete from Firebase
      await _deleteFromFirebase(eventId);

      return true;
    } catch (e) {
      developer.log('Error deleting anniversary event: $e');
      return false;
    }
  }

  /// Get nearest upcoming event
  Future<AnniversaryEvent?> getNearestEvent() async {
    try {
      final events = await getAllEvents();
      final now = DateTime.now();

      // Filter events that haven't passed this year
      final upcomingEvents = events.where((event) {
        final eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);
        final today = DateTime(now.year, now.month, now.day);
        return eventDate.isAfter(today) || eventDate.isAtSameMomentAs(today);
      }).toList();

      if (upcomingEvents.isEmpty) return null;

      // Sort by days until event
      upcomingEvents.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

      return upcomingEvents.first;
    } catch (e) {
      developer.log('Error getting nearest event: $e');
      return null;
    }
  }

  /// Get events for specific date
  Future<List<AnniversaryEvent>> getEventsForDate(DateTime date) async {
    try {
      final events = await getAllEvents();
      return events.where((event) {
        return event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day;
      }).toList();
    } catch (e) {
      developer.log('Error getting events for date: $e');
      return [];
    }
  }

  /// Get total count of events
  Future<int> getTotalEventCount() async {
    try {
      final events = await getAllEvents();
      return events.length;
    } catch (e) {
      developer.log('Error getting total event count: $e');
      return 0;
    }
  }

  /// Save event image and return path
  Future<String?> saveEventImage(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final eventsDir = Directory('${appDir.path}/anniversary_events');

      // Create directory if it doesn't exist
      if (!await eventsDir.exists()) {
        await eventsDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'event_image_$timestamp.jpg';
      final savedFile = File('${eventsDir.path}/$fileName');

      // Copy the image file
      await imageFile.copy(savedFile.path);

      return savedFile.path;
    } catch (e) {
      developer.log('Error saving event image: $e');
      return null;
    }
  }

  /// Set notification preferences
  Future<bool> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      developer.log('Error setting notification preferences: $e');
      return false;
    }
  }

  /// Get notification preferences
  Future<bool> getNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      developer.log('Error getting notification preferences: $e');
      return true;
    }
  }

  /// Sync all events from Firebase to local storage
  Future<void> syncAllEventsFromFirebase() async {
    try {
      if (!_firebaseService.isInitialized) {
        developer.log('Firebase not initialized, skipping sync');
        return;
      }

      // Ensure box is open
      await _hiveService.ensureBoxOpen('anniversary_box');
      if (!_hiveService.isBoxOpen('anniversary_box')) {
        developer.log('Box not open, cannot sync');
        return;
      }

      // Get data from Firebase
      final firebaseEvents = await _firebaseService.getAllFromFirestore(
        collection: 'anniversary_events',
      );

      if (firebaseEvents.isNotEmpty) {
        final events = firebaseEvents
            .map((data) => AnniversaryEvent.fromJson(data))
            .toList();

        // Save to local storage
        await _hiveService.store('anniversary_box', _eventsKey,
            events.map((e) => e.toJson()).toList());

        developer
            .log('✅ Synced ${events.length} anniversary events from Firebase');
      }
    } catch (e) {
      developer.log('❌ Error syncing anniversary events from Firebase: $e');
    }
  }

  /// Save to Firebase (real implementation)
  Future<void> _saveToFirebase(AnniversaryEvent event) async {
    try {
      if (!_firebaseService.isInitialized) {
        developer
            .log('Firebase not initialized, skipping anniversary event save');
        return;
      }

      final eventData = {
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'date': event.date.toIso8601String(),
        'photoPath': event.photoPath,
        'isRecurring': event.isRecurring,
        'recurringType': event.recurringType.name,
        'customEventName': event.customEventName,
        'createdAt': event.createdAt.toIso8601String(),
        'updatedAt': event.updatedAt.toIso8601String(),
      };

      await _firebaseService.saveToFirestore(
        collection: 'anniversary_events',
        documentId: event.id,
        data: eventData,
      );

      developer.log('✅ Anniversary event saved to Firebase: ${event.title}');
    } catch (e) {
      developer.log('❌ Error saving anniversary event to Firebase: $e');
      // Don't rethrow - allow local storage to continue
    }
  }

  /// Update in Firebase (real implementation)
  Future<void> _updateInFirebase(AnniversaryEvent event) async {
    try {
      if (!_firebaseService.isInitialized) {
        developer
            .log('Firebase not initialized, skipping anniversary event update');
        return;
      }

      final eventData = {
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'date': event.date.toIso8601String(),
        'photoPath': event.photoPath,
        'isRecurring': event.isRecurring,
        'recurringType': event.recurringType.name,
        'customEventName': event.customEventName,
        'updatedAt': event.updatedAt.toIso8601String(),
      };

      await _firebaseService.saveToFirestore(
        collection: 'anniversary_events',
        documentId: event.id,
        data: eventData,
      );

      developer.log('✅ Anniversary event updated in Firebase: ${event.title}');
    } catch (e) {
      developer.log('❌ Error updating anniversary event in Firebase: $e');
      // Don't rethrow - allow local storage to continue
    }
  }

  /// Delete from Firebase (real implementation)
  Future<void> _deleteFromFirebase(String eventId) async {
    try {
      if (!_firebaseService.isInitialized) {
        developer
            .log('Firebase not initialized, skipping anniversary event delete');
        return;
      }

      await _firebaseService.deleteFromFirestore(
        collection: 'anniversary_events',
        documentId: eventId,
      );

      developer.log('✅ Anniversary event deleted from Firebase: $eventId');
    } catch (e) {
      developer.log('❌ Error deleting anniversary event from Firebase: $e');
      // Don't rethrow - allow local storage to continue
    }
  }

  /// Get predefined event types
  static List<String> getPredefinedEventTypes() {
    return [
      'Anniversary',
      'Birthday',
      'First Date',
      'Engagement',
      'Wedding',
      'Valentine\'s Day',
      'Christmas',
      'New Year',
      'Custom',
    ];
  }
}
