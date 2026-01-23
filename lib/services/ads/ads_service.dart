import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../analytics/analytics_service.dart';
import '../../core/utils/logger.dart';

/// Ads Service - AdMob Integration & Rewarded Ad Management
/// Handles banner ads, interstitial ads, and rewarded video ads
/// Integrates with Analytics Service for conversion tracking
class AdsService {
  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdReady = false;

  /// Initialize AdMob SDK
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      Logger.log('AdMob initialized successfully', tag: 'Ads');
      
      // Pre-load rewarded ad
      await loadRewardedAd();
    } catch (e) {
      Logger.error('AdMob initialization failed', error: e, tag: 'Ads');
    }
  }

  // ==================== AD UNIT IDs ====================

  /// Banner Ad Unit ID (Test ID - Replace with your production ID)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
      // Production: Replace with your real Ad Unit ID from AdMob Console
      // return 'ca-app-pub-XXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
      // Production: Replace with your real Ad Unit ID
    } else {
      throw UnsupportedError('Unsupported platform for banner ads');
    }
  }

  /// Interstitial Ad Unit ID (Test ID - Replace with your production ID)
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
      // Production: Replace with your real Ad Unit ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
      // Production: Replace with your real Ad Unit ID
    } else {
      throw UnsupportedError('Unsupported platform for interstitial ads');
    }
  }

  /// Rewarded Ad Unit ID (Test ID - Replace with your production ID)
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
      // Production: Replace with your real Ad Unit ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
      // Production: Replace with your real Ad Unit ID
    } else {
      throw UnsupportedError('Unsupported platform for rewarded ads');
    }
  }

  // ==================== BANNER ADS ====================

  /// Create a banner ad instance
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          Logger.log('Banner ad loaded', tag: 'Ads');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          Logger.error('Banner ad failed to load', error: error, tag: 'Ads');
        },
        onAdOpened: (ad) {
          Logger.log('Banner ad opened', tag: 'Ads');
        },
        onAdClosed: (ad) {
          Logger.log('Banner ad closed', tag: 'Ads');
        },
      ),
    );
  }

  // ==================== REWARDED ADS ====================

  /// Load a rewarded ad
  static Future<void> loadRewardedAd() async {
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
            Logger.log('Rewarded ad loaded successfully', tag: 'Ads');

            // Set full screen content callback
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                Logger.log('Rewarded ad showed full screen', tag: 'Ads');
              },
              onAdDismissedFullScreenContent: (ad) {
                Logger.log('Rewarded ad dismissed', tag: 'Ads');
                ad.dispose();
                _rewardedAd = null;
                _isRewardedAdReady = false;
                // Pre-load next ad
                loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                Logger.error(
                  'Rewarded ad failed to show',
                  error: error,
                  tag: 'Ads',
                );
                ad.dispose();
                _rewardedAd = null;
                _isRewardedAdReady = false;
                // Pre-load next ad
                loadRewardedAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            _isRewardedAdReady = false;
            Logger.error(
              'Rewarded ad failed to load',
              error: error,
              tag: 'Ads',
            );
          },
        ),
      );
    } catch (e) {
      Logger.error('Error loading rewarded ad', error: e, tag: 'Ads');
    }
  }

  /// Check if rewarded ad is ready to show
  static bool get isRewardedAdReady => _isRewardedAdReady;

  /// Show rewarded ad and handle reward
  /// 
  /// Parameters:
  /// - [userId]: User ID for analytics tracking
  /// - [onRewarded]: Callback when user earns reward (returns credits earned)
  /// - [onAdClosed]: Callback when ad is closed (regardless of reward)
  static Future<void> showRewardedAd({
    required String userId,
    required Function(int creditsEarned) onRewarded,
    Function()? onAdClosed,
  }) async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      Logger.error(
        'Rewarded ad not ready. Please wait...',
        tag: 'Ads',
      );
      return;
    }

    try {
      // Show the ad
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          final creditsEarned = reward.amount.toInt();
          Logger.log(
            'User earned reward: $creditsEarned credits',
            tag: 'Ads',
          );

          // Track rewarded ad completion in Analytics
          AnalyticsService.logRewardedAdWatched(
            userId: userId,
            creditsEarned: creditsEarned,
          );

          // Execute reward callback
          onRewarded(creditsEarned);
        },
      );

      // Execute close callback if provided
      if (onAdClosed != null) {
        onAdClosed();
      }
    } catch (e) {
      Logger.error('Error showing rewarded ad', error: e, tag: 'Ads');
    }
  }

  // ==================== INTERSTITIAL ADS ====================

  /// Load and show an interstitial ad
  static Future<void> showInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            Logger.log('Interstitial ad loaded', tag: 'Ads');
            
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                Logger.log('Interstitial ad dismissed', tag: 'Ads');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                Logger.error(
                  'Interstitial ad failed to show',
                  error: error,
                  tag: 'Ads',
                );
              },
            );

            ad.show();
          },
          onAdFailedToLoad: (error) {
            Logger.error(
              'Interstitial ad failed to load',
              error: error,
              tag: 'Ads',
            );
          },
        ),
      );
    } catch (e) {
      Logger.error('Error with interstitial ad', error: e, tag: 'Ads');
    }
  }

  // ==================== CLEANUP ====================

  /// Dispose of all ad resources
  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
    Logger.log('Ads service disposed', tag: 'Ads');
  }
}
