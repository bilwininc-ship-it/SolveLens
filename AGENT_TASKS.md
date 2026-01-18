# 🤖 SolveLens - Agent Task List (Bölüm Bölüm İşler)

Her bölümü farklı bir agenta verebilirsiniz. Her task bağımsız çalışabilir.

---

## 📋 **PHASE 1: KRİTİK GÜVENLİK ve ALTYAPI (1-2 Hafta)**

### ✅ **TASK 1.1: Environment Variables & API Key Security**
**Öncelik:** 🔴 KRİTİK
**Süre:** 2-3 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: API key'lerini hardcoded'dan .env dosyasına taşı ve güvenli hale getir.

ADIMLAR:
1. flutter_dotenv paketini ekle (pubspec.yaml)
2. .env dosyası oluştur (root directory'de)
3. .env dosyasına tüm API key'leri ekle:
   - GEMINI_API_KEY
   - REVENUECAT_API_KEY
   - GOOGLE_CLOUD_TTS_KEY
4. .gitignore dosyasına .env ekle
5. .env.example dosyası oluştur (template için)
6. lib/core/constants/app_constants.dart dosyasını güncelle
7. main.dart'ta .env'yi load et

DEĞIŞECEK DOSYALAR:
- pubspec.yaml
- .env (yeni)
- .env.example (yeni)
- .gitignore
- lib/core/constants/app_constants.dart
- lib/main.dart

TEST:
- Uygulama başlasın
- API key'ler .env'den okunabilsin
- Hardcoded key kalmamalı
```

---

### ✅ **TASK 1.2: Firebase Analytics Integration**
**Öncelik:** 🔴 KRİTİK
**Süre:** 3-4 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Firebase Analytics, Crashlytics ve Performance Monitoring entegre et.

ADIMLAR:
1. Paketleri ekle:
   - firebase_analytics: ^11.3.4
   - firebase_crashlytics: ^4.1.4
   - firebase_performance: ^0.10.0+8

2. services/analytics/analytics_service.dart oluştur:
   - logEvent() metodu
   - logScreenView() metodu
   - setUserId() metodu
   - setUserProperty() metodu

3. Her önemli aksiyon için event tracking ekle:
   - question_analyzed
   - user_login
   - subscription_purchased
   - feature_used
   - error_occurred

4. Crashlytics'i initialize et (main.dart)

5. Performance monitoring başlat

6. Test events gönder

OLUŞTURULACAK DOSYALAR:
- lib/services/analytics/analytics_service.dart
- lib/core/di/service_locator.dart (güncelle)

DEĞİŞECEK DOSYALAR:
- pubspec.yaml
- lib/main.dart
- lib/presentation/screens/* (event tracking ekle)
- lib/services/ai/ai_service.dart (event tracking ekle)

TEST:
- Firebase Console'da events görünmeli
- Crashlytics test crash'i çalışmalı
- Performance metrics görünmeli
```

---

### ✅ **TASK 1.3: Centralized Error Handling System**
**Öncelik:** 🔴 KRİTİK
**Süre:** 4-5 saat
**Bağımlılık:** TASK 1.2 (Analytics)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Kullanıcı dostu merkezi error handling sistemi oluştur.

ADIMLAR:
1. Paketleri ekle:
   - fluttertoast: ^8.2.8
   - awesome_dialog: ^3.2.1

2. lib/core/errors/error_handler.dart oluştur:
   - showError() - Error dialog göster
   - showSuccess() - Success message
   - showWarning() - Warning message
   - logError() - Analytics'e log

3. lib/core/errors/app_exceptions.dart oluştur:
   - NetworkException
   - AuthException
   - QuotaExceededException
   - AIServiceException (zaten var, geliştir)
   - PaymentException

4. Her service'te try-catch blokları ekle ve ErrorHandler kullan

5. User-friendly error messages:
   - Türkçe ve İngilizce
   - Actionable (ne yapmalı)
   - Retry button'ları

OLUŞTURULACAK DOSYALAR:
- lib/core/errors/error_handler.dart
- lib/core/errors/app_exceptions.dart
- lib/core/constants/error_messages.dart

DEĞİŞECEK DOSYALAR:
- lib/services/**/*.dart (tüm servisler)
- lib/presentation/providers/**/*.dart (tüm provider'lar)

TEST:
- Hata durumlarında dialog görünmeli
- Analytics'e log gitmeli
- Retry çalışmalı
```

---

### ✅ **TASK 1.4: Unit Testing Setup**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 6-8 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Kritik servisler için unit testler yaz ve %60+ coverage sağla.

ADIMLAR:
1. Test paketlerini ekle:
   - mockito: ^5.4.4
   - build_runner: ^2.4.12

2. Test dosyaları oluştur:
   test/services/
   ├── ai/ai_service_test.dart
   ├── auth/auth_service_test.dart
   ├── quota/quota_service_test.dart
   ├── payment/payment_service_test.dart
   └── analytics/analytics_service_test.dart

3. Her test dosyası için:
   - Setup ve teardown
   - Mock dependencies
   - Başarı senaryoları
   - Hata senaryoları
   - Edge case'ler

4. Test coverage raporu oluştur

5. CI/CD için test script'i yaz

OLUŞTURULACAK DOSYALAR:
- test/services/**/*_test.dart (5+ dosya)
- test/helpers/mock_*.dart (mock'lar için)

TEST:
- flutter test çalışmalı
- Coverage %60+ olmalı
- Tüm testler pass etmeli
```

---

## 📋 **PHASE 2: KULLANICI DENEYİMİ (2-3 Hafta)**

### ✅ **TASK 2.1: Onboarding Flow**
**Öncelik:** 🔴 KRİTİK
**Süre:** 6-8 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Yeni kullanıcılar için swipeable onboarding ekranları oluştur.

ADIMLAR:
1. Paket ekle:
   - introduction_screen: ^3.1.14
   - shared_preferences: ^2.3.2 (zaten var)

2. lib/presentation/screens/onboarding/onboarding_screen.dart oluştur

3. 5 onboarding sayfası tasarla:
   Sayfa 1: "Welcome to SolveLens" - AI Professor tanıtımı
   Sayfa 2: "Scan & Solve" - Kamera özelliği
   Sayfa 3: "Super Chat" - Chat özelliği
   Sayfa 4: "Voice Learning" - Sesli özellikler
   Sayfa 5: "Get Started" - Sign up/login

4. Her sayfada:
   - Lottie animation (opsiyonel)
   - Title
   - Description
   - Progress indicator

5. SharedPreferences ile "first_launch" flag'i sakla

6. main.dart'ta onboarding check ekle

OLUŞTURULACAK DOSYALAR:
- lib/presentation/screens/onboarding/onboarding_screen.dart
- assets/animations/*.json (Lottie için - opsiyonel)

DEĞİŞECEK DOSYALAR:
- lib/main.dart
- lib/presentation/screens/auth/auth_wrapper.dart

TEST:
- İlk açılışta onboarding gösterilmeli
- Swipe ile ilerleme çalışmalı
- Skip button çalışmalı
- İkinci açılışta gösterilmemeli
```

---

### ✅ **TASK 2.2: Push Notifications System**
**Öncelik:** 🔴 KRİTİK
**Süre:** 8-10 saat
**Bağımlılık:** TASK 1.2 (Analytics)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Firebase Cloud Messaging ile push notification sistemi kur.

ADIMLAR:
1. Paketleri ekle:
   - firebase_messaging: ^15.1.4
   - flutter_local_notifications: ^18.0.1

2. lib/services/notifications/notification_service.dart oluştur:
   - initialize()
   - requestPermission()
   - getFCMToken()
   - handleMessage()
   - scheduleLocalNotification()

3. Notification tipleri:
   - Daily study reminder (her gün 20:00)
   - Streak at risk (20 saat activity yoksa)
   - New feature announcement
   - Subscription expiring (3 gün kala)

4. Background ve foreground handler'lar

5. Notification tap handling (deep linking)

6. Android için:
   - android/app/src/main/AndroidManifest.xml güncelle
   - Notification channel'lar oluştur

7. iOS için:
   - ios/Runner/AppDelegate.swift güncelle
   - APNs setup

OLUŞTURULACAK DOSYALAR:
- lib/services/notifications/notification_service.dart
- lib/core/routing/deep_link_handler.dart

DEĞİŞECEK DOSYALAR:
- pubspec.yaml
- lib/main.dart
- android/app/src/main/AndroidManifest.xml
- ios/Runner/AppDelegate.swift

TEST:
- FCM token alınmalı
- Test notification gönder (Firebase Console)
- Background'da notification gelsin
- Tap ile doğru sayfa açılsın
- Local notification schedule çalışsın
```

---

### ✅ **TASK 2.3: Multi-Language Support (i18n)**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 10-12 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: 5 dil desteği ekle (TR, EN, ES, FR, DE) - easy_localization ile.

ADIMLAR:
1. Paket ekle:
   - easy_localization: ^3.0.0

2. Dil dosyaları oluştur:
   assets/translations/
   ├── en.json (İngilizce)
   ├── tr.json (Türkçe)
   ├── es.json (İspanyolca)
   ├── fr.json (Fransızca)
   └── de.json (Almanca)

3. Her dosyada tüm string'leri çevir:
   - UI texts
   - Error messages
   - Success messages
   - Onboarding texts
   - Subscription details

4. main.dart'ta EasyLocalization initialize et

5. Language selector widget oluştur:
   - lib/presentation/widgets/language_selector.dart
   - Profile screen'de göster

6. System language'e göre otomatik seçim

7. Seçilen dili SharedPreferences'a kaydet

OLUŞTURULACAK DOSYALAR:
- assets/translations/*.json (5 dosya)
- lib/presentation/widgets/language_selector.dart

DEĞİŞECEK DOSYALAR:
- pubspec.yaml (assets ekle)
- lib/main.dart
- lib/presentation/screens/**/*.dart (tüm hardcoded text'leri değiştir)
- lib/presentation/screens/profile/profile_screen.dart

TEST:
- Dil değiştirme çalışmalı
- Tüm ekranlar doğru dilde
- System language detection çalışmalı
- Uygulama restart sonrası dil korunmalı
```

---

### ✅ **TASK 2.4: Offline Mode & Caching**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 10-12 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Offline'da history ve cached solutions görüntüleme sistemi.

ADIMLAR:
1. Paketleri ekle:
   - hive: ^2.2.3
   - hive_flutter: ^1.1.0
   - connectivity_plus: ^6.0.5 (zaten var)

2. Hive initialize et ve box'lar oluştur:
   - questions_box (çözülmüş sorular)
   - notes_box (notlar)
   - user_box (user data)

3. lib/services/cache/cache_service.dart oluştur:
   - cacheQuestion()
   - getCachedQuestions()
   - cacheNote()
   - clearCache()

4. lib/services/network/network_service.dart oluştur:
   - isOnline()
   - Stream<bool> connectivityStream

5. Her data fetch'te:
   - Online: Firebase'den çek, cache'e kaydet
   - Offline: Cache'den oku

6. UI'da offline indicator göster

7. Sync mechanism (online olunca sync et)

OLUŞTURULACAK DOSYALAR:
- lib/services/cache/cache_service.dart
- lib/services/network/network_service.dart
- lib/data/models/*_adapter.dart (Hive adapters)

DEĞİŞECEK DOSYALAR:
- pubspec.yaml
- lib/main.dart
- lib/services/database/realtime_database_service.dart
- lib/presentation/screens/history/history_screen.dart
- lib/presentation/screens/notes/notes_screen.dart

TEST:
- İnternet kes, history görüntülenebilmeli
- Cached solutions açılmalı
- Offline indicator görünmeli
- Online olunca sync çalışmalı
```

---

## 📋 **PHASE 3: GAMİFİCATION (2-3 Hafta)**

### ✅ **TASK 3.1: XP & Leveling System**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 8-10 saat
**Bağımlılık:** TASK 1.2 (Analytics)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: XP sistemi, level ve title sistemi oluştur.

ADIMLAR:
1. Firestore'da user document'e ekle:
   - xp: int
   - level: int
   - title: string
   - totalQuestionsAnswered: int

2. lib/data/models/user_progress_model.dart oluştur

3. lib/services/gamification/xp_service.dart oluştur:
   - addXP(userId, amount, reason)
   - calculateLevel(xp)
   - getTitle(level)
   - getXPToNextLevel(currentLevel)

4. XP kazanma yolları:
   - Soru çözme: +10 XP
   - Günlük streak: +5 XP
   - Profile completion: +30 XP
   - İlk soru: +20 XP
   - Arkadaş referansı: +50 XP
   - Daily challenge: +20 XP

5. Level sistemini tasarla:
   Level 1-5: Beginner (0-500 XP)
   Level 6-10: Student (500-2000 XP)
   Level 11-20: Scholar (2000-5000 XP)
   Level 21-30: Expert (5000-10000 XP)
   Level 31+: Professor (10000+ XP)

6. Profile screen'de XP bar göster:
   - Current level
   - Progress bar
   - XP to next level
   - Title badge

7. XP kazanıldığında animation göster

OLUŞTURULACAK DOSYALAR:
- lib/data/models/user_progress_model.dart
- lib/services/gamification/xp_service.dart
- lib/presentation/widgets/xp_bar_widget.dart
- lib/presentation/widgets/xp_earned_animation.dart

DEĞİŞECEK DOSYALAR:
- lib/data/models/user_model.dart
- lib/services/user/user_service.dart
- lib/presentation/screens/profile/profile_screen.dart
- lib/services/ai/ai_service.dart (XP track için)

TEST:
- Soru çözünce XP artmalı
- Level up olunca animation
- Profile'da doğru level
- Title'lar doğru gösterilmeli
```

---

### ✅ **TASK 3.2: Achievement System & Badges**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 10-12 saat
**Bağımlılık:** TASK 3.1 (XP System)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: 30+ achievement sistemi ve badge collection oluştur.

ADIMLAR:
1. Firestore'da achievements collection:
   - achievementId
   - name
   - description
   - icon
   - requirement
   - xpReward
   - rarity (common, rare, epic, legendary)

2. lib/data/models/achievement_model.dart oluştur

3. lib/services/gamification/achievement_service.dart oluştur:
   - checkAchievement(userId, type)
   - unlockAchievement(userId, achievementId)
   - getUserAchievements(userId)

4. 30+ Achievement tanımla:
   
   BEGINNER (Common):
   - "First Steps" - İlk soruyu çöz
   - "Quick Learner" - 10 soru çöz
   - "Dedicated" - 3 gün streak
   - "Social Butterfly" - 1 arkadaş davet et

   INTERMEDIATE (Rare):
   - "Night Owl" - Gece 12'den sonra çöz
   - "Early Bird" - Sabah 6'dan önce çöz
   - "Week Warrior" - 7 gün streak
   - "Math Genius" - 50 matematik sorusu
   - "Speed Demon" - 1 dakikada çöz

   ADVANCED (Epic):
   - "Monthly Master" - 30 gün streak
   - "Century Club" - 100 soru
   - "Subject Expert" - Bir konuda 100 soru
   - "Perfectionist" - 20 soru üst üste
   - "Social Star" - 10 arkadaş davet

   LEGENDARY:
   - "Elite Professor" - Level 50'ye ulaş
   - "Millennium" - 1000 soru çöz
   - "Legendary Streak" - 100 gün streak
   - "Master of All" - Tüm konularda 50+ soru

5. Achievement unlock popup:
   - Confetti animation
   - Badge display
   - XP reward
   - Share button

6. Profile'da badge collection ekranı

OLUŞTURULACAK DOSYALAR:
- lib/data/models/achievement_model.dart
- lib/services/gamification/achievement_service.dart
- lib/presentation/screens/achievements/achievements_screen.dart
- lib/presentation/widgets/achievement_unlock_dialog.dart

DEĞİŞECEK DOSYALAR:
- lib/services/ai/ai_service.dart (achievement check)
- lib/presentation/screens/profile/profile_screen.dart

TEST:
- Achievement unlock çalışmalı
- Popup gösterilmeli
- Badge collection görünmeli
- Progress tracking doğru
```

---

### ✅ **TASK 3.3: Daily Challenges**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 8-10 saat
**Bağımlılık:** TASK 3.1 (XP System)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Her gün farklı challenge sistemi oluştur.

ADIMLAR:
1. Firebase Remote Config'e daily challenges ekle

2. lib/data/models/daily_challenge_model.dart oluştur:
   - id
   - date
   - type (subject-based, speed, quantity, streak)
   - requirement
   - reward (XP, free questions)
   - completed: bool

3. lib/services/gamification/challenge_service.dart oluştur:
   - getDailyChallenge()
   - checkChallengeProgress(userId)
   - completeChallenge(userId)
   - claimReward(userId)

4. Challenge tipleri tasarla:
   Monday: "Math Monday" - 5 matematik sorusu
   Tuesday: "Theory Tuesday" - 3 teori sorusu
   Wednesday: "Wild Card" - 5 karışık soru
   Thursday: "Throwback Thursday" - 3 eski soru review
   Friday: "Fast Friday" - 3 soru 10 dakikada
   Saturday: "Social Saturday" - 2 çözüm paylaş
   Sunday: "Summary Sunday" - 1 not oluştur

5. Dashboard'a Daily Challenge card ekle:
   - Challenge açıklaması
   - Progress bar
   - Reward bilgisi
   - Kalan süre (countdown)

6. Challenge tamamlanınca:
   - Completion animation
   - Reward claim
   - Next challenge preview

OLUŞTURULACAK DOSYALAR:
- lib/data/models/daily_challenge_model.dart
- lib/services/gamification/challenge_service.dart
- lib/presentation/widgets/daily_challenge_card.dart
- lib/presentation/screens/challenges/challenges_screen.dart

DEĞİŞECEK DOSYALAR:
- lib/presentation/screens/dashboard/dashboard_screen.dart
- lib/services/ai/ai_service.dart (challenge tracking)

TEST:
- Her gün yeni challenge
- Progress tracking çalışmalı
- Reward claim edilebilmeli
- Countdown doğru çalışmalı
```

---

### ✅ **TASK 3.4: Leaderboard System**
**Öncelik:** 🟠 ORTA
**Süre:** 10-12 saat
**Bağımlılık:** TASK 3.1 (XP System)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Global, country ve friends leaderboard sistemi.

ADIMLAR:
1. Firestore'da leaderboard collection:
   - userId
   - username
   - xp
   - level
   - questionsAnswered
   - country
   - profilePicture
   - rank

2. lib/data/models/leaderboard_entry_model.dart oluştur

3. lib/services/gamification/leaderboard_service.dart oluştur:
   - getGlobalLeaderboard(limit: 100)
   - getCountryLeaderboard(country, limit: 50)
   - getFriendsLeaderboard(userId)
   - getUserRank(userId)

4. lib/presentation/screens/leaderboard/leaderboard_screen.dart:
   - Tab'lar: Global, Country, Friends
   - Top 3 podium animasyonu
   - Scrollable list (4-100)
   - User'ın kendi rank'i alt tarafta sabit

5. Privacy settings:
   - "Show on leaderboard" toggle
   - "Anonymous username" toggle
   - SharedPreferences'a kaydet

6. Real-time updates (Stream)

7. Filters:
   - Weekly
   - Monthly
   - All-time

OLUŞTURULACAK DOSYALAR:
- lib/data/models/leaderboard_entry_model.dart
- lib/services/gamification/leaderboard_service.dart
- lib/presentation/screens/leaderboard/leaderboard_screen.dart
- lib/presentation/widgets/leaderboard_podium.dart

DEĞİŞECEK DOSYALAR:
- lib/presentation/screens/profile/profile_screen.dart (privacy settings)
- lib/presentation/widgets/app_drawer.dart (leaderboard link)

TEST:
- Leaderboard görüntülenmeli
- Rank hesaplaması doğru
- Tab switching çalışmalı
- User'ın kendi rank'i görünmeli
- Privacy settings çalışmalı
```

---

## 📋 **PHASE 4: SOCIAL FEATURES (2-3 Hafta)**

### ✅ **TASK 4.1: Friend System**
**Öncelik:** 🟠 ORTA
**Süre:** 10-12 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Arkadaş ekleme, arkadaş listesi ve aktivite görme sistemi.

ADIMLAR:
1. Firestore'da friends collection:
   - userId
   - friendId
   - status (pending, accepted, blocked)
   - addedAt

2. lib/services/social/friend_service.dart oluştur:
   - sendFriendRequest(userId, friendId)
   - acceptFriendRequest(requestId)
   - rejectFriendRequest(requestId)
   - removeFriend(userId, friendId)
   - getFriends(userId)
   - getFriendRequests(userId)
   - searchUsers(query)

3. Arkadaş ekleme yöntemleri:
   - Username ile ara
   - QR code ile (qr_flutter paketi)
   - Contacts'tan (phone number match)

4. lib/presentation/screens/friends/friends_screen.dart:
   - Tab'lar: Friends, Requests, Add
   - Friend list (avatar, name, level, last activity)
   - Pending requests list
   - Search bar

5. Friend activity feed:
   - Son çözülen sorular
   - Kazanılan achievement'lar
   - Level up'lar
   - Privacy kontrollü

6. Compare stats ile karşılaştırma

OLUŞTURULACAK DOSYALAR:
- lib/services/social/friend_service.dart
- lib/data/models/friend_model.dart
- lib/presentation/screens/friends/friends_screen.dart
- lib/presentation/screens/friends/add_friend_screen.dart
- lib/presentation/screens/friends/friend_profile_screen.dart

DEĞİŞECEK DOSYALAR:
- pubspec.yaml (qr_flutter ekle)
- lib/presentation/widgets/app_drawer.dart

TEST:
- Arkadaş ekleme çalışmalı
- Request gönderme/kabul etme
- Friend list görüntülenmeli
- QR code scanning çalışmalı
```

---

### ✅ **TASK 4.2: Solution Sharing**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 8-10 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Çözümleri paylaşma ve sosyal medya entegrasyonu.

ADIMLAR:
1. Paketleri ekle:
   - share_plus: ^10.0.3
   - screenshot: ^3.0.0
   - path_provider: ^2.1.5 (zaten var)

2. lib/services/social/share_service.dart oluştur:
   - shareText(text)
   - shareImage(imagePath)
   - shareToWhatsApp(text)
   - shareToInstagram(imagePath)
   - shareToTwitter(text)
   - generateShareableImage(solution)

3. Solution card'a share button ekle:
   - Share sheet açılsın
   - Seçenekler:
     * Copy link
     * WhatsApp
     * Instagram Story
     * Twitter/X
     * Facebook
     * Save as image
     * PDF export

4. Shareable image template oluştur:
   - SolveLens branding
   - Solution content (LaTeX rendered)
   - QR code (app download)
   - Watermark

5. Deep linking setup (paylaşılan link'e tıklanınca app açılsın):
   - uni_links paketi ekle
   - Deep link handler

OLUŞTURULACAK DOSYALAR:
- lib/services/social/share_service.dart
- lib/core/routing/deep_link_handler.dart
- lib/presentation/widgets/shareable_solution_card.dart

DEĞİŞECEK DOSYALAR:
- pubspec.yaml
- lib/presentation/screens/solution/ai_solution_screen.dart
- lib/presentation/screens/history/history_screen.dart
- android/app/src/main/AndroidManifest.xml (deep links)
- ios/Runner/Info.plist (deep links)

TEST:
- Share sheet açılmalı
- WhatsApp'a paylaşım çalışmalı
- Screenshot generation doğru
- Deep link çalışmalı
```

---

### ✅ **TASK 4.3: Referral System**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 8-10 saat
**Bağımlılık:** TASK 4.2 (Sharing), TASK 3.1 (XP)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Viral referral programı - arkadaş davet et, ödül kazan.

ADIMLAR:
1. Firestore'da referrals collection:
   - referrerId
   - referredUserId
   - referralCode
   - status (pending, completed)
   - createdAt
   - completedAt

2. lib/services/social/referral_service.dart oluştur:
   - generateReferralCode(userId)
   - getReferralLink(code)
   - applyReferralCode(newUserId, code)
   - getReferralStats(userId)
   - getReferralRewards(userId)

3. Reward sistemi:
   Referrer (davet eden):
   - +50 XP
   - +20 free questions
   - +1 hafta Pro trial (10 referral'dan sonra)
   
   Referred (davet edilen):
   - +50 başlangıç XP
   - +20 bonus questions
   - Özel "Referred by Friend" badge

4. Milestone rewards:
   - 5 referral: +100 XP, special badge
   - 10 referral: +1 month Pro
   - 25 referral: +3 month Pro
   - 50 referral: Lifetime Elite

5. lib/presentation/screens/referral/referral_screen.dart:
   - Referral code display
   - Share button (WhatsApp, social media)
   - Referral stats (pending, completed)
   - Reward progress
   - Leaderboard (top referrers)

6. Sign-up sırasında referral code input

OLUŞTURULACAK DOSYALAR:
- lib/services/social/referral_service.dart
- lib/data/models/referral_model.dart
- lib/presentation/screens/referral/referral_screen.dart

DEĞİŞECEK DOSYALAR:
- lib/services/auth/auth_service.dart (referral tracking)
- lib/presentation/screens/auth/register_screen.dart (referral input)
- lib/presentation/screens/profile/profile_screen.dart (referral link)

TEST:
- Referral code oluşturulmalı
- Link paylaşımı çalışmalı
- Yeni kullanıcı code girebilmeli
- Reward otomatik verilmeli
- Stats doğru güncellenm eli
```

---

### ✅ **TASK 4.4: Study Groups (MVP)**
**Öncelik:** 🟠 ORTA
**Süre:** 12-15 saat
**Bağımlılık:** TASK 4.1 (Friends)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Grup çalışma özelliği - arkadaşlarla grup oluştur ve birlikte çalış.

ADIMLAR:
1. Firestore'da study_groups collection:
   - groupId
   - name
   - description
   - creatorId
   - members[] (max 10)
   - createdAt
   - totalQuestionsSolved
   - groupXP

2. lib/services/social/study_group_service.dart oluştur:
   - createGroup(name, description)
   - inviteMembers(groupId, userIds[])
   - joinGroup(userId, groupId)
   - leaveGroup(userId, groupId)
   - getGroupDetails(groupId)
   - getGroupActivity(groupId)

3. Group features:
   - Group chat (basit text-based, Firestore)
   - Shared question bank
   - Group challenges
   - Group leaderboard
   - Group achievements

4. lib/presentation/screens/groups/groups_screen.dart:
   - My groups list
   - Create group button
   - Group invitations

5. lib/presentation/screens/groups/group_detail_screen.dart:
   - Group info
   - Members list
   - Group chat
   - Group activity feed
   - Group stats

OLUŞTURULACAK DOSYALAR:
- lib/services/social/study_group_service.dart
- lib/data/models/study_group_model.dart
- lib/presentation/screens/groups/groups_screen.dart
- lib/presentation/screens/groups/group_detail_screen.dart
- lib/presentation/screens/groups/create_group_screen.dart

DEĞİŞECEK DOSYALAR:
- lib/presentation/widgets/app_drawer.dart

TEST:
- Grup oluşturulmalı
- Davet gönderilmeli
- Chat çalışmalı
- Activity feed görünmeli
```

---

## 📋 **PHASE 5: ADVANCED FEATURES (3-4 Hafta)**

### ✅ **TASK 5.1: Smart Notes Enhancement**
**Öncelik:** 🟠 ORTA
**Süre:** 10-12 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Mevcut notes sistemini geliştir - organize, search, export, AI summary.

ADIMLAR:
1. Mevcut NotesScreen'i geliştir

2. Yeni özellikler:
   a) Tag sistemi:
      - Her nota tag eklenebilsin
      - Tag'lere göre filtreleme
      - Popüler tag'ler

   b) Search functionality:
      - Title, content search
      - Tag search
      - Subject filter

   c) Organization:
      - Folders (subject-based)
      - Favorites/starred
      - Sort by: date, title, subject

   d) Export options:
      - PDF export
      - Markdown export
      - Share to Notion (webhook)
      - Share to Evernote

   e) AI-generated summaries:
      - Gemini ile özetleme
      - Key points extraction
      - "Study this note" button (spaced repetition)

