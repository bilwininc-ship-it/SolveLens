// Subscription packages and pricing constants
// Updated for Google Play In-App Purchase
class SubscriptionConstants {
  // Google Play In-App Product IDs
  // Monthly subscriptions
  static const String basicMonthly = 'solvelens_basic_monthly';
  static const String proMonthly = 'solvelens_pro_monthly';
  static const String eliteMonthly = 'solvelens_elite_monthly';
  
  // Yearly subscriptions (optional - for better value)
  static const String basicYearly = 'solvelens_basic_yearly';
  static const String proYearly = 'solvelens_pro_yearly';
  static const String eliteYearly = 'solvelens_elite_yearly';
  
  // Pricing (for display purposes - actual prices from Play Console)
  static const double basicMonthlyPrice = 29.99;
  static const double proMonthlyPrice = 49.99;
  static const double eliteMonthlyPrice = 99.99;
  
  static const double basicYearlyPrice = 299.99; // ~17% discount
  static const double proYearlyPrice = 499.99; // ~17% discount
  static const double eliteYearlyPrice = 999.99; // ~17% discount
  
  // Question Limits per Day
  static const int freeQuestionsPerDay = 3; // Free tier
  static const int basicQuestionsPerDay = 50;
  static const int proQuestionsPerDay = 200;
  static const int eliteQuestionsPerDay = -1; // Unlimited
  
  // Price Getters (for backward compatibility)
  static double get basicPrice => basicMonthlyPrice;
  static double get proPrice => proMonthlyPrice;
  static double get elitePrice => eliteMonthlyPrice;
  
  // Feature Flags
  // Basic Tier
  static const bool basicDetailedExplanations = true;
  static const bool basicStepByStep = false;
  static const bool basicVoiceFeatures = false;
  static const bool basicOfflineMode = false;
  static const bool basicPrioritySupport = false;
  static const bool basicAdsRemoved = true;
  
  // Pro Tier
  static const bool proDetailedExplanations = true;
  static const bool proStepByStep = true;
  static const bool proVoiceFeatures = true;
  static const bool proOfflineMode = true;
  static const bool proPrioritySupport = false;
  static const bool proAdsRemoved = true;
  
  // Elite Tier
  static const bool eliteDetailedExplanations = true;
  static const bool eliteStepByStep = true;
  static const bool eliteVoiceFeatures = true;
  static const bool eliteOfflineMode = true;
  static const bool elitePrioritySupport = true;
  static const bool eliteAdsRemoved = true;
  static const bool eliteCustomAIPersonality = true;
  static const bool eliteGroupFeatures = true;
}

