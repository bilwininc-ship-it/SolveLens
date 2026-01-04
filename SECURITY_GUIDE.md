# SolveLens Security Implementation Guide

## Security by Design Principles

This project implements defense-in-depth security with multiple layers:

### 1. **Client-Side Security**

#### RevenueCat Integration
- All subscription checks happen through RevenueCat SDK
- No local storage of subscription status (always fetch from server)
- Automatic receipt validation

#### Daily Limit Enforcement
\\\dart
// Check before EVERY API call
if (await userService.hasExceededDailyLimit(userId, dailyLimit)) {
  // Show upgrade screen
  return;
}
\\\

#### Secure API Key Storage
- Use Firebase Remote Config for production
- Never hardcode keys in source code
- Environment variables for development

### 2. **Firestore Security Rules**

#### User Document Rules
\\\javascript
// Users can ONLY read their own data
allow read: if isOwner(userId);

// CANNOT modify subscription fields client-side
allow update: if !affectedKeys().hasAny([
  'subscriptionType',
  'dailyLimit',
  'subscriptionExpiryDate'
]);
\\\

#### Question Document Rules
\\\javascript
// Users can ONLY see their own questions
allow read: if resource.data.userId == request.auth.uid;

// Questions cannot be modified after creation
allow update, delete: if false;
\\\

### 3. **Server-Side Validation (Cloud Functions)**

#### RevenueCat Webhook
- Verifies webhook authenticity with Bearer token
- Updates Firestore subscription status
- Atomic transactions prevent race conditions

#### Quota Check Function
\\\javascript
// Callable function for additional server-side validation
exports.checkUserQuota = functions.https.onCall(async (data, context) => {
  // Authenticate
  if (!context.auth) throw new Error('Unauthenticated');
  
  // Check quota server-side
  const canProceed = await validateQuota(context.auth.uid);
  
  return { canProceed };
});
\\\

## Setup Instructions

### 1. Firebase Project Setup

\\\ash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init

# Select:
# - Firestore (Database rules)
# - Functions (Cloud Functions)
# - Hosting (Optional)
\\\

### 2. Deploy Firestore Rules

\\\ash
firebase deploy --only firestore:rules
\\\

### 3. Setup Cloud Functions

\\\ash
cd functions
npm install

# Set RevenueCat webhook key
firebase functions:config:set revenuecat.webhook_key="YOUR_WEBHOOK_KEY"

# Deploy functions
firebase deploy --only functions
\\\

### 4. Configure RevenueCat Webhook

1. Go to RevenueCat Dashboard  Project Settings  Webhooks
2. Add webhook URL: \https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/revenuecatWebhook\
3. Set Authorization Header: \Bearer YOUR_WEBHOOK_KEY\
4. Select events:
   - INITIAL_PURCHASE
   - RENEWAL
   - CANCELLATION
   - EXPIRATION
   - BILLING_ISSUE

### 5. Firebase Remote Config Setup

1. Go to Firebase Console  Remote Config
2. Add parameters:
   - \gemini_api_key\: Your Gemini API key
   - \max_free_questions\: 3
   - \enable_premium_features\: true

3. In your app:
\\\dart
await RemoteConfigService().initialize();
final apiKey = remoteConfigService.getGeminiApiKey(AppConstants.geminiApiKey);
\\\

## Security Best Practices

###  DO

1. **Always validate server-side**
   - Never trust client input
   - Use Cloud Functions for critical checks

2. **Use atomic transactions**
\\\dart
await firestore.runTransaction((transaction) async {
  // Read, check, then write - all atomic
});
\\\

3. **Rate limit API calls**
   - Implement exponential backoff
   - Cache responses when possible

4. **Monitor suspicious activity**
   - Track API usage patterns
   - Alert on abnormal behavior

5. **Keep secrets secret**
   - Use environment variables
   - Never commit .env files
   - Rotate keys regularly

###  DON'T

1. **Never hardcode API keys**
\\\dart
// BAD
const apiKey = 'AIzaSy...';

// GOOD
final apiKey = remoteConfig.getString('gemini_api_key');
\\\

2. **Never trust client subscription status**
\\\dart
// BAD
if (localSubscriptionStatus == 'pro') { ... }

// GOOD
final status = await paymentService.checkSubscriptionStatus();
\\\

3. **Never allow client to modify critical fields**
   - subscriptionType
   - dailyLimit
   - subscriptionExpiryDate

4. **Never skip authentication checks**
\\\dart
// ALWAYS check auth first
if (!context.auth) throw new Error('Unauthenticated');
\\\

## Testing Security

### Test Rate Limiting
\\\dart
// Simulate rapid requests
for (int i = 0; i < 10; i++) {
  await analyzeQuestion(...);
}
// Should be blocked after limit
\\\

### Test Firestore Rules
\\\ash
# Use Firebase Emulator
firebase emulators:start

# Run rule tests
npm test
\\\

### Test Webhook
\\\ash
# Use RevenueCat sandbox environment
# Simulate purchase events
# Verify Firestore updates
\\\

## Monitoring & Alerts

### Key Metrics to Monitor

1. **API Usage**
   - Requests per user per day
   - Failed authentication attempts
   - Rate limit hits

2. **Subscription Events**
   - New purchases
   - Cancellations
   - Failed payments

3. **Security Events**
   - Rule violations
   - Suspicious patterns
   - Quota bypass attempts

### Setup Alerts

\\\javascript
// Cloud Function to detect abuse
exports.detectAbuse = functions.firestore
  .document('questions/{questionId}')
  .onCreate(async (snap, context) => {
    const userId = snap.data().userId;
    
    // Check recent activity
    const recentQuestions = await db.collection('questions')
      .where('userId', '==', userId)
      .where('createdAt', '>', oneHourAgo)
      .get();
    
    if (recentQuestions.size > 20) {
      // Alert: Possible abuse
      await sendAlertToAdmin(userId);
    }
  });
\\\

## Incident Response

### If API Key is Compromised

1. Immediately revoke key in Google Cloud Console
2. Generate new key
3. Update Firebase Remote Config
4. Force app refresh via Remote Config
5. Review access logs for abuse

### If Unauthorized Access Detected

1. Review Firestore Security Rules
2. Check Cloud Function logs
3. Revoke user sessions if needed
4. Update rules and redeploy

## Compliance

### GDPR
- Users can delete their data
- Data export functionality
- Clear privacy policy

### PCI DSS
- No credit card data stored
- All payments through RevenueCat
- PCI-compliant infrastructure

## Questions?

For security issues, contact: security@solvelens.app
