/// API endpoints configuration
/// Follows master plan backend standards
class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://api.babyface.app/v1';
  static const String stagingUrl = 'https://staging-api.babyface.app/v1';
  static const String developmentUrl = 'https://dev-api.babyface.app/v1';

  // Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // User management endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String uploadAvatar = '/user/avatar/upload';
  static const String deleteAccount = '/user/delete';

  // Baby generation endpoints
  static const String startGeneration = '/generations/start';
  static const String getGenerationStatus = '/generations/{id}/status';
  static const String cancelGeneration = '/generations/{id}/cancel';
  static const String getUserGenerations = '/generations/user';
  static const String deleteGeneration = '/generations/{id}/delete';

  // Image processing endpoints
  static const String uploadImage = '/images/upload';
  static const String compressImage = '/images/compress';
  static const String generateThumbnail = '/images/thumbnail';
  static const String detectFaces = '/images/faces/detect';
  static const String validateImage = '/images/validate';

  // Premium subscription endpoints
  static const String createSubscription = '/subscriptions/create';
  static const String getSubscription = '/subscriptions/current';
  static const String cancelSubscription = '/subscriptions/cancel';
  static const String updateSubscription = '/subscriptions/update';
  static const String getSubscriptionHistory = '/subscriptions/history';

  // Payment endpoints
  static const String createPaymentIntent = '/payments/create-intent';
  static const String confirmPayment = '/payments/confirm';
  static const String getPaymentHistory = '/payments/history';
  static const String refundPayment = '/payments/refund';

  // Analytics endpoints
  static const String trackEvent = '/analytics/track';
  static const String getUserAnalytics = '/analytics/user';
  static const String getAppAnalytics = '/analytics/app';
  static const String getPerformanceMetrics = '/analytics/performance';

  // Quiz endpoints
  static const String getQuizCategories = '/quiz/categories';
  static const String getQuizQuestions = '/quiz/{category}/questions';
  static const String submitQuizAnswer = '/quiz/{id}/answer';
  static const String getQuizResults = '/quiz/{id}/results';
  static const String getUserQuizHistory = '/quiz/user/history';

  // Engagement features endpoints
  static const String generateBabyNames = '/engagement/baby-names/generate';
  static const String getMemoryJournal = '/engagement/memory-journal';
  static const String addMemoryEntry = '/engagement/memory-journal/add';
  static const String getCoupleChallenges = '/engagement/challenges';
  static const String startChallenge = '/engagement/challenges/{id}/start';
  static const String completeChallenge =
      '/engagement/challenges/{id}/complete';

  // Social sharing endpoints
  static const String shareImage = '/social/share';
  static const String getShareTemplates = '/social/templates';
  static const String trackShare = '/social/track';
  static const String getViralMetrics = '/social/viral-metrics';

  // Content moderation endpoints
  static const String moderateImage = '/moderation/image';
  static const String reportContent = '/moderation/report';
  static const String getModerationStatus = '/moderation/status';

  // Notification endpoints
  static const String sendNotification = '/notifications/send';
  static const String getUserNotifications = '/notifications/user';
  static const String markNotificationRead = '/notifications/{id}/read';
  static const String updateNotificationSettings = '/notifications/settings';

  // Support endpoints
  static const String createSupportTicket = '/support/tickets/create';
  static const String getSupportTickets = '/support/tickets/user';
  static const String getSupportTicket = '/support/tickets/{id}';
  static const String replyToTicket = '/support/tickets/{id}/reply';

  // App configuration endpoints
  static const String getAppConfig = '/config/app';
  static const String getFeatureFlags = '/config/features';
  static const String getAppVersion = '/config/version';
  static const String checkForUpdates = '/config/updates';

  // Health check endpoints
  static const String healthCheck = '/health';
  static const String ping = '/ping';

  /// Get full URL for endpoint
  static String getFullUrl(String endpoint, {String? baseUrl}) {
    final base = baseUrl ?? ApiEndpoints.baseUrl;
    return '$base$endpoint';
  }

  /// Replace path parameters in endpoint
  static String replacePathParams(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  /// Get query string from parameters
  static String buildQueryString(Map<String, dynamic> params) {
    if (params.isEmpty) return '';

    final queryParams = params.entries
        .where((entry) => entry.value != null)
        .map((entry) =>
            '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    return queryParams.isNotEmpty ? '?$queryParams' : '';
  }

  /// Build complete URL with query parameters
  static String buildUrl(
    String endpoint, {
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    String? baseUrl,
  }) {
    String url = getFullUrl(endpoint, baseUrl: baseUrl);

    if (pathParams != null) {
      url = replacePathParams(url, pathParams);
    }

    if (queryParams != null) {
      url += buildQueryString(queryParams);
    }

    return url;
  }
}
