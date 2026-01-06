// RevenueCat payment service for subscription management
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/subscription_constants.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  bool _isInitialized = false;

  /// Initializes RevenueCat SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Purchases.setLogLevel(LogLevel.debug);
    
    PurchasesConfiguration configuration = PurchasesConfiguration(
      AppConstants.revenueCatApiKey,
    );
    
    await Purchases.configure(configuration);
    _isInitialized = true;
  }

  /// Checks if user has an active subscription
  Future<SubscriptionStatus> checkSubscriptionStatus() async {
    try {
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      
      // Check for Elite entitlement
      if (customerInfo.entitlements.all['elite']?.isActive == true) {
        return SubscriptionStatus(
          isSubscribed: true,
          tier: SubscriptionTier.elite,
          dailyLimit: SubscriptionConstants.eliteQuestionsPerDay,
          expirationDate: customerInfo.entitlements.all['elite']?.expirationDate,
        );
      }
      
      // Check for Pro entitlement
      if (customerInfo.entitlements.all['pro']?.isActive == true) {
        return SubscriptionStatus(
          isSubscribed: true,
          tier: SubscriptionTier.pro,
          dailyLimit: SubscriptionConstants.proQuestionsPerDay,
          expirationDate: customerInfo.entitlements.all['pro']?.expirationDate,
        );
      }
      
      // Check for Basic entitlement
      if (customerInfo.entitlements.all['basic']?.isActive == true) {
        return SubscriptionStatus(
          isSubscribed: true,
          tier: SubscriptionTier.basic,
          dailyLimit: SubscriptionConstants.basicQuestionsPerDay,
          expirationDate: customerInfo.entitlements.all['basic']?.expirationDate,
        );
      }
      
      // Free tier (no active subscription)
      return SubscriptionStatus(
        isSubscribed: false,
        tier: SubscriptionTier.free,
        dailyLimit: 3, // Free tier limit
        expirationDate: null,
      );
      
    } catch (e) {
      throw PaymentServiceException('Failed to check subscription: $e');
    }
  }

  /// Fetches available packages for purchase
  Future<List<Package>> getAvailablePackages() async {
    try {
      final Offerings offerings = await Purchases.getOfferings();
      
      if (offerings.current == null || 
          offerings.current!.availablePackages.isEmpty) {
        throw PaymentServiceException('No packages available');
      }
      
      return offerings.current!.availablePackages;
      
    } catch (e) {
      throw PaymentServiceException('Failed to fetch packages: $e');
    }
  }

  /// Purchases a subscription package
  Future<SubscriptionStatus> purchasePackage(Package package) async {
    try {
      final CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      
      // Re-check subscription status after purchase
      return await checkSubscriptionStatus();
      
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        throw PaymentServiceException('Purchase cancelled');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        throw PaymentServiceException('Purchase not allowed');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        throw PaymentServiceException('Payment pending');
      } else {
        throw PaymentServiceException('Purchase failed: ${e.message}');
      }
    } catch (e) {
      throw PaymentServiceException('Purchase error: $e');
    }
  }

  /// Restores previous purchases
  Future<SubscriptionStatus> restorePurchases() async {
    try {
      final CustomerInfo customerInfo = await Purchases.restorePurchases();
      return await checkSubscriptionStatus();
    } catch (e) {
      throw PaymentServiceException('Failed to restore purchases: $e');
    }
  }

  /// Identifies user for RevenueCat (call after auth)
  Future<void> identifyUser(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      throw PaymentServiceException('Failed to identify user: $e');
    }
  }

  /// Logs out user from RevenueCat
  Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      throw PaymentServiceException('Failed to logout user: $e');
    }
  }
}

/// Subscription tier enum
enum SubscriptionTier {
  free,
  basic,
  pro,
  elite,
}

/// Subscription status model
class SubscriptionStatus {
  final bool isSubscribed;
  final SubscriptionTier tier;
  final int dailyLimit;
  final String? expirationDate;

  SubscriptionStatus({
    required this.isSubscribed,
    required this.tier,
    required this.dailyLimit,
    this.expirationDate,
  });

  String get tierName {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.basic:
        return 'Basic';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.elite:
        return 'Elite';
    }
  }
}

/// Payment service exception
class PaymentServiceException implements Exception {
  final String message;
  PaymentServiceException(this.message);
  
  @override
  String toString() => message;
}