3. Paketler:
   - pdf: ^3.11.1
   - printing: ^5.13.3

4. Spaced repetition reminders:
   - 1 gün sonra review reminder
   - 3 gün sonra
   - 1 hafta sonra
   - 1 ay sonra

OLUŞTURULACAK DOSYALAR:
- lib/services/notes/enhanced_notes_service.dart
- lib/presentation/widgets/notes/note_tag_widget.dart
- lib/presentation/widgets/notes/note_search_widget.dart
- lib/presentation/screens/notes/note_detail_screen.dart

DEĞİŞECEK DOSYALAR:
- lib/presentation/screens/notes/notes_screen.dart
- lib/services/notes/notes_service.dart
- lib/data/models/saved_note_model.dart

TEST:
- Tag ekleme/filtreleme
- Search çalışmalı
- Export PDF çalışmalı
- AI summary oluşturulmalı
```

---

### ✅ **TASK 5.2: Study Planner**
**Öncelik:** 🟠 ORTA
**Süre:** 12-15 saat
**Bağımlılık:** TASK 2.2 (Notifications)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: AI-powered study planner - sınav takibi, plan oluşturma, reminder.

ADIMLAR:
1. Firestore'da study_plans collection:
   - userId
   - examName
   - examDate
   - subjects[]
   - dailyGoal (hours)
   - studyDays[]
   - progress

2. lib/services/study/study_planner_service.dart oluştur:
   - createStudyPlan(exam, date, subjects)
   - generateAISchedule(availableDays, totalHours)
   - markDayComplete(planId, date)
   - getStudyReminders(userId)
   - getProgressStats(planId)

3. AI schedule generation:
   - Gemini'ye plan oluşturma
   - Spaced repetition based
   - Weak subjects'e daha fazla zaman
   - Break time'lar dahil

4. lib/presentation/screens/study/study_planner_screen.dart:
   - Calendar view
   - Exam countdown
   - Daily tasks
   - Progress tracking
   - Subject breakdown

5. Features:
   - Exam date tracking
   - Daily study reminders
   - Progress visualization
   - Subject-wise breakdown
   - Weekly review suggestions

6. Integration:
   - Calendar sync (device_calendar paketi)
   - Push notifications for reminders

OLUŞTURULACAK DOSYALAR:
- lib/services/study/study_planner_service.dart
- lib/data/models/study_plan_model.dart
- lib/presentation/screens/study/study_planner_screen.dart
- lib/presentation/screens/study/create_plan_screen.dart

DEĞİŞECEK DOSYALAR:
- pubspec.yaml (calendar packages)
- lib/presentation/widgets/app_drawer.dart

TEST:
- Plan oluşturulmalı
- AI schedule generation
- Reminder notifications
- Progress tracking doğru
```

