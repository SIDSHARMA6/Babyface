/// Generation progress tracking model
class GenerationProgress {
  final String taskId;
  final double progress; // 0.0 to 1.0
  final String status;
  final String? message;
  final DateTime timestamp;
  final bool isCompleted;
  final bool hasError;
  final String? errorMessage;

  GenerationProgress({
    required this.taskId,
    required this.progress,
    required this.status,
    this.message,
    required this.timestamp,
    this.isCompleted = false,
    this.hasError = false,
    this.errorMessage,
  });

  GenerationProgress copyWith({
    String? taskId,
    double? progress,
    String? status,
    String? message,
    DateTime? timestamp,
    bool? isCompleted,
    bool? hasError,
    String? errorMessage,
  }) {
    return GenerationProgress(
      taskId: taskId ?? this.taskId,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isCompleted: isCompleted ?? this.isCompleted,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  int get progressPercentage => (progress * 100).round();

  bool get isInProgress => !isCompleted && !hasError;
}
