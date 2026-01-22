# Firestore Security Rules - SolveLens

## Overview
These security rules ensure that users can only access their own data (credits, history, profile).

## Rules Configuration

Copy these rules to Firebase Console > Firestore Database > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user is owner of the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection - Users can only read/write their own document
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isOwner(userId) && 
                      // Prevent users from manually setting isPremium to true
                      (!request.resource.data.diff(resource.data).affectedKeys().hasAny(['isPremium']));
      allow delete: if isOwner(userId);
    }
    
    // Analysis history - Users can only access their own history
    match /history/{historyId} {
      allow read: if isAuthenticated() && 
                    resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && 
                      request.resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid;
      allow delete: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid;
    }
    
    // Analyses collection - Users can only access their own analyses
    match /analyses/{analysisId} {
      allow read: if isAuthenticated() && 
                    resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && 
                      request.resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid;
      allow delete: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid;
    }
    
    // Subscriptions collection - Users can only read their own subscriptions
    match /subscriptions/{subscriptionId} {
      allow read: if isAuthenticated() && 
                    resource.data.userId == request.auth.uid;
      // Only server (Cloud Functions) can create/update subscriptions
      allow write: if false;
    }
    
    // Deny all other access by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Key Security Features

### 1. **User Isolation**
- Each user can ONLY access their own documents
- `userId` field is validated on all operations
- Authentication is required for all operations

### 2. **Credit Protection**
- Users cannot manually modify `isPremium` field
- Only Cloud Functions can grant premium status
- Prevents unauthorized credit manipulation

### 3. **History Privacy**
- Analysis history is strictly private
- No cross-user data access
- Read/write limited to document owner

### 4. **Subscription Security**
- Subscription documents are read-only for users
- Only server-side Cloud Functions can write
- Prevents fraudulent subscription claims

## Testing Security Rules

### Test in Firebase Console:

1. Go to Firestore > Rules tab
2. Click "Rules Playground"
3. Test scenarios:

**Test 1: User reads their own data**
```
Simulated User: user123
Path: /users/user123
Operation: get
Result: ✅ ALLOW
```

**Test 2: User tries to read another user's data**
```
Simulated User: user123
Path: /users/user456
Operation: get
Result: ❌ DENY
```

**Test 3: User tries to set isPremium**
```
Simulated User: user123
Path: /users/user123
Operation: update
Data: { isPremium: true }
Result: ❌ DENY
```

## Remote Config Default Values

Set these in Firebase Console > Remote Config:

```json
{
  "is_maintenance": false,
  "app_version": "1.0.0",
  "announcement_message": "Welcome to SolveLens!",
  "daily_free_credits": 3,
  "ad_reward_credits": 1,
  "premium_daily_limit": 15
}
```

## Implementation Checklist

- [ ] Copy security rules to Firebase Console
- [ ] Test rules in Rules Playground
- [ ] Set up Remote Config default values
- [ ] Enable Firebase Analytics
- [ ] Enable Firebase Crashlytics
- [ ] Configure Cloud Messaging (FCM)
- [ ] Update `firebase_options.dart` with actual credentials

## Next Steps (Phase 3)

After implementing these security rules, you'll be ready for:
- Auth UI (Login/Register screens)
- Email validation
- Password reset functionality
- Google Sign-In integration
