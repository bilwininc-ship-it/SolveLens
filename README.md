# SolveLens - AI Homework Helper

Global ölçekte hizmet veren, Gemini API destekli ödev yardýmcýsý uygulamasý.

##  Architecture

Bu proje Clean Architecture prensiplerine uygun olarak tasarlanmýþtýr:

### Katmanlar

#### 1. Presentation Layer (lib/presentation/)
- UI komponenleri, ekranlar ve state management
- Provider pattern kullanýlarak state yönetimi
- Kullanýcý etkileþimlerini handle eder

#### 2. Domain Layer (lib/domain/)
- Business logic ve use cases
- Entity tanýmlarý
- Repository interface'leri
- Framework baðýmsýz pure Dart kodu

#### 3. Data Layer (lib/data/)
- Repository implementasyonlarý
- Data source'lar (Remote: Firebase, Local: SharedPreferences)
- Model sýnýflarý (Entity -> Model dönüþümleri)

#### 4. Core Layer (lib/core/)
- Uygulama genelinde kullanýlan utilities
- Constants, theme, custom widgets
- Error handling

##  IAP (In-App Purchase) Güvenlik Mimarisi

### RevenueCat Entegrasyonu

1. **Client-Side Validation**
   - RevenueCat SDK otomatik olarak receipt'leri Apple/Google'a gönderir
   - purchases_flutter paketi kullanýlýr
   
\\\dart
import 'package:purchases_flutter/purchases_flutter.dart';

// Initialize
await Purchases.configure(
  PurchasesConfiguration(AppConstants.revenueCatApiKey)
);

// Satýn alma
try {
  CustomerInfo customerInfo = await Purchases.purchasePackage(package);
  // Subscription aktif kontrolü
  if (customerInfo.entitlements.all['pro']?.isActive == true) {
    // Pro özelliklere eriþim ver
  }
} catch (e) {
  // Hata yönetimi
}
\\\

2. **Server-Side Validation (Firebase Cloud Functions)**
   
\\\javascript
// Firebase Cloud Function
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.updateSubscription = functions.https.onCall(async (data, context) => {
  // RevenueCat Webhook'tan gelen veriyi doðrula
  const userId = data.userId;
  const subscriptionType = data.subscriptionType;
  const expiryDate = data.expiryDate;
  
  // Firestore'da kullanýcý subscription bilgisini güncelle
  await admin.firestore()
    .collection('users')
    .doc(userId)
    .update({
      subscriptionType: subscriptionType,
      subscriptionExpiryDate: expiryDate,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  
  return { success: true };
});
\\\

3. **RevenueCat Webhook Configuration**
   - RevenueCat Dashboard > Integrations > Webhooks
   - Firebase Cloud Function URL'inizi ekleyin
   - Events: Initial Purchase, Renewal, Cancellation, Expiration

### Firebase Security Rules

\\\javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanýcý sadece kendi verilerini okuyabilir/yazabilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Questions collection - sadece kendi sorularýný görebilir
    match /questions/{questionId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
    }
    
    // Subscriptions - read-only client-side
    match /subscriptions/{subscriptionId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow write: if false; // Sadece server-side güncellenebilir
    }
  }
}
\\\

### Google Cloud Configuration

1. **API Keys Güvenliði**
   - Gemini API Key'i environment variable'dan alýn
   - Firebase'de API key restrictions ekleyin
   - Android: SHA-1/SHA-256 fingerprint kýsýtlamasý
   - iOS: Bundle ID kýsýtlamasý

2. **Cloud Functions Deployment**
\\\ash
# Firebase CLI kurulumu
npm install -g firebase-tools
firebase login
firebase init functions

# Deploy
firebase deploy --only functions
\\\

3. **Rate Limiting (Cloud Functions)**
\\\javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 dakika
  max: 100 // Her IP için maksimum 100 istek
});

exports.askQuestion = functions.https.onCall(async (data, context) => {
  // Authentication kontrolü
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }
  
  // Günlük soru limitini kontrol et
  const userId = context.auth.uid;
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();
    
  const subscriptionType = userDoc.data().subscriptionType;
  const questionsUsedToday = userDoc.data().questionsUsedToday || 0;
  
  // Limit kontrolü
  const limits = {
    'free': 3,
    'basic': 10,
    'pro': 50,
    'elite': -1 // unlimited
  };
  
  if (limits[subscriptionType] !== -1 && 
      questionsUsedToday >= limits[subscriptionType]) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Daily question limit reached'
    );
  }
  
  // Gemini API'ye istek gönder
  // ...
  
  return { answer: result };
});
\\\

## ?? Abonelik Paketleri

| Paket | Fiyat | Günlük Soru | Detaylý Açýklama | Adým Adým Çözüm | Reklamsýz |
|-------|-------|-------------|------------------|-----------------|-----------|
| Free  |     | 3           |                |               |         |
| Basic | .99| 10          | ?               | ?              |         |
| Pro   | .99| 50          |                |               |         |
| Elite | .99| Sýnýrsýz    |                |               |         |

##  Kurulum

1. Flutter SDK'yý yükleyin (3.0.0+)
2. Firebase projesini oluþturun
3. FlutterFire CLI ile Firebase'i yapýlandýrýn:
\\\ash
firebase login
flutterfire configure
\\\

4. Baðýmlýlýklarý yükleyin:
\\\ash
flutter pub get
\\\

5. Environment variables'ý ayarlayýn (.env dosyasý)
\\\
GEMINI_API_KEY=your_key_here
REVENUECAT_API_KEY=your_key_here
\\\

##  Çalýþtýrma

\\\ash
flutter run
\\\

##  Geliþtirme Notlarý

- Gemini API rate limiting'e dikkat edin
- Firebase Firestore için composite index'ler oluþturun
- RevenueCat sandbox ortamýnda test edin
- App Store/Google Play IAP test kullanýcýlarý oluþturun

##  Lisans

Proprietary - Tüm haklarý saklýdýr
