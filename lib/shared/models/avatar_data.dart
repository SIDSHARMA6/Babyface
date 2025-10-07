class AvatarData {
  final String id;
  final String? imagePath;
  final bool faceDetected;
  final double faceConfidence;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? uploadedAt;

  AvatarData({
    required this.id,
    this.imagePath,
    this.faceDetected = false,
    this.faceConfidence = 0.0,
    required this.createdAt,
    this.updatedAt,
    this.uploadedAt,
  });

  bool get hasImage => imagePath != null;

  AvatarData copyWith({
    String? id,
    String? imagePath,
    bool? faceDetected,
    double? faceConfidence,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? uploadedAt,
  }) {
    return AvatarData(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      faceDetected: faceDetected ?? this.faceDetected,
      faceConfidence: faceConfidence ?? this.faceConfidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'faceDetected': faceDetected,
      'faceConfidence': faceConfidence,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }

  factory AvatarData.fromMap(Map<String, dynamic> map) {
    return AvatarData(
      id: map['id'] as String,
      imagePath: map['imagePath'] as String?,
      faceDetected: map['faceDetected'] as bool? ?? false,
      faceConfidence: map['faceConfidence'] as double? ?? 0.0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.parse(map['uploadedAt'] as String)
          : null,
    );
  }
}
