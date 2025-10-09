import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/toast_service.dart';

/// Firebase-integrated sharing service with ANR prevention
/// Follows theme standardization and zero boilerplate principles
class SharingService {
  static const String _appName = 'Future Baby';
  static const String _appUrl = 'https://futurebaby.app';
  static const String _hashtags = '#FutureBaby #BabyFace #CoupleGoals';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Share baby generation result with Firebase tracking
  static Future<void> shareBabyResult({
    required BuildContext context,
    required String imagePath,
    required String userId,
    String? customMessage,
    Map<String, dynamic>? babyData,
  }) async {
    try {
      // Generate dynamic caption using Firebase function
      final caption = await _generateDynamicCaption(
        type: 'baby_result',
        userId: userId,
        customMessage: customMessage,
        metadata: babyData,
      );

      // Create shareable content with branding
      final shareableContent = await _createShareableContent(
        imagePath: imagePath,
        caption: caption,
        userId: userId,
      );

      await Share.shareXFiles(
        [XFile(shareableContent['imagePath']!)],
        text:
            '${shareableContent['caption']!}\n\n$_hashtags\n\nGenerated with $_appName\n$_appUrl',
        subject: 'Check out our future baby!',
      );

      // Track sharing metrics in Firebase
      await _trackSharingEvent(
        userId: userId,
        contentType: 'baby_result',
        platform: 'general',
        metadata: babyData,
      );

      if (context.mounted) {
        ToastService.showSuccess(context, 'Shared successfully! 🎉');
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Sharing failed. Please try again.');
      }
    }
  }

  /// Share quiz results with Firebase analytics
  static Future<void> shareQuizResult({
    required BuildContext context,
    required String userId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required String quizCategory,
    String? imagePath,
  }) async {
    try {
      // Generate personalized quiz result using Firebase function
      final quizData = {
        'quizTitle': quizTitle,
        'score': score,
        'totalQuestions': totalQuestions,
        'category': quizCategory,
        'percentage': (score / totalQuestions * 100).round(),
      };

      final caption = await _generateDynamicCaption(
        type: 'quiz_result',
        userId: userId,
        metadata: quizData,
      );

      if (imagePath != null) {
        final shareableContent = await _createShareableContent(
          imagePath: imagePath,
          caption: caption,
          userId: userId,
        );

        await Share.shareXFiles(
          [XFile(shareableContent['imagePath']!)],
          text:
              '${shareableContent['caption']!}\n\n$_hashtags\n\nTake the quiz: $_appUrl',
          subject: 'My quiz results!',
        );
      } else {
        await Share.share(
          '$caption\n\n$_hashtags\n\nTake the quiz: $_appUrl',
          subject: 'My quiz results!',
        );
      }

      // Track quiz sharing in Firebase
      await _trackSharingEvent(
        userId: userId,
        contentType: 'quiz_result',
        platform: 'general',
        metadata: quizData,
      );

      if (context.mounted) {
        ToastService.showCelebration(context, 'Quiz results shared! 🌟');
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Sharing failed. Please try again.');
      }
    }
  }

  /// Share app invitation with Firebase referral tracking
  static Future<void> shareAppInvitation({
    required BuildContext context,
    required String userId,
    String? customMessage,
  }) async {
    try {
      // Get user's referral code from Firebase
      final referralCode = await getUserReferralCode(userId);

      // Generate dynamic sharing link
      final sharingLink = await generateSharingLink(
        userId: userId,
        contentType: 'app_invitation',
        metadata: {'referralCode': referralCode},
      );

      final message = customMessage ??
          await _generateDynamicCaption(
            type: 'app_invitation',
            userId: userId,
          );

      await Share.share(
        '$message\n\n$sharingLink\n\n$_hashtags',
        subject: 'Try this amazing baby app!',
      );

      // Track invitation sharing
      await _trackSharingEvent(
        userId: userId,
        contentType: 'app_invitation',
        platform: 'general',
        metadata: {'referralCode': referralCode},
      );

      if (context.mounted) {
        ToastService.showLove(context, 'Invitation sent with love! 💕');
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Sharing failed. Please try again.');
      }
    }
  }