---

### ✅ **TASK 5.3: Practice Mode**
**Öncelik:** 🟠 ORTA
**Süre:** 8-10 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Quota kullanmadan eski soruları tekrar çözme ve practice test modu.

ADIMLAR:
1. lib/services/practice/practice_service.dart oluştur:
   - getRandomPracticeQuestions(count, subject)
   - getPracticeTest(subject, difficulty)
   - savePracticeAttempt(userId, questionId, correct)
   - getPracticeStats(userId)

2. Practice modes:
   a) Review Mode:
      - Daha önce çözülmüş soruları tekrar göster
      - Quota harcamaz
      - Progress tracking

   b) Practice Test:
      - 10 random eski soru
      - Timed (opsiyonel)
      - Score calculation
      - Detailed feedback

   c) Subject Practice:
      - Specific subject selection
      - Difficulty-based (easy, medium, hard)
      - Adaptive difficulty

   d) Weak Area Practice:
      - AI identifies weak subjects
      - Targeted practice

3. lib/presentation/screens/practice/practice_screen.dart:
   - Mode selection
   - Subject selection
   - Difficulty selection
   - Start practice button

4. Practice test UI:
   - Timer
   - Question navigation
   - Mark for review
   - Submit test
   - Results screen with breakdown

OLUŞTURULACAK DOSYALAR:
- lib/services/practice/practice_service.dart
- lib/data/models/practice_attempt_model.dart
- lib/presentation/screens/practice/practice_screen.dart
- lib/presentation/screens/practice/practice_test_screen.dart
- lib/presentation/screens/practice/practice_results_screen.dart

