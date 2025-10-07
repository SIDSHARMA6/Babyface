class BabyResult {
  final String id;
  final String? babyImagePath;
  final int maleMatchPercentage;
  final int femaleMatchPercentage;
  final DateTime createdAt;
  final bool isProcessing;
  final String? imageUrl;
  final bool isFavorite;
  final String tags;

  BabyResult({
    required this.id,
    this.babyImagePath,
    required this.maleMatchPercentage,
    required this.femaleMatchPercentage,
    required this.createdAt,
    this.isProcessing = false,
    this.imageUrl,
    this.isFavorite = false,
    this.tags = 'Cute',
  });

  bool get hasImage => babyImagePath != null;

  String get dominantParent {
    if (maleMatchPercentage > femaleMatchPercentage) {
      return 'Dad ($maleMatchPercentage%)';
    } else if (femaleMatchPercentage > maleMatchPercentage) {
      return 'Mom ($femaleMatchPercentage%)';
    } else {
      return 'Equal ($maleMatchPercentage% each)';
    }
  }

  BabyResult copyWith({
    String? id,
    String? babyImagePath,
    int? maleMatchPercentage,
    int? femaleMatchPercentage,
    DateTime? createdAt,
    bool? isProcessing,
    String? imageUrl,
    bool? isFavorite,
    String? tags,
  }) {
    return BabyResult(
      id: id ?? this.id,
      babyImagePath: babyImagePath ?? this.babyImagePath,
      maleMatchPercentage: maleMatchPercentage ?? this.maleMatchPercentage,
      femaleMatchPercentage:
          femaleMatchPercentage ?? this.femaleMatchPercentage,
      createdAt: createdAt ?? this.createdAt,
      isProcessing: isProcessing ?? this.isProcessing,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyImagePath': babyImagePath,
      'maleMatchPercentage': maleMatchPercentage,
      'femaleMatchPercentage': femaleMatchPercentage,
      'createdAt': createdAt.toIso8601String(),
      'isProcessing': isProcessing,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'tags': tags,
    };
  }

  factory BabyResult.fromMap(Map<String, dynamic> map) {
    return BabyResult(
      id: map['id'] as String,
      babyImagePath: map['babyImagePath'] as String?,
      maleMatchPercentage: map['maleMatchPercentage'] as int,
      femaleMatchPercentage: map['femaleMatchPercentage'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isProcessing: map['isProcessing'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      isFavorite: map['isFavorite'] as bool? ?? false,
      tags: map['tags'] as String? ?? 'Cute',
    );
  }
}
