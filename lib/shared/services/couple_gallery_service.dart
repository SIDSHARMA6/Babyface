import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

/// Couple photo model
class CouplePhoto {
  final String id;
  final String title;
  final String? description;
  final String photoPath;
  final String? thumbnailPath;
  final List<String> tags;
  final bool isFavorite;
  final bool isPrivate;
  final DateTime takenAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  CouplePhoto({
    required this.id,
    required this.title,
    this.description,
    required this.photoPath,
    this.thumbnailPath,
    required this.tags,
    required this.isFavorite,
    required this.isPrivate,
    required this.takenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photoPath': photoPath,
      'thumbnailPath': thumbnailPath,
      'tags': tags,
      'isFavorite': isFavorite,
      'isPrivate': isPrivate,
      'takenAt': takenAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CouplePhoto.fromMap(Map<String, dynamic> map) {
    return CouplePhoto(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      photoPath: map['photoPath'] ?? '',
      thumbnailPath: map['thumbnailPath'],
      tags: List<String>.from(map['tags'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
      isPrivate: map['isPrivate'] ?? false,
      takenAt:
          DateTime.parse(map['takenAt'] ?? DateTime.now().toIso8601String()),
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  CouplePhoto copyWith({
    String? id,
    String? title,
    String? description,
    String? photoPath,
    String? thumbnailPath,
    List<String>? tags,
    bool? isFavorite,
    bool? isPrivate,
    DateTime? takenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CouplePhoto(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isPrivate: isPrivate ?? this.isPrivate,
      takenAt: takenAt ?? this.takenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Photo collage model
class PhotoCollage {
  final String id;
  final String title;
  final String? description;
  final List<String> photoIds;
  final String collagePath;
  final CollageLayout layout;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  PhotoCollage({
    required this.id,
    required this.title,
    this.description,
    required this.photoIds,
    required this.collagePath,
    required this.layout,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photoIds': photoIds,
      'collagePath': collagePath,
      'layout': layout.name,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PhotoCollage.fromMap(Map<String, dynamic> map) {
    return PhotoCollage(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      photoIds: List<String>.from(map['photoIds'] ?? []),
      collagePath: map['collagePath'] ?? '',
      layout: CollageLayout.values.firstWhere(
        (e) => e.name == map['layout'],
        orElse: () => CollageLayout.grid2x2,
      ),
      isFavorite: map['isFavorite'] ?? false,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  PhotoCollage copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? photoIds,
    String? collagePath,
    CollageLayout? layout,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotoCollage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      photoIds: photoIds ?? this.photoIds,
      collagePath: collagePath ?? this.collagePath,
      layout: layout ?? this.layout,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Collage layout types
enum CollageLayout {
  grid2x2,
  grid3x3,
  heart,
  circle,
  timeline,
  mosaic,
  polaroid,
  instagram,
}

/// Couple gallery service
class CoupleGalleryService {
  static final CoupleGalleryService _instance =
      CoupleGalleryService._internal();
  factory CoupleGalleryService() => _instance;
  CoupleGalleryService._internal();

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();
  static const String _boxName = 'couple_gallery_box';
  static const String _photosKey = 'couple_photos';
  static const String _collagesKey = 'photo_collages';

  /// Get couple gallery service instance
  static CoupleGalleryService get instance => _instance;

  /// Add couple photo
  Future<bool> addCouplePhoto(CouplePhoto photo) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final photos = await getAllPhotos();
      photos.add(photo);

      await _hiveService.store(
          _boxName, _photosKey, photos.map((p) => p.toMap()).toList());

      // Sync to Firebase
      await _savePhotoToFirebase(photo);

      developer.log('✅ [CoupleGalleryService] Photo added: ${photo.id}');
      return true;
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error adding photo: $e');
      return false;
    }
  }

  /// Get all photos
  Future<List<CouplePhoto>> getAllPhotos() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _photosKey);

      if (data != null) {
        return (data as List)
            .map((item) => CouplePhoto.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error getting photos: $e');
      return [];
    }
  }

  /// Get favorite photos
  Future<List<CouplePhoto>> getFavoritePhotos() async {
    try {
      final photos = await getAllPhotos();
      return photos.where((photo) => photo.isFavorite).toList();
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error getting favorite photos: $e');
      return [];
    }
  }

  /// Get photos by tag
  Future<List<CouplePhoto>> getPhotosByTag(String tag) async {
    try {
      final photos = await getAllPhotos();
      return photos.where((photo) => photo.tags.contains(tag)).toList();
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error getting photos by tag: $e');
      return [];
    }
  }

  /// Get photos by date range
  Future<List<CouplePhoto>> getPhotosByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final photos = await getAllPhotos();
      return photos.where((photo) {
        return photo.takenAt.isAfter(startDate) &&
            photo.takenAt.isBefore(endDate);
      }).toList();
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error getting photos by date range: $e');
      return [];
    }
  }

  /// Toggle photo favorite status
  Future<bool> togglePhotoFavorite(String photoId) async {
    try {
      final photos = await getAllPhotos();
      final index = photos.indexWhere((photo) => photo.id == photoId);

      if (index != -1) {
        photos[index] = photos[index].copyWith(
          isFavorite: !photos[index].isFavorite,
          updatedAt: DateTime.now(),
        );

        await _hiveService.store(
            _boxName, _photosKey, photos.map((p) => p.toMap()).toList());

        // Sync to Firebase
        await _updatePhotoInFirebase(photos[index]);

        developer.log('✅ [CoupleGalleryService] Photo favorite toggled: $photoId');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error toggling photo favorite: $e');
      return false;
    }
  }

  /// Update photo
  Future<bool> updatePhoto(CouplePhoto photo) async {
    try {
      final photos = await getAllPhotos();
      final index = photos.indexWhere((p) => p.id == photo.id);

      if (index != -1) {
        photos[index] = photo;
        await _hiveService.store(
            _boxName, _photosKey, photos.map((p) => p.toMap()).toList());

        // Sync to Firebase
        await _updatePhotoInFirebase(photo);

        developer.log('✅ [CoupleGalleryService] Photo updated: ${photo.id}');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error updating photo: $e');
      return false;
    }
  }

  /// Delete photo
  Future<bool> deletePhoto(String photoId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final photos = await getAllPhotos();
      photos.removeWhere((photo) => photo.id == photoId);

      await _hiveService.store(
          _boxName, _photosKey, photos.map((p) => p.toMap()).toList());

      // Sync to Firebase
      await _deletePhotoFromFirebase(photoId);

      developer.log('✅ [CoupleGalleryService] Photo deleted: $photoId');
      return true;
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error deleting photo: $e');
      return false;
    }
  }

  /// Add photo collage
  Future<bool> addPhotoCollage(PhotoCollage collage) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final collages = await getAllCollages();
      collages.add(collage);

      await _hiveService.store(
          _boxName, _collagesKey, collages.map((c) => c.toMap()).toList());

      // Sync to Firebase
      await _saveCollageToFirebase(collage);

      developer.log('✅ [CoupleGalleryService] Collage added: ${collage.id}');
      return true;
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error adding collage: $e');
      return false;
    }
  }

  /// Get all collages
  Future<List<PhotoCollage>> getAllCollages() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final data = _hiveService.retrieve(_boxName, _collagesKey);

      if (data != null) {
        return (data as List)
            .map(
                (item) => PhotoCollage.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error getting collages: $e');
      return [];
    }
  }

  /// Get favorite collages
  Future<List<PhotoCollage>> getFavoriteCollages() async {
    try {
      final collages = await getAllCollages();
      return collages.where((collage) => collage.isFavorite).toList();
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error getting favorite collages: $e');
      return [];
    }
  }

  /// Toggle collage favorite status
  Future<bool> toggleCollageFavorite(String collageId) async {
    try {
      final collages = await getAllCollages();
      final index = collages.indexWhere((collage) => collage.id == collageId);

      if (index != -1) {
        collages[index] = collages[index].copyWith(
          isFavorite: !collages[index].isFavorite,
          updatedAt: DateTime.now(),
        );

        await _hiveService.store(
            _boxName, _collagesKey, collages.map((c) => c.toMap()).toList());

        // Sync to Firebase
        await _updateCollageInFirebase(collages[index]);

        developer.log('✅ [CoupleGalleryService] Collage favorite toggled: $collageId');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error toggling collage favorite: $e');
      return false;
    }
  }

  /// Delete collage
  Future<bool> deleteCollage(String collageId) async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      final collages = await getAllCollages();
      collages.removeWhere((collage) => collage.id == collageId);

      await _hiveService.store(
          _boxName, _collagesKey, collages.map((c) => c.toMap()).toList());

      // Sync to Firebase
      await _deleteCollageFromFirebase(collageId);

      developer.log('✅ [CoupleGalleryService] Collage deleted: $collageId');
      return true;
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error deleting collage: $e');
      return false;
    }
  }

  /// Get gallery statistics
  Future<Map<String, dynamic>> getGalleryStatistics() async {
    try {
      final photos = await getAllPhotos();
      final collages = await getAllCollages();

      if (photos.isEmpty && collages.isEmpty) {
        return {
          'totalPhotos': 0,
          'totalCollages': 0,
          'favoritePhotos': 0,
          'favoriteCollages': 0,
          'photosByMonth': {},
          'recentPhotos': [],
          'mostUsedTags': [],
        };
      }

      // Calculate statistics
      final totalPhotos = photos.length;
      final totalCollages = collages.length;
      final favoritePhotos = photos.where((photo) => photo.isFavorite).length;
      final favoriteCollages =
          collages.where((collage) => collage.isFavorite).length;

      // Photos by month
      final photosByMonth = <String, int>{};
      for (final photo in photos) {
        final monthKey =
            '${photo.takenAt.year}-${photo.takenAt.month.toString().padLeft(2, '0')}';
        photosByMonth[monthKey] = (photosByMonth[monthKey] ?? 0) + 1;
      }

      // Recent photos (last 10)
      final recentPhotos = photos
          .take(10)
          .map((photo) => {
                'id': photo.id,
                'title': photo.title,
                'takenAt': photo.takenAt.toIso8601String(),
                'isFavorite': photo.isFavorite,
              })
          .toList();

      // Most used tags
      final tagCounts = <String, int>{};
      for (final photo in photos) {
        for (final tag in photo.tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
      final mostUsedTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return {
        'totalPhotos': totalPhotos,
        'totalCollages': totalCollages,
        'favoritePhotos': favoritePhotos,
        'favoriteCollages': favoriteCollages,
        'photosByMonth': photosByMonth,
        'recentPhotos': recentPhotos,
        'mostUsedTags': mostUsedTags.take(5).map((e) => e.key).toList(),
      };
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error getting statistics: $e');
      return {
        'totalPhotos': 0,
        'totalCollages': 0,
        'favoritePhotos': 0,
        'favoriteCollages': 0,
        'photosByMonth': {},
        'recentPhotos': [],
        'mostUsedTags': [],
      };
    }
  }

  /// Save photo to Firebase
  Future<void> _savePhotoToFirebase(CouplePhoto photo) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'couple_photos',
        documentId: photo.id,
        data: photo.toMap(),
      );
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error saving photo to Firebase: $e');
    }
  }

  /// Update photo in Firebase
  Future<void> _updatePhotoInFirebase(CouplePhoto photo) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'couple_photos',
        documentId: photo.id,
        data: photo.toMap(),
      );
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error updating photo in Firebase: $e');
    }
  }

  /// Delete photo from Firebase
  Future<void> _deletePhotoFromFirebase(String photoId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'couple_photos',
        documentId: photoId,
      );
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error deleting photo from Firebase: $e');
    }
  }

  /// Save collage to Firebase
  Future<void> _saveCollageToFirebase(PhotoCollage collage) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'photo_collages',
        documentId: collage.id,
        data: collage.toMap(),
      );
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error saving collage to Firebase: $e');
    }
  }

  /// Update collage in Firebase
  Future<void> _updateCollageInFirebase(PhotoCollage collage) async {
    try {
      await _firebaseService.updateFirestore(
        collection: 'photo_collages',
        documentId: collage.id,
        data: collage.toMap(),
      );
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error updating collage in Firebase: $e');
    }
  }

  /// Delete collage from Firebase
  Future<void> _deleteCollageFromFirebase(String collageId) async {
    try {
      await _firebaseService.deleteFromFirestore(
        collection: 'photo_collages',
        documentId: collageId,
      );
    } catch (e) {
      developer.log(
          '❌ [CoupleGalleryService] Error deleting collage from Firebase: $e');
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      await _hiveService.ensureBoxOpen(_boxName);
      await _hiveService.delete(_boxName, _photosKey);
      await _hiveService.delete(_boxName, _collagesKey);
      developer.log('✅ [CoupleGalleryService] All data cleared');
    } catch (e) {
      developer.log('❌ [CoupleGalleryService] Error clearing data: $e');
    }
  }
}