DEĞİŞECEK DOSYALAR:
- lib/presentation/widgets/app_drawer.dart

TEST:
- Random questions çekilmeli
- Timer çalışmalı
- Score hesaplanmalı
- Quota kullanmamalı
```

---

### ✅ **TASK 5.4: Parent Dashboard (Web - Optional)**
**Öncelik:** 🟢 DÜŞÜK
**Süre:** 20-25 saat
**Bağımlılık:** Tüm core features

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Web-based parent portal - çocuğun ilerlemesini takip etme.

Not: Bu Flutter Web projesi olacak (ayrı bir proje)

ADIMLAR:
1. Flutter web projesi oluştur:
   flutter create parent_dashboard_web

2. Firebase Authentication ile parent login

3. lib/services/parent/parent_service.dart:
   - linkChildAccount(parentId, childUserId)
   - getChildProgress(childUserId)
   - getChildActivity(childUserId)
   - setStudyGoals(childUserId, goals)
   - setScreenTimeLimits(childUserId, limits)

4. Dashboard features:
   - Child progress overview
   - Subject-wise performance
   - Study time tracking
   - Streak monitoring
   - Weak subjects identification
   - Question history
   - Goal setting
   - Screen time limits

5. Screens:
   - Login/Register
   - Dashboard (overview)
   - Progress (detailed stats)
   - Settings (goals, limits)
   - Reports (weekly/monthly)

6. Charts & Visualizations:
   - fl_chart paketi
   - Subject performance chart
   - Weekly activity chart
   - Progress over time

OLUŞTURULACAK DOSYALAR:
- parent_dashboard_web/ (yeni proje)
- Tüm web-specific screens ve services

DEĞİŞECEK DOSYALAR:
- Firebase Console (web app ekle)
- Firestore rules (parent access)

TEST:
- Parent login çalışmalı
- Child linking çalışmalı
- Stats doğru gösterilmeli
- Goals setting çalışmalı
```

