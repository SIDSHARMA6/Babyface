import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar_data.dart';
import '../models/baby_result.dart';

/// Simple repository manager for basic functionality
class RepositoryManager {
  static final List<AvatarData> _avatars = [];
  static final List<BabyResult> _babyResults = [];

  /// Initialize all repositories
  static Future<void> initialize() async {
    try {
      // Simple in-memory storage for now
      developer.log('Repository initialized with in-memory storage');
    } catch (e) {
      developer.log('Repository initialization error: $e');
    }
  }

  /// Get avatar repository instance
  static IAvatarRepository get avatarRepository => SimpleAvatarRepository();

  /// Get baby result repository instance
  static IBabyResultRepository get babyResultRepository =>
      SimpleBabyResultRepository();
}

/// Avatar repository interface
abstract class IAvatarRepository {
  Future<void> saveAvatar(AvatarData avatar);
  Future<AvatarData?> getAvatar(String id);
  Future<List<AvatarData>> getAllAvatars();
  Future<void> deleteAvatar(String id);
  Future<void> clearAll();
}

/// Baby result repository interface
abstract class IBabyResultRepository {
  Future<void> saveBabyResult(BabyResult result);
  Future<BabyResult?> getBabyResult(String id);
  Future<List<BabyResult>> getAllBabyResults({int? limit, int? offset});
  Future<List<BabyResult>> searchBabyResults(String query);
  Future<void> deleteBabyResult(String id);
  Future<void> clearAll();
  Stream<List<BabyResult>> watchBabyResults();
}

/// Simple in-memory avatar repository
class SimpleAvatarRepository implements IAvatarRepository {
  @override
  Future<void> saveAvatar(AvatarData avatar) async {
    RepositoryManager._avatars.removeWhere((a) => a.id == avatar.id);
    RepositoryManager._avatars.add(avatar);
  }

  @override
  Future<AvatarData?> getAvatar(String id) async {
    try {
      return RepositoryManager._avatars.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AvatarData>> getAllAvatars() async {
    return List<AvatarData>.from(RepositoryManager._avatars);
  }

  @override
  Future<void> deleteAvatar(String id) async {
    RepositoryManager._avatars.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> clearAll() async {
    RepositoryManager._avatars.clear();
  }
}

/// Simple in-memory baby result repository
class SimpleBabyResultRepository implements IBabyResultRepository {
  @override
  Future<void> saveBabyResult(BabyResult result) async {
    RepositoryManager._babyResults.removeWhere((r) => r.id == result.id);
    RepositoryManager._babyResults.add(result);
  }

  @override
  Future<BabyResult?> getBabyResult(String id) async {
    try {
      return RepositoryManager._babyResults.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<BabyResult>> getAllBabyResults({int? limit, int? offset}) async {
    var results = List<BabyResult>.from(RepositoryManager._babyResults);
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset != null) {
      results = results.skip(offset).toList();
    }
    if (limit != null) {
      results = results.take(limit).toList();
    }

    return results;
  }

  @override
  Future<List<BabyResult>> searchBabyResults(String query) async {
    final allResults = await getAllBabyResults();
    return allResults
        .where(
            (result) => result.id.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<void> deleteBabyResult(String id) async {
    RepositoryManager._babyResults.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> clearAll() async {
    RepositoryManager._babyResults.clear();
  }

  @override
  Stream<List<BabyResult>> watchBabyResults() {
    return Stream.periodic(const Duration(seconds: 1), (_) async {
      return await getAllBabyResults();
    }).asyncMap((future) => future);
  }
}

/// Repository providers for dependency injection
class RepositoryProviders {
  static final avatarRepository = Provider<IAvatarRepository>((ref) {
    return RepositoryManager.avatarRepository;
  });

  static final babyResultRepository = Provider<IBabyResultRepository>((ref) {
    return RepositoryManager.babyResultRepository;
  });
}
