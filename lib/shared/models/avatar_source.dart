/// Avatar source enum for tracking where avatar came from
enum AvatarSource {
  male,
  female,
  profile,
  uploaded,
  generated,
}

extension AvatarSourceExtension on AvatarSource {
  String get displayName {
    switch (this) {
      case AvatarSource.male:
        return 'Male Photo';
      case AvatarSource.female:
        return 'Female Photo';
      case AvatarSource.profile:
        return 'Profile Photo';
      case AvatarSource.uploaded:
        return 'Uploaded Photo';
      case AvatarSource.generated:
        return 'Generated Photo';
    }
  }

  String get description {
    switch (this) {
      case AvatarSource.male:
        return 'Using male photo';
      case AvatarSource.female:
        return 'Using female photo';
      case AvatarSource.profile:
        return 'Using your profile photo';
      case AvatarSource.uploaded:
        return 'Using uploaded photo';
      case AvatarSource.generated:
        return 'Using generated photo';
    }
  }

  String get emoji {
    switch (this) {
      case AvatarSource.male:
        return '👨';
      case AvatarSource.female:
        return '👩';
      case AvatarSource.profile:
        return '👤';
      case AvatarSource.uploaded:
        return '📷';
      case AvatarSource.generated:
        return '✨';
    }
  }
}