---

## 📋 **PHASE 6: MONETIZATION & OPTIMIZATION (2 Hafta)**

### ✅ **TASK 6.1: Dynamic Pricing & A/B Testing**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 6-8 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Remote Config ile dinamik fiyatlandırma ve A/B testing.

ADIMLAR:
1. Firebase Remote Config'te parametreler ekle:
   - basic_monthly_price
   - pro_monthly_price
   - elite_monthly_price
   - free_tier_daily_limit
   - discount_percentage
   - show_annual_plan
   - paywall_variant (A, B, C)

2. lib/services/monetization/pricing_service.dart oluştur:
   - getPricing(country)
   - getActiveDiscount()
   - getPaywallVariant()
   - logPricingView()
   - logPurchaseAttempt()

3. Country-based pricing:
   - USD: $4.99, $9.99, $19.99
   - TRY: ₺149, ₺299, ₺599
   - EUR: €4.99, €9.99, €19.99
   - Automatic currency detection

4. A/B test variants:
   Variant A: Standard paywall
   Variant B: With trial badge
   Variant C: With limited-time offer

5. Discount campaigns:
   - New user discount (20%)
   - Seasonal discount
   - Student discount (with .edu email)
   - Referral discount

6. Analytics tracking:
   - Paywall views
   - Purchase attempts
   - Conversion rate by variant
   - Revenue by variant