  /// Share to Instagram with Firebase tracking
  static Future<void> shareToInstagram({
    required BuildContext context,
    required String userId,
    required String imagePath,
    String? caption,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Generate Instagram-optimized caption
      final instagramCaption = caption ??
          await _generateDynamicCaption(
            type: 'instagram_post',
            userId: userId,
            metadata: metadata,
          );

      // Create Instagram-optimized content
      final shareableContent = await _createShareableContent(
        imagePath: imagePath,
        caption: instagramCaption,
        userId: userId,
      );

      await Share.shareXFiles(
        [XFile(shareableContent['imagePath']!)],
        text: '${shareableContent['caption']!}\n\n$_hashtags',
      );

      // Track Instagram sharing
      await _trackSharingEvent(
        userId: userId,
        contentType: 'instagram_post',
        platform: 'instagram',
        metadata: metadata,
      );

      if (context.mounted) {
        ToastService.showSuccess(context, 'Ready for Instagram! 📸');
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Instagram sharing failed.');
      }
    }
  }

  /// Share to WhatsApp with Firebase tracking
  static Future<void> shareToWhatsApp({
    required BuildContext context,
    required String userId,
    required String imagePath,
    String? message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Generate WhatsApp-optimized caption
      final whatsappCaption = message ??
          await _generateDynamicCaption(
            type: 'whatsapp_message',
            userId: userId,
            metadata: metadata,
          );

      // Generate sharing link for WhatsApp
      final sharingLink = await generateSharingLink(
        userId: userId,
        contentType: 'whatsapp_share',
        metadata: metadata,
      );

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: '$whatsappCaption\n\nTry it yourself: $sharingLink',
      );

      // Track WhatsApp sharing
      await _trackSharingEvent(
        userId: userId,
        contentType: 'whatsapp_share',
        platform: 'whatsapp',
        metadata: metadata,
      );

      if (context.mounted) {
        ToastService.showSuccess(context, 'Shared to WhatsApp! 💬');
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'WhatsApp sharing failed.');
      }
    }
  }

  /// Create shareable image with app branding (ANR-free with isolate)
  static Future<String?> createBrandedImage({
    required String originalImagePath,
    required String overlayText,
  }) async {
    try {
      // This would run in isolate to prevent ANR
      return await compute(_createBrandedImageIsolate, {
        'imagePath': originalImagePath,
        'overlayText': overlayText,
      });
    } catch (e) {
      return null;
    }
  }

  /// Generate dynamic caption using Firebase Cloud Function
  static Future<String> _generateDynamicCaption({
    required String type,
    required String userId,
    String? customMessage,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateSharingCaption');
      final result = await callable.call({
        'type': type,
        'userId': userId,
        'customMessage': customMessage,
        'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return result.data['caption'] ?? _getFallbackCaption(type);
    } catch (e) {
      developer.log('Failed to generate dynamic caption: $e');
      return _getFallbackCaption(type);
    }
  }

  /// Create shareable content with branding (ANR-free with isolate)
  static Future<Map<String, String>> _createShareableContent({
    required String imagePath,
    required String? caption,
    required String userId,
  }) async {
    try {
      // Process image in isolate to prevent ANR
      final brandedImagePath = await compute(_createBrandedImageIsolate, {
        'imagePath': imagePath,
        'caption': caption ?? '',
        'userId': userId,
        'appName': _appName,
      });

      return {
        'imagePath': brandedImagePath,
        'caption': caption ?? '',
      };
    } catch (e) {
      developer.log('Failed to create branded content: $e');
      return {
        'imagePath': imagePath,
        'caption': caption ?? '',
      };
    }
  }

  /// Isolate function for image processing (ANR prevention)
  static Future<String> _createBrandedImageIsolate(
      Map<String, String> params) async {
    try {
      // Image processing logic with app branding
      // This runs in isolate to prevent ANR
      final originalPath = params['imagePath']!;
      // final caption = params['caption']!;
      // final appName = params['appName']!;

      // For now, return original path
      // In production, this would add watermark/branding
      return originalPath;
    } catch (e) {
      return params['imagePath']!;
    }
  }

  /// Track sharing events in Firebase Analytics and Firestore
  static Future<void> _trackSharingEvent({
    required String userId,
    required String contentType,
    required String platform,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Firebase Analytics
      await _analytics.logShare(
        contentType: contentType,
        itemId: '${contentType}_${DateTime.now().millisecondsSinceEpoch}',
        method: platform,
      );

      // Firestore for detailed tracking
      await _firestore.collection('sharing_events').add({
        'userId': userId,
        'contentType': contentType,
        'platform': platform,
        'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
        'appVersion': '1.0.0',
      });

      // Update user sharing stats
      await _firestore.collection('users').doc(userId).update({
        'totalShares': FieldValue.increment(1),
        'lastSharedAt': FieldValue.serverTimestamp(),
        'sharingStats.$contentType': FieldValue.increment(1),
      });
    } catch (e) {
      developer.log('Failed to track sharing event: $e');
    }
  }

  /// Get user's referral code from Firebase
  static Future<String?> getUserReferralCode(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['referralCode'];
      }
      return null;
    } catch (e) {
      developer.log('Failed to get referral code: $e');
      return null;
    }
  }

  /// Generate viral sharing link with Firebase Dynamic Links
  static Future<String> generateSharingLink({
    required String userId,
    required String contentType,
    String? contentId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateSharingLink');
      final result = await callable.call({
        'userId': userId,
        'contentType': contentType,
        'contentId': contentId,
        'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return result.data['link'] ?? _appUrl;
    } catch (e) {
      developer.log('Failed to generate sharing link: $e');
      return _appUrl;
    }
  }

  /// Track viral metrics and referral success
  static Future<void> trackViralMetrics({
    required String userId,
    required String action, // 'shared', 'clicked', 'installed'
    String? referredBy,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('viral_metrics').add({
        'userId': userId,
        'action': action,
        'referredBy': referredBy,
        'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update referrer's stats if applicable
      if (referredBy != null && action == 'installed') {
        await _firestore.collection('users').doc(referredBy).update({
          'referralCount': FieldValue.increment(1),
          'referralRewards': FieldValue.increment(10), // 10 points per referral
        });
      }
    } catch (e) {
      developer.log('Failed to track viral metrics: $e');
    }
  }

  /// Fallback captions when Firebase function fails
  static String _getFallbackCaption(String type) {
    switch (type) {
      case 'baby_result':
        return _getBabyResultCaption();
      case 'quiz_result':
        return 'Just completed an amazing quiz! 🎯';
      case 'app_invitation':
        return _getAppInvitationCaption();
      default:
        return 'Check out this amazing app! ✨';
    }
  }

  /// Generate pre-filled captions for different content types
  static String _getBabyResultCaption() {
    final captions = [
      'Look at our adorable future baby! 👶✨',
      'Can\'t wait to meet this little angel! 💕',
      'Our future bundle of joy looks amazing! 🌟',
      'This is what our baby might look like! 😍',
      'Future family goals right here! 👨‍👩‍👧‍👦',
    ];
    return captions[DateTime.now().millisecond % captions.length];
  }

  static String _getAppInvitationCaption() {
    final invitations = [
      'Found this amazing app that shows what your future baby might look like! 👶',
      'You have to try this baby face generator - it\'s so much fun! ✨',
      'Check out this cute app for couples planning their future! 💕',
      'This baby prediction app is incredible - try it with your partner! 🌟',
    ];
    return invitations[DateTime.now().millisecond % invitations.length];
  }

  /// Copy content to clipboard with theme-aware feedback
  static Future<void> copyToClipboard({
    required BuildContext context,
    required String text,
    String? successMessage,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));

      if (context.mounted) {
        ToastService.showSuccess(
            context, successMessage ?? 'Copied to clipboard! 📋');
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Failed to copy to clipboard.');
      }
    }
  }

  /// Get available sharing platforms
  static List<SharingPlatform> getAvailablePlatforms() {
    return [
      SharingPlatform(
        name: 'Instagram',
        icon: Icons.camera_alt_rounded,
        color: const Color(0xFFE4405F),
        action: SharingAction.instagram,
      ),
      SharingPlatform(
        name: 'WhatsApp',
        icon: Icons.chat_rounded,
        color: const Color(0xFF25D366),
        action: SharingAction.whatsapp,
      ),
      SharingPlatform(
        name: 'Share More',
        icon: Icons.share_rounded,
        color: AppTheme.primaryBlue,
        action: SharingAction.general,
      ),
      SharingPlatform(
        name: 'Copy Link',
        icon: Icons.link_rounded,
        color: AppTheme.textSecondary,
        action: SharingAction.copy,
      ),
    ];
  }
}

/// Sharing platform model
class SharingPlatform {
  final String name;
  final IconData icon;
  final Color color;
  final SharingAction action;

  const SharingPlatform({
    required this.name,
    required this.icon,
    required this.color,
    required this.action,
  });
}

/// Sharing action types
enum SharingAction {
  instagram,
  whatsapp,
  general,
  copy,
}
