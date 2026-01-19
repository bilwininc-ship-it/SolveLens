// Google Play In-App Purchase service for subscription management
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/constants/subscription_constants.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isInitialized = false;

  // Product IDs for different subscription tiers
  static const String basicMonthlyId = 'solvelens_basic_monthly';
  static const String basicYearlyId = 'solvelens_basic_yearly';
  static const String proMonthlyId = 'solvelens_pro_monthly';
  static const String proYearlyId = 'solvelens_pro_yearly';
  static const String eliteMonthlyId = 'solvelens_elite_monthly';
  static const String eliteYearlyId = 'solvelens_elite_yearly';

  static const Set<String> _productIds = {
    basicMonthlyId,
    basicYearlyId,
    proMonthlyId,
    proYearlyId,
    eliteMonthlyId,
    eliteYearlyId,
  };

  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  /// Initializes Google Play In-App Purchase
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Check if IAP is available
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw PaymentServiceException('In-App Purchase is not available on this device');
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        debugPrint('Purchase stream closed');
      },
      onError: (error) {
        debugPrint('Purchase stream error: $error');
      },
    );

    _isInitialized = true;
  }

  /// Handles purchase updates from the stream
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending purchase
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
        debugPrint('Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Verify purchase and grant entitlement
        await _verifyAndDeliverProduct(purchaseDetails);
      }

      // Complete the purchase on Android
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }

    _purchases = purchaseDetailsList;
  }

  /// Verifies and delivers the purchased product
  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    // TODO: Implement server-side verification
    // For now, we trust the platform verification
    debugPrint('Purchase verified: ${purchaseDetails.productID}');
  }

  /// Fetches available subscription products
  Future<List<ProductDetails>> getAvailableProducts() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);

      if (response.error != null) {
        throw PaymentServiceException('Failed to query products: ${response.error!.message}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      if (response.productDetails.isEmpty) {
        throw PaymentServiceException('No products available');
      }

      _products = response.productDetails;
      return _products;
    } catch (e) {
      throw PaymentServiceException('Failed to fetch products: $e');
    }
  }

  /// Purchases a subscription product
  Future<bool> purchaseProduct(ProductDetails product) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      // For subscriptions, use buyNonConsumable
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      return success;
    } catch (e) {
      throw PaymentServiceException('Purchase failed: $e');
    }
  }

  /// Restores previous purchases
  Future<List<PurchaseDetails>> restorePurchases() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _inAppPurchase.restorePurchases();
      
      // Wait for purchases to be updated
      await Future.delayed(const Duration(seconds: 2));
      
      return _purchases.where((p) => p.status == PurchaseStatus.restored).toList();
    } catch (e) {
      throw PaymentServiceException('Failed to restore purchases: $e');
    }
  }

  /// Checks current subscription status
  Future<SubscriptionStatus> checkSubscriptionStatus() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Get all active purchases
      final List<PurchaseDetails> activePurchases = _purchases.where((p) =>
          p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored).toList();

      if (activePurchases.isEmpty) {
        return SubscriptionStatus(
          isSubscribed: false,
          tier: SubscriptionTier.free,
          dailyLimit: 3, // Free tier limit
          expirationDate: null,
        );
      }

      // Check for Elite subscription (highest tier)
      if (activePurchases.any((p) => p.productID.contains('elite'))) {
        return SubscriptionStatus(
          isSubscribed: true,
          tier: SubscriptionTier.elite,
          dailyLimit: SubscriptionConstants.eliteQuestionsPerDay,
          expirationDate: null, // Subscriptions don't have fixed expiration
        );
      }

      // Check for Pro subscription
      if (activePurchases.any((p) => p.productID.contains('pro'))) {
        return SubscriptionStatus(
          isSubscribed: true,
          tier: SubscriptionTier.pro,
          dailyLimit: SubscriptionConstants.proQuestionsPerDay,
          expirationDate: null,
        );
      }

      // Check for Basic subscription
      if (activePurchases.any((p) => p.productID.contains('basic'))) {
        return SubscriptionStatus(
          isSubscribed: true,
          tier: SubscriptionTier.basic,
          dailyLimit: SubscriptionConstants.basicQuestionsPerDay,
          expirationDate: null,
        );
      }

      // Default to free tier
      return SubscriptionStatus(
        isSubscribed: false,
        tier: SubscriptionTier.free,
        dailyLimit: 3,
        expirationDate: null,
      );
    } catch (e) {
      throw PaymentServiceException('Failed to check subscription: $e');
    }
  }

  /// Gets product details by ID
  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Disposes the service
  void dispose() {
    _subscription.cancel();
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
