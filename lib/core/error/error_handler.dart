import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Simple error handler for the application
class ErrorHandler {
  /// Handle an error with appropriate user feedback
  static Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    BuildContext? context,
    bool showToUser = true,
    String? customMessage,
  }) async {
    // Log error
    if (kDebugMode) {
      print('🚨 Error: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }

    // Show to user if context available and requested
    if (showToUser && context != null) {
      _showErrorToUser(context, error, customMessage);
    }
  }

  /// Show error to user with snackbar
  static void _showErrorToUser(
    BuildContext context,
    dynamic error,
    String? customMessage,
  ) {
    final message = customMessage ?? error.toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Handle network errors specifically
  static Future<void> handleNetworkError(
    dynamic error, {
    BuildContext? context,
    String? endpoint,
    int? statusCode,
  }) async {
    await handleError(error, context: context);
  }

  /// Handle image processing errors specifically
  static Future<void> handleImageError(
    dynamic error, {
    BuildContext? context,
    String? imagePath,
    String? processingStep,
    String? code,
  }) async {
    await handleError(error, context: context);
  }

  /// Handle storage errors specifically
  static Future<void> handleStorageError(
    dynamic error, {
    BuildContext? context,
    String? operation,
    String? key,
    String? code,
  }) async {
    await handleError(error, context: context);
  }

  /// Handle baby generation errors specifically
  static Future<void> handleBabyGenerationError(
    dynamic error, {
    BuildContext? context,
    String? generationStep,
    String? taskId,
    String? code,
  }) async {
    await handleError(error, context: context);
  }

  /// Handle permission errors specifically
  static Future<void> handlePermissionError(
    String permission, {
    BuildContext? context,
    String? customMessage,
  }) async {
    final message = customMessage ?? 'Permission required: $permission';
    await handleError(message, context: context);
  }
}
