class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final String? malePhotoPath;
  final String? femalePhotoPath;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.name,
    this.email,
    this.malePhotoPath,
    this.femalePhotoPath,
    required this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? malePhotoPath,
    String? femalePhotoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      malePhotoPath: malePhotoPath ?? this.malePhotoPath,
      femalePhotoPath: femalePhotoPath ?? this.femalePhotoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'malePhotoPath': malePhotoPath,
      'femalePhotoPath': femalePhotoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String?,
      email: map['email'] as String?,
      malePhotoPath: map['malePhotoPath'] as String?,
      femalePhotoPath: map['femalePhotoPath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }
}