OLUŞTURULACAK DOSYALAR:
- lib/services/monetization/pricing_service.dart
- lib/data/models/pricing_model.dart

DEĞİŞECEK DOSYALAR:
- lib/services/payment/payment_service.dart
- lib/presentation/screens/subscription/subscription_screen.dart
- lib/services/config/remote_config_service.dart

TEST:
- Remote Config'ten fiyat çekilmeli
- Country-based pricing doğru
- A/B variant assignment çalışmalı
- Analytics track edilmeli
```

---

### ✅ **TASK 6.2: Alternative Monetization - Rewarded Ads**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 6-8 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Free kullanıcılar için reklam izleyerek bonus soru kazanma.

ADIMLAR:
1. Google Mobile Ads zaten var, rewarded ad entegrasyonu ekle

2. lib/services/ads/rewarded_ad_service.dart oluştur:
   - loadRewardedAd()
   - showRewardedAd()
   - onAdRewarded(callback)
   - isAdAvailable()

3. Reward sistemi:
   - 1 rewarded ad = +3 bonus questions
   - Max 5 ad/day (15 bonus questions)
   - 30 saniye video
   - Skip after 5 seconds (no reward)

4. UI implementation:
   - Dashboard'da "Watch Ad for 3 Questions" card
   - Quota bitince "Watch ad to continue" option
   - Ad availability indicator

5. Analytics tracking:
   - Ad impressions
   - Ad completions
   - Reward claim rate
   - Revenue from ads

6. Ad placement strategy:
   - After 2 solutions (interstitial)
   - Quota bitince (rewarded)
   - Dashboard'da opt-in card

OLUŞTURULACAK DOSYALAR:
- lib/services/ads/rewarded_ad_service.dart
- lib/presentation/widgets/watch_ad_card.dart

DEĞİŞECEK DOSYALAR:
- lib/services/quota/quota_service.dart
- lib/presentation/screens/dashboard/dashboard_screen.dart

TEST:
- Ad loading çalışmalı
- Reward verilmeli
- Quota artmalı
- Daily limit uygulanmalı
```

---

### ✅ **TASK 6.3: Virtual Currency (Gems) System**
**Öncelik:** 🟠 ORTA
**Süre:** 10-12 saat
**Bağımlılık:** TASK 3.1 (XP)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Virtual currency (Gems) sistemi - kazan ve harca.

ADIMLAR:
1. Firestore'da user document'e ekle:
   - gems: int

2. lib/services/monetization/gem_service.dart oluştur:
   - addGems(userId, amount, reason)
   - spendGems(userId, amount, item)
   - getGemsBalance(userId)
   - getGemsHistory(userId)

3. Gem kazanma yolları:
   - Daily login: +5 gems
   - Soru çözme: +2 gems
   - Achievement unlock: +10 gems
   - Daily challenge: +15 gems
   - Level up: +20 gems
   - Arkadaş referansı: +100 gems
   - Watch ad: +10 gems
   - IAP: Gem packages

4. Gem harcama yerleri:
   - 50 gems = +10 bonus questions
   - 100 gems = Skip 1 ad
   - 200 gems = Profile theme unlock
   - 300 gems = Special badge
   - 500 gems = Custom AI personality
   - 1000 gems = 1 week Pro trial

5. Gem store:
   - lib/presentation/screens/store/gem_store_screen.dart
   - Items catalog
   - Purchase with gems
   - Purchase history

6. IAP gem packages:
   - 100 gems: $0.99
   - 550 gems: $4.99 (10% bonus)
   - 1200 gems: $9.99 (20% bonus)
   - 3000 gems: $19.99 (50% bonus)

OLUŞTURULACAK DOSYALAR:
- lib/services/monetization/gem_service.dart
- lib/data/models/gem_transaction_model.dart
- lib/presentation/screens/store/gem_store_screen.dart
- lib/presentation/widgets/gem_balance_widget.dart

