// Subscription packages and pricing constants
class SubscriptionConstants {
  // RevenueCat Product IDs
  static const String basicMonthly = 'basic_monthly';
  static const String proMonthly = 'pro_monthly';
  static const String eliteMonthly = 'elite_monthly';
  
  // Pricing (for display purposes)
  static const double basicPrice = 29.99;
  static const double proPrice = 49.99;
  static const double elitePrice = 99.99;
  
  // Features
  static const int basicQuestionsPerDay = 10;
  static const int proQuestionsPerDay = 50;
  static const int eliteQuestionsPerDay = -1; // Unlimited
  
  static const bool basicDetailedExplanations = false;
  static const bool proDetailedExplanations = true;
  static const bool eliteDetailedExplanations = true;
  
  static const bool basicStepByStep = false;
  static const bool proStepByStep = true;
  static const bool eliteStepByStep = true;
  
  static const bool basicPrioritySupport = false;
  static const bool proPrioritySupport = false;
  static const bool elitePrioritySupport = true;
  
  static const bool basicAdsRemoved = false;
  static const bool proAdsRemoved = true;
  static const bool eliteAdsRemoved = true;
}
