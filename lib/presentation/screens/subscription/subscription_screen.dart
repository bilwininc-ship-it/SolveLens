// Premium subscription packages screen with animated Elite tier
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../core/constants/subscription_constants.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  int _selectedIndex = 2; // Elite recommended by default

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Unlock Your Full\nPotential',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get instant homework help powered by AI',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),

                    // Subscription Cards
                    _buildSubscriptionCard(
                      index: 0,
                      title: 'Basic',
                      price: '\$${SubscriptionConstants.basicPrice}',
                      period: '/month',
                      features: [
                        '${SubscriptionConstants.basicQuestionsPerDay} questions per day',
                        'Basic explanations',
                        'Standard support',
                        'Ads included',
                      ],
                      isRecommended: false,
                    ),
                    const SizedBox(height: 16),

                    _buildSubscriptionCard(
                      index: 1,
                      title: 'Pro',
                      price: '\$${SubscriptionConstants.proPrice}',
                      period: '/month',
                      features: [
                        '${SubscriptionConstants.proQuestionsPerDay} questions per day',
                        'Detailed explanations',
                        'Step-by-step solutions',
                        'Ad-free experience',
                      ],
                      isRecommended: false,
                    ),
                    const SizedBox(height: 16),

                    _buildSubscriptionCard(
                      index: 2,
                      title: 'Elite',
                      price: '\$${SubscriptionConstants.elitePrice}',
                      period: '/month',
                      features: [
                        'Unlimited questions',
                        'Detailed explanations',
                        'Step-by-step solutions',
                        'Priority support',
                        'Ad-free experience',
                        'Exclusive features',
                      ],
                      isRecommended: true,
                    ),
                  ],
                ),
              ),
            ),

            // Subscribe Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.navyDark,
                    AppTheme.navyDark.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showComingSoonDialog();
                  },
                  child: const Text('Subscribe Now'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required int index,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isRecommended,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isRecommended
                  ? LinearGradient(
                      colors: [
                        AppTheme.premiumGold.withValues(alpha: 0.3 + _glowController.value * 0.2),
                        AppTheme.premiumGold.withValues(alpha: 0.2 + _glowController.value * 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: isRecommended
                  ? Border.all(
                      color: AppTheme.premiumGold.withValues(alpha: 0.5 + _glowController.value * 0.5),
                      width: 2,
                    )
                  : null,
              boxShadow: isRecommended
                  ? [
                      BoxShadow(
                        color: AppTheme.premiumGold.withValues(alpha: 0.3 + _glowController.value * 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.mediumGrey
                    : AppTheme.darkGrey,
                borderRadius: BorderRadius.circular(20),
                border: isSelected && !isRecommended
                    ? Border.all(color: AppTheme.premiumGold, width: 2)
                    : null,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                price,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.premiumGold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4, left: 4),
                                child: Text(
                                  period,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.premiumGold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              color: AppTheme.navyDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Features
                  ...features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.premiumGold,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showComingSoonDialog() {
    final packages = ['Basic', 'Pro', 'Elite'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mediumGrey,
        title: const Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.premiumGold,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('Coming Soon'),
          ],
        ),
        content: Text(
          'Premium subscriptions are currently being configured. The ${packages[_selectedIndex]} plan will be available soon!\n\nStay tuned for exciting features.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.premiumGold,
              foregroundColor: AppTheme.navyDark,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
