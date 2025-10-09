import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';
import '../models/profile_section.dart';

/// Service for managing dynamic profile sections
class DynamicProfileService {
  static final DynamicProfileService _instance = DynamicProfileService._internal();
  factory DynamicProfileService() => _instance;
  DynamicProfileService._internal();

  static DynamicProfileService get instance => _instance;

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();

  /// Get all profile sections
  Future<List<ProfileSection>> getAllSections() async {
    try {
      final sections = await _hiveService.retrieve('profile_sections', 'sections');
      if (sections != null && sections is List) {
        return sections
            .map((item) => ProfileSection.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }
      return await _createDefaultSections();
    } catch (e) {
      developer.log('Error getting all sections: $e');
      return await _createDefaultSections();
    }
  }

  /// Get enabled profile sections only
  Future<List<ProfileSection>> getEnabledSections() async {
    final allSections = await getAllSections();
    return allSections.where((section) => section.isEnabled).toList();
  }

  /// Add a new profile section
  Future<bool> addSection(ProfileSection section) async {
    try {
      final sections = await getAllSections();
      sections.add(section);
      
      await _hiveService.store('profile_sections', 'sections', 
          sections.map((s) => s.toMap()).toList());
      
      await _saveToFirebase(section);
      return true;
    } catch (e) {
      developer.log('Error adding section: $e');
      return false;
    }
  }

  /// Update an existing profile section
  Future<bool> updateSection(ProfileSection section) async {
    try {
      final sections = await getAllSections();
      final index = sections.indexWhere((s) => s.id == section.id);
      
      if (index != -1) {
        sections[index] = section;
        await _hiveService.store('profile_sections', 'sections', 
            sections.map((s) => s.toMap()).toList());
        
        await _updateInFirebase(section);
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error updating section: $e');
      return false;
    }
  }

  /// Delete a profile section
  Future<bool> deleteSection(String sectionId) async {
    try {
      final sections = await getAllSections();
      sections.removeWhere((section) => section.id == sectionId);
      
      await _hiveService.store('profile_sections', 'sections', 
          sections.map((s) => s.toMap()).toList());
      
      return true;
    } catch (e) {
      developer.log('Error deleting section: $e');
      return false;
    }
  }

  /// Toggle section enabled state
  Future<bool> toggleSection(String sectionId) async {
    try {
      final sections = await getAllSections();
      final index = sections.indexWhere((s) => s.id == sectionId);
      
      if (index != -1) {
        final section = sections[index];
        final updatedSection = section.copyWith(
          isEnabled: !section.isEnabled,
          updatedAt: DateTime.now(),
        );
        
        sections[index] = updatedSection;
        await _hiveService.store('profile_sections', 'sections', 
            sections.map((s) => s.toMap()).toList());
        
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error toggling section: $e');
      return false;
    }
  }

  /// Create default profile sections
  Future<List<ProfileSection>> _createDefaultSections() async {
    final defaultSections = [
      ProfileSection(
        id: 'mood_tracker',
        title: 'Mood Tracker',
        description: 'Track your daily moods and emotions',
        icon: 'mood',
        emoji: '😊',
        type: ProfileSectionType.moodTracker,
        data: {'enabled': true, 'color': '#FF6B9D'},
        isEnabled: true,
        order: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProfileSection(
        id: 'love_notes',
        title: 'Love Notes',
        description: 'Share sweet messages with your partner',
        icon: 'note',
        emoji: '💕',
        type: ProfileSectionType.loveNotes,
        data: {'enabled': true, 'color': '#FF6B9D'},
        isEnabled: true,
        order: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProfileSection(
        id: 'couple_gallery',
        title: 'Couple Gallery',
        description: 'Store your precious memories together',
        icon: 'photo_library',
        emoji: '📸',
        type: ProfileSectionType.coupleGallery,
        data: {'enabled': true, 'color': '#FF6B9D'},
        isEnabled: true,
        order: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProfileSection(
        id: 'zodiac_compatibility',
        title: 'Zodiac Compatibility',
        description: 'Discover your astrological compatibility',
        icon: 'star',
        emoji: '⭐',
        type: ProfileSectionType.zodiacCompatibility,
        data: {'enabled': true, 'color': '#FF6B9D'},
        isEnabled: true,
        order: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProfileSection(
        id: 'favorite_moments',
        title: 'Favorite Moments',
        description: 'Relive your most cherished memories',
        icon: 'favorite',
        emoji: '💖',
        type: ProfileSectionType.favoriteMoments,
        data: {'enabled': true, 'color': '#FF6B9D'},
        isEnabled: true,
        order: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProfileSection(
        id: 'bond_level',
        title: 'Bond Level',
        description: 'Track your relationship progress',
        icon: 'trending_up',
        emoji: '📈',
        type: ProfileSectionType.bondLevel,
        data: {'enabled': true, 'color': '#FF6B9D'},
        isEnabled: true,
        order: 6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await _hiveService.store('profile_sections', 'sections', 
        defaultSections.map((s) => s.toMap()).toList());
    
    return defaultSections;
  }

  /// Save section to Firebase
  Future<void> _saveToFirebase(ProfileSection section) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'profile_sections',
        documentId: section.id,
        data: section.toMap(),
      );
    } catch (e) {
      developer.log('Error saving to Firebase: $e');
    }
  }

  /// Update section in Firebase
  Future<void> _updateInFirebase(ProfileSection section) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'profile_sections',
        documentId: section.id,
        data: section.toMap(),
      );
    } catch (e) {
      developer.log('Error updating in Firebase: $e');
    }
  }
}
