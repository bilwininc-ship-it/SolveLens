import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/remote_config/remote_config_service.dart';
import '../../../../services/analytics/analytics_service.dart';
import '../../../../services/ads/ads_service.dart';
import '../../../../services/credit_timer/credit_timer_logic.dart';
import '../widgets/announcement_banner.dart';

/// Dashboard Screen - Main control center for SolveLens
/// Features:
/// - Elite header with user greeting and real-time credits
/// - Dynamic announcement banner from Remote Config
/// - Primary actions (New Analysis, etc.)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showAnnouncement = true;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    // Log screen view for analytics
    AnalyticsService.logScreenView('dashboard');
    
    // Start countdown timer for rewarded ads
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Start countdown timer that updates every minute
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // Timer will trigger rebuild to update countdown
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 600;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not authenticated'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            // Announcement Banner (if enabled)
            if (_showAnnouncement && RemoteConfigService.shouldShowAnnouncement)
              AnnouncementBanner(
                message: RemoteConfigService.dashboardAnnouncement,
                onDismiss: () {
                  setState(() {
                    _showAnnouncement = false;
                  });
                },
              ),

            // Main Content
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWeb ? 1200 : double.infinity,
                  ),
                  child: CustomScrollView(
                    slivers: [
                      // Elite Header
                      SliverToBoxAdapter(
                        child: _buildEliteHeader(user),
                      ),

                      // Main Dashboard Content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWeb ? 48 : 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 32),

                              // Primary Action Button
                              _buildPrimaryActionButton(),

                              const SizedBox(height: 24),

                              // Rewarded Ad Credit Button (Mobile only)
                              if (!kIsWeb) _buildRewardedAdButton(user),

                              const SizedBox(height: 32),

                              // Quick Stats
                              _buildQuickStats(user.uid),

                              const SizedBox(height: 32),

                              // Feature Cards
                              _buildFeatureCards(),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Elite Header with greeting and real-time credits
  Widget _buildEliteHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.navyLight,
            AppColors.navy,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.cyanNeon.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.cyanNeon, AppColors.info],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                _getInitials(user.displayName ?? user.email ?? 'User'),
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${_getFirstName(user.displayName ?? user.email ?? 'User')}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ivory,
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Welcome back to SolveLens',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                ),
              ],
            ),
          ),

          // Real-time Credits Chip
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              int credits = 0;
              bool isPremium = false;

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                credits = data?['credits'] ?? 0;
                isPremium = data?['isPremium'] ?? false;
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPremium
                        ? [AppColors.warning, AppColors.success]
                        : [AppColors.cyanNeon, AppColors.info],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: (isPremium ? AppColors.warning : AppColors.cyanNeon)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPremium ? Icons.diamond_rounded : Icons.stars_rounded,
                      color: AppColors.navy,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPremium ? 'Premium' : 'Credits: $credits',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Primary action button (New Analysis)
  Widget _buildPrimaryActionButton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cyanNeon.withOpacity(0.2),
            AppColors.info.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cyanNeon.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to analysis screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Analysis feature coming soon!'),
                backgroundColor: AppColors.info,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.cyanNeon,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyanNeon.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 40,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'New Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ivory,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload bulletin and get AI predictions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Quick stats cards
  Widget _buildQuickStats(String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        int credits = 0;
        bool isPremium = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          credits = data?['credits'] ?? 0;
          isPremium = data?['isPremium'] ?? false;
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.analytics_rounded,
                label: 'Analyses',
                value: '0', // TODO: Fetch from Firestore
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up_rounded,
                label: 'Accuracy',
                value: '0%', // TODO: Calculate from history
                color: AppColors.success,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.ivory,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey,
                ),
          ),
        ],
      ),
    );
  }

  /// Feature cards
  Widget _buildFeatureCards() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.history_rounded,
          title: 'Analysis History',
          description: 'View your past predictions',
          onTap: () {
            // TODO: Navigate to history
          },
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.workspace_premium_rounded,
          title: 'Go Premium',
          description: 'Unlimited analyses + exclusive features',
          gradient: [AppColors.warning, AppColors.success],
          onTap: () {
            // TODO: Navigate to premium
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    List<Color>? gradient,
    required VoidCallback onTap,
  }) {
    final colors = gradient ?? [AppColors.navyLight, AppColors.navyLight];

    return Container(
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(
                colors: colors.map((c) => c.withOpacity(0.2)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: gradient == null ? AppColors.navyLight : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (gradient?.first ?? AppColors.cyanNeon).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (gradient?.first ?? AppColors.cyanNeon)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: gradient?.first ?? AppColors.cyanNeon,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.ivory,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Elite Rewarded Ad Button - Watch & Get +1 Free Credit
  /// 
  /// Features:
  /// - 24-hour cooldown enforcement
  /// - Real-time countdown timer
  /// - Cyan Neon gradient when available
  /// - Disabled grey state with countdown
  /// - Mobile only (hidden on Web)
  Widget _buildRewardedAdButton(User user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final lastAdClaimAt = data?['last_ad_claim_at'] as Timestamp?;
        final isPremium = data?['isPremium'] ?? false;

        // Premium users don't need free credits from ads
        if (isPremium) {
          return const SizedBox.shrink();
        }

        final canClaim = CreditTimerLogic.canClaimCredit(lastAdClaimAt);
        final remainingTime = CreditTimerLogic.getRemainingTime(lastAdClaimAt);
        final formattedTime = CreditTimerLogic.formatRemainingTime(remainingTime);

        return Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: canClaim
                  ? [
                      AppColors.cyanNeon.withOpacity(0.2),
                      AppColors.info.withOpacity(0.1),
                    ]
                  : [
                      AppColors.grey.withOpacity(0.1),
                      AppColors.navyLight.withOpacity(0.1),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canClaim
                  ? AppColors.cyanNeon.withOpacity(0.4)
                  : AppColors.grey.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('rewarded-ad-button'),
              onTap: canClaim && !_isLoadingAd
                  ? () => _handleRewardedAdClick(user.uid)
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icon Section
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: canClaim
                            ? const LinearGradient(
                                colors: [AppColors.cyanNeon, AppColors.info],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  AppColors.grey.withOpacity(0.3),
                                  AppColors.greyDark.withOpacity(0.3),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: canClaim
                            ? [
                                BoxShadow(
                                  color: AppColors.cyanNeon.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        canClaim ? Icons.play_circle_filled : Icons.schedule,
                        color: canClaim ? AppColors.navy : AppColors.grey,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Watch & Get +1 Free Credit',
                            key: const Key('rewarded-ad-title'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: canClaim
                                      ? AppColors.ivory
                                      : AppColors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            canClaim
                                ? _isLoadingAd
                                    ? 'Loading ad...'
                                    : 'Tap to watch a short video'
                                : 'Available in $formattedTime',
                            key: const Key('rewarded-ad-subtitle'),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.grey,
                                    ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    if (canClaim && !_isLoadingAd)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.cyanNeon,
                        size: 20,
                      )
                    else if (_isLoadingAd)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.cyanNeon,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handle rewarded ad click
  /// 
  /// Flow:
  /// 1. Check if ad is ready
  /// 2. Show rewarded ad
  /// 3. On reward: +1 credit, update timestamp, log analytics
  /// 4. Show success message
  Future<void> _handleRewardedAdClick(String userId) async {
    // Check if ad is ready
    if (!AdsService.isRewardedAdReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad is not ready yet. Please try again in a moment.'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingAd = true;
    });

    try {
      // Show rewarded ad
      await AdsService.showRewardedAd(
        userId: userId,
        onRewarded: (creditsEarned) async {
          try {
            // Complete ad claim: +1 credit & update timestamp
            await CreditTimerLogic.completeAdClaim(userId);

            // Log analytics
            await AnalyticsService.logRewardedAdWatched(
              userId: userId,
              creditsEarned: creditsEarned,
            );

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.navy,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '+$creditsEarned Credit Earned! 🎉',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.cyanNeon,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update credits: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
        onAdClosed: () {
          if (mounted) {
            setState(() {
              _isLoadingAd = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAd = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to show ad: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Helper methods
  String _getInitials(String name) {
    if (name.contains('@')) {
      return name[0].toUpperCase();
    }
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getFirstName(String name) {
    if (name.contains('@')) {
      return name.split('@')[0];
    }
    return name.split(' ')[0];
  }
}
