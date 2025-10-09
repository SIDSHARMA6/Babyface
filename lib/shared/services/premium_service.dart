import 'hive_service.dart';
import 'dart:developer' as developer;
import 'firebase_service.dart';

/// Service for managing premium subscription status
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static PremiumService get instance => _instance;

  final HiveService _hiveService = HiveService();
  final FirebaseService _firebaseService = FirebaseService();

  /// Check if user has premium subscription
  Future<bool> isPremium() async {
    try {
      await _hiveService.ensureBoxOpen('premium_subscriptions');

      if (!_hiveService.isBoxOpen('premium_subscriptions')) {
        developer.log('🔐 [PremiumService] Box not open, returning false');
        return false;
      }

      final premiumData =
          _hiveService.retrieve('premium_subscriptions', 'user_premium');

      if (premiumData == null) {
        return false;
      }

      final Map<String, dynamic> premium = premiumData;
      final bool isActive = premium['isActive'] ?? false;
      final DateTime? endDate = premium['endDate'] != null
          ? DateTime.parse(premium['endDate'] as String)
          : null;

      // Check if subscription is still valid
      if (isActive && endDate != null && endDate.isAfter(DateTime.now())) {
        return true;
      } else if (isActive &&
          endDate != null &&
          endDate.isBefore(DateTime.now())) {
        // Subscription expired, update status
        await _updatePremiumStatus(false, endDate);
        return false;
      }

      return isActive;
    } catch (e) {
      developer.log('Error checking premium status: $e');
      return false;
    }
  }

  /// Get premium subscription details
  Future<Map<String, dynamic>?> getPremiumDetails() async {
    try {
      await _hiveService.ensureBoxOpen('premium_subscriptions');

      if (!_hiveService.isBoxOpen('premium_subscriptions')) {
        return null;
      }

      return _hiveService.retrieve('premium_subscriptions', 'user_premium');
    } catch (e) {
      developer.log('Error getting premium details: $e');
      return null;
    }
  }

  /// Set premium subscription status
  Future<bool> setPremiumStatus({
    required bool isActive,
    required String subscriptionType,
    required DateTime endDate,
    required List<String> features,
  }) async {
    try {
      await _hiveService.ensureBoxOpen('premium_subscriptions');

      if (!_hiveService.isBoxOpen('premium_subscriptions')) {
        developer.log('🔐 [PremiumService] Box not open, cannot save premium status');
        return false;
      }

      final premiumData = {
        'isActive': isActive,
        'subscriptionType': subscriptionType,
        'startDate': DateTime.now().toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'features': features,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      _hiveService.store('premium_subscriptions', 'user_premium', premiumData);

      // Save to Firebase
      await _saveToFirebase(premiumData);

      developer.log('✅ Premium status updated: $isActive');
      return true;
    } catch (e) {
      developer.log('Error setting premium status: $e');
      return false;
    }
  }

  /// Update premium status (internal method)
  Future<void> _updatePremiumStatus(bool isActive, DateTime endDate) async {
    try {
      await _hiveService.ensureBoxOpen('premium_subscriptions');

      if (_hiveService.isBoxOpen('premium_subscriptions')) {
        final premiumData =
            _hiveService.retrieve('premium_subscriptions', 'user_premium');
        if (premiumData != null) {
          final Map<String, dynamic> premium = premiumData;
          premium['isActive'] = isActive;
          premium['lastUpdated'] = DateTime.now().toIso8601String();

          _hiveService.store('premium_subscriptions', 'user_premium', premium);
        }
      }
    } catch (e) {
      developer.log('Error updating premium status: $e');
    }
  }

  /// Save premium data to Firebase
  Future<void> _saveToFirebase(Map<String, dynamic> premiumData) async {
    try {
      await _firebaseService.saveToFirestore(
        collection: 'premium_subscriptions',
        documentId: 'user_premium',
        data: premiumData,
      );
    } catch (e) {
      developer.log('Error saving premium data to Firebase: $e');
    }
  }

  /// Clear premium subscription (for testing)
  Future<void> clearPremiumSubscription() async {
    try {
      await _hiveService.ensureBoxOpen('premium_subscriptions');
      if (_hiveService.isBoxOpen('premium_subscriptions')) {
        _hiveService.store('premium_subscriptions', 'user_premium', null);
      }
    } catch (e) {
      developer.log('Error clearing premium subscription: $e');
    }
  }

  /// Get available premium features
  List<String> getAvailableFeatures() {
    return [
      'HD Image Generation',
      'Watermark Removal',
      'Unlimited Generations',
      'Priority Processing',
      'Advanced Filters',
      'Batch Processing',
      'Cloud Storage',
      'Premium Support',
      'Early Access',
      'Exclusive Content',
    ];
  }

  /// Check if user has access to a specific feature
  Future<bool> hasAccessToFeature(String feature) async {
    try {
      final isPremium = await this.isPremium();
      if (!isPremium) return false;

      final premiumDetails = await getPremiumDetails();
      if (premiumDetails == null) return false;

      final List<dynamic> features = premiumDetails['features'] ?? [];
      return features.contains(feature);
    } catch (e) {
      developer.log('Error checking feature access: $e');
      return false;
    }
  }
}
