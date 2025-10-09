import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../../data/models/memory_model.dart';

/// Photo Loading Service
/// Handles progressive loading, caching, and optimization of memory photos
class PhotoLoader {
  static final PhotoLoader _instance = PhotoLoader._internal();
  factory PhotoLoader() => _instance;
  PhotoLoader._internal();

  final Map<String, Uint8List> _memoryCache = {};
  final Map<String, Uint8List> _thumbnailCache = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, List<VoidCallback>> _loadingCallbacks = {};

  static const int _maxMemoryCacheSize = 50; // Maximum photos in memory
  static const int _thumbnailSize = 150; // Thumbnail size in pixels
  static const int _previewSize = 300; // Preview size in pixels
  static const int _fullSize = 1024; // Full size in pixels

  /// Load photo with progressive quality
  Future<Uint8List?> loadPhoto(
    String photoPath, {
    PhotoSize size = PhotoSize.full,
    bool useCache = true,
  }) async {
    if (useCache) {
      final cached = _getCachedPhoto(photoPath, size);
      if (cached != null) return cached;
    }

    // Check if already loading
    if (_loadingStates[photoPath] == true) {
      return _waitForLoading(photoPath);
    }

    _loadingStates[photoPath] = true;

    try {
      final photoData = await _loadPhotoFromFile(photoPath, size);

      if (photoData != null) {
        _cachePhoto(photoPath, photoData, size);
        _notifyCallbacks(photoPath, photoData);
      }

      return photoData;
    } catch (e) {
      developer.log('Error loading photo: $e');
      return null;
    } finally {
      _loadingStates[photoPath] = false;
    }
  }

  /// Preload photos for a list of memories
  Future<void> preloadPhotos(List<MemoryModel> memories) async {
    final futures = <Future>[];

    for (final memory in memories) {
      if (memory.photoPath != null) {
        // Load thumbnail first
        futures.add(loadPhoto(memory.photoPath!, size: PhotoSize.thumbnail));

        // Then load preview
        futures.add(loadPhoto(memory.photoPath!, size: PhotoSize.preview));
      }
    }

    await Future.wait(futures);
  }

  /// Load photo with callback for progressive loading
  void loadPhotoWithCallback(
    String photoPath,
    VoidCallback onLoaded, {
    PhotoSize size = PhotoSize.full,
  }) {
    if (_loadingCallbacks[photoPath] == null) {
      _loadingCallbacks[photoPath] = [];
    }
    _loadingCallbacks[photoPath]!.add(onLoaded);

    // Check if already cached
    final cached = _getCachedPhoto(photoPath, size);
    if (cached != null) {
      onLoaded();
      return;
    }

    // Start loading if not already loading
    if (_loadingStates[photoPath] != true) {
      loadPhoto(photoPath, size: size);
    }
  }

  /// Get cached photo
  Uint8List? _getCachedPhoto(String photoPath, PhotoSize size) {
    switch (size) {
      case PhotoSize.thumbnail:
        return _thumbnailCache[photoPath];
      case PhotoSize.preview:
      case PhotoSize.full:
        return _memoryCache[photoPath];
    }
  }

  /// Cache photo based on size
  void _cachePhoto(String photoPath, Uint8List data, PhotoSize size) {
    switch (size) {
      case PhotoSize.thumbnail:
        _thumbnailCache[photoPath] = data;
        break;
      case PhotoSize.preview:
      case PhotoSize.full:
        _memoryCache[photoPath] = data;
        _cleanupCache();
        break;
    }
  }

  /// Clean up cache when it gets too large
  void _cleanupCache() {
    if (_memoryCache.length > _maxMemoryCacheSize) {
      // Remove oldest entries (simple LRU)
      final keysToRemove =
          _memoryCache.keys.take(_memoryCache.length - _maxMemoryCacheSize);
      for (final key in keysToRemove) {
        _memoryCache.remove(key);
      }
    }
  }

