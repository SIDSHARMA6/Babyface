import 'package:equatable/equatable.dart';

/// Baby generation entity
/// Follows master plan clean architecture
class BabyGenerationEntity extends Equatable {
  final String id;
  final String maleImagePath;
  final String femaleImagePath;
  final String? generatedImagePath;
  final GenerationStatus status;
  final double progress;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final GenerationMetadata metadata;

  const BabyGenerationEntity({
    required this.id,
    required this.maleImagePath,
    required this.femaleImagePath,
    this.generatedImagePath,
    required this.status,
    required this.progress,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        maleImagePath,
        femaleImagePath,
        generatedImagePath,
        status,
        progress,
        createdAt,
        completedAt,
        errorMessage,
        metadata,
      ];

  BabyGenerationEntity copyWith({
    String? id,
    String? maleImagePath,
    String? femaleImagePath,
    String? generatedImagePath,
    GenerationStatus? status,
    double? progress,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
    GenerationMetadata? metadata,
  }) {
    return BabyGenerationEntity(
      id: id ?? this.id,
      maleImagePath: maleImagePath ?? this.maleImagePath,
      femaleImagePath: femaleImagePath ?? this.femaleImagePath,
      generatedImagePath: generatedImagePath ?? this.generatedImagePath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Generation status enum
enum GenerationStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

/// Generation metadata
class GenerationMetadata extends Equatable {
  final String? aiModel;
  final String? processingTime;
  final Map<String, dynamic>? parameters;
  final String? quality;
  final String? resolution;

  const GenerationMetadata({
    this.aiModel,
    this.processingTime,
    this.parameters,
    this.quality,
    this.resolution,
  });

  @override
  List<Object?> get props => [
        aiModel,
        processingTime,
        parameters,
        quality,
        resolution,
      ];

  GenerationMetadata copyWith({
    String? aiModel,
    String? processingTime,
    Map<String, dynamic>? parameters,
    String? quality,
    String? resolution,
  }) {
    return GenerationMetadata(
      aiModel: aiModel ?? this.aiModel,
      processingTime: processingTime ?? this.processingTime,
      parameters: parameters ?? this.parameters,
      quality: quality ?? this.quality,
      resolution: resolution ?? this.resolution,
    );
  }
}