DEĞİŞECEK DOSYALAR:
- lib/data/models/user_model.dart
- lib/presentation/screens/profile/profile_screen.dart
- lib/services/payment/payment_service.dart (gem IAP)

TEST:
- Gem kazanma çalışmalı
- Gem harcama çalışmalı
- Balance update doğru
- IAP gem packages çalışmalı
```

---

### ✅ **TASK 6.4: Improved Freemium Model**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 8-10 saat
**Bağımlılık:** TASK 6.1, 6.2, 6.3

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Free tier'ı iyileştir ve upgrade path'i optimize et.

ADIMLAR:
1. Free tier limitlerini güncelle:
   - 3 -> 5 questions/day (daha generous)
   - Rewarded ad ile +3 (max 5 ad/day)
   - Daily login bonus: +2 questions
   - Total max: 5 + 15 + 2 = 22 questions/day (generous)

2. Paywall timing optimization:
   - İlk 3 soru: Paywall yok
   - 4. soru sonrası: Soft paywall (skippable)
   - 6. soru sonrası: Hard paywall veya rewarded ad option
   - Quota bitince: Upgrade or watch ad

3. Feature limitations:
   FREE:
   - Basic explanations (short)
   - No voice features
   - Ads after every 2 solutions
   - Max 10 saved notes
   - No offline mode
   - No practice mode

   BASIC ($4.99/mo):
   - 50 questions/day
   - Detailed explanations
   - No ads
   - 50 saved notes
   - Voice input (limited)
   - Priority: normal

   PRO ($9.99/mo):
   - 200 questions/day
   - Step-by-step solutions
   - Full voice features
   - Unlimited notes
   - Offline mode
   - Practice mode
   - Study planner
   - Priority support

   ELITE ($19.99/mo):
   - Unlimited questions
   - Video solutions (future)
   - Custom AI personality
   - Early access
   - Group features
   - Advanced analytics
   - Priority: highest

4. Upgrade prompts:
   - Feature discovery prompts
   - "See what you're missing" cards
   - Limited-time offer banners
   - Social proof ("Join 10K+ Pro users")

5. Retention tactics:
   - Free trial (7 days) for first-time subscribers
   - Cancel feedback form
   - Win-back campaigns (for churned users)

OLUŞTURULACAK DOSYALAR:
- lib/services/monetization/paywall_service.dart
- lib/presentation/widgets/soft_paywall_widget.dart
- lib/presentation/widgets/feature_locked_widget.dart

DEĞİŞECEK DOSYALAR:
- lib/core/constants/subscription_constants.dart
- lib/services/quota/quota_service.dart
- lib/presentation/screens/subscription/subscription_screen.dart

TEST:
- Free tier limits doğru
- Paywall timing optimize
- Feature locks çalışmalı
- Upgrade flow smooth
```

---

## 📋 **PHASE 7: PERFORMANCE & POLISH (Sürekli)**

### ✅ **TASK 7.1: Image Optimization & Caching**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 6-8 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Image loading, caching ve compression optimization.

ADIMLAR:
1. Paketleri ekle:
   - cached_network_image: ^3.4.1
   - flutter_image_compress: ^2.3.0

2. lib/services/image/image_optimization_service.dart oluştur:
   - compressImage(File image, quality)
   - cacheImage(String url)
   - clearImageCache()

3. Image compression:
   - Kameradan alınan görüntüler max 1MB
   - Quality: 85%
   - WebP format'a çevir (possible)
   - Progressive loading

4. Network image caching:
   - CachedNetworkImage widget kullan
   - Memory cache: 100 MB
   - Disk cache: 200 MB
   - Cache duration: 7 days

5. Lazy loading:
   - History screen'de lazy load
   - Pagination (20 items per page)
   - Infinite scroll

6. Placeholder & Error handling:
   - Shimmer loading effect
   - Error placeholder
   - Retry option

OLUŞTURULACAK DOSYALAR:
- lib/services/image/image_optimization_service.dart
- lib/presentation/widgets/cached_image_widget.dart

DEĞİŞECEK DOSYALAR:
- lib/presentation/screens/camera/camera_screen.dart
- lib/presentation/screens/history/history_screen.dart
- lib/presentation/screens/solution/ai_solution_screen.dart

TEST:
- Image compression çalışmalı
- Cache hit rate yüksek
- Memory usage düşük
- Loading smooth
```

---

### ✅ **TASK 7.2: Database Query Optimization**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 4-6 saat
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Firestore queries optimize et, indexing ve pagination ekle.

ADIMLAR:
1. Firestore composite index'ler oluştur:
   - firestore.indexes.json dosyası
   - userId + createdAt (descending)
   - userId + subject + createdAt
   - userId + status + createdAt

2. Query optimizations:
   - Limit queries (max 50)
   - Use where clauses efficiently
   - Pagination (startAfter, limit)
   - Cache hasil queries

3. lib/services/database/optimized_query_service.dart:
   - getPaginatedHistory(userId, lastDoc, limit)
   - getFilteredQuestions(userId, subject, limit)
   - getCachedQueries()

4. Lazy loading implementation:
   - History screen: Load 20, fetch more on scroll
   - Notes screen: Load 30, pagination
   - Leaderboard: Load 50, infinite scroll

5. Local caching strategy:
   - Cache frequently accessed data
   - Invalidate cache on update
   - Background sync

OLUŞTURULACAK DOSYALAR:
- firestore.indexes.json
- lib/services/database/optimized_query_service.dart

DEĞİŞECEK DOSYALAR:
- lib/services/database/realtime_database_service.dart
- lib/presentation/screens/history/history_screen.dart

TEST:
- Query speed improved
- Pagination çalışmalı
- No over-fetching
- Firebase costs düşük
```

---

### ✅ **TASK 7.3: App Performance Monitoring**
**Öncelik:** 🟠 ORTA
**Süre:** 4-6 saat
**Bağımlılık:** TASK 1.2 (Analytics)

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: Performance metrics tracking ve bottleneck detection.

ADIMLAR:
1. Firebase Performance Monitoring kullan (already added in TASK 1.2)

2. Custom traces ekle:
   - AI analysis duration
   - Image upload duration
   - Screen load time
   - API response time

3. lib/services/performance/performance_service.dart:
   - startTrace(name)
   - stopTrace(name)
   - logMetric(name, value)
   - getPerformanceReport()

4. Key metrics track et:
   - App startup time (target: <2s)
   - Screen render time (target: <500ms)
   - API response time (target: <3s)
   - Memory usage
   - Battery usage

5. Performance alerts:
   - Slow network detection
   - Memory leak detection
   - Battery drain warning

6. Optimization recommendations:
   - Identify slow screens
   - Suggest optimizations
   - A/B test performance changes