  /// Load photo from file with specified size
  Future<Uint8List?> _loadPhotoFromFile(
      String photoPath, PhotoSize size) async {
    try {
      final file = File(photoPath);
      
      // Check if file exists and is accessible
      if (!await file.exists()) {
        developer.log('Photo file does not exist: $photoPath');
        return null;
      }

      // Check if file is readable
      try {
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          developer.log('Photo file is empty: $photoPath');
          return null;
        }

        // Resize image if needed
        final resizedBytes = await _resizeImage(bytes, size);
        return resizedBytes;
      } catch (e) {
        developer.log('Error reading photo file: $e');
        return null;
      }
    } catch (e) {
      developer.log('Error loading photo from file: $e');
      return null;
    }
  }

  /// Resize image to specified size
  Future<Uint8List> _resizeImage(Uint8List bytes, PhotoSize size) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;

      final targetSize = _getTargetSize(size);
      final resized = img.copyResize(
        image,
        width: targetSize,
        height: targetSize,
        interpolation: img.Interpolation.cubic,
      );

      return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
    } catch (e) {
      developer.log('Error resizing image: $e');
      return bytes; // Return original if resize fails
    }
  }

  /// Get target size for photo size enum
  int _getTargetSize(PhotoSize size) {
    switch (size) {
      case PhotoSize.thumbnail:
        return _thumbnailSize;
      case PhotoSize.preview:
        return _previewSize;
      case PhotoSize.full:
        return _fullSize;
    }
  }

  /// Wait for photo to finish loading
  Future<Uint8List?> _waitForLoading(String photoPath) async {
    final completer = Completer<Uint8List?>();

    void checkLoading() {
      if (_loadingStates[photoPath] == false) {
        final cached = _memoryCache[photoPath];
        completer.complete(cached);
      } else {
        Future.delayed(const Duration(milliseconds: 100), checkLoading);
      }
    }

    checkLoading();
    return completer.future;
  }

  /// Notify callbacks when photo is loaded
  void _notifyCallbacks(String photoPath, Uint8List data) {
    final callbacks = _loadingCallbacks[photoPath];
    if (callbacks != null) {
      for (final callback in callbacks) {
        callback();
      }
      _loadingCallbacks[photoPath] = [];
    }
  }

  /// Clear all caches
  void clearCache() {
    _memoryCache.clear();
    _thumbnailCache.clear();
    _loadingStates.clear();
    _loadingCallbacks.clear();
  }

  /// Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'memoryCache': _memoryCache.length,
      'thumbnailCache': _thumbnailCache.length,
      'loadingStates': _loadingStates.length,
    };
  }

  /// Preload photos for memory journey
  Future<void> preloadMemoryJourney(List<MemoryModel> memories) async {
    // Load thumbnails first for quick display
    final thumbnailFutures = memories
        .where((memory) => memory.photoPath != null)
        .map(
            (memory) => loadPhoto(memory.photoPath!, size: PhotoSize.thumbnail))
        .toList();

    await Future.wait(thumbnailFutures);

    // Then load previews for better quality
    final previewFutures = memories
        .where((memory) => memory.photoPath != null)
        .map((memory) => loadPhoto(memory.photoPath!, size: PhotoSize.preview))
        .toList();

    await Future.wait(previewFutures);
  }

  /// Load photo with loading indicator
  Future<Widget> loadPhotoWidget(
    String photoPath, {
    PhotoSize size = PhotoSize.full,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) async {
    final cached = _getCachedPhoto(photoPath, size);
    if (cached != null) {
      return Image.memory(
        cached,
        width: width,
        height: height,
        fit: fit,
      );
    }

    // Show loading indicator
    return FutureBuilder<Uint8List?>(
      future: loadPhoto(photoPath, size: size),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
          );
        } else if (snapshot.hasError) {
          return placeholder ?? _buildErrorPlaceholder(width, height);
        } else {
          return placeholder ?? _buildLoadingPlaceholder(width, height);
        }
      },
    );
  }

  /// Build error placeholder widget
  Widget _buildErrorPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 48,
      ),
    );
  }

  /// Build loading placeholder widget
  Widget _buildLoadingPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Load photo with progressive enhancement
  Widget loadPhotoProgressive(
    String photoPath, {
    PhotoSize initialSize = PhotoSize.thumbnail,
    PhotoSize finalSize = PhotoSize.full,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    return _ProgressivePhotoWidget(
      photoPath: photoPath,
      initialSize: initialSize,
      finalSize: finalSize,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
    );
  }
}

/// Photo size enumeration
enum PhotoSize {
  thumbnail,
  preview,
  full,
}

/// Progressive photo loading widget
class _ProgressivePhotoWidget extends StatefulWidget {
  final String photoPath;
  final PhotoSize initialSize;
  final PhotoSize finalSize;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const _ProgressivePhotoWidget({
    required this.photoPath,
    required this.initialSize,
    required this.finalSize,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  State<_ProgressivePhotoWidget> createState() =>
      _ProgressivePhotoWidgetState();
}

class _ProgressivePhotoWidgetState extends State<_ProgressivePhotoWidget> {
  Uint8List? _currentImage;
  bool _isLoadingHighRes = false;

  @override
  void initState() {
    super.initState();
    _loadInitialImage();
  }

  void _loadInitialImage() async {
    final image = await PhotoLoader().loadPhoto(
      widget.photoPath,
      size: widget.initialSize,
    );

    if (mounted) {
      setState(() {
        _currentImage = image;
      });

      // Load high-res version
      _loadHighResImage();
    }
  }

  void _loadHighResImage() async {
    if (_isLoadingHighRes) return;

    setState(() {
      _isLoadingHighRes = true;
    });

    final highResImage = await PhotoLoader().loadPhoto(
      widget.photoPath,
      size: widget.finalSize,
    );

    if (mounted && highResImage != null) {
      setState(() {
        _currentImage = highResImage;
        _isLoadingHighRes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentImage == null) {
      return widget.placeholder ?? const CircularProgressIndicator();
    }

    return Stack(
      children: [
        Image.memory(
          _currentImage!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        ),
        if (_isLoadingHighRes)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Photo loading completer
class Completer<T> {
  final Completer<T> _completer = Completer<T>();

  void complete(T value) => _completer.complete(value);
  void completeError(Object error, [StackTrace? stackTrace]) =>
      _completer.completeError(error, stackTrace);

  Future<T> get future => _completer.future;
}
