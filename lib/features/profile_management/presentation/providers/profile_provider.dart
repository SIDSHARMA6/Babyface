import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/avatar_data.dart';
import '../../../../shared/services/face_detection_service.dart';
import '../../../../shared/services/image_service.dart';
import '../../../../shared/repositories/repository_provider.dart';

/// Profile state
class ProfileState {
  final AvatarData? maleAvatar;
  final AvatarData? femaleAvatar;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.maleAvatar,
    this.femaleAvatar,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    AvatarData? maleAvatar,
    AvatarData? femaleAvatar,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      maleAvatar: maleAvatar ?? this.maleAvatar,
      femaleAvatar: femaleAvatar ?? this.femaleAvatar,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Profile notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref ref;

  ProfileNotifier(this.ref) : super(const ProfileState()) {
    loadProfiles();
  }

  /// Load profiles
  Future<void> loadProfiles() async {
    state = state.copyWith(isLoading: true);
    try {
      final avatarRepo = ref.read(RepositoryProviders.avatarRepository);
      final avatars = await avatarRepo.getAllAvatars();

      AvatarData? maleAvatar;
      AvatarData? femaleAvatar;

      for (final avatar in avatars) {
        if (avatar.id.contains('male')) {
          maleAvatar = avatar;
        } else if (avatar.id.contains('female')) {
          femaleAvatar = avatar;
        }
      }

      state = state.copyWith(
        maleAvatar: maleAvatar,
        femaleAvatar: femaleAvatar,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update male avatar
  Future<void> updateMaleAvatar(File imageFile) async {
    state = state.copyWith(isLoading: true);
    try {
      final compressedImage = await ImageService.compressImage(imageFile);
      final faceResult =
          await FaceDetectionService.detectFaces(compressedImage);

      final avatarData = AvatarData(
        id: 'male_avatar_${DateTime.now().millisecondsSinceEpoch}',
        imagePath: compressedImage.path,
        faceDetected: faceResult.hasFaces,
        faceConfidence: faceResult.confidence,
        createdAt: DateTime.now(),
      );

      final avatarRepo = ref.read(RepositoryProviders.avatarRepository);
      await avatarRepo.saveAvatar(avatarData);

      state = state.copyWith(
        maleAvatar: avatarData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update female avatar
  Future<void> updateFemaleAvatar(File imageFile) async {
    state = state.copyWith(isLoading: true);
    try {
      final compressedImage = await ImageService.compressImage(imageFile);
      final faceResult =
          await FaceDetectionService.detectFaces(compressedImage);

      final avatarData = AvatarData(
        id: 'female_avatar_${DateTime.now().millisecondsSinceEpoch}',
        imagePath: compressedImage.path,
        faceDetected: faceResult.hasFaces,
        faceConfidence: faceResult.confidence,
        createdAt: DateTime.now(),
      );

      final avatarRepo = ref.read(RepositoryProviders.avatarRepository);
      await avatarRepo.saveAvatar(avatarData);

      state = state.copyWith(
        femaleAvatar: avatarData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Delete male avatar
  Future<void> deleteMaleAvatar() async {
    if (state.maleAvatar != null) {
      try {
        final avatarRepo = ref.read(RepositoryProviders.avatarRepository);
        await avatarRepo.deleteAvatar(state.maleAvatar!.id);
        state = state.copyWith(maleAvatar: null);
      } catch (e) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  /// Delete female avatar
  Future<void> deleteFemaleAvatar() async {
    if (state.femaleAvatar != null) {
      try {
        final avatarRepo = ref.read(RepositoryProviders.avatarRepository);
        await avatarRepo.deleteAvatar(state.femaleAvatar!.id);
        state = state.copyWith(femaleAvatar: null);
      } catch (e) {
        state = state.copyWith(error: e.toString());
      }
    }
  }
}

/// Profile provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(ref),
);