OLUŞTURULACAK DOSYALAR:
- lib/services/performance/performance_service.dart

DEĞİŞECEK DOSYALAR:
- lib/services/ai/ai_service.dart (trace ekle)
- lib/services/database/realtime_database_service.dart
- lib/presentation/screens/**/*.dart (screen load traces)

TEST:
- Traces Firebase'de görünmeli
- Metrics track edilmeli
- Slow operations tespit edilmeli
```

---

### ✅ **TASK 7.4: App Store Optimization (ASO)**
**Öncelik:** 🟡 YÜKSEK
**Süre:** 6-8 saat (mostly research & content)
**Bağımlılık:** Yok

**Agent'a Vereceğiniz Talimat:**
```
GÖREV: App Store ve Google Play Store için metadata optimization.

ADIMLAR:
1. Keyword research:
   - Use tools: App Annie, Sensor Tower
   - Primary keywords:
     * homework helper
     * AI tutor
     * math solver
     * study app
     * homework AI
   - Secondary keywords:
     * photo math
     * step by step math
     * AI professor
     * learn with AI

2. App Store metadata oluştur:
   
   TITLE (30 chars):
   - "SolveLens: AI Homework Helper"
   
   SUBTITLE (30 chars):
   - "Photo Math & AI Tutor"
   
   DESCRIPTION (4000 chars):
   - Hook (first 170 chars - görünür kısım)
   - Features list
   - Benefits
   - Social proof
   - Call to action
   - Keywords (natural placement)

3. Screenshots oluştur (5-10):
   - Hero shot (scanning feature)
   - AI solution example
   - Chat interface
   - Gamification (badges, XP)
   - Social features
   - Pricing comparison
   - Captions ekle (clear value props)

4. App Preview Video (30 seconds):
   - Script yaz
   - Storyboard
   - Capture screen recordings
   - Add voiceover
   - Add captions

5. Store listing variations (A/B test):
   - Icon variants (3)
   - Screenshot orders (2)
   - Description variants (2)

6. Localization:
   - Turkish, Spanish, French, German
   - Localized screenshots
   - Translated descriptions

OLUŞTURULACAK DOSYALAR:
- /store_assets/screenshots/ (20+ images)
- /store_assets/descriptions/ (text files)
- /store_assets/keywords.txt
- /store_assets/video_script.txt

TEST:
- Keyword rank tracking (SensorTower)
- Conversion rate tracking
- Impression tracking
```

---

## 📋 **BONUS TASKS (İsteğe Bağlı)**

### ✅ **BONUS 1: AI Voice Clone Feature (Premium)**
**Öncelik:** 🟢 DÜŞÜK
**Süre:** 15-20 saat

```
GÖREV: Premium kullanıcılar için custom AI voice personality.

- ElevenLabs API entegrasyonu
- Voice clone setup
- Custom personality selection
- Legal disclaimer ve consent
```

---

### ✅ **BONUS 2: AR Math Visualization**
**Öncelik:** 🟢 DÜŞÜK
**Süre:** 20-25 saat

```
GÖREV: AR ile 3D geometry ve physics visualization.

- ARCore/ARKit entegrasyonu
- 3D model rendering
- Interactive manipulations
- Point-and-scan feature
```

---

### ✅ **BONUS 3: Blockchain-Based Rewards**
**Öncelik:** 🟢 DÜŞÜK
**Süre:** 25-30 saat

```
GÖREV: Crypto rewards ve NFT badge system.

- Wallet entegrasyonu
- Token minting
- NFT badge collection
- Trading marketplace
```

---

## 📊 **TASK PRİORİTY SUMMARY**

### 🔴 **HALLEDİLMESİ GEREKENLER (1-2 Hafta)**
1. ✅ TASK 1.1 - Environment Variables
2. ✅ TASK 1.2 - Analytics
3. ✅ TASK 1.3 - Error Handling
4. ✅ TASK 2.1 - Onboarding
5. ✅ TASK 2.2 - Push Notifications

### 🟡 **YÜKSEK ÖNCELİK (2-4 Hafta)**
6. ✅ TASK 2.3 - Multi-Language
7. ✅ TASK 2.4 - Offline Mode
8. ✅ TASK 3.1 - XP System
9. ✅ TASK 3.2 - Achievements
10. ✅ TASK 3.3 - Daily Challenges
11. ✅ TASK 4.2 - Solution Sharing
12. ✅ TASK 4.3 - Referral System
13. ✅ TASK 6.1 - Dynamic Pricing
14. ✅ TASK 6.2 - Rewarded Ads
15. ✅ TASK 7.1 - Image Optimization

### 🟠 **ORTA ÖNCELİK (1-2 Ay)**
16. ✅ TASK 1.4 - Unit Testing
17. ✅ TASK 3.4 - Leaderboard
18. ✅ TASK 4.1 - Friend System
19. ✅ TASK 4.4 - Study Groups
20. ✅ TASK 5.1 - Smart Notes
21. ✅ TASK 5.2 - Study Planner
22. ✅ TASK 5.3 - Practice Mode
23. ✅ TASK 6.3 - Gem System
24. ✅ TASK 6.4 - Freemium Optimization
25. ✅ TASK 7.2 - DB Optimization
26. ✅ TASK 7.3 - Performance Monitoring
27. ✅ TASK 7.4 - ASO

### 🟢 **DÜŞÜK ÖNCELİK (Gelecek)**
28. ✅ TASK 5.4 - Parent Dashboard
29. ✅ BONUS 1 - Voice Clone
30. ✅ BONUS 2 - AR Features
31. ✅ BONUS 3 - Blockchain

---

## 🎯 **HER AGENT İÇİN GENEL TALİMATLAR**

Her task'ı başka bir agenta verirken şunu ekleyin:

```
GENEL KURALLAR:
1. Tüm değişiklikler mevcut kodu bozmadan yapılmalı
2. Her yeni feature için analytics tracking ekle
3. Error handling her zaman ekle
4. User-friendly error messages (TR + EN)
5. Test edilebilir kod yaz
6. Code comments ekle (önemli kısımlar için)
7. Flutter best practices takip et
8. Material Design 3 guidelines kullan
9. Existing theme'i koru (Navy & White)
10. Performance considerations her zaman göz önünde

TEST CHECKLIST:
✅ Feature çalışıyor mu?
✅ Error handling test edildi mi?
✅ Analytics track ediliyor mu?
✅ UI responsive mu?
✅ Memory leak yok mu?
✅ Loading states var mı?
✅ Empty states var mı?
✅ Error states var mı?
```

---

Her task bağımsız çalışabilir. Agent'lara task numarası ile verin:

"TASK 1.1'i yap" veya "TASK 3.2'yi implement et" gibi.

Başarılar! 🚀