/// Collage layout extensions
extension CollageLayoutExtension on CollageLayout {
  String get displayName {
    switch (this) {
      case CollageLayout.grid2x2:
        return '2x2 Grid';
      case CollageLayout.grid3x3:
        return '3x3 Grid';
      case CollageLayout.heart:
        return 'Heart Shape';
      case CollageLayout.circle:
        return 'Circle';
      case CollageLayout.timeline:
        return 'Timeline';
      case CollageLayout.mosaic:
        return 'Mosaic';
      case CollageLayout.polaroid:
        return 'Polaroid';
      case CollageLayout.instagram:
        return 'Instagram';
    }
  }

  String get emoji {
    switch (this) {
      case CollageLayout.grid2x2:
        return '⬜';
      case CollageLayout.grid3x3:
        return '⬛';
      case CollageLayout.heart:
        return '❤️';
      case CollageLayout.circle:
        return '⭕';
      case CollageLayout.timeline:
        return '📅';
      case CollageLayout.mosaic:
        return '🧩';
      case CollageLayout.polaroid:
        return '📷';
      case CollageLayout.instagram:
        return '📱';
    }
  }

  int get maxPhotos {
    switch (this) {
      case CollageLayout.grid2x2:
        return 4;
      case CollageLayout.grid3x3:
        return 9;
      case CollageLayout.heart:
        return 6;
      case CollageLayout.circle:
        return 8;
      case CollageLayout.timeline:
        return 5;
      case CollageLayout.mosaic:
        return 12;
      case CollageLayout.polaroid:
        return 4;
      case CollageLayout.instagram:
        return 6;
    }
  }
}
