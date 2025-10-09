/// Profile section model for dynamic profile sections
class ProfileSection {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String emoji;
  final ProfileSectionType type;
  final Map<String, dynamic> data;
  final bool isEnabled;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileSection({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.emoji,
    required this.type,
    required this.data,
    required this.isEnabled,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  ProfileSection copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    String? emoji,
    ProfileSectionType? type,
    Map<String, dynamic>? data,
    bool? isEnabled,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileSection(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      data: data ?? this.data,
      isEnabled: isEnabled ?? this.isEnabled,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'emoji': emoji,
      'type': type.name,
      'data': data,
      'isEnabled': isEnabled,
      'order': order,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ProfileSection.fromMap(Map<String, dynamic> map) {
    return ProfileSection(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? 'favorite',
      emoji: map['emoji'] ?? '💕',
      type: ProfileSectionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ProfileSectionType.custom,
      ),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      isEnabled: map['isEnabled'] ?? true,
      order: map['order'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileSection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Profile section types
enum ProfileSectionType {
  moodTracker,
  loveNotes,
  coupleGallery,
  bondLevel,
  themeSelector,
  favoriteMoments,
  zodiacCompatibility,
  aiMoodAssistant,
  custom,
}

